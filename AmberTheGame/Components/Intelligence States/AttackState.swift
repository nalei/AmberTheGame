import SpriteKit
import GameplayKit

class AttackState: GKState {
  // MARK: - Properties
  
  unowned var intelligenceComponent: IntelligenceComponent
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = intelligenceComponent.entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A HitState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  required init(intelligenceComponent: IntelligenceComponent) {
    self.intelligenceComponent = intelligenceComponent
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
  }
  
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)

  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
  }
}
