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
  
  var allButtons     = [ButtonNode]()
  var pressedButtons = Set<ButtonNode>()
  
  // MARK: Initialization
  
  init(frame: CGRect) {
    super.init(texture: nil, color: UIColor.clear, size: frame.size)
    
    drawBorder(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), width: 2)
    
    let buttonDirLeft  = ButtonNode(iconName: "shevron-arrow", color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    let buttonDirRight = ButtonNode(iconName: "shevron-arrow", color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    let buttonJump     = ButtonNode(iconName: "shevron-arrow", color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    
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
  
  func addButton(button: ButtonNode, position: CGPoint, rotation: CGFloat, name: String) {
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
  
  func buttonPressed(_ button: ButtonNode) {
    let insertionResult = pressedButtons.insert(button)
    if insertionResult.inserted {
      button.alpha = alphaPressed
      
      if let buttonName = button.name {
        inputDelegate?.follow(command: "\(String(describing: buttonName))")
      }
    }
  }
  
  func buttonUnpressed(_ button: ButtonNode) {
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


extension SKSpriteNode {
    func drawBorder(color: UIColor, width: CGFloat) {
        let shapeNode = SKShapeNode(rect: frame)
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = color
        shapeNode.lineWidth = width
        addChild(shapeNode)
    }
}
