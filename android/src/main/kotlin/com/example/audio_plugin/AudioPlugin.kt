package com.example.audio_plugin

import android.annotation.TargetApi
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.concurrent.Executors

class AudioPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private var audioTrack: AudioTrack? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var isPlaying = true
    private val audioExecutor = Executors.newSingleThreadExecutor()

    private var currentFrequency: Double = 1.0 // Default frequency

    companion object {
        private var instance: AudioPlugin? = null

        @JvmStatic
        fun getInstance(): AudioPlugin {
            if (instance == null) {
                instance = AudioPlugin()
            }
            return instance!!
        }

        @JvmStatic
        fun registerWith(binding: FlutterPlugin.FlutterPluginBinding) {
            getInstance().onAttachedToEngine(binding)
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                val frequency = call.argument<Double>("frequency") ?: 1.0
                start(frequency)
            }
            "stop" -> stop()
            else -> result.notImplemented()
        }
    }

    @TargetApi(Build.VERSION_CODES.M)
    private fun start(frequency: Double) {
        // If already playing, stop and restart with the new frequency
        if (isPlaying) {
            stop()
        }

        val bufferSize = AudioTrack.getMinBufferSize(
                44100,
                AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT
        )

        audioTrack = AudioTrack.Builder()
                .setAudioAttributes(
                        AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_MEDIA)
                                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                .build()
                )
                .setAudioFormat(
                        AudioFormat.Builder()
                                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                                .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                                .setSampleRate(44100)
                                .build()
                )
                .setBufferSizeInBytes(bufferSize)
                .build()

        audioTrack?.play()

        isPlaying = true

        audioExecutor.execute {
            generateAndPlayAudio(frequency)
        }
    }

    private fun stop() {
        if (isPlaying) {
            isPlaying = false
            mainHandler.removeCallbacksAndMessages(null)

            audioTrack?.let {
                if (it.playState == AudioTrack.PLAYSTATE_PLAYING) {
                    it.stop()
                }
                it.release()
                audioTrack = null
            }
        }
    }

    private val audioTrackLock = Object()

    @TargetApi(Build.VERSION_CODES.M)
    private fun generateAndPlayAudio(frequency: Double) {
        val sampleRate = 44100
        val period = sampleRate / frequency
        val amplitude = 32767.0
        val seconds = 1.0

        // Calculate the number of periods needed for one second
        val periodsInOneSecond = (seconds * frequency).toInt()

        // Calculate the buffer size based on the number of periods
        val bufferSize = (period * periodsInOneSecond).toInt()
        val buffer = ShortArray(bufferSize)

        try {
            while (isPlaying && audioTrack != null && audioTrack!!.playState == AudioTrack.PLAYSTATE_PLAYING) {
                for (i in buffer.indices) {
                    buffer[i] = if ((i % period) < (period / 2)) {
                        amplitude.toInt().toShort()
                    } else {
                        (-amplitude).toInt().toShort()
                    }
                }
                audioTrack?.write(buffer, 0, buffer.size)
            }
        } catch (e: IllegalStateException) {
            e.printStackTrace()
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            releaseAudioResources()
        }
    }

    private fun releaseAudioResources() {
        synchronized(audioTrackLock) {
            try {
                audioTrack?.stop()
                audioTrack?.release()
            } catch (e: Exception) {
                // Handle exceptions during release
                e.printStackTrace()
            } finally {
                audioTrack = null
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) { stop()}
}
