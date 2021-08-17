import 'package:auto_route/auto_route.dart';
import 'package:dio_hub/app/Dio/response_handler.dart';
import 'package:dio_hub/app/settings/palette.dart';
import 'package:dio_hub/common/misc/app_scroll_view.dart';
import 'package:dio_hub/common/misc/button.dart';
import 'package:dio_hub/common/misc/profile_banner.dart';
import 'package:dio_hub/common/misc/repo_star.dart';
import 'package:dio_hub/common/misc/scaffold_body.dart';
import 'package:dio_hub/common/wrappers/dynamic_tabs_wrapper.dart';
import 'package:dio_hub/common/wrappers/provider_loading_progress_wrapper.dart';
import 'package:dio_hub/controller/deep_linking_handler.dart';
import 'package:dio_hub/controller/dynamic_tabs.dart';
import 'package:dio_hub/models/popup/popup_type.dart';
import 'package:dio_hub/providers/base_provider.dart';
import 'package:dio_hub/providers/repository/branch_provider.dart';
import 'package:dio_hub/providers/repository/code_provider.dart';
import 'package:dio_hub/providers/repository/issue_templates_provider.dart';
import 'package:dio_hub/providers/repository/pinned_issues_provider.dart';
import 'package:dio_hub/providers/repository/readme_provider.dart';
import 'package:dio_hub/providers/repository/repository_provider.dart';
import 'package:dio_hub/routes/router.gr.dart';
import 'package:dio_hub/style/border_radiuses.dart';
import 'package:dio_hub/view/repository/code/code_browser.dart';
import 'package:dio_hub/view/repository/issues/issues_list.dart';
import 'package:dio_hub/view/repository/pulls/pulls_list.dart';
import 'package:dio_hub/view/repository/readme/repository_readme.dart';
import 'package:dio_hub/view/repository/widgets/about_repository.dart';
import 'package:dio_hub/view/repository/widgets/action_button.dart';
import 'package:dio_hub/view/repository/widgets/branch_button.dart';
import 'package:dio_hub/view/repository/widgets/watch_repo_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

class RepositoryScreen extends StatefulWidget {
  const RepositoryScreen(this.repositoryURL,
      {this.branch, this.index = 0, this.deepLinkData, Key? key, this.initSHA})
      : super(key: key);
  final String repositoryURL;
  final String? branch;
  final int index;
  final String? initSHA;
  final DeepLinkData? deepLinkData;

  @override
  _RepositoryScreenState createState() => _RepositoryScreenState();
}

