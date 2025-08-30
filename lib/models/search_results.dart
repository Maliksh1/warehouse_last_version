// search_result.dart
import 'dart:convert';

/// عنصر نتيجة عام لأن الحقول تختلف باختلاف الموديل.
class SearchItem {
  final Map<String, dynamic> data;
  const SearchItem(this.data);

  int? get id {
    final v = data['id'];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  String get previewLine {
    final name = data['name']?.toString();
    final title = data['title']?.toString();
    final code = data['code']?.toString();
    return name ??
        title ??
        code ??
        (id != null
            ? '#$id'
            : jsonEncode(data).substring(0, data.length.clamp(0, 80)));
  }
}

class SearchResultBundle {
  final String filter; // اسم الموديل الذي طُبق
  final List<SearchItem> items;
  const SearchResultBundle({required this.filter, required this.items});
}
