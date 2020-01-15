import SpriteKit
import GameplayKit

class CharacterNode: SKSpriteNode {
  var left  = false
  var right = false
  
  var jump     = false
  var landed   = false
  var grounded = false
  
  var maxJump: CGFloat = 200.0
  
  var airAccel: CGFloat    = 0.1
  var airDecel: CGFloat    = 0.0
  var groundAccel: CGFloat = 1.1
  var groundDecel: CGFloat = 1.1
  
  var facing: CGFloat = 1.0
  
  var hSpeed   : CGFloat = 0.0
  
  var walkSpeed: CGFloat = 9
  
  var stateMachine: GKStateMachine?
  
  func setUpStateMachine() {
    let normalState = NormalState(with: self)
    stateMachine = GKStateMachine(states: [normalState])
    stateMachine?.enter(NormalState.self)
  }
}
