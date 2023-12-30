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
class SimpleLazyObject: LazyBuildable {
    var name: String?
    var id: UUID?

    init(name: String? = nil, id: UUID? = nil) {
        self.name = name
    }

    static func validate(_ container: [LazyObjectBuilderProperties : Any]) -> Bool {
        return false
    }

    static func build(_ container: [LazyObjectBuilderProperties : Any]) -> SimpleLazyObject {
        SimpleLazyObject(name: container[.name] as? String, id: container[.id] as? UUID)
    }
}

enum LazyBuilderGoalErrors: Error {
    case ohNo
}

let id = UUID(uuidString: "BE583F78-E47F-4F86-AC67-B6161D8665BB")
let object = SimpleObject(name: "Me", protocolUser: SimpleProtocolUser())
    .setId(id)
    .setName("You")
    .setProtocoluser(OtherSimpleProtocolUser())

let lazilyBuiltObject = SimpleLazyObject()

print("object.name ->", object.name)
print("object.id ->", object.id as Any)
print("object.protocolUser ->", object.protocolUser)

print("lazilyBuiltObject ->", lazilyBuiltObject.name as Any)
