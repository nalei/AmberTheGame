import UIKit

extension LevelScene {
  // MARK: - Properties
  
  /// Уведомления платформы о том, что приложение становится неактивным.
  private var pauseNotificationNames: [NSNotification.Name] {
    return [UIApplication.willResignActiveNotification]
  }
  
  
  // MARK: - Convenience
  
  /**
   Register for notifications about the app becoming inactive in
   order to pause the game.
   */
  func registerForPauseNotifications() {
    for notificationName in pauseNotificationNames {
      NotificationCenter.default.addObserver(self, selector: #selector(LevelScene.pauseGame), name: notificationName, object: nil)
    }
  }
  
  @objc func pauseGame() {
    print("pause")
  }
  
  func unregisterForPauseNotifications() {
    for notificationName in pauseNotificationNames {
      NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
  }
}
