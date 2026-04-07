using System.Diagnostics;
using MeltySynth;

namespace EoDataConverter.Converters;

/// <summary>
/// Converts MIDI files to MP3 using MeltySynth (MIDI→WAV) + ffmpeg (WAV→MP3).
/// Also copies MP3 voiceovers and WAV sound effects to the output directory.
///
/// VB6 audio system:
///   - Music: MCI Sequencer plays Mus{n}.mid per zone + Undead.mp3 for intro
///   - Voices: MediaPlayer control plays mp{n}.mp3 (Erling's voiceovers)
///   - Sound effects: DirectSound plays Snd{n}.wav
/// </summary>
public static class AudioConverter
{
    /// <summary>
    /// Convert all MIDI files to MP3 using a SoundFont synthesizer.
    /// </summary>
    public static int ConvertMidi(string musicDir, string soundFontPath, string outputDir)
    {
        Directory.CreateDirectory(outputDir);

        var midiFiles = Directory.GetFiles(musicDir, "*.mid", SearchOption.TopDirectoryOnly);
        if (midiFiles.Length == 0) return 0;

        // Load the SoundFont once
        var soundFont = new SoundFont(soundFontPath);
        var settings = new SynthesizerSettings(44100);

        int converted = 0;
        foreach (var midiFile in midiFiles)
        {
            var name = Path.GetFileNameWithoutExtension(midiFile).ToLowerInvariant();
            var mp3File = Path.Combine(outputDir, name + ".mp3");

            // Skip if already converted and newer than source
            if (File.Exists(mp3File) && File.GetLastWriteTime(mp3File) > File.GetLastWriteTime(midiFile))
            {
                converted++;
                continue;
            }

            try
            {
                RenderMidiToMp3(midiFile, mp3File, soundFont, settings);
                converted++;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"    WARNING: Failed to convert {Path.GetFileName(midiFile)}: {ex.Message}");
            }
        }

        return converted;
    }

    private static void RenderMidiToMp3(string midiFile, string mp3File, SoundFont soundFont, SynthesizerSettings settings)
    {
        var synthesizer = new Synthesizer(soundFont, settings);
        var midiData = new MidiFile(midiFile);
        var sequencer = new MidiFileSequencer(synthesizer);
        sequencer.Play(midiData, false);

        // Render to a temporary WAV file
        var wavFile = mp3File + ".tmp.wav";
        try
        {
            var sampleRate = settings.SampleRate;
            var totalSeconds = midiData.Length.TotalSeconds + 2.0; // add 2s for reverb tail
            var totalSamples = (int)(totalSeconds * sampleRate);

            using (var writer = new BinaryWriter(File.Create(wavFile)))
            {
                // Write WAV header
                var dataSize = totalSamples * 4; // 16-bit stereo = 4 bytes/sample
                WriteWavHeader(writer, sampleRate, 2, 16, dataSize);

                // Render in blocks
                var renderBlockSize = 1024;
                var left = new float[renderBlockSize];
                var right = new float[renderBlockSize];
                var samplesRemaining = totalSamples;

                while (samplesRemaining > 0)
                {
                    var blockSize = Math.Min(renderBlockSize, samplesRemaining);
                    sequencer.Render(left.AsSpan(0, blockSize), right.AsSpan(0, blockSize));

                    for (int i = 0; i < blockSize; i++)
                    {
                        var l = (short)Math.Clamp(left[i] * 32767f, short.MinValue, short.MaxValue);
                        var r = (short)Math.Clamp(right[i] * 32767f, short.MinValue, short.MaxValue);
                        writer.Write(l);
                        writer.Write(r);
                    }

                    samplesRemaining -= blockSize;
                }
            }

            // Convert WAV to MP3 using ffmpeg
            var process = Process.Start(new ProcessStartInfo
            {
                FileName = "ffmpeg",
                Arguments = $"-y -i \"{wavFile}\" -b:a 128k -q:a 2 \"{mp3File}\"",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            });
            process!.WaitForExit(30000);

            if (process.ExitCode != 0)
            {
                var stderr = process.StandardError.ReadToEnd();
                throw new Exception($"ffmpeg failed (exit {process.ExitCode}): {stderr[..Math.Min(200, stderr.Length)]}");
            }
        }
        finally
        {
            if (File.Exists(wavFile)) File.Delete(wavFile);
        }
    }

    /// <summary>
    /// Copy MP3 voiceover files and the Undead.mp3 intro music.
    /// </summary>
    public static int CopyVoiceovers(string soundDir, string? undeadMp3Path, string outputDir)
    {
        Directory.CreateDirectory(outputDir);
        int copied = 0;

        // Copy mp{n}.mp3 voiceover files
        foreach (var mp3 in Directory.GetFiles(soundDir, "mp*.mp3"))
        {
            var dest = Path.Combine(outputDir, Path.GetFileName(mp3).ToLowerInvariant());
            File.Copy(mp3, dest, overwrite: true);
            copied++;
        }

        // Copy Intro.mp3 if it exists
        var introMp3 = Path.Combine(soundDir, "Intro.mp3");
        if (File.Exists(introMp3))
        {
            File.Copy(introMp3, Path.Combine(outputDir, "intro.mp3"), overwrite: true);
            copied++;
        }

        // Copy Undead.mp3 (intro slideshow music)
        if (undeadMp3Path != null && File.Exists(undeadMp3Path))
        {
            File.Copy(undeadMp3Path, Path.Combine(outputDir, "undead.mp3"), overwrite: true);
            copied++;
        }

        return copied;
    }

    /// <summary>
    /// Copy WAV sound effect files, converting to a web-friendly format.
    /// WAV files are already browser-compatible so we just copy them with normalized names.
    /// </summary>
    public static int CopySoundEffects(string soundDir, string outputDir)
    {
        Directory.CreateDirectory(outputDir);
        int copied = 0;

        foreach (var wav in Directory.GetFiles(soundDir, "snd*.wav", SearchOption.TopDirectoryOnly))
        {
            var dest = Path.Combine(outputDir, Path.GetFileName(wav).ToLowerInvariant());
            File.Copy(wav, dest, overwrite: true);
            copied++;
        }

        return copied;
    }

    private static void WriteWavHeader(BinaryWriter w, int sampleRate, int channels, int bitsPerSample, int dataSize)
    {
        var byteRate = sampleRate * channels * bitsPerSample / 8;
        var blockAlign = channels * bitsPerSample / 8;

        w.Write("RIFF"u8);
        w.Write(36 + dataSize);
        w.Write("WAVE"u8);
        w.Write("fmt "u8);
        w.Write(16); // chunk size
        w.Write((short)1); // PCM
        w.Write((short)channels);
        w.Write(sampleRate);
        w.Write(byteRate);
        w.Write((short)blockAlign);
        w.Write((short)bitsPerSample);
        w.Write("data"u8);
        w.Write(dataSize);
    }
}
