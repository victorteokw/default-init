import Testing
@testable import DefaultInit

@DefaultInit
struct MyInit {
    var name: String
    var age: Int?
    var isBlocked: Bool??
}

@Test func initCanAcceptDoubleOptional() {
    let myInit = MyInit(name: "a", age: nil, isBlocked: Optional(Optional(nil)))
    #expect(myInit.name == "a")
    #expect(myInit.age == nil)
    if let isBlocked = myInit.isBlocked {
        #expect(isBlocked == nil)
    } else {
        #expect(1 == 2)
    }
}
