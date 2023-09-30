import 'package:dio_hub/common/markdown_view/markdown_body.dart';
import 'package:dio_hub/common/misc/loading_indicator.dart';
import 'package:dio_hub/common/wrappers/provider_loading_progress_wrapper.dart';
import 'package:dio_hub/common/wrappers/scroll_to_top_wrapper.dart';
import 'package:dio_hub/providers/repository/branch_provider.dart';
import 'package:dio_hub/providers/repository/readme_provider.dart';
import 'package:dio_hub/providers/repository/repository_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:provider/provider.dart';

class RepositoryReadme extends StatefulWidget {
  const RepositoryReadme(this.repoURL, {super.key});

  final String? repoURL;

  @override
  RepositoryReadmeState createState() => RepositoryReadmeState();
}

class RepositoryReadmeState extends State<RepositoryReadme>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ProviderLoadingProgressWrapper<RepoReadmeProvider>(
        loadingBuilder: (final BuildContext context) => const Padding(
          padding: EdgeInsets.only(top: 48),
          child: LoadingIndicator(),
        ),
        childBuilder:
            (final BuildContext context, final RepoReadmeProvider value) =>
                ScrollToTopWrapper(
          builder: (final BuildContext context,
                  final ScrollViewProperties properties,) =>
              SingleChildScrollView(
            child: MarkdownRenderAPI(
              value.data!.content!,
              repoContext:
                  Provider.of<RepositoryProvider>(context).data.fullName,
              branch: Provider.of<RepoBranchProvider>(context).currentSHA,
            ),
          ),
        ),
      ),
    );
  }
}
