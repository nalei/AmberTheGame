import GameplayKit

class MoveComponent : GKComponent {
  // MARK: Properties
  
  @GKInspectable var walkSpeed: CGFloat = 3.3
  @GKInspectable var maxJump: CGFloat  = 300.0
  
  var hSpeed: CGFloat = 0.0
  var vSpeed: CGFloat = 0.0
  var facing: CGFloat = -1.0
  
  var onGround: Bool = false
  
  // MARK: Initialization
  
  override init() {
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func moveLeft() {
    facing = -1.0
    startMoving()
  }
  
  func moveRight() {
    facing = 1.0
    startMoving()
  }
  
  func startMoving() {
    hSpeed = facing * walkSpeed
  }
  
  func stopMoving() {
    hSpeed = 0
    if let spriteNode = entity?.component(ofType: SpriteComponent.self)?.node {
      spriteNode.physicsBody?.velocity = CGVector(dx: 0, dy: (spriteNode.physicsBody?.velocity.dy)!)
    }
  }
  
  func jump() {
    if let spriteNode = entity?.component(ofType: SpriteComponent.self)?.node {
      if onGround {
        spriteNode.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: maxJump))
        onGround = false
      }
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    guard let spriteNode = entity?.component(ofType: SpriteComponent.self)?.node else {
      return
    }
    if hSpeed != 0 {
      hSpeed = facing * walkSpeed
    }
    spriteNode.xScale = facing
    spriteNode.position.x = spriteNode.position.x + hSpeed
  }
}
