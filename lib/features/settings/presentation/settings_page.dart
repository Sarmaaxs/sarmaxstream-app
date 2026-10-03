import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/brand_mark.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool autoplay = true;
  bool showExplicit = true;
  bool notifications = true;
  bool reduceMotion = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back)),
          title: const Text('Settings',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
<<<<<<< HEAD
            const Center(child: Wordmark(fontSize: 34)),
=======
            const Center(child: BrandMark(size: 58)),
            const SizedBox(height: 12),
            const Center(
                child: Text('SARMAXSTREAM',
                    style: TextStyle(
                        letterSpacing: 2.2, fontWeight: FontWeight.w900))),
>>>>>>> 559808d1ebbae9b95dcf20f0dd4adef721fc732e
            const SizedBox(height: 28),
            _Section(title: 'Playback', children: [
              _SettingSwitch(
                  title: 'Autoplay',
                  subtitle: 'Continue with the next track',
                  value: autoplay,
                  onChanged: (v) => setState(() => autoplay = v)),
              _SettingSwitch(
                  title: 'Background playback',
                  subtitle: 'Keep music playing with the screen off',
                  value: true,
                  onChanged: null),
            ]),
            const SizedBox(height: 18),
            _Section(title: 'Interface', children: [
              _SettingSwitch(
                  title: 'Show explicit content',
                  subtitle: 'Keep content labels visible',
                  value: showExplicit,
                  onChanged: (v) => setState(() => showExplicit = v)),
              _SettingSwitch(
                  title: 'Reduce motion',
                  subtitle: 'Use calmer transitions',
                  value: reduceMotion,
                  onChanged: (v) => setState(() => reduceMotion = v)),
              _SettingSwitch(
                  title: 'Playback notifications',
                  subtitle: 'Show lock-screen controls',
                  value: notifications,
                  onChanged: (v) => setState(() => notifications = v)),
            ]),
            const SizedBox(height: 18),
            _Section(title: 'About', children: [
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline, color: AppTheme.lime),
                  title: const Text('SarmaxStream'),
<<<<<<< HEAD
                  subtitle: const Text('Movies · TV · YouTube · Music'),
=======
                  subtitle: const Text('Stage 1 · Music'),
>>>>>>> 559808d1ebbae9b95dcf20f0dd4adef721fc732e
                  trailing: const Icon(Icons.chevron_right)),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.shield_outlined, color: AppTheme.lime),
                  title: const Text('Privacy'),
                  subtitle: const Text('Your API keys stay on the server'),
                  trailing: const Icon(Icons.chevron_right)),
<<<<<<< HEAD
              const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.movie_filter_outlined, color: AppTheme.lime),
                  title: Text('Movie & TV data'),
                  subtitle: Text(
                      'This product uses the TMDB API but is not endorsed or certified by TMDB.')),
=======
>>>>>>> 559808d1ebbae9b95dcf20f0dd4adef721fc732e
            ]),
          ],
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(),
            style: const TextStyle(
                color: AppTheme.lime,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3)),
        const SizedBox(height: 8),
        Card(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Column(children: children)))
      ]);
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch(
      {required this.title,
      required this.subtitle,
      required this.value,
      required this.onChanged});
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12)),
      value: value,
      onChanged: onChanged,
        activeThumbColor: AppTheme.lime);
}
