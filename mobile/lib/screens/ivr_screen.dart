import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';

class IvrScreen extends StatelessWidget {
  const IvrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('IVR Phone Helpline'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(context),
            const SizedBox(height: 20),
            _buildCallButton(context),
            const SizedBox(height: 20),
            _buildHowItWorksCard(context),
            const SizedBox(height: 20),
            _buildIvrFlowCard(context),
            const SizedBox(height: 20),
            _buildContactsCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.phone_in_talk, color: Colors.white, size: 40),
          const SizedBox(height: 16),
          const Text(
            'Navigate by Phone',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Works on any phone — no internet or smartphone required.\n'
            'Dial our IVR line and follow the voice prompts to get\n'
            'step-by-step directions inside the hospital.',
            style: TextStyle(color: Colors.white80, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.dialpad, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              GestureDetector(
                onLongPress: () {
                  Clipboard.setData(
                      const ClipboardData(text: AppConfig.ivrNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('IVR number copied to clipboard')),
                  );
                },
                child: const Text(
                  AppConfig.ivrNumber,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Long-press to copy number',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildCallButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.phone, size: 22),
        label: const Text('Call IVR Navigation Now',
            style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.success,
        ),
        onPressed: () => _dial(context, AppConfig.ivrNumber),
      ),
    ).animate().fade(delay: 150.ms, duration: 400.ms);
  }

  Widget _buildHowItWorksCard(BuildContext context) {
    const steps = [
      _IvrStep('1', 'Dial the IVR number',
          'Call ${AppConfig.ivrNumber} from any mobile or landline.',
          Icons.phone_callback_outlined),
      _IvrStep('2', 'Select your floor',
          'Press 0–8 on the keypad to choose which floor you are on.',
          Icons.layers_outlined),
      _IvrStep('3', 'Choose your current location',
          'Select from the list of rooms and departments on your floor.',
          Icons.place_outlined),
      _IvrStep('4', 'Choose destination floor',
          'Press the floor number where you want to go.',
          Icons.elevator_outlined),
      _IvrStep('5', 'Choose your destination',
          'Select the specific department or room you need.',
          Icons.flag_outlined),
      _IvrStep('6', 'Listen to directions',
          'The system reads step-by-step voice directions. Press 1 for next step, 2 to repeat, 0 to restart.',
          Icons.volume_up_outlined),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.help_outline, color: AppTheme.primary, size: 20),
                SizedBox(width: 8),
                Text('How It Works', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map(
                  (e) => e.value.build(context,
                      isLast: e.key == steps.length - 1),
                ),
          ],
        ),
      ),
    ).animate().fade(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildIvrFlowCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.dialpad, color: AppTheme.primary, size: 20),
                SizedBox(width: 8),
                Text('Keypad Reference', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            _buildKeyTable(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.emergency.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.emergency.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emergency, color: AppTheme.emergency, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Press 2 at any time for direct emergency navigation.',
                      style: TextStyle(
                          color: AppTheme.emergency, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildKeyTable() {
    const rows = [
      ['Main Menu', '1 = Navigation, 2 = Emergency, 9 = Repeat'],
      ['Floor Select', '0 = Ground Floor, 1–8 = Floors 1–8'],
      ['Department', '1–9 = Select department from list'],
      ['During Steps', '1 = Next, 2 = Repeat, 0 = Restart'],
    ];

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: rows
          .map(
            (r) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(r[0],
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.primary)),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  child: Text(r[1], style: AppTheme.bodyMedium),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildContactsCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.contacts_outlined,
                    color: AppTheme.primary, size: 20),
                SizedBox(width: 8),
                Text('Quick Contacts', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            _contactTile(context, 'Emergency', AppConfig.emergencyNumber,
                AppTheme.emergency, Icons.emergency),
            _contactTile(context, 'Reception', AppConfig.receptionNumber,
                AppTheme.primary, Icons.support_agent),
            _contactTile(context, 'IVR Navigation', AppConfig.ivrNumber,
                AppTheme.accent, Icons.dialpad),
          ],
        ),
      ),
    ).animate().fade(delay: 400.ms, duration: 400.ms);
  }

  Widget _contactTile(BuildContext context, String label, String number,
      Color color, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: AppTheme.bodyLarge),
      subtitle: Text(number, style: AppTheme.bodyMedium),
      trailing: IconButton(
        icon: const Icon(Icons.phone, color: AppTheme.primary),
        tooltip: 'Call $label',
        onPressed: () => _dial(context, number),
      ),
    );
  }

  Future<void> _dial(BuildContext context, String number) async {
    // Clean number for tel: URI
    final clean = number.replaceAll(RegExp(r'[^+\d]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open dialer. Dial $number manually.')),
        );
      }
    }
  }
}

class _IvrStep {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  const _IvrStep(this.number, this.title, this.description, this.icon);

  Widget build(BuildContext context, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primary,
                child: Text(
                  number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFBBDEFB),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2332))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
