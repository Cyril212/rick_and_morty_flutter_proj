import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/main_data_provider.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/main_data_provider/data_request.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/main_data_provider/main_data_source.dart';
import 'package:rick_and_morty_flutter_proj/core/ui/screen/abstract_stateful_screen.dart';

abstract class AbstractDataWidget extends AbstractStatefulWidget {

  @protected
  final List<DataSource> dataSources;

  final MainDataProvider mainDataProvider;

  /// AbstractDataWidget initialization
  const AbstractDataWidget({
    Key? key,
    required this.mainDataProvider,
    required this.dataSources,
  }) : super(key: key);
}

abstract class AbstractDataWidgetState<T extends AbstractDataWidget> extends AbstractStatefulWidgetState<T> {
  @protected
  MainSource? get dataSource => _mainDataSource;

  @protected
  bool get allowDidUpdateWidget => false;

  List<DataSource> _dataSources = <DataSource>[];
  MainSource? _mainDataSource;

  /// State initialization
  @override
  void initState() {
    super.initState();

    _dataSources = widget.dataSources;

    _registerDataSources(widget.mainDataProvider);
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _unRegisterDataSources(widget.mainDataProvider);

    super.dispose();
  }

  /// Widget updated
  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (allowDidUpdateWidget && oldWidget.dataSources != widget.dataSources) {
      updateDataSources(widget.dataSources);
    }
  }

  /// Register DataSources of this widget with the DataProvider
  void _registerDataSources(MainDataProvider mainDataProvider) {


    if (_dataSources.isNotEmpty) {
      final bool isFirst = _mainDataSource == null;

      _mainDataSource = mainDataProvider.registerDataSource(_dataSources);


      if (isFirst) {
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => setStateNotDisposed(() {}));
      }
    }
  }

  /// UnRegister DataSource of this widget from the DataProvider
  void _unRegisterDataSources(MainDataProvider mainDataProvider) {
    final dataSource = _mainDataSource;
    if (dataSource != null) {
      mainDataProvider.unRegisterDataSource(dataSource);

      _mainDataSource = null;
    }
  }

  /// To update DataSources unRegister old DataSources and register new DataSource
  void updateDataSources(List<DataSource> dataSources) {
    _unRegisterDataSources(widget.mainDataProvider);

    _dataSources = dataSources;

    _registerDataSources(widget.mainDataProvider);
  }

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    if (widgetState == WidgetState.notInitialized) {
      firstBuildOnly(context);
    }

    final theDataSource = _mainDataSource;

    if (theDataSource == null || theDataSource.disposed) {
      return Builder(
        builder: (BuildContext context) => buildContentUnAvailable(context),
      );
    }

    return ValueListenableBuilder(
      valueListenable: theDataSource.state,
      builder: (BuildContext context, MainDataProviderSourceState state, Widget? child) {
        switch (state) {
          case MainDataProviderSourceState.unAvailable:
            return buildContentUnAvailable(context);
          case MainDataProviderSourceState.ready:
            return buildContent(context);
          case MainDataProviderSourceState.connecting:
            return buildContentConnecting(context);
        }
      },
    );
  }

  /// Create screen content from widgets when at least one Request Source is unAvailable
  @protected
  Widget buildContentUnAvailable(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text('MainDataSource or provider source unAvailable'),
      ),
    );
  }

  /// Create screen content from widgets when at least one Request Source is Connecting
  @protected
  Widget buildContentConnecting(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text('Provider source is connecting'),
      ),
    );
  }
}