class _RepositoryScreenState extends State<RepositoryScreen>
    with TickerProviderStateMixin {
  bool loading = false;
  late RepoBranchProvider repoBranchProvider;
  late CodeProvider codeProvider;
  late RepoReadmeProvider readmeProvider;
  late DynamicTabsController tabController;
  late IssueTemplateProvider issueTemplateProvider;
  late RepositoryProvider repositoryProvider;
  late PinnedIssuesProvider pinnedIssuesProvider;
  final ScrollController scrollController = ScrollController();
  late String? initBranch;
  @override
  void initState() {
    tabController =
        DynamicTabsController(vsync: this, tabs: tabs, context: context);
    initBranch = widget.branch;
    if (widget.deepLinkData != null) {
      deepLinkHandler();
    }
    repositoryProvider = RepositoryProvider(widget.repositoryURL);
    repoBranchProvider = RepoBranchProvider(
        initialBranch: initBranch, initCommitSHA: widget.initSHA);
    codeProvider = CodeProvider(repoURL: widget.repositoryURL);
    readmeProvider = RepoReadmeProvider(widget.repositoryURL);
    issueTemplateProvider = IssueTemplateProvider();
    pinnedIssuesProvider = PinnedIssuesProvider();
    super.initState();
  }

  List<DynamicTab> tabs = [
    DynamicTab('About', isDismissible: false),
    DynamicTab('Readme', isDismissible: false),
    DynamicTab('Code'),
    DynamicTab('Issues'),
    DynamicTab('Pull Requests'),
    DynamicTab('More')
  ];

  void deepLinkHandler() {
    final data = widget.deepLinkData!;
    if (data.component(2)?.startsWith(RegExp('(tree)|(blob)|(commits)')) ==
        true) {
      // tabController.index = 2;
      initBranch = widget.deepLinkData?.component(3);
    }
    // else if (data.component(2) == 'commit') {
    //   tabController.index = 2;
    //   WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //     AutoRouter.of(context).push(CommitInfoScreenRoute(
    //         commitURL:
    //             widget.repositoryURL! + '/commits/' + data.component(3)!));
    //   });
    // }
    else if (data.component(2) == 'issues') {
      // tabController.index = 3;
    } else if (data.component(2) == 'pulls') {
      // tabController.index = 4;
    } else if (data.component(2) == 'wiki') {
      // tabController.index = 5;
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        AutoRouter.of(context)
            .push(WikiViewerRoute(repoURL: widget.repositoryURL));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => repositoryProvider,
        ),
        ChangeNotifierProxyProvider<RepositoryProvider, RepoBranchProvider>(
          create: (_) => repoBranchProvider,
          update: (_, repo, __) => repoBranchProvider..updateProvider(repo),
        ),
        ChangeNotifierProxyProvider<RepositoryProvider, IssueTemplateProvider>(
          create: (_) => issueTemplateProvider,
          update: (_, repo, __) => issueTemplateProvider..updateProvider(repo),
          lazy: false,
        ),
        ChangeNotifierProxyProvider<RepositoryProvider, PinnedIssuesProvider>(
          create: (_) => pinnedIssuesProvider,
          update: (_, repo, __) => pinnedIssuesProvider..updateProvider(repo),
          lazy: false,
        ),
        ChangeNotifierProxyProvider<RepoBranchProvider, RepoReadmeProvider>(
            create: (_) => readmeProvider,
            update: (_, branch, __) => readmeProvider..updateProvider(branch)),
        ChangeNotifierProxyProvider<RepoBranchProvider, CodeProvider>(
          create: (_) => codeProvider,
          update: (_, branch, __) => codeProvider..updateProvider(branch),
        ),
      ],
      child: Builder(builder: (context) {
        final theme = Provider.of<PaletteSettings>(context).currentSetting;

        return SafeArea(
          child: Scaffold(
            backgroundColor:
                Provider.of<PaletteSettings>(context).currentSetting.primary,
            // Show a temporary app bar until the provider loads.
            appBar:
                Provider.of<RepositoryProvider>(context).status != Status.loaded
                    ? AppBar(
                        elevation: 0,
                      )
                    : PreferredSize(
                        preferredSize: const Size(0, 0),
                        child: Container(),
                      ),
            body: WillPopScope(
              onWillPop: () async {
                // Don't pop screen if code browsing is open and not the root tree.
                if (Provider.of<CodeProvider>(context, listen: false)
                            .tree
                            .length >
                        1
                    // &&
                    // tabController.index == 2
                    ) {
                  if (Provider.of<CodeProvider>(context, listen: false)
                          .status !=
                      Status.loading) {
                    Provider.of<CodeProvider>(context, listen: false).popTree();
                  }
                  return false;
                } else {
                  return true;
                }
              },
              child: ScaffoldBody(
                child: ProviderLoadingProgressWrapper<RepositoryProvider>(
                  childBuilder: (context, value) {
                    final _repo = value.data;
                    return DynamicTabsWrapper(
                      dynamicTabsController: tabController,
                      builder: (context, tabController) => AppScrollView(
                        scrollController: scrollController,
                        scrollViewAppBar: ScrollViewAppBar(
                          expandedHeight: 340,
                          collapsedHeight: 150,
                          dynamicTabsController: tabController,
                          url: _repo.htmlUrl,
                          appBarWidget: Row(
                            children: [
                              ProfileTile(
                                _repo.owner!.avatarUrl,
                                userLogin: _repo.owner!.login,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Flexible(
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(fontSize: 18),
                                      children: [
                                        TextSpan(
                                            text: '${_repo.owner!.login}/'),
                                        TextSpan(
                                            text: _repo.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                          flexibleBackgroundWidget: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ProfileTile(
                                    _repo.owner!.avatarUrl,
                                    userLogin: _repo.owner!.login,
                                    showName: true,
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    _repo.name!,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  RepoStar(
                                    _repo.owner!.login!,
                                    _repo.name!,
                                    fadeIntoView: false,
                                    inkWellRadius: medBorderRadius,
                                    child: (context, data, onPress) {
                                      return ActionButton(
                                        count: data?.stargazerCount,
                                        icon: Octicons.star,
                                        onTap: onPress,
                                        doneColor: Colors.amber,
                                        isDone: data?.viewerHasStarred,
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  WatchRepoWrapper(
                                    _repo.owner!.login!,
                                    _repo.name!,
                                    builder: (context, watchData, onPress) =>
                                        ActionButton(
                                      count: watchData?.watchers.totalCount,
                                      onTap: onPress,
                                      doneColor: Colors.greenAccent,
                                      icon: Octicons.eye,
                                      isDone: isSubscribedToRepo(
                                          watchData?.viewerSubscription),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Octicons.repo_forked,
                                          color: Provider.of<PaletteSettings>(
                                                  context)
                                              .currentSetting
                                              .faded3,
                                          size: 15,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          _repo.forksCount.toString(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: theme.faded3,
                                          ),
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
                          tabController: tabController.controller,
                          bottomHeader: BranchButton(
                            repo: _repo,
                          ),
                        ),
                        tabController: tabController.controller,
                        loading: loading,
                        tabViews: tabController.setTabs([
                          DynamicTabView(
                              identifier: 'About',
                              child: AboutRepository(
                                _repo,
                                onTabOpened: tabController.openTab,
                              )),
                          DynamicTabView(
                            identifier: 'Readme',
                            child: RepositoryReadme(_repo.url),
                          ),
                          DynamicTabView(
                            identifier: 'Code',
                            child: CodeBrowser(
                              showCommitHistory:
                                  widget.deepLinkData?.component(2) ==
                                      'commits',
                            ),
                          ),
                          DynamicTabView(
                            identifier: 'Issues',
                            child: IssuesList(
                              scrollController: scrollController,
                            ),
                          ),
                          DynamicTabView(
                            identifier: 'Pull Requests',
                            child: PullsList(
                              scrollController: scrollController,
                            ),
                            // ProjectsList(
                            //   scrollController: scrollController,
                            // ),
                          ),
                          DynamicTabView(
                            identifier: 'More',
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Button(
                                    onTap: () {
                                      if (Provider.of<RepositoryProvider>(
                                              context,
                                              listen: false)
                                          .data
                                          .hasWiki!) {
                                        AutoRouter.of(context).push(
                                            WikiViewerRoute(
                                                repoURL: widget.repositoryURL));
                                      } else {
                                        ResponseHandler.setErrorMessage(
                                            AppPopupData(
                                                title:
                                                    'Repository has no wiki.'));
                                      }
                                    },
                                    child: const Text('Open Wiki'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
