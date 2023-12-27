import Foundation
import SwiftBuilder

@ObjectBuilder
class SimpleObject {
    var id: UUID?
    var name: String

    init(name: String) {
        self.name = name
    }
}

let object = SimpleObject(name: "Kamaal")
    .setId(UUID())
    .setName("Changed")

print("name", object.name)
print("id", object.id as Any)
