/**
 * The broken middle module of the compile-failure lifecycle: the same annotated
 * carrier with a missing semicolon before the closing brace. This file is the
 * illegal program itself; do not add the omitted semicolon, since the syntax
 * error is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.SyntaxErrorMissingSemicolon
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.SyntaxErrorMissingSemicolon
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a return statement missing its semicolon
 * @Return does not compile; diagnostic "Expected ';' / Instead found '}'"
 * @Provenance C++: AngelscriptCompilerFailureTests.cpp::SyntaxErrorFailsWithoutResidualReflection block 2
 * @Provenance sha256=0fdb282e1a662982b44789fada283ac2e74c94a2c8e5d7bc9113d48a63715dc7; lines 180-190.
 * @Provenance Expected diagnostic: Expected ';' / Instead found '}'. Isolate this failing
 * @Provenance program; do not add declarations that would compile it away. DiagnosticOnly.
 */

UCLASS()
class UBrokenCarrier : UObject
{
	/**
	 * The method whose return statement lacks its semicolon.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	UFUNCTION()
/** */
	int GetValue()
	{
		return 8
	}
}
