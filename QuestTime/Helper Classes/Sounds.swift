import Foundation
import AVFoundation

class Sounds {
    
    public static var shared = Sounds()
    
    var audioPlayer: AVAudioPlayer?
    
    func playButtonSound() {
        guard let url = Bundle.main.url(forResource: "buttonClick", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = audioPlayer else { return }
            
            player.play()
        } catch let error {
            print(error)
        }
    }
}
