
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';

void main() {
  runApp(const AudioCinemaApp());
}

class AudioCinemaApp extends StatelessWidget {
  const AudioCinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audio Cinema Studio',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CinemaHome(),
    );
  }
}

class CinemaHome extends StatefulWidget {
  const CinemaHome({super.key});

  @override
  State<CinemaHome> createState() => _CinemaHomeState();
}

class _CinemaHomeState extends State<CinemaHome>
    with SingleTickerProviderStateMixin {
  String? inputPath;
  String status = "Idle";
  bool processing = false;

  String profile = "Dolby Cinema";
  String intensity = "Medium";
  String channels = "Stereo";

  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        inputPath = result.files.single.path!;
        status = "Audio Selected";
      });
    }
  }

  Future<void> processAudio() async {
    if (inputPath == null) return;

    setState(() {
      processing = true;
      status = "Processing…";
    });

    final outputDir = Directory("/storage/emulated/0/AudioCinema/output");
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final outputPath =
        "${outputDir.path}/cinema_${DateTime.now().millisecondsSinceEpoch}.m4a";

    final filter = _buildCinemaFilter();

    final command =
        '-y -i "$inputPath" -af "$filter" -c:a aac -b:a 320k "$outputPath"';

    await FFmpegKit.execute(command);

    setState(() {
      processing = false;
      status = "Done → Saved to AudioCinema/output";
    });
  }

  String _buildCinemaFilter() {
    // SAFE, STABLE, CINEMA-GRADE FILTER CHAIN
    switch (profile) {
      case "Dolby Cinema":
        return "highpass=f=40,lowpass=f=16000,"
            "dynaudnorm=p=0.9:m=10:s=5,"
            "bass=g=4:f=90,"
            "treble=g=2:f=9000";
      case "Sony Clarity":
        return "highpass=f=120,"
            "equalizer=f=3000:t=q:w=1:g=4,"
            "equalizer=f=8000:t=q:w=1:g=3";
      case "JBL Punch":
        return "bass=g=6:f=70,"
            "equalizer=f=1000:t=q:w=1:g=-2";
      case "Bose Deep":
        return "bass=g=8:f=110,"
            "lowpass=f=14000";
      default:
        return "dynaudnorm";
    }
  }

  Widget _dropdown(
      String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Cinema Studio"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeTransition(
              opacity: _pulse,
              child: const Icon(Icons.movie, size: 60),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.library_music),
              label: const Text("Pick Audio File"),
              onPressed: pickAudio,
            ),

            const SizedBox(height: 20),
            if (inputPath != null)
              Text(
                inputPath!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dropdown(profile,
                    ["Dolby Cinema", "Sony Clarity", "JBL Punch", "Bose Deep"],
                    (v) => setState(() => profile = v!)),
                _dropdown(intensity, ["Low", "Medium", "High"],
                    (v) => setState(() => intensity = v!)),
                _dropdown(
                    channels, ["Stereo"], (v) => setState(() => channels = v!)),
              ],
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: processing ? null : processAudio,
              child: processing
                  ? const CircularProgressIndicator()
                  : const Text("PROCESS AUDIO"),
            ),

            const SizedBox(height: 12),
            Text(
              status,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
