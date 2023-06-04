import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    var session: WCSession?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation completion
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // Handle received application context
        if let primaryEmotion = applicationContext["primary_emotion"] as? String,
           let confidenceScore = applicationContext["confidence_score"] as? Double {
            // Use the received primaryEmotion and confidenceScore variables
            // for further processing or display on the Apple Watch interface
            print("Primary Emotion: \(primaryEmotion)")
            print("Confidence Score: \(confidenceScore)")
        }
    }
}
