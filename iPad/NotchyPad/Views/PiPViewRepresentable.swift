import SwiftUI
import UIKit

public struct PiPViewRepresentable: UIViewRepresentable {
    @ObservedObject var pipManager: PiPManager
    let hostingController: UIViewController

    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 340, height: 46))
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            pipManager.setupPiP(with: view, hostingController: hostingController)
        }
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}
}
