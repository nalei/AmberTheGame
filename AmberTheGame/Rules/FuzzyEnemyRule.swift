/*
 Abstract: `FuzzyEnemyRule` является подклассом `GKRule`, который утверждает `Fact` тогда и только тогда,
 когда его функция `grade()` возвращает ненулевое значение.
 Подклассы для определенных правил, используемых в игре, можно найти в Rules.swift.
 */

import GameplayKit

class FuzzyTaskBotRule: GKRule {
  // MARK: Properties
  
  var snapshot: EntitySnapshot!
  
  func grade() -> Float { return 0.0 }
  
  let fact: Fact
  
  // MARK: Initializers
  
  init(fact: Fact) {
    self.fact = fact
    
    super.init()
    
    // Устанавливаем salience так чтобы 'fuzzy' rules были оценены в первую очередь.
    salience = Int.max
  }
  
  // MARK: GPRule Overrides
  
  override func evaluatePredicate(in system: GKRuleSystem) -> Bool {
    snapshot = system.state["snapshot"] as? EntitySnapshot
    
    if grade() >= 0.0 {
      return true
    }
    
    return false
  }
  
  override func performAction(in system: GKRuleSystem) {
    system.assertFact(fact.rawValue as NSObject, grade: grade())
  }
}
