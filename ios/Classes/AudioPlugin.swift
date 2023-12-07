import Flutter
import AVFoundation

public class AudioPlugin: NSObject, FlutterPlugin {
    
    private var audioPlayer: AVAudioPlayer?
    
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
        guard audioPlayer == nil else {
            stopAudio()
            return
        }
        
        let period = 1.0 / frequency
        let amplitude: Float = 0.5
        let duration = 1.0
        
        let sampleRate = 44100
        let numberOfFrames = Int(duration * Double(sampleRate))
        
        var samples = [Float]()
        for frame in 0..<numberOfFrames {
            let value = (frame % Int(period * Double(sampleRate))) < Int(period * Double(sampleRate)) / 2 ? amplitude : -amplitude
            samples.append(value)
        }
        
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numberOfFrames))!
        buffer.floatChannelData![0].withMemoryRebound(to: Float.self, capacity: numberOfFrames) { ptr in
            memcpy(ptr, samples, numberOfFrames * MemoryLayout<Float>.size)
        }
        
        audioPlayer = AVAudioPlayer()
        audioPlayer?.prepare(toPlay: true)
        audioPlayer?.numberOfLoops = -1 // Loop indefinitely
        audioPlayer?.enableRate = true
        audioPlayer?.rate = Float(frequency)
        audioPlayer?.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        audioPlayer?.play()
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
