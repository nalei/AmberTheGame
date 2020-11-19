import SpriteKit

extension SKAction {
  class func shake(initialPosition: CGPoint, duration: Float, amplitudeX: CGFloat = 12, amplitudeY: CGFloat = 3) -> SKAction {
    let startingX = initialPosition.x
    let startingY = initialPosition.y
    let numderOfShakes = duration / 0.015
    var actionsList: [SKAction] = []
    for _ in 1...Int(numderOfShakes) {
      let newXPos = startingX + CGFloat(arc4random_uniform(UInt32(amplitudeX))) - (amplitudeX / 2)
      let newYPos = startingY + CGFloat(arc4random_uniform(UInt32(amplitudeY))) - (amplitudeY / 2)
      actionsList.append(SKAction.move(to: CGPoint(x: newXPos, y: newYPos), duration: 0.015))
    }
    actionsList.append(SKAction.move(to: initialPosition, duration: 0.015))
    return SKAction.sequence(actionsList)
  }
  
  class func pulsedWhite(node: SKSpriteNode) -> SKAction {
    let whiteColorShader = SKShader(source: "void main() { " +
                                      "    vec4 current_color = SKDefaultShading(); " +
                                      "    if (current_color.a > 0.0) { " +
                                      "        gl_FragColor = vec4(1,1,1,1); " +
                                      "    } else {" +
                                      "        gl_FragColor = current_color; " +
                                      "    } " +
                                      "} ")
    let actionsList: [SKAction] = [
      SKAction.run({node.shader = whiteColorShader}),
      SKAction.wait(forDuration: 0.15),
      SKAction.run({node.shader = nil}),
    ]

    return SKAction.sequence(actionsList)
  }
}
