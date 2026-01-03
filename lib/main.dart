
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
      theme: ThemeData(useMaterial3: true),
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
  List<String> files = [];
  String mode = 'Cinema';
  double intensity = 0.5;
  String output = 'Auto';
  String format = 'AAC';
  String status = 'Idle';

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        files = result.paths.whereType<String>().toList();
      });
    }
  }

  void runEngine() {
    setState(() => status = 'Processing...');
    startStatusWatcher();
    // actual execution is done via Termux script
  }

  void startStatusWatcher() {
    Timer.periodic(const Duration(seconds: 1), (t) async {
      final f = File('/sdcard/AudioCinema/status.txt');
      if (await f.exists()) {
        final txt = await f.readAsString();
        if (txt.contains('DONE')) {
          t.cancel();
          setState(() => status = 'Completed');
        }
      }
    });
  }

  Widget modeCard(String label) {
    final selected = mode == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => mode = label),
        child: Card(
          color: selected ? Colors.deepPurple : Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text(label,
                    style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Cinema Studio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            modeCard('Cinema'),
            modeCard('Clarity'),
            modeCard('Punch'),
            modeCard('Depth'),
          ]),
          const SizedBox(height: 20),
          Text('Intensity'),
          Slider(
            value: intensity,
            onChanged: (v) => setState(() => intensity = v),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: output,
            items: ['Auto', 'Headphones', 'Speaker']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => output = v!),
          ),
          DropdownButton<String>(
            value: format,
            items: ['AAC', 'FLAC', 'WAV']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => format = v!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: pickFiles,
            child: const Text('Pick Audio'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: files.isEmpty ? null : runEngine,
            child: Text(files.length > 1
                ? 'Enhance All (${files.length})'
                : 'Enhance Audio'),
          ),
          const SizedBox(height: 20),
          Text('Status: $status'),
        ]),
      ),
    );
  }
}
