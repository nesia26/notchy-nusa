import SwiftUI
import MediaPlayer
import AVFoundation
import Combine

public struct RealTrackInfo {
    public var title: String
    public var artist: String
    public var artwork: UIImage?
    public var duration: Double
    public var hasTrack: Bool
}

public class MusicManager: ObservableObject {
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: Double = 0.0
    @Published public var volume: Float = 0.8
    @Published public var currentTrack: RealTrackInfo = RealTrackInfo(
        title: "Not Playing",
        artist: "Play music on iPad to sync",
        artwork: nil,
        duration: 0.0,
        hasTrack: false
    )
    
    private let systemPlayer = MPMusicPlayerController.systemMusicPlayer
    private var pollTimer: Timer?
    private var volumeObserver: NSKeyValueObservation?
    
    public init() {
        setupPlayer()
        setupVolumeListener()
        updateNowPlaying()
    }
    
    deinit {
        systemPlayer.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
        pollTimer?.invalidate()
        volumeObserver?.invalidate()
    }
    
    private func setupPlayer() {
        // Request authorization to access Media Library
        MPMediaLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.updateNowPlaying()
            }
        }
        
        systemPlayer.beginGeneratingPlaybackNotifications()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackChange),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: systemPlayer
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange),
            name: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: systemPlayer
        )
        
        // Timer to poll current playback time & check updates
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.pollPlaybackTime()
        }
    }
    
    private func setupVolumeListener() {
        let session = AVAudioSession.sharedInstance()
        volume = session.outputVolume
        
        volumeObserver = session.observe(\.outputVolume, options: [.new]) { [weak self] session, _ in
            DispatchQueue.main.async {
                self?.volume = session.outputVolume
            }
        }
    }
    
    @objc private func handleTrackChange() {
        DispatchQueue.main.async {
            self.updateNowPlaying()
        }
    }
    
    @objc private func handleStateChange() {
        DispatchQueue.main.async {
            self.isPlaying = (self.systemPlayer.playbackState == .playing)
        }
    }
    
    private func pollPlaybackTime() {
        if systemPlayer.playbackState == .playing {
            isPlaying = true
            currentTime = systemPlayer.currentPlaybackTime
        } else {
            isPlaying = false
        }
    }
    
    public func updateNowPlaying() {
        if let item = systemPlayer.nowPlayingItem {
            let title = item.title ?? "Unknown Title"
            let artist = item.artist ?? item.albumArtist ?? "Unknown Artist"
            let duration = item.playbackDuration
            let art = item.artwork?.image(at: CGSize(width: 120, height: 120))
            
            self.currentTrack = RealTrackInfo(
                title: title,
                artist: artist,
                artwork: art,
                duration: duration > 0 ? duration : 180.0,
                hasTrack: true
            )
            self.isPlaying = (systemPlayer.playbackState == .playing)
            self.currentTime = systemPlayer.currentPlaybackTime
        } else {
            // No native queue item active yet
            self.currentTrack = RealTrackInfo(
                title: "Not Playing",
                artist: "Play music on iPad to sync",
                artwork: nil,
                duration: 0.0,
                hasTrack: false
            )
            self.isPlaying = false
            self.currentTime = 0.0
        }
    }
    
    // MARK: - Player Controls
    public func togglePlayPause() {
        if systemPlayer.playbackState == .playing {
            systemPlayer.pause()
            isPlaying = false
        } else {
            systemPlayer.play()
            isPlaying = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateNowPlaying()
        }
    }
    
    public func nextTrack() {
        systemPlayer.skipToNextItem()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateNowPlaying()
        }
    }
    
    public func prevTrack() {
        systemPlayer.skipToPreviousItem()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateNowPlaying()
        }
    }
    
    public func seek(to time: Double) {
        systemPlayer.currentPlaybackTime = time
        currentTime = time
    }
}
