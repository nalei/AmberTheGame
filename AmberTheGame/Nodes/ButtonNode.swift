import SpriteKit

class ButtonNode : SKSpriteNode {
  
  init(iconName: String, color: SKColor) {
    super.init(texture: .none, color: color, size: CGSize(width: 100, height: 100))
    
    let icon = SKSpriteNode(imageNamed: iconName)
    icon.zPosition = 1
    icon.setScale(1.5)
    self.addChild(icon)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
