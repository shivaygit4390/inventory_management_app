import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/product_image.dart';

void main() {
  const String imageUrl = 'https://cdn.example.com/product.png';

  Widget testApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('uses NetworkImage for a valid HTTPS URL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        const ProductImage.fromUrl(imageUrl: imageUrl, width: 120, height: 100),
      ),
    );

    final Image image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect((image.image as NetworkImage).url, imageUrl);
    expect(image.loadingBuilder, isNotNull);
    expect(image.errorBuilder, isNotNull);
  });

  testWidgets('shows a loading placeholder without live networking', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testApp(const ProductImage.fromUrl(imageUrl: imageUrl)),
    );
    final Image image = tester.widget<Image>(find.byType(Image));
    final BuildContext imageContext = tester.element(find.byType(Image));
    final Widget loading = image.loadingBuilder!(
      imageContext,
      const SizedBox(key: Key('loaded-image')),
      const ImageChunkEvent(cumulativeBytesLoaded: 50, expectedTotalBytes: 100),
    );

    await tester.pumpWidget(testApp(loading));

    final CircularProgressIndicator progress = tester
        .widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
    expect(progress.value, 0.5);
    expect(find.byKey(const Key('loaded-image')), findsNothing);
  });

  testWidgets('shows a stable fallback for failed or invalid URLs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        const ProductImage.fromUrl(
          imageUrl: 'not-an-https-url',
          width: 120,
          height: 100,
        ),
      ),
    );

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);

    await tester.pumpWidget(
      testApp(const ProductImage.fromUrl(imageUrl: imageUrl)),
    );
    final Image image = tester.widget<Image>(find.byType(Image));
    final BuildContext imageContext = tester.element(find.byType(Image));
    final Widget fallback = image.errorBuilder!(
      imageContext,
      StateError('simulated network failure'),
      StackTrace.empty,
    );

    await tester.pumpWidget(testApp(fallback));
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });
}
