import 'package:auto_route/auto_route.dart';
import 'package:diohub/adapters/deep_linking_handler.dart';
import 'package:diohub/app/api_handler/response_handler.dart';
import 'package:diohub/common/misc/app_scroll_view.dart';
import 'package:diohub/common/misc/button.dart';
import 'package:diohub/common/misc/deep_link_widget.dart';
import 'package:diohub/common/misc/menu_button.dart';
import 'package:diohub/common/misc/profile_banner.dart';
import 'package:diohub/common/misc/scaffold_body.dart';
import 'package:diohub/common/misc/theme_from_image.dart';
import 'package:diohub/common/wrappers/dynamic_tabs_parent.dart';
import 'package:diohub/common/wrappers/provider_loading_progress_wrapper.dart';
import 'package:diohub/models/popup/popup_type.dart';
import 'package:diohub/models/repositories/repository_model.dart';
import 'package:diohub/providers/base_provider.dart';
import 'package:diohub/providers/repository/branch_provider.dart';
import 'package:diohub/providers/repository/code_provider.dart';
import 'package:diohub/providers/repository/issue_templates_provider.dart';
import 'package:diohub/providers/repository/pinned_issues_provider.dart';
import 'package:diohub/providers/repository/readme_provider.dart';
import 'package:diohub/providers/repository/repository_provider.dart';
import 'package:diohub/routes/router.gr.dart';
import 'package:diohub/utils/utils.dart';
import 'package:diohub/view/repository/code/code_browser.dart';
import 'package:diohub/view/repository/issues/issues_list.dart';
import 'package:diohub/view/repository/pulls/pulls_list.dart';
import 'package:diohub/view/repository/readme/repository_readme.dart';
import 'package:diohub/view/repository/widgets/about_repository.dart';
import 'package:diohub/view/repository/widgets/branch_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_tabs/flutter_dynamic_tabs.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pull_down_button/pull_down_button.dart';

@RoutePage()
class RepositoryScreen extends DeepLinkWidget {
  const RepositoryScreen(
    this.repositoryURL, {
    this.branch,
    this.index = 0,
    final PathData? deepLinkData,
    super.key,
    this.initSHA,
  }) : super(pathData: deepLinkData);
  final String repositoryURL;
  final String? branch;
  final int index;
  final String? initSHA;

  @override
  RepositoryScreenState createState() => RepositoryScreenState();
}

