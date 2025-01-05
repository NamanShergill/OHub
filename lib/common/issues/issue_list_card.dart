import 'package:auto_route/auto_route.dart';
import 'package:diohub/adapters/deep_linking_handler.dart';
import 'package:diohub/common/issues/issue_label.dart';
import 'package:diohub/common/misc/info_card.dart';
import 'package:diohub/common/misc/ink_pot.dart';
import 'package:diohub/common/misc/loading_indicator.dart';
import 'package:diohub/common/pulls/pull_loading_card.dart';
import 'package:diohub/common/wrappers/api_wrapper_widget.dart';
import 'package:diohub/models/issues/issue_model.dart';
import 'package:diohub/services/issues/issues_service.dart';
import 'package:diohub/utils/get_date.dart';
import 'package:diohub/utils/utils.dart';
import 'package:diohub/view/issues_pulls/issue_pull_screen.dart';
import 'package:flutter/material.dart' hide State;
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class IssueListCard extends StatelessWidget {
  const IssueListCard(
    this.item, {
    this.compact = false,
    this.showRepoName = true,
    // this.disableMaterial = false,
    this.commentsSince,
    super.key,
  });

  final IssueModel item;
  final bool compact;

  // final bool disableMaterial;
  final DateTime? commentsSince;
  final bool showRepoName;

  @override
  Widget build(final BuildContext context) {
    if (item.pullRequest != null) {
      return PullLoadingCard(
        item.pullRequest!.url!,
        issueModel: item,
        // disableMaterial: disableMaterial,
        compact: compact,
      );
    }
    final Padding child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              getIcon(item.state!),
              const SizedBox(
                width: 4,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                '${item.number}',
                style: context.textTheme.bodyMedium?.asHint(),
              ),
              if (item.comments != 0)
                Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 16,
                    ),
                    Icon(
                      Octicons.comment,
                      color: context.colorScheme.onSurface.asHint(),
                      size: 11,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      '${item.comments} comments',
                      style: context.textTheme.labelMedium?.asHint(),
                    ),
                  ],
                ),
            ],
          ),
          Text(
            item.title!,
            style: context.textTheme.bodyMedium,
          ),
          if (!compact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.state == IssueState.CLOSED
                      ? 'By ${item.user!.login}, closed ${getDate(item.closedAt.toString(), shorten: false)}.'
                      : 'Opened ${getDate(item.createdAt.toString(), shorten: false)} by ${item.user!.login}',
                  style: context.textTheme.bodySmall?.asHint(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    children: List<Widget>.generate(
                      item.labels!.length,
                      (final int index) => Padding(
                        padding: const EdgeInsets.only(
                          right: 8,
                          bottom: 8,
                        ),
                        child: IssueLabel(item.labels![index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
    return InkPot(
      onTap: () async {
        await AutoRouter.of(context)
            .push(issuePullScreenRoute(PathData.fromURL(item.url!)));
      },
      child: Row(
        children: [
          Expanded(
            child: showRepoName
                ? InfoCard(
                    leading: Text(
                      item.url!
                          .replaceAll('https://api.github.com/repos/', '')
                          .split('/')
                          .sublist(0, 2)
                          .join('/'),
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.asHint(),
                    ),
                    headerPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ).copyWith(top: 8),
                    child: child,
                  )
                : child,
          )
        ],
      ),
    );
  }
}

Widget getIcon(final IssueState state) => switch (state) {
      IssueState.CLOSED => const Icon(
          Octicons.issue_closed,
          size: 15,
          color: Colors.red,
        ),
      IssueState.OPEN => const Icon(
          Octicons.issue_opened,
          size: 15,
          color: Colors.green,
        ),
      IssueState.REOPENED => const Icon(
          Octicons.issue_reopened,
          size: 15,
          color: Colors.green,
        ),
    };

class IssueLoadingCard extends StatelessWidget {
  const IssueLoadingCard(
    this.url, {
    this.compact = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    // this.backgroundColor,
    super.key,
  });

  final String url;

  // final Color? backgroundColor;
  final bool compact;
  final EdgeInsets padding;

  @override
  Widget build(final BuildContext context) => Padding(
        padding: padding,
        child: APIWrapper<IssueModel>.deferred(
          apiCall: ({required final bool refresh}) async =>
              IssuesService.getIssueInfo(fullUrl: url, refresh: refresh),
          builder: (final BuildContext context, final IssueModel data) =>
              IssueListCard(
            data,
            compact: compact,
            // disableMaterial: true,
          ),
          loadingBuilder: (final BuildContext context) => const SizedBox(
            height: 80,
            child: Center(child: LoadingIndicator()),
          ),
        ),
      );
}
