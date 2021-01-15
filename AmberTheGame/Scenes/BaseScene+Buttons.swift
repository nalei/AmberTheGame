import Foundation

/// Расширение `BaseScene` для ответа на события `ButtonNode`.
extension BaseScene: ButtonNodeResponderType {
  
  // MARK: ButtonNodeResponderType
  func buttonTriggered(button: ButtonNode) {
    
    switch button.buttonIdentifier! {
      case .proceedToNextScene:
        sceneManager.presentScene(identifier: .level)
    }
  }
}
