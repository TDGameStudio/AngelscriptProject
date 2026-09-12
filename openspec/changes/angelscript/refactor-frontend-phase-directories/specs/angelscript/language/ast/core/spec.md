# AST Core

## MODIFIED Requirements

### Requirement: Canonical AngelScript C++ names

#### Scenario: Include the reconstructed language headers
- **GIVEN** a consumer includes the maintained headers and uses the repository's existing AS namespace configuration

    Source directory organization is independent of C++ scope. Reconstructed language headers live under `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/<Phase>/`, where `<Phase>` is one of `Basic`, `Lexer`, `Parser`, `AST`, `Sema`, or `Compile`. The directory name `frontend` is not a C++ namespace.

    Consumers include against the `angelscript/` root:

    ```cpp
    #include "frontend/Lexer/as_tokenizer.h"
    #include "frontend/Parser/as_parser.h"
    #include "frontend/Sema/as_sema.h"
    #include "frontend/AST/as_ast_context.h"
    #include "frontend/Compile/as_compilation_session.h"
    ```

- **WHEN** the consumer names asCTokenizer, asCPreprocessor, asCParser, asCASTContext or asCCompilationSession

    Consumers outside the library may use AS_NAMESPACE_QUALIFIER; code inside BEGIN_AS_NAMESPACE uses the direct type name.

- **THEN** those names resolve to the sole reconstructed definitions in the existing AS scope

    | Existing configuration | Canonical qualified form |
    |---|---|
    | AS_USE_NAMESPACE defined | AngelScript::asCParser |
    | AS_USE_NAMESPACE absent | ::asCParser |

- **BUT** the migration does not remove the outer AS namespace macros or add a new configuration switch

    A directory named frontend is not a compatibility namespace. Legacy declarations must not reappear through transitive includes, aliases, or a fallback parser. A nested `frontend/Frontend/` directory is not a substitute for the `Compile/` phase folder.
