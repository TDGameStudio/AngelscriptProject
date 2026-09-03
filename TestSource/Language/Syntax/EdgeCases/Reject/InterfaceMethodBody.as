/**
 * An interface method carrying a body is rejected. This file is the illegal
 * program itself; do not strip the method body, since its presence is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.InterfaceMethodBody
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.InterfaceMethodBody
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an interface method with a concrete body
 * @Return does not compile; diagnostic "interface UIntfBody method DoSomething may not have a body"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Interface_Mixed block 3 AssertFailsToCompile.
 * @Provenance CSV SourceShape Positive is wrong; the C++ method is AssertFailsToCompile.
 * @Provenance sha256=99991528e3afe92067f5e5db676a6c85c65cf227f03c058dabb4e97cb475ab40; lines 454-456.
 * @Provenance Expected diagnostic: interface UIntfBody method DoSomething may not have a body.
 * @Provenance DiagnosticOnly. Do not strip the method body.
 */

interface UIntfBody
{
	/**
	 * The method whose concrete body inside an interface is illegal.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void DoSomething()
	{
	}
}
