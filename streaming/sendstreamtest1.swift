import Foundation
import WatchConnectivity

class AudioStreamController: NSObject, WCSessionDelegate {
    
    var session: WCSession?
    var audioStream: InputStream?
    
    func startStreaming() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        
        if let audioURL = Bundle.main.url(forResource: "audio", withExtension: "wav") {
            audioStream = InputStream(url: audioURL)
            audioStream?.open()
            
            let bufferSize = 1024
            var buffer = [UInt8](repeating: 0, count: bufferSize)
            
            while audioStream?.hasBytesAvailable ?? false {
                let bytesRead = audioStream?.read(&buffer, maxLength: bufferSize)
                let data = Data(bytes: buffer, count: bytesRead ?? 0)
                
                sendAudioDataToLambda(data: data)
            }
            
            audioStream?.close()
        }
    }
    
    func sendAudioDataToLambda(data: Data) {
        let url = URL(string: "https://28tc3d25ic.execute-api.us-east-1.amazonaws.com/default/get-emotion")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        
        // Send the request asynchronously
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error sending audio data: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
   
    
}
