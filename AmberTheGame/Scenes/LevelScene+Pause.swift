import UIKit
import SpriteKit

extension LevelScene {
  // MARK: - Properties
  
  /// Уведомления платформы о том, что приложение становится неактивным.
  private var pauseNotificationNames: [NSNotification.Name] {
    return [UIApplication.willResignActiveNotification]
  }
  
  /// Уведомления платформы о том, что приложение становится активным.
  private var activeNotificationNames: [NSNotification.Name] {
    return [UIApplication.didBecomeActiveNotification]
  }
  
  
  // MARK: - Convenience
  
  /**
   Подписываемся на получение уведомлений о том,
   что приложение становится неактивным, чтобы поставить игру на паузу.
   */
  func registerForPauseNotifications() {
    for notificationName in pauseNotificationNames {
      NotificationCenter.default.addObserver(self, selector: #selector(LevelScene.pauseGame), name: notificationName, object: nil)
    }
  }
  
  /**
   Подписываемся на получение уведомлений о том,
   что приложение становится активным, чтобы снять игру с паузы.
   */
  func registerForActiveNotifications() {
    for notificationName in activeNotificationNames {
      NotificationCenter.default.addObserver(self, selector: #selector(LevelScene.activeGame), name: notificationName, object: nil)
    }
  }
  
  @objc func pauseGame() {
    for agentComponent in entityManager.getAllAgents() {
      agentComponent.stopAgent()
    }
  }
  
  @objc func activeGame() {
    for agentComponent in entityManager.getAllAgents() {
      let wait = SKAction.wait(forDuration: TimeInterval(0.0))
      let continueAgent = SKAction.run({ agentComponent.continueAgent() })
      self.run(SKAction.sequence([wait, continueAgent]))
    }
  }
  
  func unregisterForPauseNotifications() {
    for notificationName in pauseNotificationNames {
      NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
  }
  
  func unregisterForActiveNotifications() {
    for notificationName in activeNotificationNames {
      NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
  }
}
