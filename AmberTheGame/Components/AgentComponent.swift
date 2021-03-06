import GameplayKit

class AgentComponent: GKAgent2D, GKAgentDelegate {
  
  public func stopAgent() {
    if let entity = entity as? Enemy {
      switch entity.mandate {
        case .passiveAgent:
          return
        default:
          entity.agent.delegate = nil
      }
    }
  }
  
  public func startAgent() {
    if let entity = entity as? Enemy {
      switch entity.mandate {
        case .passiveAgent:
          return
        default:
          if entity.agent.delegate == nil {
            entity.agent.delegate = entity
          }
      }
    }
  }
}
