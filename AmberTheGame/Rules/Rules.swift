/*
 Этот файл представляет правила, используемые системой правил для определения соответствующего действия `Enemy`.
 Правила представлены перечислением:
 Насколько близко `Enemy` к `Amber` (near, medium, far):
   `AmberNearRule`
   `AmberMediumRule`
   `AmberFarRule`
 */

import GameplayKit

/// Fuzzy rules насколько близко `Enemy` к `Amber`.
enum Fact: String {
  case amberNear = "AmberNear"
  case amberMedium = "AmberMedium"
  case amberFar = "AmberFar"
}

/// Утверждает, что `Amber` находится близко к `Enemy`.
class AmberNearRule: FuzzyEnemyRule {
  // MARK: Properties
  
  override func grade() -> Float {
    guard let distance = snapshot.amberTarget?.distance else { return 0.0 }
    let oneThird = snapshot.proximityFactor / 3
    return (oneThird - distance) / oneThird
  }
  
  // MARK: Initializers
  
  init() { super.init(fact: .amberNear) }
}

/// Утверждает, что `Amber` находится на среднем расстоянии от `Enemy`.
class AmberMediumRule: FuzzyEnemyRule {
  // MARK: Properties
  
  override func grade() -> Float {
    guard let distance = snapshot.amberTarget?.distance else { return 0.0 }
    let oneThird = snapshot.proximityFactor / 3
    return 1 - (abs(distance - oneThird) / oneThird)
  }
  
  // MARK: Initializers
  
  init() { super.init(fact: .amberMedium) }
}

/// Утверждает, что `Amber` находится далеко от `Enemy`.
class AmberFarRule: FuzzyEnemyRule {
  // MARK: Properties
  
  override func grade() -> Float {
    guard let distance = snapshot.amberTarget?.distance else { return 0.0 }
    let oneThird = snapshot.proximityFactor / 3
    return (distance - oneThird) / oneThird
  }
  
  // MARK: Initializers
  
  init() { super.init(fact: .amberFar) }
}
