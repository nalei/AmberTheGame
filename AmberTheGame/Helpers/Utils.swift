import SpriteKit

func giveTileMapPhysicsBody(tileMap: SKTileMapNode) {
  let tileSize = tileMap.tileSize
  let halfWidth = CGFloat(tileMap.numberOfColumns) / 2 * tileSize.width
  let halfHeight = CGFloat(tileMap.numberOfRows) / 2 * tileSize.height
  
  for col in 0..<tileMap.numberOfColumns {
    for row in 0..<tileMap.numberOfRows {
      if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row),
        let isGround = tileDefinition.userData?["isGround"] as? Bool {
        
        if isGround {
          let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
          let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
          
          let tileNode = SKNode()
          tileNode.position = CGPoint(x: x, y: y)
          tileNode.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(
            x: -(tileSize.width / 2),
            y: -(tileSize.height / 2),
            width: tileSize.width,
            height: tileSize.height)
          )
          tileNode.physicsBody?.isDynamic = false
          tileNode.physicsBody?.allowsRotation = false
          tileNode.physicsBody?.restitution = 0
          tileNode.physicsBody?.categoryBitMask = CollisionCategory.GROUND
          tileMap.addChild(tileNode)
        }
      }
    }
  }
}

//func checkPhysics() {
//  // Create an array of all the nodes with physicsBodies
//  var physicsNodes = [SKNode]()
//
//  if let spriteComponent = character?.component(ofType: SpriteComponent.self) {
//    physicsNodes.append(spriteComponent.node)
//  }
//
//  if let idolSprite = childNode(withName: "Idol") as? SKSpriteNode {
//    physicsNodes.append(idolSprite)
//  }
//
//  //For each node, check it's category against every other node's collion and contctTest bit mask
//  for node in physicsNodes {
//    let category = node.physicsBody!.categoryBitMask
//    // Identify the node by its category if the name is blank
//    let name = node.name != nil ? node.name : "Category \(category)"
//
//    if category == UInt32.max {
//      print("Category for \(name!) does not appear to be set correctly as \(category)")
//    }
//
//    let collisionMask = node.physicsBody!.collisionBitMask
//    let contactMask = node.physicsBody!.contactTestBitMask
//
//    // If all bits of the collisonmask set, just say it collides with everything.
//    if collisionMask == UInt32.max {
//      print("\(name!) collides with everything")
//    }
//
//    for otherNode in physicsNodes {
//      if (node != otherNode) && (node.physicsBody?.isDynamic == true) {
//        let otherCategory = otherNode.physicsBody!.categoryBitMask
//        // Identify the node by its category if the name is blank
//        let otherName = otherNode.name != nil ? otherNode.name : "Category \(otherCategory)"
//
//        // If the collisonmask and category match, they will collide
//        if ((collisionMask & otherCategory) != 0) && (collisionMask != UInt32.max) {
//          print("\(name!) collides with \(otherName!)")
//        }
//        // If the contactMAsk and category match, they will contact
//        if (contactMask & otherCategory) != 0 {print("\(name!) notifies when contacting \(otherName!)")}
//      }
//    }
//  }
//}
