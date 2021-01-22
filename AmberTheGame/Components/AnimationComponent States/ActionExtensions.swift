import SpriteKit

extension SKAction {
  class func pulsedWhite(node: SKSpriteNode) -> SKAction {
    let actionsList: [SKAction] = [
      SKAction.run({node.shader = Amber.blinckShader}),
      SKAction.wait(forDuration: 0.15),
      SKAction.run({node.shader = nil}),
    ]

    return SKAction.sequence(actionsList)
  }
}
