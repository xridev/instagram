import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram/config/themes/app_theme.dart';
import 'package:instagram/config/themes/theme_service.dart';
import 'package:instagram/core/translations/app_lang.dart';
import 'package:instagram/core/translations/translations.dart';
import 'package:instagram/core/utility/constant.dart';
import 'package:instagram/presentation/pages/register/login_page.dart';
import 'package:instagram/presentation/widgets/global/others/multi_bloc_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _defineThePlatform(context);
    return MultiBlocs(materialApp(context));
  }

  Widget materialApp(BuildContext context) {
    return GetBuilder<AppLanguage>(
      init: AppLanguage.getInstance(),
      tag: AppLanguage.tag,
      builder: (controller) {
        return GetMaterialApp(
          defaultTransition: Transition.noTransition,
          transitionDuration: const Duration(seconds: 0),
          translations: Translation(),
          locale: Locale(controller.languageSelected),
          fallbackLocale: const Locale('en'),
          debugShowCheckedModeBanner: false,
          title: 'Instagram',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeOfApp.theme,
          home: const LoginPage(), // Direct login page call kora holo
        );
      },
    );
  }
}

void _defineThePlatform(BuildContext context) {
  TargetPlatform platform = Theme.of(context).platform;
  isThatMobile =
      platform == TargetPlatform.iOS || platform == TargetPlatform.android;
  isThatAndroid = platform == TargetPlatform.android;
}
