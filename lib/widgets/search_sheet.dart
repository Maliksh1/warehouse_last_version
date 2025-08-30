// search_sheet.dart
import 'package:flutter/material.dart';
import 'package:warehouse/models/search_filter.dart';
import 'package:warehouse/models/search_results.dart';
import 'package:warehouse/services/search_api.dart';

typedef OnOpenResult = void Function(String filter, SearchItem item);

Future<void> showSearchSheet(
  BuildContext context, {
  String? initialFilterKey,
  String? initialQuery,
  OnOpenResult? onOpenResult,
}) async {
  final theme = Theme.of(context);
  SearchFilter? filter = initialFilterKey != null
      ? SearchFilter.byKey(initialFilterKey)
      : SearchFilter.defaults.first;
  String query = initialQuery ?? '';

  SearchResultBundle? bundle;
  bool loading = false;
  String? error;

  final asciiPattern = RegExp(r'^[a-zA-Z0-9 ]+$');

  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        Future<void> doSearch() async {
          FocusScope.of(ctx).unfocus();
          final q = query.trim();
          if (filter == null || q.isEmpty) {
            setState(() => error = 'اختر فلترًا وأدخل نصًا للبحث');
            return;
          }
          // تنبيه مبكر بما يتوافق مع RegEx في الباك
          if (!asciiPattern.hasMatch(q)) {
            setState(() => error =
                'حسب منطق الباك: البحث يقبل أحرف إنجليزية وأرقام ومسافة فقط.');
            return;
          }
          setState(() {
            loading = true;
            error = null;
          });
          try {
            bundle = await SearchApi.search(filter: filter!.key, value: q);
          } catch (e) {
            error = e.toString();
          } finally {
            setState(() => loading = false);
          }
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 8),
                  const Text('بحث عام',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<SearchFilter>(
                      value: filter,
                      decoration: const InputDecoration(
                        labelText: 'الفلتر',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: SearchFilter.defaults
                          .map((f) =>
                              DropdownMenuItem(value: f, child: Text(f.label)))
                          .toList(),
                      onChanged: (v) => setState(() => filter = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: query,
                      decoration: const InputDecoration(
                        labelText: 'اكتب نص البحث (EN فقط)',
                        helperText: 'أحرف إنجليزية/أرقام/مسافة فقط',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (t) => query = t,
                      onFieldSubmitted: (_) => doSearch(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: loading ? null : doSearch,
                    icon: loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.search),
                    label: const Text('بحث'),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12)),
                  ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 12),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: bundle == null
                      ? const Center(
                          child: Text('أدخل عبارة البحث ثم اضغط \"بحث\"'))
                      : bundle!.items.isEmpty
                          ? const Center(child: Text('لا توجد نتائج'))
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: bundle!.items.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final it = bundle!.items[i];
                                return ListTile(
                                  leading: CircleAvatar(
                                      child:
                                          Text((it.id ?? (i + 1)).toString())),
                                  title: Text(it.previewLine),
                                  subtitle: Text(
                                      'النموذج: ${bundle!.filter}  |  المعرف: ${it.id ?? '—'}'),
                                  onTap: () {
                                    if (onOpenResult != null) {
                                      onOpenResult!(bundle!.filter, it);
                                    }
                                  },
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      });
    },
  );
}
