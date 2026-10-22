import '../core/queue/upload_policy.dart';
import '../core/queue/workmanager_task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../core/storage/local_store.dart';
import '../core/crypto/signer_factory.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _uploadPolicy;
  bool _saving = false;
  @override
  void initState() {
    // Restore the actual policy used by the background worker.
    super.initState();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    try {
      final policy = await UploadPolicy.load();
      if (mounted) setState(() => _uploadPolicy = policy);
    } catch (error) {
      debugPrint('Cannot load upload policy: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('settings_error'))));
      }
    }
  }

  Future<void> _savePolicy(String value) async {
    // Serialize preference writes before scheduling a connected worker.
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await UploadPolicy.save(value);
      if (mounted) setState(() => _uploadPolicy = value);
      await WorkmanagerService.requestOneOffSync();
    } catch (error) {
      debugPrint('Settings save failed: $error');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('settings_error'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('nav_settings')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Секция: Мова додатку
            _buildSectionHeader(
                loc.translate('settings_language'), Icons.language),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildLanguageTile('uk', 'Українська', localeProvider),
                  const Divider(color: AppColors.border, height: 1),
                  _buildLanguageTile('en', 'English', localeProvider),
                  const Divider(color: AppColors.border, height: 1),
                  _buildLanguageTile('ru', 'Русский', localeProvider),
                  const Divider(color: AppColors.border, height: 1),
                  _buildLanguageTile('ja', '日本語', localeProvider),
                  const Divider(color: AppColors.border, height: 1),
                  _buildLanguageTile('es', 'Español', localeProvider),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Секция: Політика відправки файлів (ТЗ розділ 3)
            _buildSectionHeader(loc.translate('file_upload_policy'),
                Icons.cloud_upload_outlined),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<String>(
                      value: 'any',
                      groupValue: _uploadPolicy,
                      title: Text(loc.translate('file_upload_any')),
                      subtitle: Text(loc.translate('upload_any_desc')),
                      onChanged: _saving || _uploadPolicy == null
                          ? null
                          : (val) {
                              if (val != null) _savePolicy(val);
                            },
                    ),
                    RadioListTile<String>(
                      value: 'wifi',
                      groupValue: _uploadPolicy,
                      activeColor: AppColors.accentAmber,
                      title: Text(
                        loc.translate('file_upload_wifi'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        loc.translate('upload_wifi_desc'),
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      onChanged: _saving || _uploadPolicy == null
                          ? null
                          : (val) {
                              if (val != null) _savePolicy(val);
                            },
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    RadioListTile<String>(
                      value: 'manual',
                      groupValue: _uploadPolicy,
                      activeColor: AppColors.accentAmber,
                      title: Text(
                        loc.translate('file_upload_manual'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        loc.translate('upload_manual_desc'),
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      onChanged: _saving || _uploadPolicy == null
                          ? null
                          : (val) {
                              if (val != null) _savePolicy(val);
                            },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        loc.translate('file_upload_desc'),
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Секция: Очищення локальних даних (Purge)
            _buildSectionHeader(
                loc.translate('security_section'), Icons.security),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppColors.recordRed, size: 22),
                        SizedBox(width: 8),
                        Expanded(
                            child: Text(
                          loc.translate('delete_device'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.translate('purge_confirm_desc'),
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.recordRed),
                        foregroundColor: AppColors.recordRed,
                      ),
                      onPressed: () => _confirmPurgeDialog(context, loc),
                      icon: const Icon(Icons.delete_forever, size: 20),
                      label: Text(loc.translate('btn_purge_data')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Секция: Інформація про додаток та протокол
            _buildSectionHeader(loc.translate('about'), Icons.info_outline),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 52,
                            height: 52,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.accentAmber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shield_outlined,
                                  color: AppColors.textOnAmber, size: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.translate('app_title'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                loc.translate('organization'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.accentAmber,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                        '${loc.translate('app_version')}:', '1.0.3+4'),
                    const SizedBox(height: 8),
                    _buildInfoRow(loc.translate('protocol'),
                        'MDFP1 (Merkle RFC-6962 sep)'),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        loc.translate('key_protection'),
                        SignerFactory.getSigner()
                                .runtimeType
                                .toString()
                                .contains('Android')
                            ? loc.translate('keystore_unverified')
                            : loc.translate('software_test')),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        loc.translate('server_label'),
                        const String.fromEnvironment('API_BASE_URL',
                            defaultValue: 'https://api.digitaltrust.living')),
                    const SizedBox(height: 8),
                    _buildInfoRow(loc.translate('network_label'),
                        'Solana Devnet ${loc.translate('testnet_note')}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(loc.translate('developed_by'),
                        loc.translate('organization')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accentAmber),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
      String langCode, String name, LocaleProvider provider) {
    final isSelected = provider.locale.languageCode == langCode;

    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.accentAmber : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.accentAmber)
          : null,
      onTap: () async {
        try {
          await provider.setLocale(Locale(langCode));
        } catch (error) {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    AppLocalizations.of(context).translate('settings_error'))));
        }
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    // Vertical layout wraps long translations and server URLs on small screens.
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      SelectableText(value,
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
    ]);
  }

  void _confirmPurgeDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.recordRed),
            SizedBox(width: 8),
            Expanded(
                child: Text(loc.translate('purge_title'),
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 16))),
          ],
        ),
        content: Text(
          loc.translate('purge_confirm_desc'),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.translate('cancel'),
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.recordRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await LocalEvidenceStore().purgeAll();
              } catch (error) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.translate('purge_error'))));
                return;
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.translate('purge_success')),
                    backgroundColor: AppColors.recordRed,
                  ),
                );
              }
            },
            child: Text(loc.translate('delete_all'),
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
