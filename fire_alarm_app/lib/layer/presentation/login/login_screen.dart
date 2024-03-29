import 'package:fire_alarm_app/layer/data/repos/user_repos.dart';
import 'package:fire_alarm_app/layer/presentation/register/register_page.dart';
import 'package:fire_alarm_app/main.dart';
import 'package:fire_alarm_app/utils/font_data.dart';
import 'package:fire_alarm_app/utils/text_data.dart';
import 'package:fire_alarm_app/utils/validation.dart';
import 'package:fire_alarm_app/utils/widgets/flush_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fire_alarm_app/layer/presentation/login/index.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/dimen.dart';

class LoginScreen extends StatefulWidget {
  final UserRepository userRepository;
  const LoginScreen({
    Key? key,
    required LoginBloc loginBloc,
    required this.userRepository,
  })  : _loginBloc = loginBloc,
        super(key: key);

  final LoginBloc _loginBloc;

  @override
  LoginScreenState createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  LoginScreenState();

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final GlobalKey<FormState> loginForm = GlobalKey<FormState>();
  final FlushBar flushBar = FlushBar();

  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
        bloc: widget._loginBloc,
        builder: (
          BuildContext context,
          LoginState currentState,
        ) {
          if (currentState is UnLoginState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (currentState is ErrorLoginState) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(currentState.errorMessage),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: ElevatedButton(
                    onPressed: _load,
                    child: const Text('reload'),
                  ),
                ),
              ],
            ));
          }
          if (currentState is InLoginState) {
            return body();
          }
          if (currentState is InLoginButtonState) {
            return body();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget body() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (usernameFocusNode.hasFocus || passwordFocusNode.hasFocus) {
              usernameFocusNode.unfocus();
              passwordFocusNode.unfocus();
            }
          },
          child: Center(
            child: Card(
              elevation: 8,
              shadowColor: Colors.black,
              child: Container(
                height: Dimen.sizeDevice.height * 0.5,
                width: Dimen.sizeDevice.width * 0.7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //Text 'Đăng Nhập'
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 40,
                                width: 5,
                                color: Colors.orange,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Text(
                                  TextData.loginTilte,
                                  style: FontData.dMSans20Bold(
                                      color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                                height: 80,
                                width: 80,
                                child: IconButton(
                                  onPressed: () {
                                    GoRouter.of(StateManager
                                            .navigatorKey.currentContext!)
                                        .go(RegisterPage.routeName);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                )),
                          ),
                        ],
                      ),
                      //form user and password
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Form(
                            key: loginForm,
                            child: Column(
                              children: [
                                TextFormField(
                                  focusNode: usernameFocusNode,
                                  controller: userNameController,
                                  cursorColor: Colors.orange,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: TextData.usernameTilte,
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.orange),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  focusNode: passwordFocusNode,
                                  controller: passwordController,
                                  style: const TextStyle(color: Colors.black),
                                  cursorColor: Colors.orange,
                                  obscureText: true,
                                  onChanged: (value) {
                                    if (userNameController.text != '' &&
                                        passwordController.text != '') {
                                      widget._loginBloc
                                          .add(LoadLoginButtonEvent());
                                    } else {
                                      widget._loginBloc.add(LoadLoginEvent());
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: TextData.passwordTilte,
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.orange),
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ),
                      //button submit
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        width: double.infinity,
                        child: TextButton(
                            onPressed: () {
                              if (userNameController.text != "" ||
                                  passwordController.text != "") {
                                widget.userRepository.loginApp(
                                    userNameController.text,
                                    passwordController.text);
                              } else {
                                Validation.loginValidation(LoginValidationType
                                    .passwordOrUsernameEmpty);
                              }
                            },
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                side: BorderSide(
                                  color: (userNameController.text != '' &&
                                          passwordController.text != '')
                                      ? Colors.orange
                                      : Colors.grey[300]!,
                                  width: 2,
                                )),
                            child: Text(TextData.confirmTilte,
                                style: FontData.dMSans20Bold(
                                  color: (userNameController.text != '' &&
                                          passwordController.text != '')
                                      ? Colors.orange
                                      : Colors.grey[300],
                                ))),
                      )
                    ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _load() {
    widget._loginBloc.add(LoadLoginEvent());
  }
}
