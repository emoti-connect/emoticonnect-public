import SwiftUI
import AVFoundation

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
            
            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
                self.stopAndUploadRecording()
                self.startRecording()
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
        
        // Configure AWS
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "YOUR_ACCESS_KEY", secretKey: "YOUR_SECRET_KEY")
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // Save the recording to S3
        let transferManager = AWSS3TransferManager.default()
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "YOUR_S3_BUCKET_NAME"
        uploadRequest?.key = "recordings/\(UUID().uuidString).wav"
        uploadRequest?.body = audioFileURL
        
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//for use with a bucket if bucket works
//no use for endpoint url anymore
//we simply use the following: (still need to see how to get these tho)
//"YOUR_ACCESS_KEY" = aws access key
//"YOUR_SECRET_KEY" = aws secret key
//"YOUR_S3_BUCKET_NAME" = name of bucket







