// ignore_for_file: use_build_context_synchronously

import 'package:test/utilities/constants.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utilities/custom_widgets/rectangular_button.dart';

class ForgotPassword extends StatefulWidget {
  static const String id = '/forgotPassword';

  const ForgotPassword({super.key});
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String? email;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  clearText() {
    emailController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Forgot Password',
                  style:
                      kTitleStyle.copyWith(color: Colors.white, fontSize: 25))
              .tr(),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Please enter your email address where we'll send the verification link.",
                      style: kInputStyle.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.5,
                          fontSize: 20),
                      textAlign: TextAlign.center,
                    ).tr(),
                    const SizedBox(height: 32),
                    TextFormField(
                      style: kInputStyle,
                      controller: emailController,
                      onChanged: (value) {
                        setState(() {
                          email = value.trim();
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return getTranslatedText(
                              'اپنا ای میل درج کریں', "Enter your email");
                        }
                        if (!EmailValidator.validate(val.trim())) {
                          return getTranslatedText(
                              'ایک درست ای میل ایڈریس درج کریں',
                              "Enter a valid email address");
                        }
                        return null;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        prefixIcon: const Icon(Icons.email),
                        hintText: getTranslatedText('ای میل', 'Email address'),
                        hintStyle: kTextStyle,
                        errorStyle:
                            kTextStyle.copyWith(color: Colors.redAccent),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 40),
                    RectangularRoundedButton(
                      buttonName: 'Send Link',
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email!);
                            clearText();
                            showMyDialog(
                                context,
                                'Info.',
                                getTranslatedText(
                                    'تصدیقی لنک کامیابی کے ساتھ بھیج دیا گیا۔',
                                    'Verification link sent successfully.'));
                          } on FirebaseAuthException catch (e) {
                            print(e.code);
                            if (e.code == "user-not-found") {
                              showMyDialog(
                                  context,
                                  'Error!',
                                  getTranslatedText('ای میل رجسٹرڈ نہیں ہے۔',
                                      'Email not registered.'));
                            } else if (e.code == "network-request-failed") {
                              showMyDialog(
                                  context,
                                  'Login Error!',
                                  getTranslatedText("کوئی انٹرنیٹ کنیکشن نہیں۔",
                                      'No Internet Connection'),
                                  disposeAfterMillis: 700);
                            } else if (e.code == "invalid-email") {
                              showMyDialog(
                                context,
                                'Error!',
                                getTranslatedText(
                                    "غیر قانونی ای میل داخل کیا گیا۔",
                                    'Invalid email entered.'),
                                disposeAfterMillis: 700,
                              );
                            }
                            print(e.code);
                          }
                        } else {
                          print("Validation failed!");
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
