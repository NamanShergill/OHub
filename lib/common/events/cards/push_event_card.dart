import 'package:auto_route/auto_route.dart';
import 'package:dio_hub/app/settings/palette.dart';
import 'package:dio_hub/common/events/cards/base_card.dart';
import 'package:dio_hub/common/misc/branch_label.dart';
import 'package:dio_hub/common/misc/custom_expansion_tile.dart';
import 'package:dio_hub/models/events/events_model.dart' hide Key;
import 'package:dio_hub/routes/router.gr.dart';
import 'package:dio_hub/style/border_radiuses.dart';
import 'package:dio_hub/style/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PushEventCard extends StatelessWidget {
  const PushEventCard(this.event, this.data, {super.key});
  final EventsModel event;
  final Payload data;
  @override
  Widget build(final BuildContext context) => BaseEventCard(
        onTap: () {
          AutoRouter.of(context).push(
            RepositoryRoute(
              repositoryURL: event.repo!.url!,
              branch: data.ref!.split('/').last,
              index: 2,
            ),
          );
        },
        userLogin: event.actor!.login,
        date: event.createdAt,
        childPadding: const EdgeInsets.all(8),
        actor: event.actor!.login,
        headerText: [
          TextSpan(
            text: ' pushed to ',
            style: AppThemeTextStyles.eventCardHeaderMed(context),
          ),
          TextSpan(
            text: event.repo!.name,
            style: AppThemeTextStyles.eventCardHeaderBold(context),
          ),
        ],
        avatarUrl: event.actor!.avatarUrl,
        child: CustomExpansionTile(
          expanded: false,
          title: Row(
            children: [
              Text(
                '${data.size} commit${data.size! > 1 ? 's' : ''} to',
                style: AppThemeTextStyles.eventCardChildTitleSmall(context),
              ),
              Flexible(
                child: BranchLabel(
                  data.ref!.split('/').last,
                  size: 12,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: data.commits!.length,
                separatorBuilder: (final context, final index) => const Divider(
                  height: 0,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (final context, final index) => InkWell(
                  borderRadius: smallBorderRadius,
                  onTap: () {
                    AutoRouter.of(context).push(
                      CommitInfoRoute(
                        commitURL: data.commits![index].url!,
                      ),
                    );
                  },
                  onLongPress: () {
                    AutoRouter.of(context).push(
                      RepositoryRoute(
                        index: 2,
                        branch: data.ref!.split('/').last,
                        repositoryURL: event.repo!.url!,
                        initSHA: data.commits![index].sha,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text:
                                '#${data.commits![index].sha!.substring(0, 6)}',
                            style: TextStyle(
                              color: Provider.of<PaletteSettings>(context)
                                  .currentSetting
                                  .accent,
                            ),
                          ),
                          TextSpan(text: '  ${data.commits![index].message!}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
