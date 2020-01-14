import SpriteKit


// Протокол управления событиями
protocol ControlInputSourceDelegate : class {
  func follow(command : String?)
}

class TouchControlInputNode: SKSpriteNode {
  var inputDelegate : ControlInputSourceDelegate?
  
  var alphaUnpressed:CGFloat = 0.8
  var alphaPressed:CGFloat   = 1
  
  var allButtons     = [SKSpriteNode]()
  var pressedButtons = Set<SKSpriteNode>()
  
  let buttonDirLeft  = SKSpriteNode(imageNamed: "button-left")
  let buttonDirRight = SKSpriteNode(imageNamed: "button-right")
  let buttonA        = SKSpriteNode(imageNamed: "button-A")
  
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
  
  func setAlphaStatus(_ button: SKSpriteNode) {
    if pressedButtons.firstIndex(of: button) == nil {
      button.alpha = alphaUnpressed
    } else {
      button.alpha = alphaPressed
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let touchPoint = touch.location(in: self)
      
      for button in allButtons {
        
        if button.contains(touchPoint) && !pressedButtons.contains(button) {
          pressedButtons.insert(button)
          inputDelegate?.follow(command: button.name!)
        }
        
        setAlphaStatus(button)
      }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let touchPoint = touch.location(in: self)
      let previousTouchPoint = touch.previousLocation(in: self)
      
      for button in allButtons {
        
        // если касание покидает кнопку
        if button.contains(previousTouchPoint) && !button.contains(touchPoint) {
          if let _ = pressedButtons.remove(button) {
            inputDelegate?.follow(command: "cancel \(String(describing: button.name!))")
          }
        }
        // если касание перемещается на кнопку которая ещё не нажата
        else if !button.contains(previousTouchPoint) && button.contains(touchPoint) && !pressedButtons.contains(button) {
          pressedButtons.insert(button)
          inputDelegate?.follow(command: button.name!)
        }
        
        setAlphaStatus(button)
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchStop(touches: touches)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchStop(touches: touches)
  }
  
  func touchStop(touches: Set<UITouch>) {
    for touch in touches {
      let touchPoint = touch.location(in: self)
      
      for button in allButtons {
        
        if button.contains(touchPoint) {
          if let _ = pressedButtons.remove(button) {
            inputDelegate?.follow(command: "stop \(String(describing: button.name!))")
          }
        }
        
        setAlphaStatus(button)
      }
    }
  }
}
