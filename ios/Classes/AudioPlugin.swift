import Flutter
import AVFoundation

public class AudioPlugin: NSObject, FlutterPlugin {

    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_plugin", binaryMessenger: registrar.messenger())
        let instance = AudioPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "start":
            if let frequency = call.arguments as? Double {
                startAudio(frequency: frequency)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Frequency argument is missing or invalid", details: nil))
            }
        case "stop":
            stopAudio()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startAudio(frequency: Double) {
        stopAudio()

        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        audioEngine?.attach(playerNode!)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        audioEngine?.connect(playerNode!, to: audioEngine!.mainMixerNode, format: format)

        let sampleRate = 44100
        let period = 1.0 / frequency
        let amplitude: Float = 0.5
        let duration = 1.0
        let numberOfFrames = Int(duration * Double(sampleRate))

        var samples = [Float]()
        for frame in 0..<numberOfFrames {
            let value = (frame % Int(period * Double(sampleRate))) < Int(period * Double(sampleRate)) / 2 ? amplitude : -amplitude
            samples.append(value)
        }

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numberOfFrames))!
        buffer.frameLength = AVAudioFrameCount(numberOfFrames)
        for channel in 0..<Int(format.channelCount) {
            let channelData = buffer.floatChannelData![channel]
            for frame in 0..<numberOfFrames {
                channelData[frame] = samples[frame]
            }
        }

        playerNode?.scheduleBuffer(buffer, completionHandler: nil)
        audioEngine?.prepare()

        do {
            try audioEngine?.start()
            playerNode?.play()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    private func stopAudio() {
        playerNode?.stop()
        audioEngine?.stop()
        audioEngine?.reset()
    }
}