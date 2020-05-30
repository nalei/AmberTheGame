import SpriteKit
import GameplayKit

/**
 Расширение `LevelScene`,
 добавляет методы  для рисования графов, соединений и препятствий
 */
extension LevelScene {
  
  func debugDrawingEnabledDidChange() {
    drawGraph()
    
//    /*
//     Для каждого перпятствия на уровне, добавляем отладочную ноду,
//     которая покажет их радиус буфера для поиска пути
//     */
//    for obstacle in obstacleSpriteNodes {
//      obstacle.debugDrawingEnabled = debugDrawingEnabled
//    }
  }
  
  /// Рисует (или удаляет) отладочное представление графа поиска пути
  func drawGraph() {
    guard debugDrawingEnabled else {
      graphLayer.removeAllChildren()
      return
    }
    
    for node in graph.nodes as! [GKGraphNode2D] {
      for destination in node.connectedNodes as! [GKGraphNode2D] {
        var points = [CGPoint(node.position), CGPoint(destination.position)]
        let linearShapeNode = SKShapeNode(points: &points, count: 2)
        linearShapeNode.strokeColor = SKColor(white: 1.0, alpha: 0.1)
        linearShapeNode.lineWidth = 2.0
        linearShapeNode.zPosition = -1
        graphLayer.addChild(linearShapeNode)
      }
    }
  }
}

///**
// Расширение `SKSpriteNode`, которое рисует радиус буфера вокруг узлов, которые имеют физические тела.
// Это полезно при отладке пути обхода препятствий агентами `GKAgent2D`
// */
//extension SKSpriteNode {
//
//  var debugDrawingEnabled: Bool {
//    set {
//      // Разрешить отладку можно только для спрайтов с физическим телом
//      if physicsBody == nil { return }
//
//      // Добавляем форму препятствия, если мы включаем дебаг режим
//      if newValue == true {
//        let bufferRadius = CGFloat(25)
//        let bufferFrame = frame.insetBy(dx: -bufferRadius, dy: -bufferRadius)
//        let bufferedShape = SKShapeNode(rectOf: bufferFrame.size)
//        bufferedShape.fillColor = SKColor(red: CGFloat(1.0), green: CGFloat(0.5), blue: CGFloat(0.0), alpha: CGFloat(0.2))
//        bufferedShape.strokeColor = SKColor(red: CGFloat(1.0), green: CGFloat(0.5), blue: CGFloat(0.0), alpha: CGFloat(0.4))
//        bufferedShape.name = "debugBufferShape"
//        addChild(bufferedShape)
//      }
//      else {
//        // Удаляем все существующие формы препятствий, если мы отключаем дебаг режим
//        guard let debugBufferShape = childNode(withName: "debugBufferShape") else { return }
//        removeChildren(in: [debugBufferShape])
//      }
//    }
//    get {
//      // Дебаг режим отладки считается «включенным», если есть хотя бы один узел формы препятствия
//      return childNode(withName: "debugBufferShape") != nil
//    }
//  }
//
//  func drawBorder(color: UIColor, width: CGFloat) {
//    let shapeNode = SKShapeNode(rect: frame)
//    shapeNode.fillColor = .clear
//    shapeNode.strokeColor = color
//    shapeNode.lineWidth = width
//    addChild(shapeNode)
//  }
//}
