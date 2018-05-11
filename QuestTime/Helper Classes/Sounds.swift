import Foundation
import AVFoundation

enum Sound: String {
    case buttonClick
}

class Sounds {
    
    public static var shared = Sounds()
    
    var audioPlayer: AVAudioPlayer?
    var muted: Bool = false
    
    init() {
        if let soundOn = UserDefaults.standard.value(forKey: Constants.UserDefaults.sound) as? Bool {
            muted = !soundOn
        }
    }
    
    func play(sound: Sound) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = audioPlayer else { return }
            
            audioPlayer?.volume = muted ? 0 : 1
            
            player.play()
        } catch let error {
            print(error)
        }
    }
    
    func toggleMute() {
        muted = !muted
    }
}
