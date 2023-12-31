import Foundation
import SwiftBuilder

protocol SimpleProtocol { }

struct SimpleProtocolUser: SimpleProtocol { }

struct OtherSimpleProtocolUser: SimpleProtocol { }

@Builder
class SimpleLazyObject: Buildable {
    var name: String?
    var id: UUID?
    var protocolUser: (any SimpleProtocol)?

    init(name: String? = nil, id: UUID? = nil, protocolUser: SimpleProtocol? = nil) {
        self.name = name
        self.id = id
        self.protocolUser = protocolUser
    }

    static func validate(_ container: [BuildableContainerProperties : Any]) -> Bool {
        for (key, value) in container {
            switch key {
            case .id:
                if !(value is UUID) {
                    return false
                }
            case .name:
                if !(value is String) {
                    return false
                }
            case .protocolUser:
                if !(value is SimpleProtocol) {
                    return false
                }
            }
        }
        return true
    }

    static func build(_ container: [BuildableContainerProperties : Any]) -> SimpleLazyObject {
        SimpleLazyObject(name: container[.name] as? String, id: container[.id] as? UUID)
    }
}

enum LazyBuilderGoalErrors: Error {
    case ohNo
}

let id = UUID(uuidString: "BE583F78-E47F-4F86-AC67-B6161D8665BB")
let lazilyBuiltObject = try SimpleLazyObject.Builder()
    .setId(id)
    .setName("Kamaal")
    .setProtocoluser(OtherSimpleProtocolUser())
    .build()

print("lazilyBuiltObject.name ->", lazilyBuiltObject.name as Any)
print("lazilyBuiltObject.id ->", lazilyBuiltObject.id as Any)
print("lazilyBuiltObject.protocolUser ->", lazilyBuiltObject.protocolUser as Any)
