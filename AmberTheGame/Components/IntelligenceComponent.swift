import SpriteKit
import GameplayKit

class IntelligenceComponent: GKComponent {
  // MARK: - Properties
  
  var stateMachine: GKStateMachine
  
  let initialStateClass: AnyClass
  
  
  // MARK: - Initializers
  init(states: [GKState]) {
    stateMachine = GKStateMachine(states: states)
    let firstState = states.first!
    initialStateClass = type(of: firstState)
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)

    stateMachine.update(deltaTime: seconds)
  }
  
  
  // MARK: - Actions
  
  public func enterInitialState() {
    stateMachine.enter(initialStateClass)
  }
}
