import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import './handlers/auth.dart';
import '../../../plugins/database/database.dart';
import '../../secrets/anilist.dart';

export './handlers/auth.dart';

abstract class MyAnimeListManager {
  static const String webURL = 'https://myanimelist.com';
  static const String baseURL = 'https://myanimelist.net/v1';

  static final Auth auth = Auth(AnilistSecrets.clientId);

  static Future<void> initialize() async {
    final Map<dynamic, dynamic>? _token = DataStore.credentials.anilist;

    if (_token != null) {
      final TokenInfo token = TokenInfo.fromJson(_token);
      if (DateTime.now().isBefore(token.expiresAt)) {
        auth.token = token;
      } else {
        await auth.deleteToken();
      }
    }
  }

  static Future<void> authenticate(final TokenInfo token) async {
    auth.authorize(token);
    if (auth.token != null) {
      await auth.saveToken();
    }
  }

  static Future<dynamic> request(final String url) async {
    if (!auth.isValidToken()) throw StateError('Not logged in');

    // TODO
    final http.Response res = await http.post(
      Uri.parse(baseURL),
      // body: json.encode(body.toJson()),
      headers: <String, String>{
        'Authorization': '${auth.token!.tokenType} ${auth.token!.accessToken}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final dynamic parsed = res.body.isNotEmpty ? json.decode(res.body) : null;
    if (parsed is Map<dynamic, dynamic> &&
        (parsed['errors'] as List<dynamic>?)?.firstWhereOrNull(
              (final dynamic x) => x['message'] == 'Invalid token',
            ) !=
            null) {
      await auth.deleteToken();
      throw StateError('Login expired');
    }

    return parsed;
  }

  bool get isLoggedIn => auth.isValidToken();
}
