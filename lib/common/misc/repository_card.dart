import 'package:auto_route/auto_route.dart';
import 'package:diohub/common/misc/ink_pot.dart';
import 'package:diohub/common/misc/language_indicator.dart';
import 'package:diohub/common/misc/shimmer_widget.dart';
import 'package:diohub/common/wrappers/api_wrapper_widget.dart';
import 'package:diohub/models/repositories/repository_model.dart';
import 'package:diohub/routes/router.gr.dart';
import 'package:diohub/services/repositories/repo_services.dart';
import 'package:diohub/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class PaddedBuilder {
  const PaddedBuilder({
    required this.padding,
  });

  final EdgeInsets padding;

  Widget applyPadding(final Widget child) => Padding(
        padding: padding,
        child: child,
      );
}

class RepositoryCard extends StatelessWidget {
  const RepositoryCard(
    this.repo, {
    // this.isThemed = true,
    this.branch,
    // this.padding = const EdgeInsets.symmetric(vertical: 8),
    super.key,
  });

  final RepositoryModel? repo;

  // final bool isThemed;
  final String? branch;

  // final EdgeInsets padding;

  static const PaddedBuilder paddedBuilderData = PaddedBuilder(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  Column repoUnthemedWidget(final BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: repo!.private!,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Octicons.lock,
                          size:
                              context.textTheme.bodyLarge!.getIconSize(context),
                        ),
                      ),
                    ),
                    Text(
                      repo!.name!,
                      style: context.textTheme.bodyLarge,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Visibility(
                      visible: repo!.fork ?? false,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Octicons.repo_forked,
                            size: 12,
                            color: context.colorScheme.onSurface.asHint(),
                            // color: Provider.of<PaletteSettings>(
                            //   context,
                            // ).currentSetting.faded3,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            'Forked',
                            style: context.textTheme.bodyLarge?.asHint(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (repo?.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      repo!.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.asHint(),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(
            height: 8,
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              LanguageIndicator(
                repo!.language,
                // size: 11,
                // textStyle: AppThemeTextStyles.eventCardChildFooter(
                //   context,
                // ),
              ),
              if ((repo?.stargazersCount ?? 0) > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Octicons.star_fill,
                        size: 12,
                        color: context.colorScheme.onSurface.asHint(),
                        // color: Provider.of<PaletteSettings>(context)
                        //     .currentSetting
                        //     .faded3,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        repo!.stargazersCount!.toShortenedStr(),
                        style: context.textTheme.bodySmall?.asHint(),
                        // style: AppThemeTextStyles.eventCardChildFooter(
                        //   context,
                        // ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(
                width: 16,
              ),
              // Icon(
              //   Icons.update_rounded,
              //   size: 12,
              //   color: context.colorScheme.onSurface.asHint(),
              // ),
              // const SizedBox(
              //   width: 4,
              // ),
              // Text(
              //   getDate(repo!.updatedAt.toString()),
              //   style: context.textTheme.bodySmall?.asHint(),
              //   // style: AppThemeTextStyles.eventCardChildFooter(
              //   //   context,
              //   // ),
              // ),
            ],
          ),
        ],
      );

  @override
  Widget build(final BuildContext context) => InkPot(
        onTap: () async {
          await pushToRepo(context);
        },
        child: paddedBuilderData.applyPadding(
          repoUnthemedWidget(context),
        ),
      );

  Future<void> pushToRepo(final BuildContext context) async {
    await AutoRouter.of(context).push(
      RepositoryRoute(
        repositoryURL: repo!.url!,
        branch: branch,
      ),
    );
  }
}

class RepoCardLoading extends StatelessWidget {
  const RepoCardLoading(
    this.repoURL,
    this.repoName, {
    this.branch,
    this.refresh = false,
    super.key,
  });

  final String? repoURL;
  final String? repoName;

  // final double elevation;
  final bool refresh;
  final String? branch;

  @override
  Widget build(final BuildContext context) =>
      APIWrapper<RepositoryModel>.deferred(
        // fadeIntoView: false,
        apiCall: ({required final bool refresh}) async =>
            RepositoryServices.fetchRepository(repoURL!, refresh: refresh),
        loadingBuilder: (final BuildContext context) => buildLoading(),
        builder: (final BuildContext context, final RepositoryModel repo) =>
            RepositoryCard(repo, branch: branch),
      );

  Widget buildLoading() => RepositoryCard.paddedBuilderData.applyPadding(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              repoName!.split('/').last,
              // style: AppThemeTextStyles.eventCardChildTitle(context),
            ),
            const SizedBox(
              height: 8,
            ),
            ShimmerWidget.container(),
            const SizedBox(
              height: 4,
            ),
            ShimmerWidget.container(
              width: 200,
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      );
}
