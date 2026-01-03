
import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';

class CinemaEngine {
  /* ============================================================
     PUBLIC ENGINE ENTRY POINT
     Replaces: engine.sh
  ============================================================ */

  static Future<String> process({
    required String inputPath,
    required String profile,
    required String intensity,
    required String channels,
    required String codec,
  }) async {
    // -------- Output directory --------
    final outputDir = "/storage/emulated/0/AudioCinema/output";
    await Directory(outputDir).create(recursive: true);

    // -------- Safety normalization --------
    final safeProfile = _normalizeProfile(profile);
    final safeIntensity = _normalizeIntensity(intensity);
    final safeChannels = _normalizeChannels(channels);
    final safeCodec = _normalizeCodec(codec, safeChannels);

    final outputPath =
        "$outputDir/processed_${DateTime.now().millisecondsSinceEpoch}.$safeCodec";

    // -------- Build FFmpeg pipeline --------
    final filterGraph = _buildFilterGraph(
      profile: safeProfile,
      intensity: safeIntensity,
      channels: safeChannels,
    );

    final codecArgs = _buildCodecArgs(
      codec: safeCodec,
      channels: safeChannels,
    );

    final command = '''
      -y
      -i "$inputPath"
      -af "$filterGraph"
      $codecArgs
      "$outputPath"
    ''';

    // -------- Execute --------
    final session = await FFmpegKit.execute(command);
    final rc = await session.getReturnCode();

    if (rc == null || !ReturnCode.isSuccess(rc)) {
      final logs = await session.getAllLogsAsString();
      throw Exception("FFmpeg failed:\n$logs");
    }

    return outputPath;
  }

  /* ============================================================
     AUDIO SCIENCE — FILTER GRAPH
  ============================================================ */

  static String _buildFilterGraph({
    required String profile,
    required String intensity,
    required String channels,
  }) {
    final gain = _intensityGain(intensity);
    final spatial = _spatialDownmix(channels);

    switch (profile) {
      case "cinema":
        return _join([
          "highpass=f=30",
          "lowpass=f=18000",
          "dynaudnorm=p=0.7:m=15",
          "equalizer=f=80:t=q:w=1:g=4",
          "equalizer=f=3000:t=q:w=1:g=2",
          spatial,
          "volume=$gain",
        ]);

      case "clarity":
        return _join([
          "highpass=f=120",
          "equalizer=f=4000:t=q:w=1:g=4",
          "equalizer=f=9000:t=q:w=1:g=2",
          "volume=$gain",
        ]);

      case "punch":
        return _join([
          "equalizer=f=90:t=q:w=1:g=6",
          "dynaudnorm=p=0.6:m=10",
          "volume=$gain",
        ]);

      case "depth":
        return _join([
          "equalizer=f=60:t=q:w=1:g=5",
          "equalizer=f=12000:t=q:w=1:g=3",
          "volume=$gain",
        ]);

      case "atmos":
        return _join([
          "highpass=f=40",
          "lowpass=f=17000",
          "dynaudnorm=p=0.6:m=12",
          "equalizer=f=90:t=q:w=1:g=5",
          "equalizer=f=6000:t=q:w=1:g=3",
          spatial,
          "volume=$gain",
        ]);

      default:
        return "volume=1.0";
    }
  }

  /* ============================================================
     INTENSITY CURVE (SAFE RANGES)
  ============================================================ */

  static String _intensityGain(String intensity) {
    switch (intensity) {
      case "low":
        return "1.10";
      case "medium":
        return "1.25";
      case "high":
        return "1.40";
      default:
        return "1.25";
    }
  }

  /* ============================================================
     SPATIAL DOWNMIX (NO INVALID PAN SYNTAX)
  ============================================================ */

  static String _spatialDownmix(String channels) {
    switch (channels) {
      case "5.1":
        return "pan=stereo|c0=c0+0.5*c2|c1=c1+0.5*c3";
      case "7.1":
        return "pan=stereo|c0=c0+0.7*c2|c1=c1+0.7*c3";
      default:
        return "";
    }
  }

  /* ============================================================
     CODEC RULES (NO ILLEGAL COMBINATIONS)
  ============================================================ */

  static String _buildCodecArgs({
    required String codec,
    required String channels,
  }) {
    switch (codec) {
      case "aac":
        // AAC is stereo-safe
        return "-c:a aac -b:a 256k";

      case "mp3":
        return "-c:a libmp3lame -b:a 320k";

      case "ac3":
        return channels == "stereo"
            ? "-c:a ac3 -b:a 192k"
            : "-c:a ac3 -b:a 640k";

      case "eac3":
        return channels == "stereo"
            ? "-c:a eac3 -b:a 384k"
            : "-c:a eac3 -b:a 768k";

      case "wav":
        return "-c:a pcm_s16le";

      case "flac":
        return "-c:a flac";

      default:
        return "-c:a aac -b:a 256k";
    }
  }

  /* ============================================================
     SAFETY NORMALIZATION (STEP 3)
  ============================================================ */

  static String _normalizeProfile(String p) {
    const allowed = ["cinema", "clarity", "punch", "depth", "atmos"];
    return allowed.contains(p) ? p : "cinema";
  }

  static String _normalizeIntensity(String i) {
    const allowed = ["low", "medium", "high"];
    return allowed.contains(i) ? i : "medium";
  }

  static String _normalizeChannels(String c) {
    const allowed = ["stereo", "5.1", "7.1"];
    return allowed.contains(c) ? c : "stereo";
  }

  static String _normalizeCodec(String codec, String channels) {
    // Prevent illegal combos (e.g. AAC 7.1)
    if (codec == "aac" && channels != "stereo") {
      return "eac3";
    }
    return codec;
  }

  /* ============================================================
     UTILITY
  ============================================================ */

  static String _join(List<String> filters) {
    return filters.where((f) => f.isNotEmpty).join(",");
  }
}
