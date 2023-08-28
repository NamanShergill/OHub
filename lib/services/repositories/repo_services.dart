import 'package:dio_hub/app/Dio/dio.dart';
import 'package:dio_hub/graphql/graphql.dart';
import 'package:dio_hub/models/commits/commit_model.dart';
import 'package:dio_hub/models/repositories/branch_list_model.dart';
import 'package:dio_hub/models/repositories/branch_model.dart';
import 'package:dio_hub/models/repositories/commit_list_model.dart';
import 'package:dio_hub/models/repositories/readme_model.dart';
import 'package:dio_hub/models/repositories/repository_model.dart';
import 'package:dio_hub/utils/type_cast.dart';

class RepositoryServices {
  RepositoryServices({
    required this.name,
    required this.owner,
  });
  final String owner;
  final String name;

  static final GraphqlHandler _gqlHandler =
      GraphqlHandler(apiLogSettings: APILoggingSettings.comprehensive());
  static final RESTHandler _restHandler = RESTHandler();

  Future<PinnedIssues$Query$Repository$PinnedIssues> getPinnedIssues() async {
    final response = await _gqlHandler.query(
      PinnedIssuesQuery(
        variables: PinnedIssuesArguments(
          name: name,
          owner: owner,
        ),
      ),
    );

    return PinnedIssues$Query.fromJson(response.data!)
        .repository!
        .pinnedIssues!;
  }

  // Ref: https://docs.github.com/en/rest/reference/repos#get-a-repository
  static Future<RepositoryModel> fetchRepository(
    final String url, {
    final bool refresh = false,
  }) async {
    final response = await _restHandler.get(
      url,
      refreshCache: refresh,
    );
    return RepositoryModel.fromJson(response.data);
  }

  // Ref: https://docs.github.com/en/rest/reference/repos#get-a-repository-readme
  static Future<RepositoryReadmeModel> fetchReadme(
    final String repoUrl, {
    final String? branch,
  }) async {
    final response = await _restHandler.get(
      '$repoUrl/readme',
      queryParameters: {
        'ref': branch,
      },
    );
    return RepositoryReadmeModel.fromJson(response.data);
  }

  // Ref: https://docs.github.com/en/rest/reference/repos#get-a-branch
  static Future<BranchModel> fetchBranch(final String branchUrl) async {
    final response = await _restHandler.get(branchUrl);
    return BranchModel.fromJson(response.data);
  }

  // Ref: https://docs.github.com/en/rest/reference/repos#list-branches
  static Future<List<RepoBranchListItemModel>> fetchBranchList(
    final String repoURL,
    final int pageNumber,
    final int perPage, {
    final bool refresh = false,
  }) async {
    final response = await _restHandler.get(
      '$repoURL/branches',
      queryParameters: {'per_page': perPage, 'page': pageNumber},
      refreshCache: refresh,
    );
    return listTypeCast<JsonMap>(response.data)
        .map(RepoBranchListItemModel.fromJson)
        .toList();
  }

  // Ref: https://docs.github.com/en/rest/reference/repos#list-commits
  static Future<List<CommitListModel>> getCommitsList({
    required final String repoURL,
    final String? path,
    final String? sha,
    final int? pageNumber,
    final int? pageSize,
    final String? author,
    final bool refresh = false,
  }) async {
    final queryParams = <String, dynamic>{
      'path': path,
      'per_page': pageSize,
      'page': pageNumber,
      'sha': sha,
    };
    if (author != null) {
      queryParams['author'] = author;
    }
    final response = await _restHandler.get<List>(
      '$repoURL/commits',
      queryParameters: queryParams,
      refreshCache: refresh,
    );
    // ignore: unnecessary_lambdas
    return response.data!.map((final e) => CommitListModel.fromJson(e)).toList();
  }

  // Ref: https://docs.github.com/en/rest/reference/repos#get-a-commit
  static Future<CommitModel> getCommit(
    final String commitURL, {
    final bool refresh = false,
  }) async {
    final response = await _restHandler.get(
      commitURL,
      refreshCache: refresh,
    );
    return CommitModel.fromJson(response.data);
  }

  // Ref: https://docs.github.com/en/rest/reference/repos#get-repository-permissions-for-a-user
  // static Future<bool> checkUserRepoPerms(String login, String? repoURL) async {
  //   final response = await request(
  //     applyBaseURL: false,
  //     showPopup: false,
  //     cacheOptions: CacheManager.defaultCache(),
  //   )
  //       .get(
  //     '$repoURL/collaborators/$login/permission',
  //     options: Options(
  //       validateStatus: (status) {
  //         return status! < 500;
  //       },
  //     ),
  //   );
  //   if (response.statusCode == 200 || response.statusCode == 304) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  static Future<List<IssueTemplates$Query$Repository$IssueTemplates>>
      getIssueTemplates(final String name, final String owner) async {
    final res = await _gqlHandler.query(
      IssueTemplatesQuery(
        variables: IssueTemplatesArguments(name: name, owner: owner),
      ),
    );
    return IssueTemplates$Query.fromJson(res.data!).repository!.issueTemplates!;
  }

  // Ref: https://docs.github.com/en/rest/reference/activity#check-if-a-repository-is-starred-by-the-authenticated-user
  static Future<HasStarred$Query$Repository> isStarred(
    final String owner,
    final String name,
  ) async {
    final res = await _gqlHandler.query(
      HasStarredQuery(variables: HasStarredArguments(name: name, owner: owner)),
      refreshCache: true,
    );
    return HasStarred$Query.fromJson(res.data!).repository!;
  }

  // Ref: https://docs.github.com/en/rest/reference/activity#star-a-repository-for-the-authenticated-user
  static Future<bool> changeStar(
    final String owner,
    final String name, {
    required final bool isStarred,
  }) async {
    final endpoint = '/user/starred/$owner/$name';
    final res = isStarred
        ? await _restHandler.delete(endpoint)
        : await _restHandler.put(endpoint);
    if (res.statusCode == 204) {
      return !isStarred;
    } else {
      return isStarred;
    }
  }

  static Future<HasWatched$Query$Repository> isSubscribed(
    final String owner,
    final String name,
  ) async =>
      HasWatched$Query.fromJson(
        (await _gqlHandler.query(
          HasWatchedQuery(
            variables: HasWatchedArguments(owner: owner, name: name),
          ),
        ))
            .data!,
      ).repository!;

  static Future<bool> subscribeToRepo(
    final String owner,
    final String name, {
    required final bool isSubscribing,
    final bool ignored = false,
  }) async {
    final res = isSubscribing
        ? await _restHandler.put(
            '/repos/$owner/$name/subscription',
            data: {
              if (ignored) 'ignored': true,
              if (!ignored) 'subscribed': true,
            },
          )
        : await _restHandler.delete(
            '/repos/$owner/$name/subscription',
          );
    if ((isSubscribing && res.statusCode == 200) ||
        (!isSubscribing && res.statusCode == 204)) {
      return !isSubscribing;
    } else {
      return isSubscribing;
    }
  }
}
