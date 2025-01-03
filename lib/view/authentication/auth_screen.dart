import 'package:auto_route/auto_route.dart';
import 'package:diohub/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:diohub/common/animations/size_expanded_widget.dart';
import 'package:diohub/common/const/app_info.dart';
import 'package:diohub/common/const/version_info.dart';
import 'package:diohub/routes/router.gr.dart';
import 'package:diohub/view/authentication/widgets/code_info_box.dart';
import 'package:diohub/view/authentication/widgets/error_popup.dart';
import 'package:diohub/view/authentication/widgets/login_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, this.onAuthenticated});
  final VoidCallback? onAuthenticated;

  @override
  Widget build(final BuildContext context) => SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizeExpandedSection(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AppLogoWidget(
                              size: MediaQuery.of(context).size.width * 0.3,
                            ),
                            const AppNameWidget(
                              size: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    child:
                        BlocConsumer<AuthenticationBloc, AuthenticationState>(
                      listener: (
                        final BuildContext context,
                        final AuthenticationState state,
                      ) async {
                        if (state is AuthenticationSuccessful) {
                          if (onAuthenticated != null) {
                            onAuthenticated!();
                          } else {
                            await AutoRouter.of(context).replace(HomeRoute());
                          }
                        }
                      },
                      builder: (
                        final BuildContext context,
                        final AuthenticationState state,
                      ) {
                        if (state is AuthenticationUnauthenticated) {
                          return const LoginPopup();
                        } else if (state is AuthenticationInitialized) {
                          return CodeInfoBox(state.deviceCodeModel);
                        } else if (state is AuthenticationError) {
                          return ErrorPopup(state.error);
                        }
                        return Container();
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                ],
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: VersionInfoWidget(),
              ),
            ],
          ),
        ),
      );
}
