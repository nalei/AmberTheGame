import SpriteKit
import GameplayKit

extension LevelScene: SKPhysicsContactDelegate {
  
  func didBegin(_ contact: SKPhysicsContact) {
    handleContact(contact: contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity) in
      ContactNotifiableType.contactWithEntityDidBegin(otherEntity)
    }
    
    // Любой объект, касающийся нижней стороной земли и имеющий `MovementComponent` получает флаг onGround
    if contact.bodyA.categoryBitMask == ColliderType.GROUND.rawValue || contact.bodyB.categoryBitMask == ColliderType.GROUND.rawValue {
      if collisionDirection(contact) == .bottom {
        if let movementComponent = contact.bodyA.node?.entity?.component(ofType: MovementComponent.self) {
          movementComponent.onGround = true
        } else if let movementComponent = contact.bodyB.node?.entity?.component(ofType: MovementComponent.self) {
          movementComponent.onGround = true
        }
      }
    }
  }
  
  func didEnd(_ contact: SKPhysicsContact) {
    handleContact(contact: contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity) in
      ContactNotifiableType.contactWithEntityDidEnd(otherEntity)
    }
  }
  
  private func handleContact(contact: SKPhysicsContact, contactCallback: (ContactNotifiableType, GKEntity) -> Void) {
    // Получаем `ColliderType` для каждого тела, которое учавствует в столкновении.
    let colliderTypeA = ColliderType(rawValue: contact.bodyA.categoryBitMask)
    let colliderTypeB = ColliderType(rawValue: contact.bodyB.categoryBitMask)
    
    // Определяем, какой `ColliderType` должен быть уведомлен о контакте.
    let aWantsCallback = colliderTypeA.notifyOnContactWith(colliderTypeB)
    let bWantsCallback = colliderTypeB.notifyOnContactWith(colliderTypeA)
    
    
    // Убеждаемся, что хотя бы одна из сущностей хочет обработать этот контакт.
    // assert(aWantsCallback || bWantsCallback, "Unhandled physics contact - A = \(colliderTypeA), B = \(colliderTypeB)")
    
    let entityA = contact.bodyA.node?.entity
    let entityB = contact.bodyB.node?.entity
    
    /*
     Если `entityA` является уведомляемым типом, а `colliderTypeA` указывает, что он должен быть уведомлен
     о контакте с `colliderTypeB`, вызываем колбэк `entityA`.
     */
    if let notifiableEntity = entityA as? ContactNotifiableType, let otherEntity = entityB, aWantsCallback {
      contactCallback(notifiableEntity, otherEntity)
    }
    
    /*
     Если `entityB` является уведомляемым типом, а `scolliderTypeB` указывает, что он должен быть уведомлен
     о контакте с `colliderTypeA`, вызываем колбэк `entityB`.
     */
    if let notifiableEntity = entityB as? ContactNotifiableType, let otherEntity = entityA, bWantsCallback {
      contactCallback(notifiableEntity, otherEntity)
    }
  }
  
  private func collisionDirection(_ contact: SKPhysicsContact) -> ColliderType.Direction {
    if contact.contactNormal.dy > 0.9 && contact.contactNormal.dy <= 1 {
      return .bottom
    }
    if contact.contactNormal.dx == 1 {
      return .left
    }
    if contact.contactNormal.dx == -1 {
      return .right
    }
    return .none
  }
}
