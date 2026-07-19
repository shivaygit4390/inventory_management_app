import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_management_app/app/theme/app_theme.dart';
import 'package:inventory_management_app/core/network/api_client.dart';
import 'package:inventory_management_app/features/inventory/data/data_sources/inventory_remote_data_source.dart';
import 'package:inventory_management_app/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_products.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/pages/inventory_list_page.dart';

class InventoryApp extends StatefulWidget {
  const InventoryApp({this.inventoryBloc, super.key});

  final InventoryBloc? inventoryBloc;

  @override
  State<InventoryApp> createState() => _InventoryAppState();
}

class _InventoryAppState extends State<InventoryApp> {
  http.Client? _httpClient;
  late final InventoryBloc _inventoryBloc;

  @override
  void initState() {
    super.initState();

    final InventoryBloc? providedBloc = widget.inventoryBloc;
    if (providedBloc != null) {
      _inventoryBloc = providedBloc;
      return;
    }

    final http.Client httpClient = http.Client();
    _httpClient = httpClient;
    final ApiClient apiClient = ApiClient(client: httpClient);
    final InventoryRemoteDataSource remoteDataSource =
        InventoryRemoteDataSourceImpl(apiClient: apiClient);
    final InventoryRepository repository = InventoryRepositoryImpl(
      remoteDataSource,
    );
    _inventoryBloc = InventoryBloc(GetProducts(repository));
  }

  @override
  void dispose() {
    unawaited(_inventoryBloc.close());
    _httpClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InventoryBloc>.value(
      value: _inventoryBloc,
      child: MaterialApp(
        title: 'Inventory Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const InventoryListPage(),
      ),
    );
  }
}
