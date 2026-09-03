/**
 * Declaring the same function signature twice is rejected. This file is the
 * illegal program itself; do not change either signature, since the collision is
 * the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DuplicateFunctionSignature
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.DuplicateFunctionSignature
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs two identical function declarations
 * @Return does not compile; diagnostic "Duplicate signature"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Negative block 3 AssertFailsToCompile.
 * @Provenance sha256=4d435a7ada163cb5b51ffb640ab38428ac39d6a6d841fc2b322d70e7341ecae4; lines 692-695.
 * @Provenance Expected diagnostic: "Duplicate signature". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * The first declaration of the duplicated signature.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo(int X)
{
}

/**
 * The second declaration of the same signature.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo(int X)
{
}
