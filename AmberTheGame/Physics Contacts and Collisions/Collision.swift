import SpriteKit
import GameplayKit

struct CollisionCategory: OptionSet {
  let rawValue: UInt32
  static let PLAYER   = CollisionCategory(rawValue: 0x1 << 0)
  static let GROUND   = CollisionCategory(rawValue: 0x1 << 1)
  static let ENEMY    = CollisionCategory(rawValue: 0x1 << 2)
}

struct Collision {
  enum Direction {
    case None, Top, Bottom, Left, Right
  }
}
