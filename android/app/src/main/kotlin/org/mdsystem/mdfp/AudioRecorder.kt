package org.mdsystem.mdfp

import android.media.MediaRecorder
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Owns one microphone recording and releases it on every failure. */
class AudioRecorder(private val activity: MainActivity) {
    private var recorder: MediaRecorder? = null
    private var output: String? = null

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        // Return a path only after Android has finalized a valid MPEG-4 container.
        try {
            when (call.method) {
                "start" -> {
                    check(recorder == null) { "Recording is already running" }
                    val path = requireNotNull(call.argument<String>("path"))
                    val next = if (Build.VERSION.SDK_INT >= 31) MediaRecorder(activity)
                        else @Suppress("DEPRECATION") MediaRecorder()
                    recorder = next
                    output = path
                    next.setAudioSource(MediaRecorder.AudioSource.MIC)
                    next.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                    next.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                    next.setAudioEncodingBitRate(128000)
                    next.setAudioSamplingRate(44100)
                    next.setOutputFile(path)
                    next.prepare()
                    next.start()
                    result.success(null)
                }
                "stop" -> {
                    val active = checkNotNull(recorder) { "No recording is running" }
                    active.stop()
                    val path = output
                    release()
                    result.success(path)
                }
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            release()
            result.error("AUDIO_RECORDING_FAILED", error.message, null)
        }
    }

    fun release() {
        // Always release the microphone, including activity destruction.
        try { recorder?.release() } catch (error: Exception) {
            Log.e("MDFP", "Cannot release audio recorder", error)
        } finally { recorder = null; output = null }
    }
}
