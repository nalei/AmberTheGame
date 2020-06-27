import SpriteKit
import GameplayKit

/**
 Расширение `LevelScene`,
 добавляет метод  для рисования графов
 */
extension LevelScene {
  
  func debugDrawingEnabledDidChange() {
    drawGraph()
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
