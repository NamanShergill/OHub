import 'package:dio_hub/app/settings/palette.dart';
import 'package:dio_hub/common/animations/size_expanded_widget.dart';
import 'package:dio_hub/common/misc/info_card.dart';
import 'package:dio_hub/common/misc/loading_indicator.dart';
import 'package:dio_hub/common/misc/repository_card.dart';
import 'package:dio_hub/common/misc/shimmer_widget.dart';
import 'package:dio_hub/common/wrappers/api_wrapper_widget.dart';
import 'package:dio_hub/graphql/graphql.dart';
import 'package:dio_hub/models/repositories/repository_model.dart';
import 'package:dio_hub/models/users/user_info_model.dart';
import 'package:dio_hub/services/users/user_info_service.dart';
import 'package:dio_hub/style/border_radiuses.dart';
import 'package:dio_hub/utils/to_hex_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class UserOverviewScreen extends StatelessWidget {
  const UserOverviewScreen(this.userInfoModel, {Key? key}) : super(key: key);
  final UserInfoModel? userInfoModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Provider.of<PaletteSettings>(context).currentSetting.primary,
      child: Column(
        children: [
          Flexible(
            child: WrappedCollection(
              children: [
                InfoCard(
                  title: 'Pinned Repos',
                  mode: InfoCardMode.expanded,
                  child: APIWrapper<
                      List<GetUserPinnedRepos$Query$User$PinnedItems$Edges?>>(
                    apiCall: ({required refresh}) =>
                        UserInfoService.getUserPinnedRepos(
                            userInfoModel!.login!),
                    responseBuilder: (context, data) {
                      return data.isEmpty
                          ? const Text('No Pinned items.')
                          : SizeExpandedSection(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final node = data[index]!.node
                                      as GetUserPinnedRepos$Query$User$PinnedItems$Edges$Node$Repository;
                                  return RepositoryCard(
                                    RepositoryModel(
                                      stargazersCount: node.stargazerCount,
                                      description: node.description,
                                      language:
                                          node.languages!.edges!.isNotEmpty
                                              ? node.languages?.edges?.first!
                                                      .node.name ??
                                                  'N/A'
                                              : 'N/A',
                                      owner: Owner(login: node.owner.login),
                                      name: node.name,
                                      private: false,
                                      url: node.url.toString().replaceFirst(
                                          'https://github.com',
                                          'https://api.github.com/repos'),
                                      updatedAt: node.updatedAt,
                                    ),
                                  );
                                },
                              ),
                            );
                    },
                    loadingBuilder: (context) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: LoadingIndicator(),
                      );
                    },
                  ),
                ),
                InfoCard(
                  title: 'Contribution Graph',
                  mode: InfoCardMode.expanded,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        SvgPicture.network(
                          'http://ghchart.rshah.org/${toHexString(Provider.of<PaletteSettings>(context).currentSetting.accent).substring(2)}/${userInfoModel!.login}',
                          placeholderBuilder: (context) {
                            return ShimmerWidget(
                              baseColor: Provider.of<PaletteSettings>(context)
                                  .currentSetting
                                  .secondary,
                              highlightColor: Colors.grey.shade800,
                              borderRadius: medBorderRadius,
                              child: Container(
                                height: 70,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                        // Row(
                        //   children: [
                        //     LinkText(
                        //       'https://ghchart.rshah.org/',
                        //       style: TextStyle(color: faded3(context)),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
