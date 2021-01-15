/*
 Протокол, представляющий способность `GKEntity` реагировать
 на начало и конец физического контакта с другим `GKEntity`.
 */

import GameplayKit

protocol ContactNotifiableType {
  
  func contactWithEntityDidBegin(_ entity: GKEntity)
  
  func contactWithEntityDidEnd(_ entity: GKEntity)
}
