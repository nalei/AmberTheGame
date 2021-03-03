/*
 ButtonNode - настраиваемый SKSpriteNode, который обеспечивает поведение кнопок в сцене SpriteKit.
 ButtonNodeResponderType - протокол для классов, которые могут реагировать на нажатия кнопок.
 ButtonIdentifier - перечисление, определяющее все типы кнопок, которые поддерживаются в игре.
 */
import SpriteKit

/// Тип, который может реагировать на события нажатия кнопки `ButtonNode`.
@objc protocol ButtonNodeResponderType: class {
  /// Колбэк на нажатие кнопки.
  @objc func buttonTriggered(button: ButtonNode)
}

/// Полный набор идентификаторов кнопок, поддерживаемых в приложении.
enum ButtonIdentifier: String {
  case proceedToNextScene = "ProceedToNextScene"
}

/// Настраиваемый `SKSpriteNode`, который представляет кнопку в сцене.
class ButtonNode: SKSpriteNode {
  // MARK: - Properties
  
  /// Идентификатор этой кнопки, создается из ее имени в сцене.
  var buttonIdentifier: ButtonIdentifier!
  
  /**
   Сцена, содержащая `ButtonNode`, должна быть `ButtonNodeResponderType`,
   так что события касания будут вызывать метод `buttonTriggered()`.
   */
  var responder: ButtonNodeResponderType {
    guard let responder = scene as? ButtonNodeResponderType else {
      fatalError("ButtonNode may only be used within a `ButtonNodeResponderType` scene.")
    }
    return responder
  }
  
  /// Указывает, что кнопка нажата
  var isHighlighted = false {
    // Анимация в нажатом / не нажатом состоянии.
    didSet {
      // Защита от повторения одного и того же действия.
      guard oldValue != isHighlighted else { return }
      
      // Удаляем все существующие анимации, которые могут быть в процессе.
      removeAllActions()
      
      // Создаем анимацию масштабирования, чтобы кнопка выглядела слегка нажатой.
      let newScale: CGFloat = isHighlighted ? 0.99 : 1.01
      let scaleAction = SKAction.scale(by: newScale, duration: 0.15)
      
      // Создаем анимацию наложения цветов, чтобы немного затемнить кнопку, когда она нажата.
      let newColorBlendFactor: CGFloat = isHighlighted ? 1.0 : 0.0
      let colorBlendAction = SKAction.colorize(withColorBlendFactor: newColorBlendFactor, duration: 0.15)
      
      // Выполняем действия одновременно.
      run(SKAction.group([scaleAction, colorBlendAction]))
    }
  }
  
  /// Текстура кнопки по умолчанию
  var defaultTexture: SKTexture?
  
  
  // MARK: - Initializers
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    // Проверяем, что в качестве имени узла указан поддерживаемый идентификатор кнопки.
    guard let nodeName = name, let buttonIdentifier = ButtonIdentifier(rawValue: nodeName) else {
      fatalError("Unsupported button name found.")
    }
    self.buttonIdentifier = buttonIdentifier
    
    // Сохраняем текстуру кнопки по умолчанию (взятую из ее текстуры в сцене).
    defaultTexture = texture
  }
  
  func buttonTriggered() {
    // Пробрасываем событие нажатия кнопки в сцену.
    responder.buttonTriggered(button: self)
  }
  
  
  // MARK: - Responder
  
  /// Обработка касаний UIResponder.
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    isHighlighted = true
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    isHighlighted = false
    
    // Нажатие.
    if containsTouches(touches: touches) {
      buttonTriggered()
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
    super.touchesCancelled(touches!, with: event)
    
    isHighlighted = false
  }
  
  /// Определяет, находится ли какое-либо из касаний в пределах  `ButtonNode`.
  private func containsTouches(touches: Set<UITouch>) -> Bool {
    guard let scene = scene else { fatalError("Button must be used within a scene.") }
    
    return touches.contains { touch in
      let touchPoint = touch.location(in: scene)
      let touchedNode = scene.atPoint(touchPoint)
      return touchedNode === self || touchedNode.inParentHierarchy(self)
    }
  }
}
