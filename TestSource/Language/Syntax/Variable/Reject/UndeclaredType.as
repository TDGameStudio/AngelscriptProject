/**
 * Declaring a local with a type that does not exist is rejected. This file is
 * the illegal program itself; do not introduce the missing type, since the
 * undeclared name is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.UndeclaredType
 * @Harness CompileReject
 * @Tag Language.Syntax.Variable.UndeclaredType
 * @Kind CompileReject
 * @Covers Syntax.Variable
 * @Inputs a local typed with an unknown type name
 * @Return does not compile; diagnostic "Undeclared type"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 1 AssertFailsToCompile.
 * @Provenance sha256=1375780ba5ef11f0b7ad7e58a2568d8d7ae469de9a7eaa881545c43007493605; lines 571-573.
 * @Provenance Expected diagnostic: "Undeclared type". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to declare a local with a type that does not exist.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	NonExistentType X;
}
