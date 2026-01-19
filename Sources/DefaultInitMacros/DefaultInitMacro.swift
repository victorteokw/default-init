import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

struct DefaultInitDiagnosticMessage: DiagnosticMessage {

    let message: String

    init(_ message: String) {
        self.message = message
    }

    var description: String {
        message
    }

    var diagnosticID: MessageID {
        MessageID(domain: "DefaultInit", id: "\(self)")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

func requireStruct(declaration: some DeclGroupSyntax, context: some MacroExpansionContext) -> [DeclSyntax] {
    let message = DefaultInitDiagnosticMessage("DefaultInit: declaration is not struct")
    let diagnostic = Diagnostic(node: declaration, position: declaration.memberBlock.position, message: message)
    context.diagnose(diagnostic)
    return []
}

struct Field {
    var identifier: TokenSyntax
    var type: TypeSyntax
    var defaultValue: ExprSyntax?
}

func fields(decl: StructDeclSyntax) -> [Field] {
    decl.memberBlock.members.compactMap { member in
        if let variableDecl = member.decl.as(VariableDeclSyntax.self),
           let binding = variableDecl.bindings.first,
           let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self),
           let typeAnnotation = binding.typeAnnotation,
           binding.accessorBlock == nil {
            Field(identifier: identifierPattern.identifier.trimmed, type: typeAnnotation.type.trimmed, defaultValue: binding.initializer?.value)
        } else {
            nil
        }
    }
}

enum IsOptional {
    case required
    case optional(TypeSyntax)

    static func match(_ typeSyntax: TypeSyntax) -> Self {
        if let optionalSyntax = typeSyntax.as(OptionalTypeSyntax.self) {
            .optional(optionalSyntax.wrappedType.trimmed)
        } else {
            .required
        }
    }
}

func initFrom(from fields: [Field]) -> DeclSyntax {
    let arguments = fields.map { field in
        if let defaultValue = field.defaultValue {
            switch IsOptional.match(field.type) {
            case .required: "\(field.identifier): \(field.type)? = \(defaultValue)"
            case .optional: "\(field.identifier): \(field.type) = \(defaultValue)"
            }
        } else {
            switch IsOptional.match(field.type) {
            case .required: "\(field.identifier): \(field.type)"
            case .optional: "\(field.identifier): \(field.type) = nil"
            }
        }
    }.joined(separator: ", ")
    let assignments = fields.map { field in
        "self.\(field.identifier) = \(field.identifier)"
    }.joined(separator: "\n")
    return DeclSyntax(stringLiteral: """
        init(\(arguments)) {
            \(assignments)
        }
    """)
}

public struct DefaultInitMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return requireStruct(declaration: declaration, context: context)
        }
        let fields = fields(decl: structDecl)
        let initializer = initFrom(from: fields)
        return [initializer]
    }
}

@main
struct DefaultInitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DefaultInitMacro.self,
    ]
}
