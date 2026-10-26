import SwiftUI
import AVKit
import AVFoundation

public class PiPManager: NSObject, ObservableObject, AVPictureInPictureControllerDelegate {
    @Published public var isPiPActive: Bool = false
    @Published public var isPiPSupported: Bool = false
    
    private var pipController: AVPictureInPictureController?
    private var sourceView: UIView?
    
    public override init() {
        super.init()
        setupAudioSession()
        isPiPSupported = AVPictureInPictureController.isPictureInPictureSupported()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    public func setupPiP(with sourceView: UIView, hostingController: UIViewController) {
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }
        self.sourceView = sourceView
        
        let callVC = AVPictureInPictureVideoCallViewController()
        callVC.preferredContentSize = CGSize(width: 340, height: 46)
        
        callVC.addChild(hostingController)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 340, height: 46)
        hostingController.view.backgroundColor = .clear
        callVC.view.backgroundColor = .clear
        callVC.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: callVC)
        
        let contentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: sourceView,
            contentViewController: callVC
        )
        
        let controller = AVPictureInPictureController(contentSource: contentSource)
        controller.delegate = self
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        self.pipController = controller
    }
    
    public func togglePiP() {
        guard let pip = pipController else { return }
        if pip.isPictureInPictureActive {
            pip.stopPictureInPicture()
        } else {
            pip.startPictureInPicture()
        }
    }
    
    // MARK: - AVPictureInPictureControllerDelegate
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        DispatchQueue.main.async {
            self.isPiPActive = true
        }
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        DispatchQueue.main.async {
            self.isPiPActive = false
        }
    }
}
