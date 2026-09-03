/**
 * Two declarations on one line with no separating semicolon are rejected. This
 * file is the illegal program itself; do not insert the omitted semicolon, since
 * the missing separator is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.MissingSemicolonBetweenDeclarations
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.MissingSemicolonBetweenDeclarations
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs two declarations run together without a separator
 * @Return does not compile; diagnostic "missing semicolon"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Negative block 4 AssertFailsToCompile.
 * @Provenance sha256=a5f857d294cad8efbb4ff024788d4a0a218e9d21a9e9926d0fae7d31a3028bb4; lines 298-300.
 * @Provenance Expected diagnostic: missing semicolon between int X = 1 and int Y = 2.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A function whose two declarations are not separated by a semicolon.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int X = 1 int Y = 2;
}
