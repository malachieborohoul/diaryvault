import 'package:dairy_app/core/dependency_injection/injection_container.dart';
import 'package:dairy_app/features/auth/core/constants.dart';
import 'package:dairy_app/features/auth/domain/repositories/authentication_repository.dart';
import 'package:dairy_app/features/auth/presentation/bloc/auth_session/auth_session_bloc.dart';
import 'package:dairy_app/features/auth/presentation/bloc/user_config/user_config_cubit.dart';
import 'package:dairy_app/features/auth/presentation/bloc/user_config/user_config_cubit.dart';
import 'package:dairy_app/features/auth/presentation/widgets/password_enter_popup.dart';
import 'package:dairy_app/features/auth/presentation/widgets/password_reset_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class SecuritySettings extends StatelessWidget {
  late IAuthenticationRepository authenticationRepository;
  SecuritySettings({Key? key}) : super(key: key) {
    authenticationRepository = sl<IAuthenticationRepository>();
  }

  @override
  Widget build(BuildContext context) {
    final authSessionBloc = BlocProvider.of<AuthSessionBloc>(context);
    return Container(
      padding: const EdgeInsets.only(top: 5.0),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Security",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15.0),
          Material(
            color: Colors.transparent,
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: const [
                    Text("Change password", style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              ),
              onTap: () async {
                //! accessing userId like this is bad, but since it is assured that userId will be always present if user is logged in we are doing it
                String? result = await passwordLoginPopup(
                  context: context,
                  submitPassword: (password) => authenticationRepository
                      .verifyPassword(authSessionBloc.state.user!.id, password),
                );

                // old password will be retrieved from previous dialog
                if (result != null) {
                  passwordResetPopup(
                    context: context,
                    submitPassword: (newPassword) =>
                        authenticationRepository.updatePassword(
                      authSessionBloc.state.user!.email,
                      result,
                      newPassword,
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<UserConfigCubit, UserConfigState>(
            builder: (context, state) {
              final userConfigCubit = BlocProvider.of<UserConfigCubit>(context);

              // if the value for config is not set yet, then set it
              if (userConfigCubit
                      .state.userConfigModel!.isFingerPrintAuthPossible ==
                  null) {
                authenticationRepository.isFingerprintAuthPossible().then(
                  (value) {
                    userConfigCubit.setUserConfig(
                        UserConfigConstants.isFingerPrintAuthPossible, value);
                  },
                );
              }

              var isFingerPrintAuthPossible =
                  state.userConfigModel!.isFingerPrintAuthPossible;
              var isFingerPrintLoginEnabledValue =
                  state.userConfigModel!.isFingerPrintLoginEnabled;
              return SwitchListTile(
                activeColor: Colors.pinkAccent,
                contentPadding: const EdgeInsets.all(0.0),
                title: const Text("Enable fingerprint login"),
                subtitle: const Text(
                    "Fingerprint auth should be enabled in device settings"),
                value: isFingerPrintLoginEnabledValue ?? false,
                onChanged: (isFingerPrintAuthPossible == null ||
                        isFingerPrintAuthPossible == false)
                    ? null
                    : (value) {
                        userConfigCubit.setUserConfig(
                          UserConfigConstants.isFingerPrintLoginEnabled,
                          value,
                        );
                      },
              );
            },
          ),
        ],
      ),
    );
  }
}
