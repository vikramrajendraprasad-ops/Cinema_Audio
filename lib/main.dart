
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:android_intent_plus/android_intent.dart';

void main() {
  runApp(const AudioCinemaApp());
}

/* =========================================================
   CONFIG
========================================================= */

const bool creatorMode = true; // set false before Play Store

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
      debugShowCheckedModeBanner: false,
      title: 'Audio Cinema Studio',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0E11),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE2B86C),
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
  bool isProcessing = false;

  Profile profile = Profile.cinema;
  Intensity intensity = Intensity.medium;
  Channels channels = Channels.stereo;
  Codec codec = Codec.aac;

  Future<void> pickFile() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (res != null && res.files.single.path != null) {
      setState(() {
        selectedFile = res.files.single.path!;
        status = 'Audio selected';
      });
    }
  }

  Future<void> process() async {
    if (selectedFile == null) return;

    setState(() {
      status = 'Processing…';
      isProcessing = true;
    });

    await runEngine(
      inputPath: selectedFile!,
      profile: profile,
      intensity: intensity,
      channels: channels,
      codec: codec,
    );

    setState(() {
      status = 'Done';
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlide(delayMs: 80, child: section('SOURCE')),
          FadeSlide(
            delayMs: 120,
            child: card(
              Column(
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
          ),
          const SizedBox(height: 18),

          FadeSlide(delayMs: 180, child: section('CINEMA PROFILE')),
          FadeSlide(
            delayMs: 220,
            child: dropdown<Profile>(
              value: profile,
              items: creatorMode
                  ? Profile.values
                  : Profile.values.where((p) => p != Profile.atmos).toList(),
              onChanged: (v) => setState(() => profile = v!),
            ),
          ),

          FadeSlide(delayMs: 260, child: section('INTENSITY')),
          FadeSlide(
            delayMs: 300,
            child: segmented<Intensity>(
              values: Intensity.values,
              current: intensity,
              onTap: (v) => setState(() => intensity = v),
            ),
          ),

          FadeSlide(delayMs: 340, child: section('CHANNELS')),
          FadeSlide(
            delayMs: 380,
            child: segmented<Channels>(
              values: Channels.values,
              current: channels,
              labels: const {
                Channels.stereo: 'Stereo',
                Channels.fiveOne: '5.1',
                Channels.sevenOne: '7.1',
              },
              onTap: (v) => setState(() => channels = v),
            ),
          ),

          if (creatorMode) ...[
            FadeSlide(delayMs: 420, child: section('CODEC (CREATOR MODE)')),
            FadeSlide(
              delayMs: 460,
              child: dropdown<Codec>(
                value: codec,
                items: Codec.values,
                onChanged: (v) => setState(() => codec = v!),
              ),
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
              style: TextStyle(letterSpacing: 1.2),
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
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Cinema Studio'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          content,
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.65),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE2B86C),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /* =========================================================
     UI HELPERS
  ========================================================= */

  Widget section(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          t,
          style: const TextStyle(
            color: Color(0xFFE2B86C),
            letterSpacing: 1.1,
          ),
        ),
      );

  Widget card(Widget child) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF151518),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget dropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) =>
      card(
        DropdownButton<T>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          dropdownColor: const Color(0xFF1A1A1D),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.toString().split('.').last.toUpperCase()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      );

  Widget segmented<T>({
    required List<T> values,
    required T current,
    required ValueChanged<T> onTap,
    Map<T, String>? labels,
  }) =>
      card(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: values.map((v) {
            final active = v == current;
            return GestureDetector(
              onTap: () => onTap(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      active ? const Color(0xFFE2B86C) : Colors.transparent,
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

/* =========================================================
   FADE + SLIDE ANIMATION
========================================================= */

class FadeSlide extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const FadeSlide({super.key, required this.child, this.delayMs = 0});

  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(_opacity);

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
