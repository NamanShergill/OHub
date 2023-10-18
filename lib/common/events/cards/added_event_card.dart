import 'package:diohub/common/events/cards/base_card.dart';
import 'package:diohub/common/misc/profile_card.dart';
import 'package:diohub/common/misc/repository_card.dart';
import 'package:diohub/models/events/events_model.dart' hide Key;
import 'package:diohub/models/repositories/repository_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        children: <Widget>[
          ProfileCard(
            event.payload!.member!,
            compact: true,
          ),
          RepoCardLoading(
            repo != null ? repo!.url : event.repo!.url,
            repo != null ? repo!.name : event.repo!.name,
            // elevation: 0,
            branch: branch,
          ),
        ],
      );
}
