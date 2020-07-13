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
