import Foundation
import SwiftBuilder

protocol SimpleProtocol { }

struct SimpleProtocolUser: SimpleProtocol { }

struct OtherSimpleProtocolUser: SimpleProtocol { }

@ObjectBuilder
class SimpleObject {
    private(set) var id: UUID?
    private(set) var name: String
    var protocolUser: any SimpleProtocol

    init(name: String, protocolUser: some SimpleProtocol) {
        self.name = name
        self.protocolUser = protocolUser
    }
}

@LazyObjectBuilder
class SimpleLazyObject {
    private(set) var id: UUID?
    var name: String

    init(name: String) {
        self.name = name
    }
}

let id = UUID(uuidString: "BE583F78-E47F-4F86-AC67-B6161D8665BB")
let object = SimpleObject(name: "Me", protocolUser: SimpleProtocolUser())
    .setId(id)
    .setName("You")
    .setProtocoluser(OtherSimpleProtocolUser())

let lazilyBuiltObject = SimpleLazyObject(name: "You")

print("object.name ->", object.name)
print("object.id ->", object.id as Any)
print("object.protocolUser ->", object.protocolUser)

print("lazilyBuiltObject.name ->", lazilyBuiltObject.name)
print("lazilyBuiltObject.id ->", lazilyBuiltObject.id as Any)
