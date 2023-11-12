import 'package:auto_route/auto_route.dart';
import 'package:diohub/common/misc/app_scroll_view.dart';
import 'package:diohub/common/misc/scaffold_body.dart';
import 'package:diohub/common/wrappers/provider_loading_progress_wrapper.dart';
import 'package:diohub/graphql/__generated__/schema.schema.gql.dart';
import 'package:diohub/graphql/queries/issues_pulls/__generated__/issue_pull_info.query.data.gql.dart';
import 'package:diohub/graphql/queries/issues_pulls/__generated__/timeline.query.data.gql.dart';
import 'package:diohub/models/issues/issue_model.dart';
import 'package:diohub/providers/base_provider.dart';
import 'package:diohub/providers/issue_pulls/comment_provider.dart';
import 'package:diohub/providers/issue_pulls/pull_provider.dart';
import 'package:diohub/routes/router.gr.dart';
import 'package:diohub/style/border_radiuses.dart';
import 'package:diohub/utils/utils.dart';
import 'package:diohub/view/issues_pulls/pull_information.dart';
import 'package:diohub/view/issues_pulls/widgets/discussion.dart';
import 'package:diohub/view/issues_pulls/widgets/discussion_comment.dart';
import 'package:diohub/view/issues_pulls/widgets/pull_changed_files_list.dart';
import 'package:diohub/view/issues_pulls/widgets/pulls_commits_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class PullScreen extends StatefulWidget {
  const PullScreen(
    this.pullInfo, {
    this.initialIndex = 0,
    this.commentsSince,
    super.key,
  });

  final GpullInfo pullInfo;
  final DateTime? commentsSince;
  final int initialIndex;

  @override
  PullScreenState createState() => PullScreenState();
}

class PullScreenState extends State<PullScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    tabController = TabController(
      length: 4,
      initialIndex: widget.initialIndex,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(final BuildContext context) => MultiProvider(
        providers: <SingleChildWidget>[
          // ChangeNotifierProvider(
          //   create: (_) => PullProvider(
          //       widget.pullURL,
          //       Provider.of<CurrentUserProvider>(context, listen: false)
          //           .data
          //           .login!),
          // ),
          ChangeNotifierProvider<CommentProvider>(
            create: (final BuildContext context) => CommentProvider(),
          ),
        ],
        builder: (final BuildContext context, final Widget? child) => SafeArea(
          child: Consumer<PullProvider>(
            builder: (
              final BuildContext context,
              final PullProvider value,
              final _,
            ) =>
                Scaffold(
              appBar: value.status != Status.loaded
                  ? AppBar(
                      elevation: 0,
                    )
                  : null,
              body: ScaffoldBody(
                child: ProviderLoadingProgressWrapper<PullProvider>(
                  childBuilder:
                      (final BuildContext context, final PullProvider value) =>
                          AppScrollView(
                    // nestedScrollViewController: scrollController,
                    scrollViewAppBar: ScrollViewAppBar(
                      tabController: tabController,
                      // url: value.data.htmlUrl,
                      tabs: const <String>[
                        'Information',
                        'Discussion',
                        'Commits',
                        'Files Changed',
                      ],
                      collapsedHeight: 120,
                      expandedHeight: 250,
                      appBarWidget: Row(
                        children: <Widget>[
                          getIcon(
                            IssueState.OPEN,
                            15,
                            merged: true,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            value.data.state == GPullRequestState.OPEN
                                ? 'Open'
                                : value.data.merged
                                    ? 'Merged'
                                    : 'Closed',
                            // style: context.colorScheme,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            '#${value.data.number}',
                            style: context.textTheme.bodySmall?.asHint(),
                          ),
                        ],
                      ),
                      flexibleBackgroundWidget: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              getIcon(
                                IssueState.REOPENED,
                                20,
                                merged: value.data.merged,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                value.data.state == GPullRequestState.OPEN
                                    ? 'Open'
                                    : value.data.merged
                                        ? 'Merged'
                                        : 'Closed',
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                '#${value.data.number}',
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                              const Icon(
                                Octicons.comment,
                                // color: Provider.of<PaletteSettings>(context)
                                //     .currentSetting
                                //     .faded3,
                                size: 11,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                '${value.data.comments} comments',
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text(
                            'value.data.title!',
                            overflow: TextOverflow.ellipsis,
                          ),
                          Material(
                            // color: transparent,
                            child: InkWell(
                              borderRadius: medBorderRadius,
                              onTap: () async {
                                await AutoRouter.of(context)
                                    .push(RepositoryRoute(repositoryURL: ''));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'value.repoURL'.replaceFirst(
                                    'https://api.github.com/repos/',
                                    '',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          // Text(
                          //   value.data.state == GIssueState.CLOSED
                          //       ? 'By ${value.data.user!.login}, closed ${getDate(value.data.closedAt.toString(), shorten: false)}.'
                          //       : 'Opened ${getDate(value.data.createdAt.toString(), shorten: false)} by ${value.data.user!.login}',
                          //   style: TextStyle(
                          //       color: Provider.of<PaletteSettings>(context)
                          //           .currentSetting
                          //           .faded3,
                          //        12),
                          // ),
                        ],
                      ),
                    ),
                    tabController: tabController,
                    tabViews: <Widget>[
                      const PullInformation(),
                      // Text(widget.pullInfo.reactionGroups.toString()),
                      IssuePullTimeline(
                        // nestedScrollViewController: scrollController,
                        pullNodeID: 'value.data.nodeId',
                        number: value.data.number,
                        owner: 'value.repoURL'
                            .replaceFirst(
                              'https://api.github.com/repos/',
                              '',
                            )
                            .split('/')
                            .first,
                        repoName: 'value.repoURL'
                            .replaceFirst(
                              'https://api.github.com/repos/',
                              '',
                            )
                            .split('/')
                            .last,
                        isPull: true,
                        commentsSince: widget.commentsSince,
                        isLocked: value.data.locked,
                        createdAt: value.data.createdAt,
                        issueUrl: Uri.parse('value.data.issueUrl!'),
                        initComment: BaseComment(
                          isMinimized: false,
                          reactions: widget.pullInfo.reactionGroups?.toList() ??
                              <GreactionGroups>[],
                          onQuote: () {},
                          viewerCanDelete: false,
                          viewerCanMinimize: false,
                          viewerCannotUpdateReasons: null,
                          viewerCanReact: false,
                          viewerCanUpdate: false,
                          viewerDidAuthor: false,
                          createdAt: value.data.createdAt,
                          author: value.data.author,
                          body: '',
                          lastEditedAt: null,
                          // description: '',
                          bodyHTML: 'value.data.bodyHtml',
                          authorAssociation: GCommentAuthorAssociation.NONE,
                        ),
                      ),
                      const PullsCommitsList(),
                      const PullChangedFilesList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget getIcon(
    final IssueState state,
    final double size, {
    required final bool merged,
  }) {
    switch (state) {
      case IssueState.CLOSED:
        if (merged) {
          return Icon(
            Octicons.git_merge,
            color: Colors.deepPurpleAccent,
            size: size,
          );
        } else {
          return Icon(
            Octicons.git_pull_request,
            color: Colors.red,
            size: size,
          );
        }
      // case GIssueState.REOPENED:
      case IssueState.OPEN:
        return Icon(
          Octicons.git_pull_request,
          color: Colors.green,
          size: size,
        );
      default:
        throw UnimplementedError();
    }
  }
}
