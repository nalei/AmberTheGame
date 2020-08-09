import GameplayKit

protocol RulesComponentDelegate: class {
  // Вызывается каждый раз, когда `RulesComponent` заканчивает оценку своих правил.
  func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem)
}

class RulesComponent: GKComponent {
  // MARK: - Properties
  
  weak var delegate: RulesComponentDelegate?
  
  var ruleSystem: GKRuleSystem
  
  /// Количество времени, прошедшее с момента, когда `Enemy` последний раз оценивал свои правила.
  private var timeSinceRulesUpdate: TimeInterval = 0.0
  
  
  // MARK: - Initializers
  
  override init() {
    ruleSystem = GKRuleSystem()
    super.init()
  }
  
  init(rules: [GKRule]) {
    ruleSystem = GKRuleSystem()
    ruleSystem.add(rules)
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    timeSinceRulesUpdate += seconds
    
    if timeSinceRulesUpdate < 1.0 { return }
    
    timeSinceRulesUpdate = 0.0
    
    if let enemy = entity as? Enemy,
      let levelScene = enemy.component(ofType: SpriteComponent.self)?.node.scene as? LevelScene,
      let entitySnapshot = levelScene.entitySnapshotForEntity(entity: enemy) {
      
      ruleSystem.reset()
      
      ruleSystem.state["snapshot"] = entitySnapshot
      
      ruleSystem.evaluate()
      
      delegate?.rulesComponent(rulesComponent: self, didFinishEvaluatingRuleSystem: ruleSystem)
    }
  }
}
