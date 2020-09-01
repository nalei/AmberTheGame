import GameplayKit

class AgentComponent: GKAgent2D, GKAgentDelegate {
  var previousPosition = vector_float2(x: 0, y: 0)
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    if let entity = entity as? Enemy {
      entity.agent.behavior = entity.behaviorForCurrentMandate
    }
  }
  
  public func stopAgent() {
    if let entity = entity as? Enemy {
      entity.agent.delegate = nil
    }
  }
  
  public func continueAgent() {
    if let entity = entity as? Enemy {
      if entity.agent.delegate == nil {
        entity.agent.delegate = entity
      }
    }
  }
}
