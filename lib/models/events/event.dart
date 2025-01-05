import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

// Common fields shared by all events
@freezed
class CommonFields with _$CommonFields {
  const factory CommonFields({
    required int id,
    required String type,
    required Actor actor,
    required Repo repo,
    required bool public,
    required String createdAt,
    Organization? org,
  }) = _CommonFields;

  factory CommonFields.fromJson(Map<String, dynamic> json) =>
      _$CommonFieldsFromJson(json);
}

// Actor class
@freezed
class Actor with _$Actor {
  const factory Actor({
    required int id,
    required String login,
    String? gravatarId,
    required String avatarUrl,
    required String url,
  }) = _Actor;

  factory Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);
}

// Repo class
@freezed
class Repo with _$Repo {
  const factory Repo({
    required int id,
    required String name,
    required String url,
  }) = _Repo;

  factory Repo.fromJson(Map<String, dynamic> json) => _$RepoFromJson(json);
}

// Organization class
@freezed
class Organization with _$Organization {
  const factory Organization({
    required int id,
    required String login,
    String? gravatarId,
    required String avatarUrl,
    required String url,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
}

// Specific payload classes and event classes

// CommitCommentEvent
@freezed
class CommitCommentPayload with _$CommitCommentPayload {
  const factory CommitCommentPayload({
    required String action,
    required Comment comment,
  }) = _CommitCommentPayload;

  factory CommitCommentPayload.fromJson(Map<String, dynamic> json) =>
      _$CommitCommentPayloadFromJson(json);
}

@freezed
class Comment with _$Comment {
  const factory Comment({
    required String body,
    required String htmlUrl,
    required String id, // Example of an additional property
    required String nodeId,
    required Actor user,
    required String createdAt,
    required String updatedAt,
    // Add other fields as necessary
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}

@freezed
class CommitCommentEvent with _$CommitCommentEvent {
  const factory CommitCommentEvent({
    required CommonFields commonFields,
    required CommitCommentPayload payload,
  }) = _CommitCommentEvent;

  factory CommitCommentEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = CommitCommentPayload.fromJson(json['payload']);
    return CommitCommentEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// CreateEvent
@freezed
class CreatePayload with _$CreatePayload {
  const factory CreatePayload({
    required String ref,
    required String refType,
    String? masterBranch,
    String? description,
    required String pusherType,
  }) = _CreatePayload;

  factory CreatePayload.fromJson(Map<String, dynamic> json) =>
      _$CreatePayloadFromJson(json);
}

@freezed
class CreateEvent with _$CreateEvent {
  const factory CreateEvent({
    required CommonFields commonFields,
    required CreatePayload payload,
  }) = _CreateEvent;

  factory CreateEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = CreatePayload.fromJson(json['payload']);
    return CreateEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// DeleteEvent
@freezed
class DeletePayload with _$DeletePayload {
  const factory DeletePayload({
    required String ref,
    required String refType,
  }) = _DeletePayload;

  factory DeletePayload.fromJson(Map<String, dynamic> json) =>
      _$DeletePayloadFromJson(json);
}

@freezed
class DeleteEvent with _$DeleteEvent {
  const factory DeleteEvent({
    required CommonFields commonFields,
    required DeletePayload payload,
  }) = _DeleteEvent;

  factory DeleteEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = DeletePayload.fromJson(json['payload']);
    return DeleteEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// ForkEvent
@freezed
class ForkPayload with _$ForkPayload {
  const factory ForkPayload({
    required Repo forkee,
  }) = _ForkPayload;

  factory ForkPayload.fromJson(Map<String, dynamic> json) =>
      _$ForkPayloadFromJson(json);
}

@freezed
class ForkEvent with _$ForkEvent {
  const factory ForkEvent({
    required CommonFields commonFields,
    required ForkPayload payload,
  }) = _ForkEvent;

  factory ForkEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = ForkPayload.fromJson(json['payload']);
    return ForkEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// GollumEvent
@freezed
class GollumPayload with _$GollumPayload {
  const factory GollumPayload({
    required List<Page> pages,
  }) = _GollumPayload;

  factory GollumPayload.fromJson(Map<String, dynamic> json) =>
      _$GollumPayloadFromJson(json);
}

@freezed
class Page with _$Page {
  const factory Page({
    required String pageName,
    required String title,
    required String action,
    required String sha,
    required String htmlUrl,
  }) = _Page;

  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);
}

@freezed
class GollumEvent with _$GollumEvent {
  const factory GollumEvent({
    required CommonFields commonFields,
    required GollumPayload payload,
  }) = _GollumEvent;

  factory GollumEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = GollumPayload.fromJson(json['payload']);
    return GollumEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// IssueCommentEvent
@freezed
class IssueCommentPayload with _$IssueCommentPayload {
  const factory IssueCommentPayload({
    required String action,
    Map<String, dynamic>? changes,
    required Issue issue,
    required Comment comment,
  }) = _IssueCommentPayload;

  factory IssueCommentPayload.fromJson(Map<String, dynamic> json) =>
      _$IssueCommentPayloadFromJson(json);
}

@freezed
class Issue with _$Issue {
  const factory Issue({
    required int id,
    required String title,
    required String state,
    required String htmlUrl,
    required int number,
    required Actor user,
    required String createdAt,
    required String updatedAt,
    String? closedAt,
    // Add other fields as necessary
  }) = _Issue;

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);
}

@freezed
class IssueCommentEvent with _$IssueCommentEvent {
  const factory IssueCommentEvent({
    required CommonFields commonFields,
    required IssueCommentPayload payload,
  }) = _IssueCommentEvent;

  factory IssueCommentEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = IssueCommentPayload.fromJson(json['payload']);
    return IssueCommentEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// IssuesEvent
@freezed
class IssuesPayload with _$IssuesPayload {
  const factory IssuesPayload({
    required String action,
    required Issue issue,
    Map<String, dynamic>? changes,
    Actor? assignee,
    Label? label,
  }) = _IssuesPayload;

  factory IssuesPayload.fromJson(Map<String, dynamic> json) =>
      _$IssuesPayloadFromJson(json);
}

@freezed
class Label with _$Label {
  const factory Label({
    required int id,
    required String name,
    required String color,
    String? description,
    // Add other fields as necessary
  }) = _Label;

  factory Label.fromJson(Map<String, dynamic> json) => _$LabelFromJson(json);
}

@freezed
class IssuesEvent with _$IssuesEvent {
  const factory IssuesEvent({
    required CommonFields commonFields,
    required IssuesPayload payload,
  }) = _IssuesEvent;

  factory IssuesEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = IssuesPayload.fromJson(json['payload']);
    return IssuesEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// MemberEvent
@freezed
class MemberPayload with _$MemberPayload {
  const factory MemberPayload({
    required String action,
    required Actor member,
    Map<String, dynamic>? changes,
  }) = _MemberPayload;

  factory MemberPayload.fromJson(Map<String, dynamic> json) =>
      _$MemberPayloadFromJson(json);
}

@freezed
class MemberEvent with _$MemberEvent {
  const factory MemberEvent({
    required CommonFields commonFields,
    required MemberPayload payload,
  }) = _MemberEvent;

  factory MemberEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = MemberPayload.fromJson(json['payload']);
    return MemberEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// PublicEvent
@freezed
class PublicPayload with _$PublicPayload {
  const factory PublicPayload() = _PublicPayload;

  factory PublicPayload.fromJson(Map<String, dynamic> json) =>
      _$PublicPayloadFromJson(json);
}

@freezed
class PublicEvent with _$PublicEvent {
  const factory PublicEvent({
    required CommonFields commonFields,
    required PublicPayload payload,
  }) = _PublicEvent;

  factory PublicEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = PublicPayload.fromJson(json['payload']);
    return PublicEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// PullRequestEvent
@freezed
class PullRequestPayload with _$PullRequestPayload {
  const factory PullRequestPayload({
    required String action,
    required int number,
    Map<String, dynamic>? changes,
    required PullRequest pullRequest,
    String? reason,
  }) = _PullRequestPayload;

  factory PullRequestPayload.fromJson(Map<String, dynamic> json) =>
      _$PullRequestPayloadFromJson(json);
}

// PullRequest class (complete all properties as per GitHub API)
@freezed
class PullRequest with _$PullRequest {
  const factory PullRequest({
    required int id,
    required String htmlUrl,
    required String state,
    required String title,
    required Actor user,
    required String createdAt,
    required String updatedAt,
    String? mergedAt,
    String? closedAt,
    // Add other fields as necessary
  }) = _PullRequest;

  factory PullRequest.fromJson(Map<String, dynamic> json) =>
      _$PullRequestFromJson(json);
}

@freezed
class PullRequestEvent with _$PullRequestEvent {
  const factory PullRequestEvent({
    required CommonFields commonFields,
    required PullRequestPayload payload,
  }) = _PullRequestEvent;

  factory PullRequestEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = PullRequestPayload.fromJson(json['payload']);
    return PullRequestEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// PullRequestReviewEvent
@freezed
class PullRequestReviewPayload with _$PullRequestReviewPayload {
  const factory PullRequestReviewPayload({
    required String action,
    required PullRequest pullRequest,
    required Review review,
  }) = _PullRequestReviewPayload;

  factory PullRequestReviewPayload.fromJson(Map<String, dynamic> json) =>
      _$PullRequestReviewPayloadFromJson(json);
}

// Review class (complete all properties as per GitHub API)
@freezed
class Review with _$Review {
  const factory Review({
    required int id,
    required String body,
    required String state,
    required Actor user,
    required String htmlUrl,
    required String submittedAt,
    // Add other fields as necessary
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}

@freezed
class PullRequestReviewEvent with _$PullRequestReviewEvent {
  const factory PullRequestReviewEvent({
    required CommonFields commonFields,
    required PullRequestReviewPayload payload,
  }) = _PullRequestReviewEvent;

  factory PullRequestReviewEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = PullRequestReviewPayload.fromJson(json['payload']);
    return PullRequestReviewEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// PullRequestReviewCommentEvent
@freezed
class PullRequestReviewCommentPayload with _$PullRequestReviewCommentPayload {
  const factory PullRequestReviewCommentPayload({
    required String action,
    Map<String, dynamic>? changes,
    required PullRequest pullRequest,
    required Comment comment,
  }) = _PullRequestReviewCommentPayload;

  factory PullRequestReviewCommentPayload.fromJson(Map<String, dynamic> json) =>
      _$PullRequestReviewCommentPayloadFromJson(json);
}

@freezed
class PullRequestReviewCommentEvent with _$PullRequestReviewCommentEvent {
  const factory PullRequestReviewCommentEvent({
    required CommonFields commonFields,
    required PullRequestReviewCommentPayload payload,
  }) = _PullRequestReviewCommentEvent;

  factory PullRequestReviewCommentEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = PullRequestReviewCommentPayload.fromJson(json['payload']);
    return PullRequestReviewCommentEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// PullRequestReviewThreadEvent
@freezed
class PullRequestReviewThreadPayload with _$PullRequestReviewThreadPayload {
  const factory PullRequestReviewThreadPayload({
    required String action,
    required PullRequest pullRequest,
    required Thread thread,
  }) = _PullRequestReviewThreadPayload;

  factory PullRequestReviewThreadPayload.fromJson(Map<String, dynamic> json) =>
      _$PullRequestReviewThreadPayloadFromJson(json);
}

@freezed
class Thread with _$Thread {
  const factory Thread({
    required String id,
    required String nodeId,
    required String htmlUrl,
    required List<Comment> comments,
    // Add other fields as necessary
  }) = _Thread;

  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);
}

@freezed
class PullRequestReviewThreadEvent with _$PullRequestReviewThreadEvent {
  const factory PullRequestReviewThreadEvent({
    required CommonFields commonFields,
    required PullRequestReviewThreadPayload payload,
  }) = _PullRequestReviewThreadEvent;

  factory PullRequestReviewThreadEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = PullRequestReviewThreadPayload.fromJson(json['payload']);
    return PullRequestReviewThreadEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// PushEvent
@freezed
class PushPayload with _$PushPayload {
  const factory PushPayload({
    required int pushId,
    required int size,
    required int distinctSize,
    required String ref,
    required String head,
    required String before,
    List<Commit>? commits,
  }) = _PushPayload;

  factory PushPayload.fromJson(Map<String, dynamic> json) =>
      _$PushPayloadFromJson(json);
}

@freezed
class Commit with _$Commit {
  const factory Commit({
    required String sha,
    required String message,
    required CommitAuthor author,
    required String url,
    required bool distinct,
  }) = _Commit;

  factory Commit.fromJson(Map<String, dynamic> json) => _$CommitFromJson(json);
}

@freezed
class CommitAuthor with _$CommitAuthor {
  const factory CommitAuthor({
    required String name,
    required String email,
  }) = _CommitAuthor;

  factory CommitAuthor.fromJson(Map<String, dynamic> json) =>
      _$CommitAuthorFromJson(json);
}

@freezed
class PushEvent with _$PushEvent {
  const factory PushEvent({
    required CommonFields commonFields,
    required PushPayload payload,
  }) = _PushEvent;

  factory PushEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = PushPayload.fromJson(json['payload']);
    return PushEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// ReleaseEvent
@freezed
class ReleasePayload with _$ReleasePayload {
  const factory ReleasePayload({
    required String action,
    Map<String, dynamic>? changes,
    required Release release,
  }) = _ReleasePayload;

  factory ReleasePayload.fromJson(Map<String, dynamic> json) =>
      _$ReleasePayloadFromJson(json);
}

@freezed
class Release with _$Release {
  const factory Release({
    required String id,
    required String tagName,
    required String name,
    required bool draft,
    required bool prerelease,
    required Actor author,
    required String createdAt,
    required String publishedAt,
    // Add other fields as necessary
  }) = _Release;

  factory Release.fromJson(Map<String, dynamic> json) =>
      _$ReleaseFromJson(json);
}

@freezed
class ReleaseEvent with _$ReleaseEvent {
  const factory ReleaseEvent({
    required CommonFields commonFields,
    required ReleasePayload payload,
  }) = _ReleaseEvent;

  factory ReleaseEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = ReleasePayload.fromJson(json['payload']);
    return ReleaseEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// SponsorshipEvent
@freezed
class SponsorshipPayload with _$SponsorshipPayload {
  const factory SponsorshipPayload({
    required String action,
    required String effectiveDate,
    Map<String, dynamic>? changes,
  }) = _SponsorshipPayload;

  factory SponsorshipPayload.fromJson(Map<String, dynamic> json) =>
      _$SponsorshipPayloadFromJson(json);
}

@freezed
class SponsorshipEvent with _$SponsorshipEvent {
  const factory SponsorshipEvent({
    required CommonFields commonFields,
    required SponsorshipPayload payload,
  }) = _SponsorshipEvent;

  factory SponsorshipEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = SponsorshipPayload.fromJson(json['payload']);
    return SponsorshipEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// WatchEvent
@freezed
class WatchPayload with _$WatchPayload {
  const factory WatchPayload({
    required String action,
  }) = _WatchPayload;

  factory WatchPayload.fromJson(Map<String, dynamic> json) =>
      _$WatchPayloadFromJson(json);
}

@freezed
class WatchEvent with _$WatchEvent {
  const factory WatchEvent({
    required CommonFields commonFields,
    required WatchPayload payload,
  }) = _WatchEvent;

  factory WatchEvent.fromJson(Map<String, dynamic> json) {
    final commonFields = CommonFields.fromJson(json);
    final payload = WatchPayload.fromJson(json['payload']);
    return WatchEvent(
      commonFields: commonFields,
      payload: payload,
    );
  }
}

// Parsing function
dynamic parseEvent(Map<String, dynamic> json) {
  final String eventType = json['type'];
  switch (eventType) {
    case 'CommitCommentEvent':
      return CommitCommentEvent.fromJson(json);
    case 'CreateEvent':
      return CreateEvent.fromJson(json);
    case 'DeleteEvent':
      return DeleteEvent.fromJson(json);
    case 'ForkEvent':
      return ForkEvent.fromJson(json);
    case 'GollumEvent':
      return GollumEvent.fromJson(json);
    case 'IssueCommentEvent':
      return IssueCommentEvent.fromJson(json);
    case 'IssuesEvent':
      return IssuesEvent.fromJson(json);
    case 'MemberEvent':
      return MemberEvent.fromJson(json);
    case 'PublicEvent':
      return PublicEvent.fromJson(json);
    case 'PullRequestEvent':
      return PullRequestEvent.fromJson(json);
    case 'PullRequestReviewEvent':
      return PullRequestReviewEvent.fromJson(json);
    case 'PullRequestReviewCommentEvent':
      return PullRequestReviewCommentEvent.fromJson(json);
    case 'PullRequestReviewThreadEvent':
      return PullRequestReviewThreadEvent.fromJson(json);
    case 'PushEvent':
      return PushEvent.fromJson(json);
    case 'ReleaseEvent':
      return ReleaseEvent.fromJson(json);
    case 'SponsorshipEvent':
      return SponsorshipEvent.fromJson(json);
    case 'WatchEvent':
      return WatchEvent.fromJson(json);
    default:
      throw Exception('Unknown event type: $eventType');
  }
}
