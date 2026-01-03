
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const AudioCinemaApp());
}

/* =========================================================
   METHOD CHANNEL (LOCKED)
========================================================= */

const MethodChannel _engineChannel =
    MethodChannel('cinema.engine/termux');

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
  bool isProcessing = false;
  String status = 'Idle';

  String profile = 'cinema';
  String intensity = 'medium';
  String channels = 'stereo';
  String codec = 'aac';

  /* ================= FILE PICK ================= */

  Future<void> pickFile() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (res != null && res.files.single.path != null) {
      setState(() {
        selectedFile = res.files.single.path!;
        status = 'Audio selected';
      });
    }
  }

  /* ================= ENGINE CALL ================= */

  Future<void> processAudio() async {
    if (selectedFile == null) return;

    setState(() {
      isProcessing = true;
      status = 'Processing…';
    });

    final String cmd = '''
cd ~/cinema_engine &&
./engine.sh "$selectedFile" $profile $intensity $channels $codec
''';

    try {
      await _engineChannel.invokeMethod(
        'runEngine',
        {'cmd': cmd},
      );

      setState(() {
        status = 'Done (see Termux)';
      });
    } catch (e) {
      setState(() {
        status = 'Engine error';
      });
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Cinema Studio'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _section('SOURCE'),
                _card(
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
                const SizedBox(height: 18),

                _section('PROFILE'),
                _dropdown(
                  value: profile,
                  items: const ['cinema', 'clarity', 'punch', 'deep', 'atmos'],
                  onChanged: (v) => setState(() => profile = v!),
                ),

                _section('INTENSITY'),
                _segmented(
                  values: const ['low', 'medium', 'high'],
                  current: intensity,
                  onTap: (v) => setState(() => intensity = v),
                ),

                _section('CHANNELS'),
                _segmented(
                  values: const ['stereo', '5.1', '7.1'],
                  current: channels,
                  onTap: (v) => setState(() => channels = v),
                ),

                _section('CODEC (CREATOR MODE)'),
                _dropdown(
                  value: codec,
                  items: const ['aac', 'mp3', 'ac3', 'eac3', 'wav', 'flac'],
                  onChanged: (v) => setState(() => codec = v!),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: selectedFile == null ? null : processAudio,
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
          ),

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

  /* ================= UI HELPERS ================= */

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          t,
          style: const TextStyle(
            color: Color(0xFFE2B86C),
            letterSpacing: 1.1,
          ),
        ),
      );

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF151518),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) =>
      _card(
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          dropdownColor: const Color(0xFF1A1A1D),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.toUpperCase()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      );

  Widget _segmented({
    required List<String> values,
    required String current,
    required ValueChanged<String> onTap,
  }) =>
      _card(
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
                  v.toUpperCase(),
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
