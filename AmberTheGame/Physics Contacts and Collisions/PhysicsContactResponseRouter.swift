import SpriteKit

class PhysicsContactResponseRouter: NSObject {
  
  private struct Handler {
    weak var target: AnyObject?
    let action: Selector
    let maskA: UInt32
    let maskB: UInt32
    func invoke(nodeA: SKNode, nodeB: SKNode) {
      let _ = target?.perform(action, with: nodeA, with: nodeB)
    }
  }
  
  private var handlers: [UInt32 : Handler] = [:]
  
  func add(target: AnyObject, action: Selector, maskA: UInt32, maskB: UInt32) {
    handlers[maskA | maskB] = Handler(target: target, action: action, maskA: maskA, maskB: maskB)
  }
  
  func remove(maskA: UInt32, maskB: UInt32) {
    handlers[maskA | maskB] = nil
  }
  
  func respond(to physicsContact: SKPhysicsContact) {
    let bodyA = physicsContact.bodyA
    let bodyB = physicsContact.bodyB
    let maskA = bodyA.categoryBitMask
    let maskB = bodyB.categoryBitMask
    guard let handler = handlers[maskA | maskB],
      let nodeA = bodyA.node,
      let nodeB = bodyB.node else { return }
    if maskA == handler.maskA && maskB == handler.maskB {
      handler.invoke(nodeA: nodeA, nodeB: nodeB)
    } else if maskB == handler.maskA && maskA == handler.maskB {
      handler.invoke(nodeA: nodeB, nodeB: nodeA)
    }
  }
}

// MARK: SKPhysicsContactDelegate

extension PhysicsContactResponseRouter: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    respond(to: contact)
  }
}
