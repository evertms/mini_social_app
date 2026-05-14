import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _favIdsKey = 'favorite_post_ids';
  static const String _themeKey = 'is_dark_theme';

  final SharedPreferences _prefs;

  PrefsService(this._prefs);

  static Future<PrefsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsService(prefs);
  }

  List<int> getFavIds() {
    final List<String>? strIds = _prefs.getStringList(_favIdsKey);
    if (strIds == null) return [];
    return strIds.map((id) => int.parse(id)).toList();
  }

  Future<void> toggleFavId(int id) async {
    final List<String> currentIds = _prefs.getStringList(_favIdsKey) ?? [];
    final strId = id.toString();
    
    if (currentIds.contains(strId)) {
      currentIds.remove(strId);
    } else {
      currentIds.add(strId);
    }
    
    await _prefs.setStringList(_favIdsKey, currentIds);
  }

  bool getTheme() {
    return _prefs.getBool(_themeKey) ?? false;
  }

  Future<void> setTheme(bool isDark) async {
    await _prefs.setBool(_themeKey, isDark);
  }
}
