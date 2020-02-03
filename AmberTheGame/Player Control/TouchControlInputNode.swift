import SpriteKit

protocol ControlInputSourceDelegate : class {
  func follow(command : String?)
}

/// Виртуальный геймпад
class TouchControlInputNode: SKSpriteNode {
  weak var inputDelegate : ControlInputSourceDelegate?
  
  var alphaUnpressed:CGFloat = 0.8
  var alphaPressed:CGFloat   = 1
  
  var allButtons     = [ButtonNode]()
  var pressedButtons = Set<ButtonNode>()
  
  init(frame: CGRect) {
    super.init(texture: nil, color: UIColor.clear, size: frame.size)
    
    let buttonDirLeft  = ButtonNode(iconName: "shevron-arrow", color: .clear)
    let buttonDirRight = ButtonNode(iconName: "shevron-arrow", color: .clear)
    let buttonJump     = ButtonNode(iconName: "shevron-arrow", color: .clear)
    
    addButton(button: buttonDirLeft,
              position: CGPoint(
                x: -(size.width / 2) + 100,
                y: -(size.height / 2) + 100),
              rotation: 0,
              name: "left")
    
    addButton(button: buttonDirRight,
              position: CGPoint(
                x: -(size.width / 2) + 250,
                y: -(size.height / 2) + 100),
              rotation: .pi,
              name: "right")
    
    addButton(button: buttonJump,
              position: CGPoint(
                x: (size.width / 2 ) - 100,
                y: -(size.height / 2)  + 100),
              rotation: -(.pi / 2),
              name: "jump")
    
    isUserInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func addButton(button: ButtonNode, position: CGPoint, rotation: CGFloat, name: String) {
    button.size = CGSize(width: 150, height: 150)
    button.position = position
    button.name = name
    button.zRotation = rotation
    button.zPosition = 10
    button.alpha = alphaUnpressed
    allButtons.append(button)
    self.addChild(button)
  }
  
  // MARK: UIResponder
  
  private func buttonPressed(_ button: ButtonNode) {
    let insertionResult = pressedButtons.insert(button)
    if insertionResult.inserted {
      button.alpha = alphaPressed
      
      if let buttonName = button.name {
        inputDelegate?.follow(command: "\(String(describing: buttonName))")
      }
    }
  }
  
 private func buttonUnpressed(_ button: ButtonNode) {
    if let _ = pressedButtons.remove(button) {
      button.alpha = alphaUnpressed
      
      if let buttonName = button.name {
        inputDelegate?.follow(command: "stop \(String(describing: buttonName))")
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    for touch in touches {
      let touchPoint = touch.location(in: self)
      
      for button in allButtons {
        if button.contains(touchPoint) {
          buttonPressed(button)
        }
      }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    
    for touch in touches {
      let touchPoint = touch.location(in: self)
      let previousTouchPoint = touch.previousLocation(in: self)
      
      for button in allButtons {
        
        // Если касание перемещается на кнопку которая ещё не нажата
        if !button.contains(previousTouchPoint) && button.contains(touchPoint) {
          buttonPressed(button)
        }
          // Если касание покидает кнопку
        else if button.contains(previousTouchPoint) && !button.contains(touchPoint) {
          buttonUnpressed(button)
        }
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    touchStop(touches: touches)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    
    touchStop(touches: touches)
  }
  
  private func touchStop(touches: Set<UITouch>) {
    // Если нет нажатых кнопок, выходим немедленно
    guard !pressedButtons.isEmpty else { return }
    
    for touch in touches {
      let touchPoint = touch.location(in: self)
      
      for button in allButtons {
        
        if button.contains(touchPoint) {
          buttonUnpressed(button)
        }
      }
    }
  }
}
