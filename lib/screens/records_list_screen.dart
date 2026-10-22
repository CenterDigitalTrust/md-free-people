import 'dart:async';
import 'package:flutter/material.dart';
import '../core/storage/local_store.dart';
import '../core/queue/sync_queue_manager.dart';
import '../core/localization/app_localizations.dart';
import 'record_detail_screen.dart';

/// Displays persisted evidence rather than sample records.
class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({super.key});
  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen> {
  List<EvidenceItem> _items = [];
  String? _error;
  Timer? _timer;
  bool _loading = false;

  @override
  void initState() {
    // Refresh statuses while this screen is visible.
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _refresh());
  }

  Future<void> _refresh() async {
    // Keep the last successful list if reading storage fails.
    if (_loading) return;
    _loading = true;
    try {
      final queue = SyncQueueManager();
      await queue.triggerSync();
      final items = await LocalEvidenceStore().getAllItems();
      if (mounted)
        setState(() {
          _items = items;
          _error = null;
        });
    } catch (error) {
      if (mounted) setState(() => _error = 'storage_error');
    } finally {
      _loading = false;
    }
  }

  @override
  void dispose() {
    // Stop polling once navigation leaves the records screen.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Every displayed value originates from the local evidence record.
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('nav_records')),
          actions: [
            IconButton(
                tooltip: loc.translate('refresh'),
                onPressed: _refresh,
                icon: const Icon(Icons.refresh))
          ]),
      body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (_error != null)
                  ListTile(title: Text(loc.translate(_error!))),
                if (_items.isEmpty)
                  ListTile(title: Text(loc.translate('records_empty'))),
                ..._items.map((item) => Card(
                        child: ListTile(
                      leading: Icon(item.mediaType.startsWith('image')
                          ? Icons.photo
                          : item.mediaType.startsWith('video')
                              ? Icons.videocam
                              : Icons.mic),
                      title: Text(item.shortId ?? item.localId),
                      subtitle: Text(
                          '${loc.formatDateTime(DateTime.fromMillisecondsSinceEpoch(item.createdAtMs).toLocal())}\n${loc.recordStatus(item.status)} • Vault: ${loc.vaultStatus(item.vaultStatus)} • ${loc.fileSize(item.fileSize)}'),
                      isThreeLine: true,
                      onTap: () async {
                        await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (_) =>
                                    RecordDetailScreen(item: item)));
                        await _refresh();
                      },
                    ))),
              ])),
    );
  }
}
