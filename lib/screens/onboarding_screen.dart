import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Офіційний логотип ГО "Центр цифрової довіри" та заголовок
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accentAmber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: AppColors.textOnAmber,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(
                    loc.translate('app_title'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                loc.translate('tagline'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentAmber,
                ),
              ),
              const SizedBox(height: 20),

              // Карточки в строгом порядке ТЗ
              Expanded(
                child: ListView(
                  children: [
                    // Карточка 1: Снимай только в приложении
                    _buildInfoCard(
                      icon: Icons.camera_alt_outlined,
                      title: loc.translate('card1_title'),
                      desc: loc.translate('card1_desc'),
                    ),

                    // Карточка 2: Чего приложение не делает
                    _buildInfoCard(
                      icon: Icons.info_outline,
                      title: loc.translate('card2_title'),
                      desc: loc.translate('card2_desc'),
                      highlightColor: AppColors.error,
                    ),

                    // Переключатель языков (UK, RU, EN, JA)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('settings_language'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _langButton(context, locProvider, 'uk', 'UK'),
                                _langButton(context, locProvider, 'ru', 'RU'),
                                _langButton(context, locProvider, 'en', 'EN'),
                                _langButton(context, locProvider, 'ja', 'JA'),
                                _langButton(context, locProvider, 'es', 'ES'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Карточка 3: Подпись на телефоне, отпечаток в блокчейне
                    _buildInfoCard(
                      icon: Icons.lock_outline,
                      title: loc.translate('card3_title'),
                      desc: loc.translate('card3_desc'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              // Кнопка «Продолжить»
              ElevatedButton(
                onPressed: () {
                  _showPermissionsDialog(context, loc, onFinish);
                },
                child: Text(loc.translate('btn_continue')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String desc,
    Color highlightColor = AppColors.accentAmber,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: highlightColor, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langButton(
      BuildContext context, LocaleProvider prov, String code, String label) {
    final isSelected = prov.locale.languageCode == code;
    return InkWell(
      onTap: () async {
        try {
          await prov.setLocale(Locale(code));
        } catch (error) {
          if (context.mounted)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    AppLocalizations.of(context).translate('settings_error'))));
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentAmber : AppColors.card,
          border: Border.all(
            color: isSelected ? AppColors.accentAmber : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.textOnAmber : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _showPermissionsDialog(
      BuildContext context, AppLocalizations loc, VoidCallback onFinish) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          loc.translate('btn_continue'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _permRow(Icons.camera_alt, loc.translate('perm_camera')),
            const SizedBox(height: 10),
            _permRow(Icons.mic, loc.translate('perm_mic')),
            const SizedBox(height: 10),
            _permRow(Icons.location_on, loc.translate('perm_location')),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onFinish();
            },
            child: Text(loc.translate('btn_continue')),
          ),
        ],
      ),
    );
  }

  Widget _permRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accentAmber, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
