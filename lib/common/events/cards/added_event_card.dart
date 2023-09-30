import 'package:dio_hub/app/settings/palette.dart';
import 'package:dio_hub/common/events/cards/base_card.dart';
import 'package:dio_hub/common/misc/profile_card.dart';
import 'package:dio_hub/common/misc/repository_card.dart';
import 'package:dio_hub/models/events/events_model.dart' hide Key;
import 'package:dio_hub/models/repositories/repository_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddedEventCard extends StatelessWidget {
  const AddedEventCard(
    this.event,
    this.eventTextMiddle, {
    this.branch,
    this.repo,
    super.key,
  });
  final EventsModel event;
  final String eventTextMiddle;
  final RepositoryModel? repo;
  final String? branch;
  @override
  Widget build(final BuildContext context) => BaseEventCard(
        actor: event.actor!.login,
        headerText: <TextSpan>[
          TextSpan(text: ' $eventTextMiddle '),
          TextSpan(
            text: event.repo!.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
        userLogin: event.actor!.login,
        date: event.createdAt,
        avatarUrl: event.actor!.avatarUrl,
        childPadding: EdgeInsets.zero,
        child: ColoredBox(
          color: Provider.of<PaletteSettings>(context).currentSetting.secondary,
          child: Column(
            children: <Widget>[
              ProfileCard(
                event.payload!.member!,
                compact: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              const SizedBox(
                height: 8,
              ),
              RepoCardLoading(
                repo != null ? repo!.url : event.repo!.url,
                repo != null ? repo!.name : event.repo!.name,
                elevation: 0,
                branch: branch,
              ),
            ],
          ),
        ),
      );
}
