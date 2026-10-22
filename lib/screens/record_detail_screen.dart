import 'dart:convert';
import '../core/localization/app_localizations.dart';
import '../core/app_failure.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/storage/local_store.dart';
import '../core/queue/sync_queue_manager.dart';

/// Shows real record identifiers and explicitly requests manual file upload.
class RecordDetailScreen extends StatefulWidget {
  final EvidenceItem item;
  const RecordDetailScreen({super.key, required this.item});
  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _copyReceipt() async {
    // Fetch the actual server receipt; never synthesize proof or transaction data.
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final item = widget.item;
      if (item.shortId == null || item.recordToken == null)
        throw const AppFailure('record_not_sent');
      final response = await http.get(
          Uri.parse('${ApiConfig.api}/v1/records/${item.shortId}'),
          headers: {
            'X-Record-Token': item.recordToken!
          }).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200)
        throw StateError('API HTTP ${response.statusCode}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['receipt'] == null) throw const AppFailure('receipt_not_ready');
      await Clipboard.setData(ClipboardData(text: jsonEncode(data['receipt'])));
      if (mounted) setState(() => _message = 'receipt_copied');
    } catch (error) {
      if (mounted)
        setState(
            () => _message = error is AppFailure ? error.key : 'receipt_error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareFile() async {
    // Android grants temporary read access only to the chosen exported file.
    try {
      await const MethodChannel('org.mdsystem.mdfp/files')
          .invokeMethod<void>('share', {
        'path': widget.item.filePath,
        'mime': widget.item.mediaType,
        'title': AppLocalizations.of(context).translate('share_original')
      });
    } catch (error) {
      if (mounted)
        setState(
            () => _message = error is AppFailure ? error.key : 'share_error');
    }
  }

  Future<void> _upload() async {
    // The user's tap authorizes uploading this media file on any network.
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await SyncQueueManager().uploadManually(widget.item.localId);
      final item =
          await LocalEvidenceStore().getItemByLocalId(widget.item.localId);
      if (mounted)
        setState(() {
          widget.item.vaultStatus =
              item?.vaultStatus ?? widget.item.vaultStatus;
          _message = 'upload_success';
        });
    } catch (error) {
      if (mounted)
        setState(
            () => _message = error is AppFailure ? error.key : 'upload_error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The public QR contains only the digest, never the private record token.
    final item = widget.item;
    final loc = AppLocalizations.of(context);
    final blockTime = DateTime.tryParse(item.blockTime ?? "");

    return Scaffold(
        appBar: AppBar(title: Text(loc.translate('record_detail_title'))),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(
              '${loc.translate('status_label')}: ${loc.recordStatus(item.status)}',
              style: Theme.of(context).textTheme.titleLarge),
          Text('Vault: ${loc.vaultStatus(item.vaultStatus)}'),
          const SizedBox(height: 12),
          SelectableText(
              'ID: ${item.shortId ?? item.localId}\n${loc.translate('file_label')}: ${item.filePath}\nSHA-256: ${item.fileSha256}\nDigest: ${item.recordDigest}\n${loc.translate('signature_label')}: ${item.signature}\n${loc.translate('size_label')}: ${loc.fileSize(item.fileSize)}'),
          const SizedBox(height: 12),
          Text(item.geoLat == null
              ? loc.translate('gps_missing')
              : loc.translate('gps_coordinates', params: {
                  'lat': '${item.geoLat}',
                  'lon': '${item.geoLon}',
                  'accuracy':
                      item.geoAcc?.toString() ?? loc.translate('unknown')
                })),
          if (item.solanaTx != null)
            SelectableText(
                'Solana Devnet TX: ${item.solanaTx}\n${loc.translate('block_time')}: ${blockTime == null ? loc.translate('unknown') : loc.formatDateTime(blockTime.toLocal())}'),
          const SizedBox(height: 12),
          Text(loc.translate('public_digest')),
          Center(
              child: QrImageView(
                  data: item.recordDigest,
                  size: 190,
                  backgroundColor: Colors.white)),
          TextButton(
              onPressed: () async {
                try {
                  await Clipboard.setData(
                      ClipboardData(text: item.recordDigest));
                  if (mounted) setState(() => _message = 'copy_success');
                } catch (error) {
                  if (mounted)
                    setState(() => _message =
                        error is AppFailure ? error.key : 'copy_error');
                }
              },
              child: Text(loc.translate('copy_digest'))),
          ElevatedButton(
              onPressed:
                  _busy || item.vaultStatus == 'uploaded' ? null : _upload,
              child: Text(_busy
                  ? loc.translate('uploading')
                  : loc.translate('upload_file'))),
          OutlinedButton(
              onPressed: _busy ? null : _copyReceipt,
              child: Text(loc.translate('copy_receipt'))),
          OutlinedButton(
              onPressed: _busy ? null : _shareFile,
              child: Text(loc.translate('share_original'))),
          if (_message != null)
            Padding(
                padding: const EdgeInsets.all(8),
                child: Text(loc.translate(_message!))),
          Text(loc.translate('devnet_disclaimer')),
        ]));
  }
}
