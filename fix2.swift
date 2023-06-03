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
                    stopAndUploadRecording()
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
            stopAndUploadRecording()
        }
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            audioSession.requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
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
        let url = URL(string: "https://7hb5wxrmzqw7x4tuyeck2kgl5a0brzco.lambda-url.us-east-1.on.aws/")!
        var request = URLRequest(url: url,
cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 10)
        request.httpMethod = "POST"
        
        do {
            let audioData = try Data(contentsOf: audioFileURL)
            let base64Audio = audioData.base64EncodedString()

            let jsonData: [String: Any] = ["audio": base64Audio]
            let requestBody = try JSONSerialization.data(withJSONObject: jsonData)

            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            request.httpMethod = "POST"
            request.httpBody = requestBody


            // Rest of the code remains the same
        } catch {
            print("Failed to read audio data: \(error.localizedDescription)")
        }

        
        do {
            let audioData = try Data(contentsOf: audioFileURL)
            let uploadTask = URLSession.shared.uploadTask(with: request, from: audioData) { data, response, error in
                if let error = error {
                    print("Error uploading audio: \(error.localizedDescription)")
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Upload completed with status code: \(httpResponse.statusCode)")
                    }
                    // Handle the response data as needed
                }
            }
            uploadTask.resume()
        } catch {
            print("Failed to read audio data: \(error.localizedDescription)")
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

//changes:
//audiorecorder delegate is outside
//stop and upload now instead of stop recording for continuation
//timer set for 10 second chunks
//using URLSession.shared.uploadTask(with:from:) for upload again
//some more error handling

