import Foundation
import WatchConnectivity

class EmotionDataReceiver: NSObject, WCSessionDelegate {
    
    var session: WCSession?
    
    func startReceivingEmotionData() {
        // Initialize and activate the Watch Connectivity session
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        
        // Subscribe to the SNS topic to receive emotion data updates
        let snsTopicArn = "arn:aws:lambda:us-east-1:439088822958:function:get-emotion"  // Replace with your SNS topic ARN
        session?.sendMessage(["subscribe": snsTopicArn], replyHandler: nil, errorHandler: { error in
            print("Failed to subscribe to SNS topic: \(error.localizedDescription)")
        })
    }
    
    // WCSessionDelegate method
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // Handle the received message containing emotion data
        if let emotions = message["emotions"] as? [String],
           let intensity = message["intensity"] as? [Double],
           let confidence = message["confidence"] as? [Double] {
            // Process the received emotion data
            print("Received emotion data:")
            print("Emotions: \(emotions)")
            print("Intensity: \(intensity)")
            print("Confidence: \(confidence)")
            
            // Update UI or perform any required tasks with the received data
            // ...
        }
    }
    
    // WCSessionDelegate method
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch Connectivity activation failed: \(error.localizedDescription)")
        } else {
            print("Watch Connectivity activated")
        }
    }
}
