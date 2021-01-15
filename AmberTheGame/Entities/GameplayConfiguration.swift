import Foundation
import CoreGraphics

struct GameplayConfiguration {
  
  struct Amber {
    /// The radius of the agent associated with this `Amber` for pathfinding.
    static let agentRadius: Float = 40
    
    /// Период времени, в течение которого `Amber` остается в состоянии `AttackState`.
    static let hitStateDuration: TimeInterval = 0.4
    
    /// Период времени, в течение которого `Amber` остается в состоянии `DamageState`.
    static let damageStateDuration: TimeInterval = 0.4
  }
  
  struct Enemy {
    /// The radius of the path along which an agent travels when hunting.
    static let huntPathRadius: Float = 5
    
    /// The radius of the path along which an agent patrols.
    static let patrolPathRadius: Float = 5
    
    /// The buffer radius (in points) to add to polygon obstacles when calculating agent pathfinding.
    static let pathfindingGraphBufferRadius: Float = 40
  }
  
  struct SceneManager {
    /// The duration of a transition between loaded scenes.
    static let transitionDuration: TimeInterval = 2.0
    
    /// The duration of a transition from the progress scene to its loaded scene.
    static let progressSceneTransitionDuration: TimeInterval = 0.5
  }
}
