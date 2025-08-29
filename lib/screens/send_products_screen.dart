// lib/screens/send_products_screen.dart
import 'package:flutter/material.dart';
import 'package:warehouse/models/transfer_request.dart';
import 'package:warehouse/widgets/send_products_card.dart';

/// شاشة كاملة لإرسال المنتجات مع AppBar وعناصر تنقل
class SendProductsScreen extends StatelessWidget {
  final PlaceType? prefillSourceType;
  final int? prefillSourceId;
  const SendProductsScreen({
    super.key,
    this.prefillSourceType,
    this.prefillSourceId,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إرسال منتجات'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'رجوع',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SendProductsCard(
                initialSourceType: prefillSourceType,
                initialSourceId: prefillSourceId,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
