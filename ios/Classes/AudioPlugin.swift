import Flutter
import AVFoundation

public class AudioPlugin: NSObject, FlutterPlugin {

    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    private var isPlaying = false
    private var isBuffering = false
    private var frequency: Double = 1
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_plugin", binaryMessenger: registrar.messenger())
        let instance = AudioPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            if let arguments = call.arguments as? [String: Any], let flutter_frequency = arguments["frequency"] as? Double {
                frequency=flutter_frequency
                startAudio(frequency: flutter_frequency)
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

        if let engine = audioEngine, engine.isRunning {
                // Stop the engine if it's already running
                stopAudio()
            }

        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else {
            print("Error creating audio format")
            return
        }

        guard let buffer = generateBuffer(frequency: frequency, format: format) else {
            print("Error generating audio buffer")
            return
        }

        setupAudioEngine(format: format, buffer: buffer)

        do {
            try audioEngine?.start()
            audioPlayerNode?.play()
            isPlaying = true

            observeBufferState()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
            stopAudio()
        }
    }

    private func generateBuffer(frequency: Double, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sampleRate = Int(format.sampleRate)
        let period = 1.0 / frequency
        let amplitude: Float = 1.0
        let duration = 1.0
        let numberOfFrames = Int(duration * Double(sampleRate))

        var samples = [Float]()
        for frame in 0..<numberOfFrames {
            let value = (frame % Int(period * Double(sampleRate))) < Int(period * Double(sampleRate)) / 2 ? amplitude : -amplitude
            samples.append(value)
        }

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numberOfFrames)) else {
            print("Error creating audio buffer")
            return nil
        }

        buffer.frameLength = AVAudioFrameCount(numberOfFrames)
        for channel in 0..<Int(format.channelCount) {
            let channelData = buffer.floatChannelData?[channel]
            for frame in 0..<numberOfFrames {
                channelData?[frame] = samples[frame]
            }
        }

        return buffer
    }

    private func setupAudioEngine(format: AVAudioFormat, buffer: AVAudioPCMBuffer) {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        guard let audioEngine = audioEngine, let audioPlayerNode = audioPlayerNode else {
            print("Error creating audio engine or player node")
            return
        }

        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: format)

        audioPlayerNode.scheduleBuffer(buffer, completionHandler: nil)
    }

    private func stopAudio() {
        do {
            // Stop the audio player node
            audioPlayerNode?.stop()

            // Stop the audio engine
            audioEngine?.stop()

            // Reset the audio engine
            audioEngine?.reset()

            // Detach the audio player node
            if let playerNode = audioPlayerNode, let engine = audioEngine {
                engine.detach(playerNode)
            }

            // Set properties to false
            isPlaying = false
            isBuffering = false

            // Set optional values to nil
            audioEngine = nil
            audioPlayerNode = nil

        } catch {
            print("Error stopping audio engine: \(error.localizedDescription)")
        }
    }



private func observeBufferState() {
    let displayLink = CADisplayLink(target: self, selector: #selector(handleBufferState(_:)))
    displayLink.add(to: .main, forMode: .common)
}

@objc private func handleBufferState(_ displayLink: CADisplayLink) {
    guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else {
        print("Error creating audio format")
        return
    }

    guard let buffer = generateBuffer(frequency: frequency, format: format) else {
        print("Error generating audio buffer")
        return
    }

    if !isBuffering {
        isBuffering = buffer.frameLength < AVAudioFrameCount(buffer.frameCapacity)
        if isBuffering {
            // Buffering, pause playback
            audioPlayerNode?.pause()
            print("Buffering...")
        } else {
            // Buffering complete, resume playback
            audioPlayerNode?.scheduleBuffer(buffer, completionHandler: nil)
            audioPlayerNode?.play()

        }
    }
}

}
