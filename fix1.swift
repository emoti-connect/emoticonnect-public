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
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.audioRecorder?.updateMeters()
                let averagePower = self.audioRecorder?.averagePower(forChannel: 0) ?? 0.0
                
                if averagePower > -10.0 { // Adjust the threshold as per your requirement
                    print("Working")
                }
            }
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        
	//main change-tried using URLSession.shared.uploadTask(with:from:)

        let audioFileURL = getDocumentsDirectory().appendingPathComponent("recording.wav")
        let url = URL(string: "https://7hb5wxrmzqw7x4tuyeck2kgl5a0brzco.lambda-url.us-east-1.on.aws/")!
        var request = URLRequest(url: url, 
cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 10)
        request.httpMethod = "POST"
        
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
    
    private var audioRecorderDelegate = AudioRecorderDelegate()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//this code will only upload a single audio recording to the endpoint