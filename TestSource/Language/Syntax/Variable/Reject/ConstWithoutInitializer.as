/**
 * A const local declared without an initializer is rejected. C++ currently wraps
 * this AssertFailsToCompile in #if 0 because const without an initializer is
 * accepted today, but the case remains a reject by intent.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.ConstWithoutInitializer
 * @Harness CompileReject
 * @Tag Language.Syntax.Variable.ConstWithoutInitializer
 * @Kind CompileReject
 * @Covers Syntax.Variable
 * @Inputs a const local with no initializer
 * @Return does not compile; diagnostic "Const without initializer"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 4 AssertFailsToCompile.
 * @Provenance sha256=e9b7f2bc8b330523ce2df806a70833c83a4d622241f0db616b3afa19f854edcf; lines 591-593.
 * @Provenance Expected diagnostic: "Const without initializer".
 * @Provenance C++ currently wraps this AssertFailsToCompile in #if 0 (const without init is accepted).
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * Attempt to declare a const local without an initializer.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	const int X;
}
