import 'package:utilx/utilx.dart';

enum AnilistCharacterRole {
  main,
  supporting,
  background,
}

extension AnilistCharacterRoleUtils on AnilistCharacterRole {
  String get stringify => name.toUpperCase();
}

AnilistCharacterRole parseAnilistCharacterRole(final String value) =>
    EnumUtils.find(AnilistCharacterRole.values, value.toLowerCase());
