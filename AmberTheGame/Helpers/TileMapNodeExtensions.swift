import SpriteKit

extension SKTileMapNode {
  
  public func giveTileMapPhysicsBody() {
    let tilePositionArray = getTilePositionArray()
    
    let tileSize = self.tileSize
    
    let rWidth = tileSize.width / 2
    let rHeight = tileSize.height / 2
    
    var ti: Int = 0
    var ti2: Int = 0
    var id: Int = 0
    var dl: CGPoint = CGPoint(x: 0, y: 0)
    
    var tLE = [CGPoint]()
    var tRE = [CGPoint]()
    
    for t in tilePositionArray {
      if ti-1 < 0 || tilePositionArray[ti-1].y != tilePositionArray[ti].y - tileSize.height {
        dl = CGPoint(x: t.x - rWidth, y: t.y - rHeight)
      }
      if (ti+1 > tilePositionArray.count-1) {
        tLE.append(dl)
        tRE.append(CGPoint(x: t.x + rWidth, y: t.y + rHeight))
      } else if (tilePositionArray[ti+1].y != tilePositionArray[ti].y + tileSize.height) {
        if let _ = tRE.first(where: {
          if $0 == CGPoint(x: t.x + rWidth - tileSize.width, y: t.y + rHeight) {id = tRE.firstIndex(of: $0)!}
          return $0 == CGPoint(x: t.x + rWidth - tileSize.width, y: t.y + rHeight)}) {
          if tLE[id].y == dl.y {
            tRE[id] = CGPoint(x: t.x + rWidth, y: t.y + rHeight)
          } else {
            tLE.append(dl)
            tRE.append(CGPoint(x: t.x + rWidth, y: t.y + rHeight))
          }
        } else {
          tLE.append(dl)
          tRE.append(CGPoint(x: t.x + rWidth, y: t.y + rHeight))
        }
      }
      ti += 1
    }
    
    for t in tLE {
      let size = CGSize(width: abs(t.x - tRE[ti2].x), height: abs(t.y - tRE[ti2].y))
      let loadnode = SKSpriteNode()
      loadnode.color = #colorLiteral(red: 0.08749931306, green: 0.02683358826, blue: 0.1405134499, alpha: 1)
      loadnode.zPosition = -1
      loadnode.anchorPoint = CGPoint(x: 0, y: 0)
      loadnode.size = CGSize(width: size.width, height: size.height)
      loadnode.position = CGPoint(x: t.x, y: t.y)
      loadnode.name = "Ground"
      
      loadnode.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(
        x: 0,
        y: 0,
        width: size.width,
        height: size.height)
      )
      loadnode.physicsBody?.isDynamic = false
      loadnode.physicsBody?.allowsRotation = false
      loadnode.physicsBody?.restitution = 0
      loadnode.physicsBody?.categoryBitMask = ColliderType.GROUND.rawValue
      
      self.addChild(loadnode)
      
      ti2 += 1
    }
  }
  
  private func getTilePositionArray() -> [CGPoint] {
    var tilePositionArray = [CGPoint]()
    let tileSize = self.tileSize
    let halfWidth = CGFloat(self.numberOfColumns) / 2 * tileSize.width
    let halfHeight = CGFloat(self.numberOfRows) / 2 * tileSize.height
    for col in 0..<self.numberOfColumns {
      for row in 0..<self.numberOfRows {
        if let _ = self.tileDefinition(atColumn: col, row: row) {
          let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
          let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
          tilePositionArray.append(CGPoint(x: x, y: y))
        }
      }
    }
    return tilePositionArray
  }
}
