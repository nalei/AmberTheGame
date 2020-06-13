import Foundation
import CoreGraphics

struct GameplayConfiguration {
  
  struct Amber {
    /// The radius of the agent associated with this `Amber` for pathfinding.
    static let agentRadius: Float = 50
  }
  
  struct Enemy {
    /// The radius of the path along which an agent travels when hunting.
    static let huntPathRadius: Float = 5
    
    /// The radius of the path along which an agent patrols.
    static let patrolPathRadius: Float = 10
    
    /// The buffer radius (in points) to add to polygon obstacles when calculating agent pathfinding.
    static let pathfindingGraphBufferRadius: Float = 40
  }
}
