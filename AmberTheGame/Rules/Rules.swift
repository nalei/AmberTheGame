/*
 Abstract: Этот файл представляет правила, используемые системой правил для определения соответствующего действия `Enemy`.
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

/// Утверждает, что `Amber` находится близко к `Enemy`.
class PlayerBotNearRule: FuzzyEnemyRule {
  // MARK: Properties
  
  override func grade() -> Float {
    guard let distance = snapshot.amberTarget?.distance else { return 0.0 }
    let oneThird = snapshot.proximityFactor / 3
    return (oneThird - distance) / oneThird
  }
  
  // MARK: Initializers
  
  init() { super.init(fact: .playerBotNear) }
}

/// Утверждает, что `Amber` находится на среднем расстоянии от `Enemy`.
class PlayerBotMediumRule: FuzzyEnemyRule {
  // MARK: Properties
  
  override func grade() -> Float {
    guard let distance = snapshot.amberTarget?.distance else { return 0.0 }
    let oneThird = snapshot.proximityFactor / 3
    return 1 - (abs(distance - oneThird) / oneThird)
  }
  
  // MARK: Initializers
  
  init() { super.init(fact: .playerBotMedium) }
}

/// Утверждает, что `Amber` находится далеко от `Enemy`.
class PlayerBotFarRule: FuzzyEnemyRule {
  // MARK: Properties
  
  override func grade() -> Float {
    guard let distance = snapshot.amberTarget?.distance else { return 0.0 }
    let oneThird = snapshot.proximityFactor / 3
    return (distance - oneThird) / oneThird
  }
  
  // MARK: Initializers
  
  init() { super.init(fact: .playerBotFar) }
}
