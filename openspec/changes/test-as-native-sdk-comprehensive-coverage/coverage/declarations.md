# Declarations

## Elements

The declaration catalog covers global functions, methods, classes, structs, fields, constructors, destructors, namespaces, enums, typedef/alias forms, funcdefs, imports, shared/external declarations, virtual/indexed properties, access sections, mixin global functions, forward declarations, and every declaration form actively recognized or deliberately rejected by this fork. Parser-tree shape remains Frontend-owned; this theme proves build publication, lookup, metadata, execution reachability, and failure atomicity.

## Dimensions

| Axis | Values |
| --- | --- |
| Declaration family | function, method, class, struct, field, constructor, destructor, namespace, enum, typedef/alias, funcdef, import, virtual property, indexed property, mixin global |
| Scope | global, one namespace, nested namespace, class/struct member, multiple module sections, imported module |
| Body form | declaration only where legal, empty body, executable body, accessor pair, external/shared form |
| Visibility/modifier | default, private, protected, const/read-only, shared, external, mixin, current-fork rejection |
| Ordering | declaration before use, use before declaration, same section, later section, reversed section insertion, rebuild |
| Name relation | unique, legal overload, duplicate identical, duplicate incompatible, type/function/property collision, same short name in different namespace |
| Source shape | LF, CRLF, empty/comment-separated, valid terminator, missing terminator, missing body/delimiter, unexpected token |
| Observation | public lookup, exact declaration, namespace, owning section, access/trait metadata, execution, save/load, cleanup after failure |

## Required products

- `Declaration family × legal scope × publication observation` is a complete constrained product. Every supported family must be found through its owning public interface and, where executable, invoked.
- `Declaration family × ordering` covers same-section forward use, later-section dependency, reverse section insertion, failed build, corrected rebuild, and bytecode reload where supported.
- `Meaningful declaration pair × namespace relation × insertion order` covers global function/type/enum and member method/field/virtual-property collision rules. The pair axis names legal overload/complementary-accessor forms and illegal duplicates/cross-kind collisions explicitly; script-level funcdef rejection stays in publication coverage instead of being multiplied through unrelated collision cells. Each rejected pair has one owning diagnostic, proves that neither a partial symbol nor executable body was published, and performs a clean rebuild under the same module name.
- `Malformed declaration form × placement × line ending` is an active current-fork rejection product: six malformed forms (unbalanced class, incomplete parameter list, unclosed function body, missing type name, unexpected handle, and unknown base) are exercised at entry scope, after a valid declaration, and inside a namespace under LF and CRLF. Every cell retains diagnostics, checks that no partial `Entry` was published, discards the failed module, then compiles and executes a same-name recovery module.
- `Visibility/modifier × member family × access site` covers same type, derived type, unrelated type, and namespace/global access where applicable.
- `Namespace depth × qualification form × declaration family` covers fully qualified, relative, default namespace, nested lookup, shadowing, and missing/ambiguous lookup.
- `Shared/external/import form × module relation × signature compatibility` covers matching identity, incompatible signature, missing source, bind/unbind, rebuild, and execution.

## Boundaries and invalid forms

- Empty modules, declaration-only sections, comments/BOM before declarations, long identifiers, reserved words, duplicate modifiers, invalid modifier order, missing delimiters, incomplete parameter lists, incomplete base lists, and recovery to the next declaration.
- Current-fork rejected forms—such as script interfaces, explicit handles, mixin classes, or mutable globals—remain enabled negative contracts and are linked to Conformance.
- A parser-only success does not count as a declaration success. The module must publish the expected symbol and no unintended symbol.
- A failed declaration build must be discardable/rebuildable and must not leave stale type/function/global tables.

## Planned ownership

- `Language/Declarations/AngelscriptNativeDeclarationPublicationTests.cpp`
- `Language/Declarations/AngelscriptNativeDeclarationOrderingTests.cpp`
- `Language/Declarations/AngelscriptNativeDeclarationCollisionTests.cpp`
- `Language/Declarations/AngelscriptNativeDeclarationAccessTests.cpp`
- `Language/Declarations/AngelscriptNativeDeclarationFailureRecoveryTests.cpp`
- cross-module/shared/import execution remains under `Module`, with shared coverage IDs referenced rather than duplicated.
