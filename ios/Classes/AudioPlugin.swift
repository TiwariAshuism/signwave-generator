import Flutter
import AVFoundation

public class AudioPlugin: NSObject, FlutterPlugin {

    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    private var isPlaying = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_plugin", binaryMessenger: registrar.messenger())
        let instance = AudioPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            if let arguments = call.arguments as? [String: Any], let frequency = arguments["frequency"] as? Double {
                startAudio(frequency: frequency)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            }
        case "stop":
            stopAudio()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startAudio(frequency: Double) {
        if isPlaying {
            stopAudio()
        }

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine?.attach(audioPlayerNode!)
        audioEngine?.connect(audioPlayerNode!, to: audioEngine!.mainMixerNode, format: format)

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

        audioPlayerNode?.scheduleBuffer(buffer, completionHandler: nil)

        do {
            try audioEngine?.start()
            audioPlayerNode?.play()
            isPlaying = true
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    private func stopAudio() {
        audioPlayerNode?.stop()
        audioEngine?.stop()
        audioEngine?.reset()
        isPlaying = false
    }
}
