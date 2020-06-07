import CoreGraphics
import simd

// Extend `CGPoint` to add an initializer from a `float2` representation of a point.
extension CGPoint {
  init(_ point: vector_float2) {
    self.init()
    x = CGFloat(point.x)
    y = CGFloat(point.y)
  }
}

// Extend `float2` to add an initializer from a `CGPoint`.
extension vector_float2 {
  init(_ point: CGPoint) {
    self.init(x: Float(point.x), y: Float(point.y))
  }
}
