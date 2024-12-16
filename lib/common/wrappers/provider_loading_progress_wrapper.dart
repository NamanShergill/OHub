import 'package:dio/dio.dart';
import 'package:diohub/adapters/internet_connectivity.dart';
import 'package:diohub/common/misc/api_error.dart';
import 'package:diohub/common/misc/button.dart';
import 'package:diohub/common/misc/loading_indicator.dart';
import 'package:diohub/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef ErrorBuilder = Widget Function(BuildContext context, Object error);
typedef ChildBuilder<T> = Widget Function(BuildContext context, T value);

class ProviderLoadingProgressWrapper<T extends BaseDataProvider<dynamic>>
    extends StatefulWidget {
  const ProviderLoadingProgressWrapper({
    required this.childBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
    this.listener,
  });

  final ChildBuilder<T> childBuilder;
  final ValueChanged<Status>? listener;
  final WidgetBuilder? loadingBuilder;
  final ErrorBuilder? errorBuilder;

  @override
  ProviderLoadingProgressWrapperState<T> createState() =>
      ProviderLoadingProgressWrapperState<T>();
}

class ProviderLoadingProgressWrapperState<T extends BaseDataProvider<dynamic>>
    extends State<ProviderLoadingProgressWrapper<T>> {
  @override
  void initState() {
    if (widget.listener != null) {
      context.read<T>().statusStream.listen((final Status event) {
        widget.listener?.call(event);
      });
    }
    InternetConnectivity.networkStream.listen((NetworkStatus event) async {
      final BuildContext bContext = context;
      if (event == NetworkStatus.online && bContext.mounted) {
        final T provider = bContext.read<T>();
        if (provider.status == Status.error) {
          await provider.loadData();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    final BaseProvider value = Provider.of<T>(context);
    return StreamBuilder<Status>(
      stream: value.statusStream,
      initialData: value.status,
      builder:
          (final BuildContext context, final AsyncSnapshot<Status> snapshot) {
        if (snapshot.data == Status.loaded) {
          return widget.childBuilder(context, value as T);
        }
        if (snapshot.data == Status.loading) {
          return widget.loadingBuilder != null
              ? widget.loadingBuilder!(context)
              : const LoadingIndicator();
        }
        if (snapshot.data == Status.error) {
          return widget.errorBuilder != null
              ? widget.errorBuilder!(
                  context,
                  value.errorInfo ?? 'Something went wrong.',
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Builder(
                        builder: (final BuildContext context) {
                          if (value.errorInfo is DioException) {
                            final DioException err =
                                value.errorInfo! as DioException;
                            if (err.response != null) {
                              return Center(
                                child: APIError(
                                  err.response!.statusCode!,
                                  err.response!.statusMessage!,
                                ),
                              );
                            }
                          }
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(value.errorInfo.toString()),
                            ),
                          );
                        },
                      ),
                      Button(
                        onTap: () async {
                          final T provider = context.provider<T>(listen: false);
                          return provider.loadData();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
        }
        return widget.loadingBuilder != null
            ? widget.loadingBuilder!(context)
            : const LoadingIndicator();
      },
    );
  }
}
