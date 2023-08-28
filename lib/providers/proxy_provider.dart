import 'package:dio_hub/providers/base_provider.dart';

abstract class ProxyProvider<T, Parent extends BaseDataProvider>
    extends BaseDataProvider<T> {
  ProxyProvider([final Status status = Status.initialized])
      : super(status: status, loadDataOnInit: false);
  Parent? _parentProvider;
  Parent get parentProvider => _parentProvider!;

  /// Update the provider with new data.
  Future<void> updateProvider(final Parent parentProvider) async {
    // Only initialise streams if the provider is not equal,
    // ignore the call otherwise.
    if (_parentProvider != parentProvider) {
      _parentProvider = parentProvider;
      // In case the provider loads lazily and the event of load is
      // already dispatched before it started listening to the stream.
      if (_parentProvider!.status == Status.loaded) {
        await loadData();
      }
      _parentProvider!.statusStream.listen(
        (final event) async {
          // This event happens whenever the parent provider is reloaded, so this provider
          // is reset and new data is fetched.
          if (event == Status.loaded) {
            reset();
            await loadData();
          }
        },
      );
      customStreams();
    }
  }

  void customStreams() {}
}
