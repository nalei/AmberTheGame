import SpriteKit
import GameplayKit

class IntelligenceComponent: GKComponent {
  // MARK: - Properties

  var stateMachine: GKStateMachine!
  
  
  // MARK: - Initializers
  
  override init() {
    super.init()
    
    stateMachine = GKStateMachine(states: [
      AgentControlledState(intelligenceComponent: self)
    ])
    
    stateMachine.enter(AgentControlledState.self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    stateMachine.update(deltaTime: seconds)
  }
}
