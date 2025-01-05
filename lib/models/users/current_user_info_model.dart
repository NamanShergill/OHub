// // Todo: Redo Model. Ref: https://app.quicktype.io/
//
// import 'package:diohub/models/users/user_info_model.dart';
// // ignore_for_file: type=lint
//
// class CurrentUserInfoModel extends UserInfoModel {
//   int? privateGists;
//   int? totalPrivateRepos;
//   int? ownedPrivateRepos;
//   int? diskUsage;
//   int? collaborators;
//   bool? twoFactorAuthentication;
//   Plan? plan;
//
//   CurrentUserInfoModel(
//       {this.privateGists,
//       this.totalPrivateRepos,
//       this.ownedPrivateRepos,
//       this.diskUsage,
//       this.collaborators,
//       this.twoFactorAuthentication,
//       this.plan});
//
//   CurrentUserInfoModel.fromJson(Map<String, dynamic> json) {
//     login = json['login'];
//     id = json['id'];
//     nodeId = json['node_id'];
//     avatarUrl = json['avatar_url'];
//     gravatarId = json['gravatar_id'];
//     url = json['url'];
//     htmlUrl = json['html_url'];
//     followersUrl = json['followers_url'];
//     followingUrl = json['following_url'];
//     gistsUrl = json['gists_url'];
//     starredUrl = json['starred_url'];
//     subscriptionsUrl = json['subscriptions_url'];
//     organizationsUrl = json['organizations_url'];
//     reposUrl = json['repos_url'];
//     eventsUrl = json['events_url'];
//     receivedEventsUrl = json['received_events_url'];
//     if (json['type'] == 'User')
//       type = Type.user;
//     else if (json['type'] == 'Organization') type = Type.org;
//     siteAdmin = json['site_admin'];
//     name = json['name'];
//     company = json['company'];
//     blog = json['blog'];
//     location = json['location'];
//     email = json['email'];
//     hireable = json['hireable'];
//     bio = json['bio'];
//     twitterUsername = json['twitter_username'];
//     publicRepos = json['public_repos'];
//     publicGists = json['public_gists'];
//     followers = json['followers'];
//     following = json['following'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     privateGists = json['private_gists'];
//     totalPrivateRepos = json['total_private_repos'];
//     ownedPrivateRepos = json['owned_private_repos'];
//     diskUsage = json['disk_usage'];
//     collaborators = json['collaborators'];
//     twoFactorAuthentication = json['two_factor_authentication'];
//     plan = json['plan'] != null ? new Plan.fromJson(json['plan']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['login'] = this.login;
//     data['id'] = this.id;
//     data['node_id'] = this.nodeId;
//     data['avatar_url'] = this.avatarUrl;
//     data['gravatar_id'] = this.gravatarId;
//     data['url'] = this.url;
//     data['html_url'] = this.htmlUrl;
//     data['followers_url'] = this.followersUrl;
//     data['following_url'] = this.followingUrl;
//     data['gists_url'] = this.gistsUrl;
//     data['starred_url'] = this.starredUrl;
//     data['subscriptions_url'] = this.subscriptionsUrl;
//     data['organizations_url'] = this.organizationsUrl;
//     data['repos_url'] = this.reposUrl;
//     data['events_url'] = this.eventsUrl;
//     data['received_events_url'] = this.receivedEventsUrl;
//     data['type'] = this.type;
//     data['site_admin'] = this.siteAdmin;
//     data['name'] = this.name;
//     data['company'] = this.company;
//     data['blog'] = this.blog;
//     data['location'] = this.location;
//     data['email'] = this.email;
//     data['hireable'] = this.hireable;
//     data['bio'] = this.bio;
//     data['twitter_username'] = this.twitterUsername;
//     data['public_repos'] = this.publicRepos;
//     data['public_gists'] = this.publicGists;
//     data['followers'] = this.followers;
//     data['following'] = this.following;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['private_gists'] = this.privateGists;
//     data['total_private_repos'] = this.totalPrivateRepos;
//     data['owned_private_repos'] = this.ownedPrivateRepos;
//     data['disk_usage'] = this.diskUsage;
//     data['collaborators'] = this.collaborators;
//     data['two_factor_authentication'] = this.twoFactorAuthentication;
//     if (this.plan != null) {
//       data['plan'] = this.plan!.toJson();
//     }
//     return data;
//   }
// }
//
// class Plan {
//   String? name;
//   int? space;
//   int? privateRepos;
//   int? collaborators;
//
//   Plan({this.name, this.space, this.privateRepos, this.collaborators});
//
//   Plan.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     space = json['space'];
//     privateRepos = json['private_repos'];
//     collaborators = json['collaborators'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['name'] = this.name;
//     data['space'] = this.space;
//     data['private_repos'] = this.privateRepos;
//     data['collaborators'] = this.collaborators;
//     return data;
//   }
// }
