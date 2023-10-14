import 'package:auto_route/auto_route.dart';
import 'package:dio_hub/common/misc/loading_indicator.dart';
import 'package:dio_hub/common/misc/shimmer_widget.dart';
import 'package:dio_hub/common/misc/tappable_card.dart';
import 'package:dio_hub/common/pulls/pull_list_card.dart';
import 'package:dio_hub/common/wrappers/api_wrapper_widget.dart';
import 'package:dio_hub/controller/deep_linking_handler.dart';
import 'package:dio_hub/models/issues/issue_model.dart';
import 'package:dio_hub/models/pull_requests/pull_request_model.dart';
import 'package:dio_hub/services/pulls/pulls_service.dart';
import 'package:dio_hub/style/border_radiuses.dart';
import 'package:dio_hub/utils/utils.dart';
import 'package:dio_hub/view/issues_pulls/issue_pull_screen.dart';
import 'package:flutter/material.dart';

class PullLoadingCard extends StatelessWidget {
  const PullLoadingCard(
    this.url, {
    this.compact = false,
    this.issueModel,
    // this.disableMaterial = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    super.key,
    this.cardLinkType = CardLinkType.none,
  });
  final CardLinkType cardLinkType;
  final String url;
  final bool compact;
  final IssueModel? issueModel;
  final EdgeInsets padding;
  // final bool disableMaterial;

  @override
  Widget build(final BuildContext context) => Padding(
        padding: padding,
        child: APIWrapper<PullRequestModel>.deferred(
          apiCall: ({required final bool refresh}) async =>
              PullsService.getPullInformation(fullUrl: url, refresh: refresh),
          loadingBuilder: (final BuildContext context) {
            if (issueModel != null) {
              return InkWell(
                borderRadius: medBorderRadius,
                onTap: () async {
                  await AutoRouter.of(context).push(
                    issuePullScreenRoute(PathData.fromURL(issueModel!.url!)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          // const GetPullIcon(null, null),
                          const SizedBox(
                            width: 4,
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                issueModel!.url!
                                    .replaceAll(
                                      'https://api.github.com/repos/',
                                      '',
                                    )
                                    .split('/')
                                    .sublist(0, 2)
                                    .join('/'),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    // color: Provider.of<PaletteSettings>(context)
                                    //     .currentSetting
                                    //     .faded3,
                                    ),
                              ),
                            ),
                          ),
                          Text(
                            '#${issueModel!.number}',
                            style: const TextStyle(
                                // color: Provider.of<PaletteSettings>(context)
                                //     .currentSetting
                                //     .faded3,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        issueModel!.title!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (!compact)
                        Column(
                          children: <Widget>[
                            const SizedBox(
                              height: 16,
                            ),
                            ShimmerWidget(
                              borderRadius: smallBorderRadius,
                              child: Container(
                                height: 20,
                                width: double.infinity,
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox(
              height: 80,
              child: Center(
                child: LoadingIndicator(),
              ),
            );
          },
          builder: (final BuildContext context, final PullRequestModel data) =>
              PullListCard(
            data,
            compact: compact,
            cardLinkType: cardLinkType,
            padding: EdgeInsets.zero,
          ),
        ),
      );
}
