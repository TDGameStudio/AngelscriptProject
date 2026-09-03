/**
 * A for header without semicolons separating its clauses is rejected. This file
 * is the illegal program itself; do not add the semicolons, since their absence
 * is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ForHeaderWithoutSemicolons
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ForHeaderWithoutSemicolons
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a for header with no semicolons
 * @Return does not compile; diagnostic "For without semicolons"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::For_Negative ForN_NoSemicolon
 * @Provenance sha256=ec1e173f198261790dc29f694ebdb2d27e6d75d6cf7b6889fd3df52bb010739f; lines 170-172.
 * @Provenance Expected diagnostic: "For without semicolons".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * A loop whose header clauses run together without separators.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for (int I = 0 I < 10 ++I)
	{
	}
}
