import SwiftUI
struct ContentView: View {
    @State private var isRecording = false
    @State private var currentEmotion: Emotion = .neutral
    @State private var timer: Timer?
    @State private var counter = 0
    let emotions: [Emotion] = [.neutral, .sadness, .happiness, .anger, .fear]
    var body: some View {
        VStack {
            Text(currentEmotion.rawValue)
                .font(.title)
            EmojiView(emotion: currentEmotion)
                .font(.system(size: 80))
            Button(action: {
                isRecording.toggle()
                if isRecording {
                    startEmotionTimer()
                } else {
                    stopEmotionTimer()
                }
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .foregroundColor(isRecording ? Color.red : Color.green)
                    .font(.headline)
                    .cornerRadius(10)
            }
        }
    }
    private func startEmotionTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            currentEmotion = emotions[counter]
            counter = (counter + 1) % emotions.count
        }
    }
    
    private func stopEmotionTimer() {
        timer?.invalidate()
        timer = nil
        currentEmotion = .neutral
        counter = 0
    }
}
struct EmojiView: View {
    let emotion: Emotion
    var body: some View {
        switch emotion {
            
        case .neutral:
            return Text("😐")
        case .sadness:
            return Text("😢")
        case .happiness:
            return Text("😃")
        case .anger:
            return Text("😡")
        case .fear:
            return Text("😨")
        }
    }
}
enum Emotion: String {
    
    case neutral = "Neutral"
    case sadness = "Sadness"
    case happiness = "Happiness"
    case anger = "Anger"
    case fear = "Fear"

}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()

    }

}
