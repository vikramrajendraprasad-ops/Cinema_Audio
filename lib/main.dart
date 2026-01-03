
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:android_intent_plus/android_intent.dart';

void main() {
  runApp(const AudioCinemaApp());
}

/* =========================================================
   CONFIG
========================================================= */

const bool creatorMode = true; // 🔒 set false before Play Store

/* =========================================================
   ENUMS (LOCKED CONTRACT)
========================================================= */

enum Profile { cinema, clarity, punch, deep, atmos }
enum Intensity { low, medium, high }
enum Channels { stereo, fiveOne, sevenOne }
enum Codec { aac, wav, flac, mp3, ac3, eac3 }

/* =========================================================
   MAPPERS
========================================================= */

String profileStr(Profile p) => p.name;
String intensityStr(Intensity i) => i.name;

String channelsStr(Channels c) {
  switch (c) {
    case Channels.fiveOne:
      return '5.1';
    case Channels.sevenOne:
      return '7.1';
    default:
      return 'stereo';
  }
}

String codecStr(Codec c) => c.name;

/* =========================================================
   ENGINE RUNNER (LOCKED)
========================================================= */

Future<void> runEngine({
  required String inputPath,
  required Profile profile,
  required Intensity intensity,
  required Channels channels,
  required Codec codec,
}) async {
  final intent = AndroidIntent(
    action: 'com.termux.RUN_COMMAND',
    package: 'com.termux',
    arguments: {
      'command':
          '/data/data/com.termux/files/home/cinema_engine/engine.sh',
      'arguments':
          '$inputPath ${profileStr(profile)} ${intensityStr(intensity)} ${channelsStr(channels)} ${codecStr(codec)}',
      'background': true,
    },
  );

  await intent.launch();
}

/* =========================================================
   APP
========================================================= */

class AudioCinemaApp extends StatelessWidget {
  const AudioCinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Cinema Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0E11),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE2B86C),
          secondary: Color(0xFF8A8A8A),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Color(0xFFE2B86C),
          thumbColor: Color(0xFFE2B86C),
        ),
      ),
      home: const CinemaHome(),
    );
  }
}

/* =========================================================
   HOME
========================================================= */

class CinemaHome extends StatefulWidget {
  const CinemaHome({super.key});

  @override
  State<CinemaHome> createState() => _CinemaHomeState();
}

class _CinemaHomeState extends State<CinemaHome> {
  String? selectedFile;
  String status = 'Idle';

  Profile profile = Profile.cinema;
  Intensity intensity = Intensity.medium;
  Channels channels = Channels.stereo;
  Codec codec = Codec.aac;

  /* ---------- FILE PICK ---------- */
  Future<void> pickFile() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (res != null && res.files.single.path != null) {
      setState(() {
        selectedFile = res.files.single.path!;
        status = 'Audio selected';
      });
    }
  }

  /* ---------- PROCESS ---------- */
  Future<void> process() async {
    if (selectedFile == null) return;

    setState(() => status = 'Processing…');

    await runEngine(
      inputPath: selectedFile!,
      profile: profile,
      intensity: intensity,
      channels: channels,
      codec: codec,
    );

    setState(() => status = 'Done');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Cinema Studio'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('SOURCE'),
            _card(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.library_music),
                    label: const Text('Pick Audio File'),
                    onPressed: pickFile,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedFile ?? 'No file selected',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _sectionTitle('CINEMA PROFILE'),
            _dropdown<Profile>(
              value: profile,
              items: creatorMode
                  ? Profile.values
                  : Profile.values.where((p) => p != Profile.atmos).toList(),
              onChanged: (v) => setState(() => profile = v!),
            ),

            _sectionTitle('INTENSITY'),
            _segmented<Intensity>(
              values: Intensity.values,
              current: intensity,
              onTap: (v) => setState(() => intensity = v),
            ),

            _sectionTitle('CHANNELS'),
            _segmented<Channels>(
              values: Channels.values,
              current: channels,
              labels: const {
                Channels.stereo: 'Stereo',
                Channels.fiveOne: '5.1',
                Channels.sevenOne: '7.1',
              },
              onTap: (v) => setState(() => channels = v),
            ),

            if (creatorMode) ...[
              _sectionTitle('CODEC (CREATOR MODE)'),
              _dropdown<Codec>(
                value: codec,
                items: Codec.values,
                onChanged: (v) => setState(() => codec = v!),
              ),
            ],

            const Spacer(),

            ElevatedButton(
              onPressed: selectedFile == null ? null : process,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2B86C),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'PROCESS AUDIO',
                style: TextStyle(fontSize: 16, letterSpacing: 1.2),
              ),
            ),

            const SizedBox(height: 10),
            Center(
              child: Text(
                status,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* =========================================================
     UI HELPERS
  ========================================================= */

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          t,
          style: const TextStyle(
            color: Color(0xFFE2B86C),
            letterSpacing: 1.1,
          ),
        ),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF151518),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) =>
      _card(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A1D),
          underline: const SizedBox(),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.toString().split('.').last.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      );

  Widget _segmented<T>({
    required List<T> values,
    required T current,
    required ValueChanged<T> onTap,
    Map<T, String>? labels,
  }) =>
      _card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: values.map((v) {
            final active = v == current;
            return GestureDetector(
              onTap: () => onTap(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFE2B86C)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labels?[v] ?? v.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: active ? Colors.black : Colors.white70,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
}
