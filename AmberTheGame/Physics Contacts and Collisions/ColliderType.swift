/*
 Набор параметров, используемый для категоризации физических тел в физическом мире SpriteKit.
 */

import SpriteKit
import GameplayKit

struct ColliderType: OptionSet, Hashable {
  enum Direction {
    case none, top, bottom, left, right
  }
  
  // MARK: - Static properties
  
  /// Словарь, указывает, какой `ColliderType` должен получать уведомления о контактах с другим `ColliderType`.
  static var requestedContactNotifications = [ColliderType: [ColliderType]]()
  
  /// Словарь,  указывает какой `ColliderType` должен сталкиваться в физическом мире с другим ` ColliderType`.
  static var definedCollisions = [ColliderType: [ColliderType]]()
  
  
  // MARK: - Properties
  
  let rawValue: UInt32
  
  
  // MARK: - Options
  
  static var PLAYER: ColliderType { return self.init(rawValue: 1 << 0) } // bitmask is ...00000001
  static var GROUND: ColliderType { return self.init(rawValue: 1 << 1) } // bitmask is ...00000010
  static var ENEMY:  ColliderType { return self.init(rawValue: 1 << 2) } // bitmask is ...00000100
  
  
  // MARK: - SpriteKit Physics Convenience
  
  /// Значение, которое  будет  присвоено свойству `categoryBitMask` физического тела объекта.
  var categoryMask: UInt32 {
    return rawValue
  }
  
  /// Значение, которое  будет  присвоено свойству `collisionBitMask` физического тела объекта.
  var collisionMask: UInt32 {
    // Combine all of the collision requests for this type using a bitwise or.
    let mask = ColliderType.definedCollisions[self]?.reduce(ColliderType()) { initial, colliderType in
      return initial.union(colliderType)
    }
    
    // Provide the rawValue of the resulting mask or 0 (so the object doesn't collide with anything).
    return mask?.rawValue ?? 0
  }
  
  /// Значение, которое  будет  присвоено свойству `contactTestBitMask` физического тела объекта.
  var contactMask: UInt32 {
    // Combine all of the contact requests for this type using a bitwise or.
    let mask = ColliderType.requestedContactNotifications[self]?.reduce(ColliderType()) { initial, colliderType in
      return initial.union(colliderType)
    }
    
    // Provide the rawValue of the resulting mask or 0 (so the object doesn't need contact callbacks).
    return mask?.rawValue ?? 0
  }
  
  
  // MARK: - ContactNotifiableType Convenience
  
  /**
   Возвращает true, если `ContactNotifiableType`, связанный с этим `ColliderType`, должен быть
   уведомлен о контакте с переданным `ColliderType`.
   */
  func notifyOnContactWith(_ colliderType: ColliderType) -> Bool {
    if let requestedContacts = ColliderType.requestedContactNotifications[self] {
      return requestedContacts.contains(colliderType)
    }
    
    return false
  }
}
