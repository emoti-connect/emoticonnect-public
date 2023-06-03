import SwiftUI
import AVFoundation
import AWSS3

class AudioRecorderDelegate: NSObject, AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Audio recording finished successfully")
        } else {
            print("Audio recording failed")
        }
    }
}

struct ContentView: View {
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    private var audioRecorderDelegate = AudioRecorderDelegate()
    
    var body: some View {
        VStack {
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
            }
        }
        .onAppear {
            configureAudioSession()
        }
        .onDisappear {
            stopRecording()
        }
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            audioSession.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self?.startRecording()
                    } else {
                        print("Permission denied")
                    }
                }
            }
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = audioRecorderDelegate
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            
            Timer.scheduledTimer(withTimeInterval: 25.0, repeats: true) { _ in
                self.stopAndUploadRecording()
            }
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    private func stopAndUploadRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        
        let audioFileURL = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        // Convert to MP3
        let mp3FileURL = convertToMP3(audioFileURL: audioFileURL)
        
        // Configure AWS
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "YOUR_ACCESS_KEY", secretKey: "YOUR_SECRET_KEY") // Replace with your AWS access key and secret key
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // Save the MP3 recording to S3
        let transferManager = AWSS3TransferManager.default()
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "YOUR_S3_BUCKET_NAME" // Replace with your S3 bucket name
        uploadRequest?.key = "audio/output/processed-audio.mp3"
        uploadRequest?.body = mp3FileURL
        
        transferManager?.upload(uploadRequest!).continueWith { task in
            if let error = task.error {
                print("Error uploading audio to S3: \(error.localizedDescription)")
            } else if let _ = task.result {
                print("Recording saved to S3 successfully")
            }
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func convertToMP3(audioFileURL: URL) -> URL {
        let outputURL = getDocumentsDirectory().appendingPathComponent("recording.mp3")
        
        let asset = AVURLAsset(url: audioFileURL)
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        
        exporter?.outputFileType = .mp3
        exporter?.outputURL = outputURL
        
        do {
            try exporter?.exportAsynchronously(completionHandler: {
                if exporter?.status == .completed {
                    print("Audio conversion to MP3 finished successfully")
                } else if let error = exporter?.error {
                    print("Error converting audio to MP3: \(error.localizedDescription)")
                }
            })
        } catch {
            print("Failed to export audio as MP3: \(error.localizedDescription)")
        }
        
        return outputURL
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

