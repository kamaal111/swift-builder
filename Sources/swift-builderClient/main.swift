import Foundation
import SwiftBuilder

@ObjectBuilder
class SimpleObject {
    private(set) var id: UUID?
    private(set) var name: String

    init(name: String) {
        self.name = name
    }
}

let id = UUID(uuidString: "BE583F78-E47F-4F86-AC67-B6161D8665BB")
let object = SimpleObject(name: "Me")
    .setId(id)
    .setName("You")

print("name ->", object.name)
print("id ->", object.id as Any)
