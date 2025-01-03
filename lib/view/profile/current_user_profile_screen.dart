import 'package:diohub/common/wrappers/provider_loading_progress_wrapper.dart';
import 'package:diohub/graphql/queries/users/__generated__/user_info.data.gql.dart';
import 'package:diohub/models/users/current_user_info_model.dart';
import 'package:diohub/providers/users/current_user_provider.dart';
import 'package:diohub/view/profile/user_profile_screen.dart';
import 'package:flutter/material.dart';

// class CurrentUserProfileScreen extends StatelessWidget {
//   const CurrentUserProfileScreen({super.key});
//   @override
//   Widget build(final BuildContext context) =>
//       ProviderLoadingProgressWrapper<CurrentUserProvider>(
//         childBuilder:
//             (final BuildContext context, final CurrentUserProvider value) =>
//                 UserProfileScreen<GuserInfoData_user>(
//           value.data,
//           isCurrentUser: true,
//         ),
//       );
// }
