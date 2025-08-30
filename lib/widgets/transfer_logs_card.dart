// transfer_logs_card.dart
import 'package:flutter/material.dart';
import 'package:warehouse/models/transfer.dart';
import 'package:warehouse/services/transfers_api.dart';

/// كارد عرض سجلات النقل (الواردة/الصادرة) لمكان معيّن.
class TransferLogsCard extends StatefulWidget {
  final TransferLogType type;
  final String
      placeType; // Warehouse | DistributionCenter (أو أي صيغة، سيتم تطبيعها)
  final int placeId;
  final String? title;

  const TransferLogsCard({
    super.key,
    required this.type,
    required this.placeType,
    required this.placeId,
    this.title,
  });

  @override
  State<TransferLogsCard> createState() => _TransferLogsCardState();
}

class _TransferLogsCardState extends State<TransferLogsCard> {
  late Future<TransferBuckets> _future;
  int _tab = 0; // 0 live, 1 wait, 2 archiv

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = widget.type == TransferLogType.incoming
        ? TransfersApi.fetchIncoming(widget.placeType, widget.placeId)
        : TransfersApi.fetchOutgoing(widget.placeType, widget.placeId);
  }

  Future<void> _refresh() async {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.type == TransferLogType.incoming ? 'الواردة' : 'الصادرة';
    final title = widget.title ?? 'سجلات النقل $t';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.type == TransferLogType.incoming
                    ? Icons.call_received
                    : Icons.call_made),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  tooltip: 'تحديث',
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<TransferBuckets>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return _ErrorState(
                    message: snap.error.toString(),
                    onRetry: _refresh,
                  );
                }
                final buckets = snap.data ??
                    const TransferBuckets(live: [], archiv: [], wait: []);
                final live = buckets.live;
                final wait = buckets.wait;
                final archiv = buckets.archiv;

                final counts = [
                  ('جارية', live.length),
                  ('بانتظار البدء', wait.length),
                  ('أرشيف', archiv.length),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(counts.length, (i) {
                        final selected = _tab == i;
                        final (label, count) = counts[i];
                        return ChoiceChip(
                          label: Text('$label ($count)'),
                          selected: selected,
                          onSelected: (_) => setState(() => _tab = i),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    _buildListFor(_tab, live, wait, archiv),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListFor(int t, List<TransferItem> live, List<TransferItem> wait,
      List<TransferItem> archiv) {
    final items = t == 0
        ? live
        : t == 1
            ? wait
            : archiv;
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('لا توجد سجلات هنا بعد')),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 12),
      itemBuilder: (context, i) {
        final it = items[i];
        final status = (it.status ?? '').toLowerCase();
        IconData icon;
        Color? color;
        if (status.contains('return')) {
          icon = Icons.undo;
          color = Colors.orange;
        } else if (status.contains('contain')) {
          icon = Icons.inventory_2;
          color = Colors.green;
        } else {
          icon = Icons.local_shipping_outlined;
          color = null;
        }
        return ListTile(
          leading: CircleAvatar(
            child: Icon(icon, color: color),
          ),
          title: Text('نقل رقم #${it.id}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (it.counterpartName != null)
                Text('الطرف الآخر: ${it.counterpartName}'),
              if (it.dateOfResiving != null)
                Text('تاريخ الاستلام: ${it.dateOfResiving}'),
              if (it.dateOfFinishing != null)
                Text('تاريخ الإنهاء: ${it.dateOfFinishing}'),
              if (it.status != null) Text('الحالة: ${it.status}'),
            ],
          ),
          onTap: () {
            // يمكنك فتح شاشة تفاصيل النقل هنا مستقبلاً
          },
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            message,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }
}
