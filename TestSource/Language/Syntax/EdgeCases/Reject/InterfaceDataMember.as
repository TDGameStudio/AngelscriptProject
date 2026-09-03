/**
 * An interface declaring a data member is rejected. This file is the illegal
 * program itself; do not drop the data member, since its presence is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.InterfaceDataMember
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.InterfaceDataMember
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an interface body declaring a member variable
 * @Return does not compile; diagnostic "interface UIntfMember may not declare member variable X"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Interface_Mixed block 2 AssertFailsToCompile.
 * @Provenance CSV SourceShape Positive is wrong; the C++ method is AssertFailsToCompile.
 * @Provenance sha256=894f664193697fe12edd79a6b07144d7108fc2583b77d73c42e1597dfb156da7; lines 448-450.
 * @Provenance Expected diagnostic: interface UIntfMember may not declare member variable X.
 * @Provenance DiagnosticOnly. Do not drop the data member.
 */

interface UIntfMember
{
	/**
	 * The data member whose presence inside an interface is illegal.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	int X;
}
