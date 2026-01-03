import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'engine/cinema_engine.dart';

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
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFD4AF37), // cinema gold
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

class _CinemaHomeState extends State<CinemaHome> {
  String? inputPath;
  String status = "Idle";

  String profile = "cinema";
  String intensity = "medium";
  String channels = "stereo";
  String codec = "aac";

  bool processing = false;

  // ================= FILE PICK =================

  Future<void> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        inputPath = result.files.single.path!;
        status = "Audio selected";
      });
    }
  }

  // ================= PROCESS AUDIO =================

  Future<void> processAudio() async {
    if (inputPath == null) return;

    setState(() {
      processing = true;
      status = "Processing...";
    });

    try {
      final output = await CinemaEngine.process(
        inputPath: inputPath!,
        profile: profile,
        intensity: intensity,
        channels: channels,
        codec: codec,
      );

      setState(() {
        status = "Done\n$output";
      });
    } catch (e) {
      setState(() {
        status = "Engine error";
      });
    } finally {
      setState(() {
        processing = false;
      });
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Cinema Studio"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // SOURCE
            section("SOURCE"),
            ElevatedButton.icon(
              onPressed: pickAudio,
              icon: const Icon(Icons.library_music),
              label: const Text("Pick Audio File"),
            ),
            if (inputPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  inputPath!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 24),

            // PROFILE
            section("PROFILE"),
            dropdown(
              value: profile,
              items: const {
                "cinema": "Cinema",
                "clarity": "Clarity",
                "punch": "Punch",
                "depth": "Depth",
              },
              onChanged: (v) => setState(() => profile = v),
            ),

            const SizedBox(height: 16),

            // INTENSITY
            section("INTENSITY"),
            segmented(
              value: intensity,
              options: const {
                "low": "Low",
                "medium": "Medium",
                "high": "High",
              },
              onChanged: (v) => setState(() => intensity = v),
            ),

            const SizedBox(height: 16),

            // CHANNELS
            section("CHANNELS"),
            segmented(
              value: channels,
              options: const {
                "stereo": "Stereo",
                "5.1": "5.1",
                "7.1": "7.1",
              },
              onChanged: (v) => setState(() => channels = v),
            ),

            const SizedBox(height: 16),

            // CODEC
            section("CODEC (Creator mode)"),
            dropdown(
              value: codec,
              items: const {
                "aac": "AAC",
                "mp3": "MP3",
                "ac3": "AC3",
                "eac3": "EAC3",
              },
              onChanged: (v) => setState(() => codec = v),
            ),

            const SizedBox(height: 30),

            // PROCESS BUTTON
            ElevatedButton(
              onPressed: processing ? null : processAudio,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(),
              ),
              child: processing
                  ? const CircularProgressIndicator()
                  : const Text(
                      "PROCESS AUDIO",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),

            const SizedBox(height: 20),

            // STATUS
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET HELPERS =================

  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget dropdown({
    required String value,
    required Map<String, String> items,
    required Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.entries
          .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              ))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  Widget segmented({
    required String value,
    required Map<String, String> options,
    required Function(String) onChanged,
  }) {
    return Wrap(
      spacing: 10,
      children: options.entries.map((e) {
        final selected = value == e.key;
        return ChoiceChip(
          label: Text(e.value),
          selected: selected,
          onSelected: (_) => onChanged(e.key),
        );
      }).toList(),
    );
  }
}
