import SpriteKit
import GameplayKit

struct CollisionCategory: OptionSet {
  let rawValue: UInt32
  
  static let PLAYER  = CollisionCategory(rawValue: 1 << 0).rawValue // bitmask is ...00000001
  static let GROUND  = CollisionCategory(rawValue: 1 << 1).rawValue // bitmask is ...00000010
  static let ENEMY   = CollisionCategory(rawValue: 1 << 2).rawValue // bitmask is ...00000100
}

struct Collision {
  enum Direction {
    case None, Top, Bottom, Left, Right
  }
}
