import 'package:flutter/material.dart';

import '../models/phone.dart';
import '../services/phone_service.dart';
import '../widgets/error_view.dart';
import '../widgets/phone_image.dart';

class PhoneDetailScreen extends StatefulWidget {
  const PhoneDetailScreen({super.key, required this.id, required this.source});

  final int id;
  final PhoneSource source;

  @override
  State<PhoneDetailScreen> createState() => _PhoneDetailScreenState();
}

class _PhoneDetailScreenState extends State<PhoneDetailScreen> {
  late Future<Phone> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.source.getPhone(widget.id);
  }

  void _reload() => setState(() => _future = widget.source.getPhone(widget.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('THÔNG TIN SẢN PHẨM')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
      body: FutureBuilder<Phone>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ErrorView(error: snap.error!, onRetry: _reload);
          }
          final p = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tên: ${p.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                PhoneImage(
                  url: p.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text('Giá: ${p.price} đ', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                const Text('Mô tả',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(p.description),
              ],
            ),
          );
        },
      ),
    );
  }
}
