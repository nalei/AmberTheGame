import GameplayKit

class NormalState: GKState {
  var character: CharacterNode
  
  init(with node: CharacterNode) {
    self.character = node
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    var accel: CGFloat = 0.0
    var decel: CGFloat = 0.0
    
    if character.grounded {
      accel = character.groundAccel
      decel = character.groundDecel
    } else {
      accel = character.airAccel
      decel = character.airDecel
    }

    if character.left {
      character.facing = -1.0
      character.xScale = -1.0
      character.hSpeed = approach(start: character.hSpeed, end: -character.walkSpeed, shift: accel)
    } else if character.right {
      character.facing = 1.0
      character.xScale = 1.0
      character.hSpeed = approach(start: character.hSpeed, end: character.walkSpeed, shift: accel)
    } else {
      character.hSpeed = approach(start: character.hSpeed, end: 0.0, shift: decel)
    }
    
    if character.grounded {
      if (!character.landed) {
        squashAndSretch(xScale: 1.3, yScale: 0.7)
        character.physicsBody?.velocity = CGVector(dx: (character.physicsBody?.velocity.dx)!, dy: 0.0)
        character.landed = true
      }
      if character.jump {
        character.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: character.maxJump))
        character.grounded = false
        squashAndSretch(xScale: 0.7, yScale: 1.3)
      }
    }

    if !character.grounded {
      if (character.physicsBody?.velocity.dy)! < CGFloat(0.0) {
        character.jump = false
      }
      if ((character.physicsBody?.velocity.dy)! > CGFloat(0.0) && !character.jump) {
        character.physicsBody?.velocity.dy *= 0.5
      }
      character.landed = false
    }
    
    character.xScale = approach(start: character.xScale, end: character.facing, shift: 0.05)
    character.yScale = approach(start: character.yScale, end: 1.0, shift: 0.05)
    
    character.position.x = character.position.x + character.hSpeed
  }
  
  func approach(start: CGFloat, end: CGFloat, shift: CGFloat) -> CGFloat {
    return start < end
    ? min(start + shift, end)
    : max(start - shift, end)
  }
  
  func squashAndSretch(xScale: CGFloat, yScale: CGFloat) {
    character.xScale = xScale * character.facing
    character.yScale = yScale
  }
}
