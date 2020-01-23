import GameplayKit

class ActionComponent : GKComponent {

  @GKInspectable var walkSpeed: CGFloat = 1.6
  @GKInspectable var runSpeed: CGFloat = 3.3
  @GKInspectable var maxJump: CGFloat  = 50.0

  var hSpeed: CGFloat = 0.0
  var vSpeed: CGFloat = 0.0
  var direction: CGFloat = -1.0

  var runMode = false
  var onGround = false

  func moveLeft() {
    direction = -1.0
    startMoving()
  }

  func moveRight() {
    direction = 1.0
    startMoving()
  }

  func startMoving() {
    let stateMachine = (self.entity as! Amber).stateMachine

    if runMode {
      hSpeed = direction * runSpeed
      if (stateMachine?.canEnterState(RunningState.self))! && onGround{
        stateMachine?.enter(RunningState.self)
      }
    }else{
      hSpeed = direction * walkSpeed
      if (stateMachine?.canEnterState(WalkingState.self))! && onGround{
        stateMachine?.enter(WalkingState.self)
      }
    }
  }

  func stopMoving(){
    hSpeed = 0
    if let node = entity?.component(ofType: GKSKNodeComponent.self)?.node {
      node.physicsBody?.velocity = CGVector(dx: 0, dy: (node.physicsBody?.velocity.dy)!)
      if (node.physicsBody?.velocity.dy)! == 0{
        (self.entity as! CharacterEntity).st_machine?.enter(IdleState.self)
      }
    }
  }

  func jump(){
    if let node = entity?.component(ofType: GKSKNodeComponent.self)?.node {
      if (onGround == true){
        node.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: maxJump))
        (self.entity as! CharacterEntity).st_machine?.enter(JumpingState.self)
        onGround = false
      }
    }
  }

  func getDown(){
    if let pdown = self.entity?.component(ofType: GKSKNodeComponent.self)?.node as? PlayerNode {
      pdown.pressingDown = true
    }
  }

  func stopDown(){
    if let pdown = self.entity?.component(ofType: GKSKNodeComponent.self)?.node as? PlayerNode {
      pdown.pressingDown = false
    }
  }

  func beginRun(){
    runMode = true
  }

  func stopRun(){
    runMode = false
  }

  func attack(){
    if let attackComp = self.entity?.component(ofType: AttackComponent.self) {
      attackComp.attack()
    } else {
      print("no attack component attached")
    }
  }

  override init() {
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)

    let stateMachine = (self.entity as! CharacterEntity).st_machine

    if let node = entity?.component(ofType: GKSKNodeComponent.self)?.node {

      if (node.physicsBody?.velocity.dy)! == 0 {
        if (hSpeed == 0){
          if (stateMachine?.canEnterState(IdleState.self))! {
            stateMachine?.enter(IdleState.self)
          }
        } else {

          if (runMode){
            if (stateMachine?.canEnterState(RunningState.self))!{
              stateMachine?.enter(RunningState.self)
              hSpeed = direction * runSpeed
            }
          }else if (stateMachine?.canEnterState(WalkingState.self))!{
            stateMachine?.enter(WalkingState.self)
            hSpeed = direction * walkSpeed
          }

        }
      } else if (node.physicsBody?.velocity.dy)! < -0.1 {
        if (stateMachine?.canEnterState(FallingState.self))!{
          stateMachine?.enter(FallingState.self)
        }
      }

      node.position.x = node.position.x + hSpeed
      if (hSpeed > 0){
        node.xScale = -1
      }else if (hSpeed < 0){
        node.xScale = 1
      }
    }
  }
}
