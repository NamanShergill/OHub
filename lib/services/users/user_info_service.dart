import 'package:dio/dio.dart';
import 'package:diohub/app/api_handler/dio.dart';
import 'package:diohub/graphql/queries/users/__generated__/user_info.data.gql.dart';
import 'package:diohub/graphql/queries/users/__generated__/user_info.req.gql.dart';
import 'package:diohub/graphql/queries/viewer/__generated__/viewer.query.data.gql.dart';
import 'package:diohub/graphql/queries/viewer/__generated__/viewer.query.req.gql.dart';
import 'package:diohub/models/repositories/repository_model.dart';
import 'package:diohub/models/users/user_info_model.dart';
import 'package:diohub/utils/type_cast.dart';

class UserInfoService {
  UserInfoService(this.login);

  static final GraphqlHandler _gqlHandler = GraphqlHandler();
  final String login;
  static final RESTHandler _restHandler = RESTHandler();

  // Ref: https://docs.github.com/en/rest/reference/users#get-the-authenticated-user
  static Future<GviewerInfoData_viewer> getViewerInfo() async {
    final GQLResponse response = await _gqlHandler.query(
      GviewerInfoReq(),
    );
    return GviewerInfoData.fromJson(response.data!)!.viewer;
  }

  // Ref: https://docs.github.com/en/rest/reference/repos#list-repositories-for-the-authenticated-user
  static Future<List<RepositoryModel>> getCurrentUserRepos(
    final int perPage,
    final int pageNumber, {
    required final bool refresh,
    final String? sort,
    final bool? ascending = false,
  }) async {
    final Response<List<dynamic>> response =
        await _restHandler.get<List<dynamic>>(
      '/user/repos',
      queryParameters: <String, dynamic>{
        if (sort != null) 'sort': sort,
        if (ascending != null) 'direction': ascending ? 'asc' : 'desc',
        'per_page': perPage,
        'type': 'owner',
        'page': pageNumber,
      },
      refreshCache: refresh,
    );
    return response.data!
        // ignore: unnecessary_lambdas
        .map((final dynamic e) => RepositoryModel.fromJson(e))
        .toList();
  }

  static Future<List<RepositoryModel>> getUserRepos(
    final String? username,
    final int perPage,
    final int pageNumber,
    final String? sort, {
    required final bool refresh,
  }) async {
    final Response<DynamicList> response = await _restHandler.get<DynamicList>(
      '/users/$username/repos',
      queryParameters: <String, dynamic>{
        'sort': 'updated',
        'per_page': perPage,
        'page': pageNumber,
        if (sort != null) 'sort': sort,
      },
      refreshCache: refresh,
    );
    final DynamicList unParsedData = response.data!;
    final List<RepositoryModel> data = unParsedData
        .map(
          // ignore: unnecessary_lambdas
          (final dynamic e) => RepositoryModel.fromJson(e),
        )
        .toList();
    return data;
  }

  static Future<UserInfoModel> getUserInfo(final String? login) async {
    final Response<TypeMap> response = await _restHandler.get<TypeMap>(
      '/users/$login',
    );
    return UserInfoModel.fromJson(response.data!);
  }

  static Future<List<GgetUserPinnedReposData_user_pinnedItems_edges?>>
      getUserPinnedRepos(final String user) async {
    final GQLResponse res = await _gqlHandler.query(
      GgetUserPinnedReposReq(
          (final GgetUserPinnedReposReqBuilder b) => b..vars.user = user),
    );
    return GgetUserPinnedReposData.fromJson(res.data!)!
        .user!
        .pinnedItems
        .edges!
        .toList();
  }

  static Future<List<GgetViewerOrgsData_viewer_organizations_edges?>>
      getViewerOrgs({required final bool refresh, final String? after}) async {
    final GQLResponse res = await _gqlHandler.query(
      GgetViewerOrgsReq(
          (final GgetViewerOrgsReqBuilder b) => b..vars.cursor = after),
      refreshCache: refresh,
    );
    return GgetViewerOrgsData.fromJson(res.data!)!
        .viewer
        .organizations
        .edges!
        .toList();
  }

  static Future<GfollowStatusInfoData_user> getFollowInfo(
    final String login,
  ) async =>
      GfollowStatusInfoData.fromJson(
        (await _gqlHandler.query(
          GfollowStatusInfoReq(
            (final GfollowStatusInfoReqBuilder b) => b..vars.user = login,
          ),
        ))
            .data!,
      )!
          .user!;

  static Future<GQLResponse> changeFollowStatus(
    final String id, {
    required final bool follow,
  }) async {
    if (follow) {
      return _gqlHandler.mutation(
        GfollowUserReq(
          (final GfollowUserReqBuilder b) => b..vars.user = id,
        ),
      );
    } else {
      return _gqlHandler.mutation(
        GunfollowUserReq(
          (final GunfollowUserReqBuilder b) => b..vars.user = id,
        ),
      );
    }
  }
}
