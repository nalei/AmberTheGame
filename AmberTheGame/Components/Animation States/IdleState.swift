import SpriteKit
import GameplayKit

class IdleState: GKState {
  unowned var animationComponent: AnimationComponent
  
  var totalSeconds:Int = 0
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A IdleState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    spriteComponent.node.texture = animationComponent.idle
    
    //    let pulsed = SKAction.sequence([
    //      SKAction.fadeAlpha(to: 1, duration: 0.1),
    //      SKAction.wait(forDuration: 0.1),
    //      SKAction.fadeAlpha(to: 0 , duration: 0.1)])
    //    spriteComponent.node.run(SKAction.repeatForever(pulsed))
    
    let breathe = SKAction.sequence([
      SKAction.resize(toWidth: 190, height: 215, duration: 1),
      SKAction.wait(forDuration: 0.5),
      SKAction.resize(toWidth: 200, height: 200, duration: 0.7),
      SKAction.wait(forDuration: 0.5)])
    spriteComponent.node.run(SKAction.repeatForever(breathe), withKey: "breathe")
    
    startTimer()
    
    if let _ = previousState as? FallingState {
      spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    if let _ = animationComponent.entity as? Amber {
      if totalSeconds == 5 {
        spriteComponent.node.run(SKAction(named: "amber-blinks")!, withKey: "blinks")
        totalSeconds = 0
      }
    }
  }
  
  override func willExit(to nextState: GKState) {
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
