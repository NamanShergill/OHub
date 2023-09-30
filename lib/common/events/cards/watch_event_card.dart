import 'package:dio_hub/common/events/cards/base_card.dart';
import 'package:dio_hub/common/misc/repository_card.dart';
import 'package:dio_hub/models/events/events_model.dart' hide Key;
import 'package:dio_hub/models/repositories/repository_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RepoEventCard extends StatelessWidget {
  const RepoEventCard(
    this.event,
    this.eventTextMiddle, {
    this.eventTextEnd,
    this.branch,
    this.repo,
    this.refresh = false,
    super.key,
  });
  final EventsModel event;
  final String eventTextMiddle;
  final RepositoryModel? repo;
  final String? eventTextEnd;
  final String? branch;
  final bool refresh;
  @override
  Widget build(final BuildContext context) => BaseEventCard(
        actor: event.actor!.login,
        headerText: <TextSpan>[
          TextSpan(text: ' $eventTextMiddle '),
          TextSpan(
            text: event.repo!.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (eventTextEnd != null) TextSpan(text: ' $eventTextEnd'),
        ],
        userLogin: event.actor!.login,
        date: event.createdAt,
        avatarUrl: event.actor!.avatarUrl,
        childPadding: EdgeInsets.zero,
        child: RepoCardLoading(
          repo != null ? repo!.url : event.repo!.url,
          repo != null ? repo!.name : event.repo!.name,
          elevation: 0,
          branch: branch,
          refresh: refresh,
        ),
      );
}
