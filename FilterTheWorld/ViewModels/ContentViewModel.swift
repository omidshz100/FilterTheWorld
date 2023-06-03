import Foundation
import CoreImage

class ContentViewModel: ObservableObject {
  
  @Published var frame: CGImage?
  @Published var error: Error?
  private let cameraManager = CameraManager.shared

  private let frameManager = FrameManager.shared

  /// Adding Image fillter business logic
  var comicFilter = false
  var monoFilter = false
  var crystalFilter = false
  private let context = CIContext()
  /// Ending of adding business logic
  ////

  
  init() {
    setupSubscriptions()
  }
  
  func setupSubscriptions() {
    //------------
    cameraManager.$error
      
      .receive(on: RunLoop.main)
      
      .map { $0 }
      
      .assign(to: &$error)
    //-------------------
    frameManager.$current
      .receive(on: RunLoop.main)
      .compactMap { $0 }
      .compactMap { buffer in
        // 1
        guard let image = CGImage.create(from: buffer) else {
          return nil
        }
        // 2
        var ciImage = CIImage(cgImage: image)
        // 3
        if self.comicFilter {
          ciImage = ciImage.applyingFilter("CIComicEffect")
        }
        if self.monoFilter {
          ciImage = ciImage.applyingFilter("CIPhotoEffectNoir")
        }
        if self.crystalFilter {
          ciImage = ciImage.applyingFilter("CICrystallize")
        }
        // 4
        return self.context.createCGImage(ciImage, from: ciImage.extent)
      }
      .assign(to: &$frame)

    //------------------------
  }
}
