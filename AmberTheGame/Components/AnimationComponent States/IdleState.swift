import SpriteKit
import GameplayKit

class IdleState: GKState {
  // MARK: - Properties
  
  unowned var entity: GKEntity
  
  var idleAnimation: SKTexture
  
  var totalSeconds:Int = 0
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
      fatalError("A IdleState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  required init(entity: GKEntity, idleAnimation: SKTexture?) {
    self.entity = entity
    self.idleAnimation = idleAnimation!
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    spriteComponent.node.texture = idleAnimation
    
    //    let pulsed = SKAction.sequence([
    //      SKAction.fadeAlpha(to: 1, duration: 0.1),
    //      SKAction.wait(forDuration: 0.1),
    //      SKAction.fadeAlpha(to: 0 , duration: 0.1)])
    //    spriteComponent.node.run(SKAction.repeatForever(pulsed))
    
    startTimer()
    
    if previousState is FallingState {
      spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // `Amber` моргает
    if entity is Amber {
      if totalSeconds == 5 {
        spriteComponent.node.run(SKAction(named: "amber-blinks")!, withKey: "blinks")
        totalSeconds = 0
      }
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    stopTimer()
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is WalkingState.Type, is JumpingState.Type, is FallingState.Type, is HitState.Type, is DamageState.Type:
      return true
    case is IdleState.Type:
      return false
    default:
      return false
    }
  }
  
  
  // MARK: - Convenience
  
  private func startTimer() {
    let wait: SKAction = SKAction.wait(forDuration: 1)
    let finishTimer: SKAction = SKAction.run {
      self.totalSeconds += 1
      self.startTimer()
    }
    
    let seq:SKAction = SKAction.sequence([wait, finishTimer])
    spriteComponent.node.run(seq, withKey: "timer")
  }
  
  private func stopTimer() {
    self.totalSeconds = 0
    spriteComponent.node.removeAction(forKey: "timer")
  }
}
