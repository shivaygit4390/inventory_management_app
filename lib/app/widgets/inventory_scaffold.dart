import 'package:flutter/material.dart';
import 'package:inventory_management_app/app/theme/app_theme.dart';

class InventoryScaffold extends StatelessWidget {
  const InventoryScaffold({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: context.inventoryTheme.pageGradient,
            ),
          ),
          const Positioned(
            top: -110,
            right: -80,
            child: _AmbientOrb(color: Color(0x247A5AF8), size: 270),
          ),
          const Positioned(
            bottom: -130,
            left: -120,
            child: _AmbientOrb(color: Color(0x1816A6A1), size: 300),
          ),
          body,
        ],
      ),
    );
  }
}

class InventoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const InventoryAppBar({
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.showBrandMark = false,
    this.height = 76,
    this.useGradientBackground = false,
    this.headerKey,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool showBrandMark;
  final double height;
  final bool useGradientBackground;
  final Key? headerKey;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color foregroundColor = useGradientBackground
        ? Colors.white
        : theme.colorScheme.onSurface;
    final Widget titleContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBrandMark) ...[
          _BrandMark(compact: height < 70),
          SizedBox(width: height < 70 ? 9 : 12),
        ],
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: useGradientBackground
                        ? Colors.white.withValues(alpha: 0.84)
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    if (useGradientBackground) {
      return DecoratedBox(
        key: headerKey,
        decoration: BoxDecoration(
          gradient: context.inventoryTheme.heroGradient,
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x2424246C),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 8)],
                  Expanded(child: titleContent),
                  ...?actions,
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: foregroundColor,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: automaticallyImplyLeading && Navigator.canPop(context)
          ? 0
          : 16,
      title: titleContent,
      actions: actions,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: useGradientBackground
              ? context.inventoryTheme.heroGradient
              : null,
          color: useGradientBackground
              ? null
              : Colors.white.withValues(alpha: 0.88),
          border: Border(
            bottom: BorderSide(
              color: useGradientBackground
                  ? Colors.white.withValues(alpha: 0.14)
                  : context.inventoryTheme.subtleBorder,
            ),
          ),
        ),
      ),
    );
  }
}

class GradientActionButton extends StatelessWidget {
  const GradientActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    super.key,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? context.inventoryTheme.accentGradient : null,
          color: enabled ? null : Theme.of(context).disabledColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled ? context.inventoryTheme.softShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 21),
                  const SizedBox(width: 9),
                  Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ResponsivePagePadding extends StatelessWidget {
  const ResponsivePagePadding({
    required this.child,
    this.maxWidth = 1240,
    this.top = 16,
    this.bottom = 32,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double horizontal = width < 600
        ? 16
        : width < 1180
        ? 24
        : 32;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom),
          child: child,
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: compact ? null : context.inventoryTheme.accentGradient,
        color: compact ? Colors.white.withValues(alpha: 0.16) : null,
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        border: compact
            ? Border.all(color: Colors.white.withValues(alpha: 0.2))
            : null,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x315254D8),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox.square(
        dimension: compact ? 36 : 42,
        child: Icon(
          Icons.inventory_2_rounded,
          color: Colors.white,
          size: compact ? 20 : 23,
        ),
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: SizedBox.square(dimension: size),
      ),
    );
  }
}
