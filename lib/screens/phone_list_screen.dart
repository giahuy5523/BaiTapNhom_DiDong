import 'package:flutter/material.dart';

import '../models/phone.dart';
import '../services/phone_service.dart';
import '../widgets/error_view.dart';
import '../widgets/phone_card.dart';
import 'phone_detail_screen.dart';

class PhoneListScreen extends StatefulWidget {
  const PhoneListScreen({super.key, required this.source});

  final PhoneSource source;

  @override
  State<PhoneListScreen> createState() => _PhoneListScreenState();
}

class _PhoneListScreenState extends State<PhoneListScreen> {
  late Future<List<Phone>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.source.getPhones();
  }

  void _reload() {
    // Callback của setState chỉ gán trạng thái, không trả Future cho Flutter.
    setState(() {
      _future = widget.source.getPhones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DANH MỤC SẢN PHẨM')),
      body: FutureBuilder<List<Phone>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ErrorView(error: snap.error!, onRetry: _reload);
          }
          final phones = snap.data!;
          if (phones.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Chưa có điện thoại nào'),
                  TextButton(onPressed: _reload, child: const Text('Tải lại')),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: phones.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => PhoneCard(
              phone: phones[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PhoneDetailScreen(
                    id: phones[i].id,
                    source: widget.source,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
