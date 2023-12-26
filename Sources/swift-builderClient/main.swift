import Foundation
import SwiftBuilder

@ObjectBuilder
class SimpleObject {
    var id: UUID?

    init() { }
}

let object = SimpleObject()
print("object", object)
