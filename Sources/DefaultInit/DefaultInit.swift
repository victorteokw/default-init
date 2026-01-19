/// A macro that produces a initializer from stored properties.
///
///     @DefaultInit
///     struct MyModel {
///         var name: String
///         var age: Int?
///     }
///
@attached(member, names: named(init))
public macro DefaultInit() = #externalMacro(module: "DefaultInitMacros", type: "DefaultInitMacro")
