import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';

class CinemaEngine {
  static Future<String> process({
    required String inputPath,
    required String profile,
    required String intensity,
    required String channels,
    required String codec,
  }) async {
    final outputDir = "/storage/emulated/0/AudioCinema/output";
    await Directory(outputDir).create(recursive: true);

    final outputPath =
        "$outputDir/processed_${DateTime.now().millisecondsSinceEpoch}.$codec";

    final filter = _buildFilter(profile, intensity, channels);
    final codecArgs = _codecArgs(codec, channels);

    final cmd = '''
      -y -i "$inputPath"
      -af "$filter"
      $codecArgs
      "$outputPath"
    ''';

    final session = await FFmpegKit.execute(cmd);

    final rc = await session.getReturnCode();
    if (rc?.isValueSuccess() != true) {
      throw Exception("FFmpeg processing failed");
    }

    return outputPath;
  }

  // ================= AUDIO SCIENCE =================

  static String _buildFilter(
      String profile, String intensity, String channels) {
    final intensityGain = {
      "low": "1.1",
      "medium": "1.25",
      "high": "1.4",
    }[intensity] ?? "1.25";

    final spatial = channels == "7.1"
        ? "pan=stereo|c0=c0+0.7*c2|c1=c1+0.7*c3"
        : channels == "5.1"
            ? "pan=stereo|c0=c0+0.5*c2|c1=c1+0.5*c3"
            : "";

    switch (profile) {
      case "cinema":
        return [
          "highpass=f=30",
          "lowpass=f=18000",
          "dynaudnorm=p=0.7:m=15",
          "equalizer=f=80:t=q:w=1:g=4",
          "equalizer=f=3000:t=q:w=1:g=2",
          spatial,
          "volume=$intensityGain"
        ].where((e) => e.isNotEmpty).join(",");

      case "clarity":
        return [
          "highpass=f=120",
          "equalizer=f=4000:t=q:w=1:g=4",
          "volume=$intensityGain"
        ].join(",");

      case "punch":
        return [
          "equalizer=f=90:t=q:w=1:g=6",
          "dynaudnorm=p=0.6:m=10",
          "volume=$intensityGain"
        ].join(",");

      case "depth":
        return [
          "equalizer=f=60:t=q:w=1:g=5",
          "equalizer=f=10000:t=q:w=1:g=3",
          "volume=$intensityGain"
        ].join(",");

      default:
        return "volume=1.0";
    }
  }

  static String _codecArgs(String codec, String channels) {
    switch (codec) {
      case "aac":
        return "-c:a aac -b:a 256k";
      case "mp3":
        return "-c:a libmp3lame -b:a 320k";
      case "eac3":
        return channels == "stereo"
            ? "-c:a eac3 -b:a 384k"
            : "-c:a eac3 -b:a 768k";
      case "ac3":
        return "-c:a ac3 -b:a 640k";
      default:
        return "-c:a aac -b:a 256k";
    }
  }
}
