
import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {


    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!

    var audioPlayer: AVAudioPlayer?
    var currentSongIndex = 0

    let songs = [
        "Mesmerizing Galaxy",
        "Paradise Found",
        "Evening",
        "Morning",
        "Southern Gothic",
        "Sergio's Magic Dustbin",
        "Goblin Tinker Soldier Spy",
        "Grand Dark Waltz Trio Vivace",
        "Grand Dark Waltz Trio Allegro",
        "Adventures in Adventureland"
    ]

    let artists = [
        "Kevin MacLeod",
        "Alex Rivera",
        "Luna Hayes",
        "Ethan Brooks",
        "Sofia Bennett",
        "Oliver Stone",
        "Maya Collins",
        "Noah Sterling",
        "Isabella Reed",
        "Daniel Frost"
    ]

    let covers = [
        "cover1",
        "cover2",
        "cover3",
        "cover4",
        "cover5",
        "cover6",
        "cover7",
        "cover8",
        "cover9",
        "cover10"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        albumImageView.layer.cornerRadius = 18
        albumImageView.clipsToBounds = true
        albumImageView.contentMode = .scaleAspectFill

        updateSong()
        loadCurrentSong()
    }

  
    func updateSong() {
        songTitleLabel.text = songs[currentSongIndex]
        artistLabel.text = artists[currentSongIndex]

        albumImageView.image = UIImage(
            named: covers[currentSongIndex]
        ) ?? UIImage(named: "cover1")
    }


    func loadCurrentSong() {
        audioPlayer?.stop()
        audioPlayer = nil

        let fileName = "song\(currentSongIndex + 1)"

        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: "mp3"
        ) else {
            print("Missing audio file: \(fileName).mp3")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to load audio: \(error)")
        }
    }


    func updatePlayButton(_ button: UIButton) {
        let iconName = audioPlayer?.isPlaying == true
            ? "pause.fill"
            : "play.fill"

        button.setImage(
            UIImage(systemName: iconName),
            for: .normal
        )
    }


    @IBAction func playPauseTapped(_ sender: UIButton) {

        if audioPlayer == nil {
            loadCurrentSong()
        }

        guard let player = audioPlayer else {
            updatePlayButton(sender)
            return
        }

        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }

        updatePlayButton(sender)
    }


    @IBAction func previoustapped(_ sender: UIButton) {

        let wasPlaying = audioPlayer?.isPlaying == true

        currentSongIndex = (
            currentSongIndex - 1 + songs.count
        ) % songs.count

        updateSong()
        loadCurrentSong()

        if wasPlaying {
            audioPlayer?.play()
        }

        syncPlayButton()
    }


    @IBAction func nextTapped(_ sender: UIButton) {

        let wasPlaying = audioPlayer?.isPlaying == true

        currentSongIndex = (
            currentSongIndex + 1
        ) % songs.count

        updateSong()
        loadCurrentSong()

        if wasPlaying {
            audioPlayer?.play()
        }

        syncPlayButton()
    }

    func syncPlayButton() {
        guard let button = view.subviews
            .flatMap({ findButtons(in: $0) })
            .first(where: {
                $0.allTargets.contains(self) &&
                $0.actions(
                    forTarget: self,
                    forControlEvent: .touchUpInside
                )?.contains("playPauseTapped:") == true
            }) else {
            return
        }

        updatePlayButton(button)
    }

    func findButtons(in view: UIView) -> [UIButton] {
        var buttons: [UIButton] = []

        if let button = view as? UIButton {
            buttons.append(button)
        }

        for subview in view.subviews {
            buttons.append(contentsOf: findButtons(in: subview))
        }

        return buttons
    }


    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        guard flag else {
            syncPlayButton()
            return
        }

        currentSongIndex = (
            currentSongIndex + 1
        ) % songs.count

        updateSong()
        loadCurrentSong()
        audioPlayer?.play()
        syncPlayButton()
    }
}

