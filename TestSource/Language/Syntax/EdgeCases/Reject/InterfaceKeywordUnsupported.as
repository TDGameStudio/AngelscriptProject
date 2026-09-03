/**
 * The interface keyword itself is rejected on this AS 2.33 fork. C++ originally
 * expected this to compile, but the assertion is #if 0 because the fork rejects
 * interfaces. This file is the illegal program itself; do not rewrite
 * UIntfBasic as a class, since the interface declaration is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.InterfaceKeywordUnsupported
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.InterfaceKeywordUnsupported
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an interface declaration
 * @Return does not compile; diagnostic "interface is not a supported declaration"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Interface_Mixed block 1 was AssertCompiles
 * @Provenance but is #if 0 (feature-not-supported: AS 2.33 fork rejects interface).
 * @Provenance CSV SourceShape Positive is not a compile-success on this fork.
 * @Provenance sha256=e31ad9c0e92b75da82828b85c33ffe06086dfe5d44ef8e34d89d63eef0cb064b; lines 436-442.
 * @Provenance Expected diagnostic: interface is not a supported declaration.
 * @Provenance Isolate this program. Do not rewrite UIntfBasic as a class.
 */

interface UIntfBasic
{
	/**
	 * A method declaration inside the unsupported interface.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void DoSomething();

	/**
	 * A value-returning declaration inside the unsupported interface.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	int GetValue();
}
