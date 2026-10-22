import 'package:flutter/material.dart';
import '../core/localization/app_localizations.dart';
import '../core/capture/evidence_verifier.dart';
import '../core/storage/local_store.dart';

/// Verifies actual saved bytes; no demo success state or invented transaction.
class VerifyFileScreen extends StatefulWidget {
  const VerifyFileScreen({super.key});
  @override
  State<VerifyFileScreen> createState() => _VerifyFileScreenState();
}

class _VerifyFileScreenState extends State<VerifyFileScreen> {
  List<EvidenceItem> _items = [];
  String? _result;
  bool _busy = false;

  @override
  void initState() {
    // Read the same store that capture and sync use.
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Surface storage failure instead of presenting a fabricated sample.
    try {
      final items = await LocalEvidenceStore().getAllItems();
      if (mounted) setState(() => _items = items);
    } catch (error) {
      if (mounted) setState(() => _result = 'verify_error');
    }
  }

  Future<void> _verify(EvidenceItem item) async {
    // A matching hash establishes local consistency, not authenticity of events.
    setState(() {
      _busy = true;
      _result = null;
    });
    try {
      final valid = await EvidenceVerifier.verifyLocal(item);
      if (mounted)
        setState(
            () => _result = valid ? 'verify_local_ok' : 'verify_local_fail');
    } catch (error) {
      if (mounted) setState(() => _result = 'verify_error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Allow selecting only real records with known original digests.
    final loc = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(title: Text(loc.translate('verify_title')), actions: [
          IconButton(
              tooltip: loc.translate('refresh'),
              onPressed: _busy ? null : _load,
              icon: const Icon(Icons.refresh))
        ]),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(loc.translate('verify_help')),
          if (_busy) const LinearProgressIndicator(),
          if (_result != null)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SelectableText(loc.translate(_result!))),
          if (_items.isEmpty)
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text(loc.translate('verify_empty'))),
          ..._items.map((item) => ListTile(
              title: Text(item.shortId ?? item.localId),
              subtitle: Text(item.mediaType),
              trailing: const Icon(Icons.fact_check),
              onTap: _busy ? null : () => _verify(item))),
        ]));
  }
}
