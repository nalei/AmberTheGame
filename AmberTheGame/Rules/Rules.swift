/*
 Abstract: Этот файл представляет правила, используемые системой правил `Enemy` для определения соответствующего действия.
 Правила представлены перечислением:
 Насколько близко `Enemy` к `Amber` (near, medium, far):
 `PlayerBotNearRule`
 `PlayerBotMediumRule`
 `PlayerBotFarRule`
 */

import GameplayKit

/// Fuzzy rules насколько близко `Enemy` к `Amber`.
enum Fact: String {
  case playerBotNear = "PlayerBotNear"
  case playerBotMedium = "PlayerBotMedium"
  case playerBotFar = "PlayerBotFar"
}

/// Утверждает, `Enemy` близко к `Amber`.
class PlayerBotNearRule: FuzzyTaskBotRule {
  // MARK: Properties
  
  override func grade() -> Float {
    guard let distance = snapshot.amberTarget?.distance else { return 0.0 }
    return distance
  }
  
  // MARK: Initializers
  
  init() { super.init(fact: .playerBotNear) }
}

/// Утверждает, `Enemy` находится на среднем расстоянии к `Amber`.
class PlayerBotMediumRule: FuzzyTaskBotRule {
  // MARK: Properties
  
  override func grade() -> Float {
    guard let distance = snapshot.amberTarget?.distance else { return 0.0 }
    return distance
  }
  
  // MARK: Initializers
  
  init() { super.init(fact: .playerBotMedium) }
}

/// Утверждает, `Enemy` далеко от `Amber`.
class PlayerBotFarRule: FuzzyTaskBotRule {
  // MARK: Properties
  
  override func grade() -> Float {
    guard let distance = snapshot.amberTarget?.distance else { return 0.0 }
    return distance
  }
  
  // MARK: Initializers
  
  init() { super.init(fact: .playerBotFar) }
}
