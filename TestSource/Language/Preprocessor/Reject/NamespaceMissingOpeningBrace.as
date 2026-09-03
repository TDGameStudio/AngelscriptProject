/**
 * A namespace declaration must be followed by an opening brace. Omitting it is
 * a syntax error, and the preprocessor emits no processed code even though the
 * chunks it recognised survive. This file is the illegal program itself; do not
 * add the brace, since the malformed declaration is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.NamespaceMissingOpeningBrace
 * @Harness CompileReject
 * @Tag Language.Preprocessor.NamespaceMissingOpeningBrace
 * @Kind CompileReject
 * @Covers Preprocessor.Namespaces
 * @Inputs a namespace name not followed by '{'
 * @Return does not preprocess; diagnostic "Invalid namespace declaration, expected '{' after namespace name."
 * @Provenance C++: AngelscriptPreprocessorNamespaceTests.cpp::InvalidDeclarationReportsSyntax
 * @Provenance sha256=2e1a11b5838b41ca5a32544b7595aa9e5ad1c0432a2deef0c1247045398ff4d5; lines 57-68.
 * @Provenance Expected diagnostic: "Invalid namespace declaration, expected '{' after namespace name." (count 1).
 * @Provenance Chunks for UBrokenNamespaceCarrier and Entry remain, but no processed code is emitted.
 * @Provenance DiagnosticOnly. Do not add the missing '{' or extra declarations that would compile this away.
 */

namespace Gameplay
UCLASS()
class UBrokenNamespaceCarrier : UObject
{
}

/**
 * A plain entry point outside the malformed namespace. It never runs, since no
 * processed code is emitted at all.
 *
 * @Covers Preprocessor.Namespaces
 * @Inputs none
 * @Return 7, never reached
 */
int Entry()
{
	return 7;
}
