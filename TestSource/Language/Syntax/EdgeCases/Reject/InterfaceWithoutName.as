/**
 * An interface declaration with no name is rejected. This file is the illegal
 * program itself; do not invent an interface name, since the missing name is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.InterfaceWithoutName
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.InterfaceWithoutName
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an interface declaration with no identifier
 * @Return does not compile; diagnostic "interface without a name is invalid"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Interface_Mixed block 4 AssertFailsToCompile.
 * @Provenance CSV SourceShape Positive is wrong; the C++ method is AssertFailsToCompile.
 * @Provenance sha256=173f6fdfbaafe86dd181abc6a85c7567b562df83aff052a66392fea164a6308c; lines 460-462.
 * @Provenance Expected diagnostic: interface without a name is invalid.
 * @Provenance DiagnosticOnly. Do not invent an interface name.
 */

interface
{
	/**
	 * A method inside the unnamed interface.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Foo();
}
