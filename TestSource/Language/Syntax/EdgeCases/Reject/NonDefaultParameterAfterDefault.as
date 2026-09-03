/**
 * A parameter without a default following one with a default is rejected. This
 * file is the illegal program itself; do not add a default to Y, since the
 * ordering violation is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.NonDefaultParameterAfterDefault
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.NonDefaultParameterAfterDefault
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a defaulted parameter followed by a plain one
 * @Return does not compile; diagnostic "Non-default after default"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Negative block 4 AssertFailsToCompile.
 * @Provenance sha256=1a7155088a87e3342f2ce75636eb0aa296f62de0f4cf12b8a0fa67c9f5e9a350; lines 699-701.
 * @Provenance Expected diagnostic: "Non-default after default". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * A function whose defaulted parameter is followed by a plain one.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo(int X = 5, int Y)
{
}
