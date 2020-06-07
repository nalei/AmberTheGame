import GameplayKit

class AgentComponent: GKAgent2D {
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    if let entity = entity as? Enemy {
      entity.agent.behavior = entity.behaviorForCurrentMandate
    }
    
  }
}
