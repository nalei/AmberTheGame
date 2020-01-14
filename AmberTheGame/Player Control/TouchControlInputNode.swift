import SpriteKit


protocol ControlInputSourceDelegate : class {
  func follow(command : String?)
}

/// Виртуальный геймпад
class TouchControlInputNode: SKSpriteNode {
  // MARK: Properties
  
  weak var inputDelegate : ControlInputSourceDelegate?
  
  var alphaUnpressed:CGFloat = 0.8
  var alphaPressed:CGFloat   = 1
  
  var allButtons     = [SKSpriteNode]()
  var pressedButtons = Set<SKSpriteNode>()
  
  let buttonDirLeft  = SKSpriteNode(imageNamed: "button-left")
  let buttonDirRight = SKSpriteNode(imageNamed: "button-right")
  let buttonA        = SKSpriteNode(imageNamed: "button-A")
  
  // MARK: Initialization
  
  init(frame: CGRect) {
    super.init(texture: nil, color: UIColor.clear, size: frame.size)
    
    setupControls(size: frame.size)
    isUserInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupControls(size : CGSize) {
    addButton(button: buttonDirLeft,
              position: CGPoint(x: -(size.width / 2) + 100, y: -(size.height / 2) + 100),
              name: "left",
              scale: 1.5)
    addButton(button: buttonDirRight,
              position: CGPoint(x: -(size.width / 2) + 250, y: -(size.height / 2) + 100),
              name: "right",
              scale: 1.5)
    addButton(button: buttonA,
              position: CGPoint(x: (size.width / 2 ) - 100, y: -(size.height / 2)  + 100),
              name: "A",
              scale: 1.5)
  }
  
  func addButton(button: SKSpriteNode, position: CGPoint, name: String, scale: CGFloat) {
    button.position = position
    button.setScale(scale)
    button.name = name
    button.zPosition = 10
    button.alpha = alphaUnpressed
    allButtons.append(button)
    self.addChild(button)
  }
  
  // MARK: UIResponder
  
  func buttonPressed(_ button: SKSpriteNode) {
    let insertionResult = pressedButtons.insert(button)
    if insertionResult.inserted {
      button.alpha = alphaPressed
      
      if let buttonName = button.name {
        inputDelegate?.follow(command: "\(String(describing: buttonName))")
      }
    }
  }
  
  func buttonUnpressed(_ button: SKSpriteNode) {
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
  
  func touchStop(touches: Set<UITouch>) {
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
