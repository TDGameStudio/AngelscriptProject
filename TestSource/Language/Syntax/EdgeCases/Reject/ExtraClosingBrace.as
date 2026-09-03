/**
 * An extra closing brace at module scope is rejected. This file is the illegal
 * program itself; do not remove the extra brace, since the stray brace is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ExtraClosingBrace
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ExtraClosingBrace
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a stray closing brace after a complete function
 * @Return does not compile; diagnostic "unexpected / extra closing brace"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Negative block 2 AssertFailsToCompile.
 * @Provenance sha256=cf73380bf4980d3b286d32760d846f198a1330c2f3ea6a8f8c9669247834c944; lines 286-288.
 * @Provenance Expected diagnostic: unexpected / extra closing brace after Test.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A complete function followed by a stray closing brace.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
}
}
