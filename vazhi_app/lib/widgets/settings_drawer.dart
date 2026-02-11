/// Settings Drawer
///
/// Provides intuitive access to app settings and customization.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../config/theme.dart';
import '../providers/voice_provider.dart';
import '../providers/chat_provider.dart';
import 'download_dialog.dart';

// Language provider (true = Tamil, false = English)
final languageProvider = StateProvider<bool>((ref) => false);

class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inferenceMode = ref.watch(inferenceModeProvider);
    final modelStatus = ref.watch(modelManagerProvider);
    final downloadProgress = ref.watch(downloadProgressProvider);
    final voiceOutput = ref.watch(voiceOutputStateProvider);
    final isTamil = ref.watch(languageProvider);

    // Bilingual text helper
    String t(String en, String ta) => isTamil ? ta : en;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: VazhiTheme.primaryGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/vazhi_logo_white.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'வ',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: VazhiTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VAZHI வழி',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Tamil AI Assistant',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mode indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      inferenceMode == InferenceMode.cloud
                          ? '☁️ Cloud Mode'
                          : '📱 Offline Mode',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Settings List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Language Toggle
                  _buildSectionHeader(t('Language', 'மொழி')),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(t('Display Language', 'காட்சி மொழி')),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: VazhiTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: isTamil
                                ? () =>
                                      ref
                                              .read(languageProvider.notifier)
                                              .state =
                                          false
                                : null,
                            style: TextButton.styleFrom(
                              backgroundColor: !isTamil
                                  ? VazhiTheme.primaryColor
                                  : Colors.transparent,
                              foregroundColor: !isTamil
                                  ? Colors.white
                                  : VazhiTheme.textSecondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'English',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: !isTamil
                                ? () =>
                                      ref
                                              .read(languageProvider.notifier)
                                              .state =
                                          true
                                : null,
                            style: TextButton.styleFrom(
                              backgroundColor: isTamil
                                  ? VazhiTheme.primaryColor
                                  : Colors.transparent,
                              foregroundColor: isTamil
                                  ? Colors.white
                                  : VazhiTheme.textSecondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Tamil',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  // Inference Mode Section
                  _buildSectionHeader(t('Inference Mode', 'செயல்முறை')),
                  _buildInferenceModeTile(
                    context,
                    ref,
                    inferenceMode,
                    modelStatus,
                    isTamil,
                  ),

                  const Divider(height: 32),

                  // Model Management Section (always show)
                  _buildSectionHeader(t('Model', 'மாடல்')),
                  _buildModelManagementTile(
                    context,
                    ref,
                    modelStatus,
                    downloadProgress,
                    isTamil,
                  ),

                  const Divider(height: 32),

                  // Voice Settings
                  _buildSectionHeader(t('Voice', 'குரல்')),
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up_outlined),
                    title: Text(t('Voice Output', 'குரல் வெளியீடு')),
                    subtitle: Text(
                      t('Read responses aloud', 'பதில்களை சத்தமாக படிக்கவும்'),
                    ),
                    value: voiceOutput.isEnabled,
                    onChanged: (value) {
                      ref
                          .read(voiceOutputStateProvider.notifier)
                          .toggleEnabled();
                    },
                  ),
                  if (voiceOutput.isEnabled)
                    ListTile(
                      leading: const Icon(Icons.speed),
                      title: Text(t('Speech Speed', 'பேச்சு வேகம்')),
                      subtitle: Slider(
                        value: voiceOutput.speed,
                        min: 0.25,
                        max: 1.0,
                        divisions: 15,
                        label: '${(voiceOutput.speed * 100).round()}%',
                        onChanged: (value) {
                          ref
                              .read(voiceOutputStateProvider.notifier)
                              .setSpeed(value);
                        },
                      ),
                    ),

                  const Divider(height: 32),

                  // Feedback Section
                  _buildSectionHeader(t('Feedback', 'கருத்து')),
                  ListTile(
                    leading: const Icon(
                      Icons.chat_outlined,
                      color: Colors.green,
                    ),
                    title: Text(t('WhatsApp Community', 'WhatsApp சமூகம்')),
                    subtitle: Text(
                      t(
                        'Join discussion & give feedback',
                        'கலந்துரையாடலில் சேரவும்',
                      ),
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => _openWhatsApp(context),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.bug_report_outlined,
                      color: Colors.orange,
                    ),
                    title: Text(t('Report Issue', 'சிக்கலைப் புகாரளி')),
                    subtitle: Text(
                      t(
                        'Help us improve VAZHI',
                        'VAZHI-ஐ மேம்படுத்த உதவுங்கள்',
                      ),
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => _openGitHub(context),
                  ),

                  const Divider(height: 32),

                  // About Section
                  _buildSectionHeader(t('About', 'பற்றி')),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(t('About VAZHI', 'VAZHI பற்றி')),
                    subtitle: Text(
                      '${t('Version', 'பதிப்பு')} ${AppConfig.appVersion}',
                    ),
                    onTap: () => _showAboutDialog(context, isTamil),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.volunteer_activism_outlined,
                      color: Colors.pink,
                    ),
                    title: Text(
                      t('Support the Project', 'திட்டத்தை ஆதரிக்கவும்'),
                    ),
                    subtitle: Text(
                      t(
                        'Help keep VAZHI free',
                        'VAZHI-ஐ இலவசமாக வைக்க உதவுங்கள்',
                      ),
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => _openDonation(context),
                  ),
                ],
              ),
            ),

            // Version footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                t(
                  'VAZHI ${AppConfig.appVersion} • Made with ❤️ for Tamil community',
                  'VAZHI ${AppConfig.appVersion} • தமிழ் சமூகத்திற்காக ❤️ உடன் உருவாக்கப்பட்டது',
                ),
                style: TextStyle(fontSize: 11, color: VazhiTheme.textLight),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: VazhiTheme.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInferenceModeTile(
    BuildContext context,
    WidgetRef ref,
    InferenceMode currentMode,
    ModelStatus modelStatus,
    bool isTamil,
  ) {
    final bool canUseLocal = modelStatus == ModelStatus.ready;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _ModeCard(
              title: isTamil ? 'கிளவுட்' : 'Cloud',
              subtitle: isTamil ? 'இணையம் தேவை' : 'Needs internet',
              icon: Icons.cloud_outlined,
              isSelected: currentMode == InferenceMode.cloud,
              onTap: () => ref.read(inferenceModeProvider.notifier).state =
                  InferenceMode.cloud,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ModeCard(
              title: isTamil ? 'ஆஃப்லைன்' : 'Offline',
              subtitle: canUseLocal
                  ? (isTamil ? 'தயார்' : 'Ready')
                  : (isTamil ? 'மாடல் தேவை' : 'Model needed'),
              icon: Icons.phone_android,
              isSelected: currentMode == InferenceMode.local,
              isDisabled: !canUseLocal,
              onTap: canUseLocal
                  ? () => ref.read(inferenceModeProvider.notifier).state =
                        InferenceMode.local
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isTamil
                                ? 'முதலில் மாடலை பதிவிறக்கவும்'
                                : 'Please download the model first',
                          ),
                          action: SnackBarAction(
                            label: isTamil ? 'பதிவிறக்கு' : 'Download',
                            onPressed: () => ref
                                .read(modelManagerProvider.notifier)
                                .downloadModel(),
                          ),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelManagementTile(
    BuildContext context,
    WidgetRef ref,
    ModelStatus status,
    double progress,
    bool isTamil,
  ) {
    String statusText;
    Widget? trailing;
    VoidCallback? onTap;

    switch (status) {
      case ModelStatus.notDownloaded:
        statusText = isTamil
            ? 'பதிவிறக்கவில்லை (~1.6 GB)'
            : 'Not downloaded (~1.6 GB)';
        trailing = ElevatedButton.icon(
          icon: const Icon(Icons.download, size: 18),
          label: Text(isTamil ? 'பதிவிறக்கு' : 'Download'),
          style: ElevatedButton.styleFrom(
            backgroundColor: VazhiTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            Navigator.pop(context); // Close drawer
            final result = await DownloadDialog.show(context);
            if (result == true) {
              // Download completed, model will be loaded
            }
          },
        );
        break;
      case ModelStatus.downloading:
        statusText = isTamil
            ? 'பதிவிறக்கம்... ${(progress * 100).toInt()}%'
            : 'Downloading... ${(progress * 100).toInt()}%';
        trailing = SizedBox(
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: progress,
                color: VazhiTheme.primaryColor,
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
        break;
      case ModelStatus.downloaded:
        statusText = isTamil ? 'பதிவிறக்கப்பட்டது' : 'Downloaded';
        trailing = ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow, size: 18),
          label: Text(isTamil ? 'ஏற்று' : 'Load'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () => ref.read(modelManagerProvider.notifier).loadModel(),
        );
        break;
      case ModelStatus.loading:
        statusText = isTamil ? 'ஏற்றுகிறது...' : 'Loading...';
        trailing = const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        break;
      case ModelStatus.ready:
        statusText = isTamil
            ? 'தயார் - ஆஃப்லைன் பயன்படுத்தலாம்'
            : 'Ready - Can use offline';
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: isTamil ? 'நீக்கு' : 'Delete',
              onPressed: () => _confirmDeleteModel(context, ref, isTamil),
            ),
          ],
        );
        break;
      case ModelStatus.error:
        statusText = isTamil ? 'பிழை ஏற்பட்டது' : 'Error occurred';
        trailing = ElevatedButton.icon(
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(isTamil ? 'மீண்டும்' : 'Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          onPressed: () =>
              ref.read(modelManagerProvider.notifier).downloadModel(),
        );
        break;
    }

    return ListTile(
      leading: Icon(
        status == ModelStatus.ready
            ? Icons.memory
            : Icons.cloud_download_outlined,
        color: status == ModelStatus.ready
            ? Colors.green
            : VazhiTheme.primaryColor,
      ),
      title: Text(isTamil ? 'VAZHI மாடல்' : 'VAZHI Model'),
      subtitle: Text(statusText),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _confirmDeleteModel(BuildContext context, WidgetRef ref, bool isTamil) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTamil ? 'மாடலை நீக்கவா?' : 'Delete Model?'),
        content: Text(
          isTamil
              ? 'இது 1.6 GB சேமிப்பிடத்தை விடுவிக்கும். மீண்டும் பதிவிறக்க வேண்டும்.'
              : 'This will free up 1.6 GB of storage. You will need to download again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isTamil ? 'ரத்து' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ref.read(modelManagerProvider.notifier).deleteModel();
              // Switch back to cloud mode when model is deleted
              ref.read(inferenceModeProvider.notifier).state =
                  InferenceMode.cloud;
            },
            child: Text(
              isTamil ? 'நீக்கு' : 'Delete',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    // WhatsApp community link
    final url = Uri.parse('https://chat.whatsapp.com/your-group-link');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openGitHub(BuildContext context) async {
    final url = Uri.parse(AppConfig.githubUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDonation(BuildContext context) async {
    final url = Uri.parse(AppConfig.donationUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showAboutDialog(BuildContext context, bool isTamil) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: VazhiTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'வ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('VAZHI வழி'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTamil
                  ? 'இலவச உதவிகரமான AI வழி தோழன்'
                  : 'Voluntary AI with Zero-cost Helpful Intelligence',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              isTamil
                  ? 'VAZHI (வழி) என்பது தமிழில் "பாதை" என்று பொருள். எல்லா இடங்களிலும் உள்ள தமிழர்களுக்கு AI-ஐ அணுகக்கூடியதாக ஆக்குவதன் மூலம் நாங்கள் வழி காட்டுகிறோம்.'
                  : 'VAZHI (வழி) means "path" or "way" in Tamil. We show the way by making AI accessible to Tamilians everywhere.',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              isTamil
                  ? '• 100% இலவசம், விளம்பரங்கள் இல்லை\n• ஆஃப்லைனில் வேலை செய்யும் (முழு பயன்முறை)\n• தமிழ் சமூகத்திற்காக உருவாக்கப்பட்டது'
                  : '• 100% Free, No Ads\n• Works Offline (Full mode)\n• Built for Tamil community',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isTamil ? 'மூடு' : 'Close'),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled
        ? Colors.grey[400]!
        : (isSelected ? VazhiTheme.primaryColor : Colors.grey[600]!);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey[50]
              : (isSelected
                    ? VazhiTheme.primaryColor.withValues(alpha: 0.1)
                    : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? Colors.grey[300]!
                : (isSelected ? VazhiTheme.primaryColor : Colors.grey[300]!),
            width: isSelected && !isDisabled ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: effectiveColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDisabled
                    ? Colors.grey[400]
                    : (isSelected ? VazhiTheme.primaryColor : Colors.grey[800]),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDisabled
                    ? Colors.grey[400]
                    : (isSelected
                          ? VazhiTheme.primaryColor.withValues(alpha: 0.8)
                          : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
