import SpriteKit
import GameplayKit

struct ColliderType {
  static let PLAYER: UInt32 = 0x1 << 0
  static let GROUND: UInt32 = 0x1 << 1
  static let ENEMY: UInt32  = 0x1 << 2
//  static let GROUNDDETECTOR: UInt32 = 0x1 << 2
}

struct Collision {
  enum Direction {
    case None, Top, Bottom, Left, Right
  }
}
