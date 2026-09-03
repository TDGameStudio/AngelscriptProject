/**
 * void is not a value type, so declaring a local of that type is rejected. This
 * file is the illegal program itself; do not give the variable a real type, since
 * the void declaration is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.VoidVariable
 * @Harness CompileReject
 * @Tag Language.Syntax.Variable.VoidVariable
 * @Kind CompileReject
 * @Covers Syntax.Variable
 * @Inputs a local declared with type void
 * @Return does not compile; diagnostic "Void variable"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 7 AssertFailsToCompile.
 * @Provenance sha256=db160d8f8ad749b323fa05123f681652827495223494e20c7a50671450132b1f; lines 610-612.
 * @Provenance Expected diagnostic: "Void variable". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to declare a local whose type is void.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	void X;
}
