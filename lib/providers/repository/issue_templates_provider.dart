import 'package:built_collection/built_collection.dart';
import 'package:diohub/graphql/queries/issues_pulls/__generated__/issue_templates.query.data.gql.dart';
import 'package:diohub/providers/proxy_provider.dart';
import 'package:diohub/providers/repository/repository_provider.dart';
import 'package:diohub/services/repositories/repo_services.dart';

class IssueTemplateProvider extends ProxyProvider<
    BuiltList<GissueTemplatesData_repository_issueTemplates>,
    RepositoryProvider> {
  @override
  Future<BuiltList<GissueTemplatesData_repository_issueTemplates>> setInitData({
    final bool isInitialisation = false,
  }) async =>
      RepositoryServices.getIssueTemplates(
        parentProvider.data.name!,
        parentProvider.data.owner!.login!,
      );
}