class RepositoryScreenState extends DeepLinkWidgetState<RepositoryScreen>
    with TickerProviderStateMixin {
  bool loading = false;
  late RepoBranchProvider repoBranchProvider;
  late CodeProvider codeProvider;
  late RepoReadmeProvider readmeProvider;
  late DynamicTabsController tabController;
  late IssueTemplateProvider issueTemplateProvider;
  late RepositoryProvider repositoryProvider;
  late PinnedIssuesProvider pinnedIssuesProvider;

  // final ScrollController scrollController = ScrollController();
  late String? initBranch;

  @override
  void handleDeepLink(final PathData deepLinkData) {
    final PathData data = deepLinkData;
    if (_isDeepLinkCode(data)) {
      initBranch = data.component(3);
    } else if (data.componentIs(2, 'wiki')) {
      WidgetsBinding.instance
          .addPostFrameCallback((final Duration timeStamp) async {
        await AutoRouter.of(context)
            .push(WikiViewer(repoURL: widget.repositoryURL));
      });
    }
  }

  bool _isDeepLinkCode(final PathData? data) =>
      data?.component(2)?.startsWith(RegExp('(tree)|(blob)|(commits)')) ??
      false;

  bool _isDeepLinkComp(final String data) =>
      widget.pathData?.componentIs(2, data) ?? false;

  @override
  void initState() {
    _setupTabs();
    tabController = DynamicTabsController(vsync: this, tabs: tabs);
    initBranch = widget.branch;
    super.initState();
    // This HAS to be after the super initState call as some required data
    // is being set in handleDeepLink()!
    _setupProviders();
  }

  void _setupProviders() {
    repositoryProvider = RepositoryProvider(widget.repositoryURL);
    repoBranchProvider = RepoBranchProvider(
      initialBranch: initBranch,
      initCommitSHA: widget.initSHA,
    );
    codeProvider = CodeProvider(repoURL: widget.repositoryURL);
    readmeProvider = RepoReadmeProvider(widget.repositoryURL);
    issueTemplateProvider = IssueTemplateProvider();
    pinnedIssuesProvider = PinnedIssuesProvider();
  }

  void _setupTabs() {
    tabs = <DynamicTab>[
      DynamicTab(
        identifier: 'About',
        isDismissible: false,
        tabViewBuilder: (final BuildContext context) => AboutRepository(
          context.repoProvider().data,
          onTabOpened: tabController.openTab,
        ),
      ),
      DynamicTab(
        identifier: 'Readme',
        isDismissible: false,
        tabViewBuilder: (final BuildContext context) =>
            RepositoryReadme(context.repoProvider(listen: false).url),
      ),
      DynamicTab(
        identifier: 'Code',
        isFocusedOnInit: _isDeepLinkCode(widget.pathData),
        tabViewBuilder: (final BuildContext context) => CodeBrowser(
          showCommitHistory: widget.pathData?.component(2) == 'commits',
        ),
      ),
      DynamicTab(
        identifier: 'Issues',
        isFocusedOnInit: _isDeepLinkComp('issues'),
        keepViewAlive: true,
        tabViewBuilder: (final BuildContext context) => const IssuesList(),
      ),
      DynamicTab(
        identifier: 'Pull Requests',
        isFocusedOnInit: _isDeepLinkComp('pulls'),
        keepViewAlive: true,
        tabViewBuilder: (final BuildContext context) => const PullsList(),
      ),
      DynamicTab(
        identifier: 'More',
        tabViewBuilder: (final BuildContext context) => Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Button(
                onTap: () async {
                  if (Provider.of<RepositoryProvider>(context, listen: false)
                      .data
                      .hasWiki!) {
                    await AutoRouter.of(context).push(
                      WikiViewer(
                        repoURL: widget.repositoryURL,
                      ),
                    );
                  } else {
                    ResponseHandler.setErrorMessage(
                      AppPopupData(
                        title: 'Repository has no wiki.',
                      ),
                    );
                  }
                },
                child: const Text('Open Wiki'),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  late List<DynamicTab> tabs;

  @override
  Widget build(final BuildContext context) => MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<RepositoryProvider>.value(
            value: repositoryProvider,
          ),
          ChangeNotifierProxyProvider<RepositoryProvider, RepoBranchProvider>(
            create: (final _) => repoBranchProvider,
            update: (
              final BuildContext context,
              final RepositoryProvider value,
              final RepoBranchProvider? previous,
            ) =>
                repoBranchProvider..updateProvider(value),
          ),
          ChangeNotifierProxyProvider<RepositoryProvider,
              IssueTemplateProvider>(
            create: (final _) => issueTemplateProvider,
            update: (final _, final RepositoryProvider repo, final __) =>
                issueTemplateProvider..updateProvider(repo),
            lazy: false,
          ),
          ChangeNotifierProxyProvider<RepositoryProvider, PinnedIssuesProvider>(
            create: (final _) => pinnedIssuesProvider,
            update: (final _, final RepositoryProvider repo, final __) =>
                pinnedIssuesProvider..updateProvider(repo),
            lazy: false,
          ),
          ChangeNotifierProxyProvider<RepoBranchProvider, RepoReadmeProvider>(
            create: (final _) => readmeProvider,
            update: (final _, final RepoBranchProvider branch, final __) =>
                readmeProvider..updateProvider(branch),
          ),
          ChangeNotifierProxyProvider<RepoBranchProvider, CodeProvider>(
            create: (final _) => codeProvider,
            update: (final _, final RepoBranchProvider branch, final __) =>
                codeProvider..updateProvider(branch),
          ),
        ],
        builder: (final BuildContext context, final _) => SafeArea(
          child: Scaffold(
            // backgroundColor:
            // Provider.of<PaletteSettings>(context).currentSetting.primary,
            // Show a temporary app bar until the provider loads.
            appBar:
                Provider.of<RepositoryProvider>(context).status != Status.loaded
                    ? AppBar(
                        elevation: 0,
                      )
                    : PreferredSize(
                        preferredSize: Size.zero,
                        child: Container(),
                      ),
            body: WillPopScope(
              onWillPop: () async {
                // Don't pop screen if code browsing is open and not the root tree.
                if (Provider.of<CodeProvider>(context, listen: false)
                            .tree
                            .length >
                        1 &&
                    tabController.activeIdentifier == 'Code') {
                  Provider.of<CodeProvider>(context, listen: false).popTree();
                  return false;
                } else {
                  return true;
                }
              },
              child: ScaffoldBody(
                child: ProviderLoadingProgressWrapper<RepositoryProvider>(
                  childBuilder: (
                    final BuildContext context,
                    final RepositoryProvider value,
                  ) {
                    final RepositoryModel repo = value.data;
                    return ThemeFromImage(
                      // imageUri: repo.owner?.avatarUrl,
                      builder: (context) => DynamicTabsParent(
                        controller: tabController,
                        builder: (
                          final BuildContext context,
                          final PreferredSizeWidget tabs,
                          final Widget tabView,
                        ) =>
                            AppScrollView(
                          // nestedScrollViewController: scrollController,
                          scrollViewAppBar: ScrollViewAppBar(
                            expandedHeight: 340,
                            collapsedHeight: 150,
                            tabBar: tabs,
                            url: repo.htmlUrl,
                            appBarWidget: Row(
                              children: <Widget>[
                                ProfileTile.avatar(
                                  avatarUrl: repo.owner?.avatarUrl,
                                  userLogin: repo.owner?.login,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      style: context.textTheme.bodyLarge,
                                      children: <InlineSpan>[
                                        TextSpan(text: '${repo.owner!.login}/'),
                                        TextSpan(
                                          text: repo.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            flexibleBackgroundWidget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ProfileTile.login(
                                      avatarUrl: repo.owner!.avatarUrl,
                                      userLogin: repo.owner!.login,
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      repo.name!,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  children: <Widget>[
                                    // RepoStar(
                                    //   repo.owner!.login!,
                                    //   repo.name!,
                                    //   fadeIntoView: false,
                                    //   inkWellRadius: medBorderRadius,
                                    //   child: (
                                    //     final BuildContext context,
                                    //     final HasStarred$Query$Repository? data,
                                    //     final VoidCallback? onPress,
                                    //   ) =>
                                    //       ActionButton(
                                    //     count: data?.stargazerCount,
                                    //     icon: Octicons.star_fill,
                                    //     onTap: onPress,
                                    //     doneColor: amber,
                                    //     isDone: data?.viewerHasStarred,
                                    //   ),
                                    // ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    // WatchRepoWrapper(
                                    //   repo.owner!.login!,
                                    //   repo.name!,
                                    //   builder: (
                                    //     final BuildContext context,
                                    //     final HasWatched$Query$Repository?
                                    //         watchData,
                                    //     final VoidCallback? onPress,
                                    //   ) =>
                                    //       ActionButton(
                                    //     count: watchData?.watchers.totalCount,
                                    //     onTap: onPress,
                                    //     doneColor: greenAccent,
                                    //     icon: Octicons.eye,
                                    //     isDone: isSubscribedToRepo(
                                    //       watchData?.viewerSubscription,
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(
                                            Octicons.repo_forked,
                                            // color: Provider.of<PaletteSettings>(
                                            //   context,
                                            // ).currentSetting.faded3,
                                            size: 15,
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            repo.forksCount.toString(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // ActionButton(
                                    //   count: _repo.forksCount,
                                    //   icon: Octicons.repo_forked,
                                    //   action: 'Fork',
                                    // ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 60,
                                ),
                              ],
                            ),
                            bottomPadding: 60,
                            bottomHeader: BranchButton(
                              repo: repo,
                            ),
                          ),
                          loading: loading,
                          child: tabView,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
}
