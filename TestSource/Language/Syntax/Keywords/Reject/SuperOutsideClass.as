/**
 * Calling Super:: outside a class has no parent scope to resolve against, so the
 * program is rejected. This file is the illegal program itself; do not wrap it
 * in a class, since being outside one is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Keywords.SuperOutsideClass
 * @Harness CompileReject
 * @Tag Language.Syntax.Keywords.SuperOutsideClass
 * @Kind CompileReject
 * @Covers Syntax.Keywords
 * @Inputs a Super:: call at global scope
 * @Return does not compile; diagnostic "Super outside class should fail"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Negative block 5 AssertFailsToCompile.
 * @Provenance sha256=78db4da04dfcbe9777bf9cef53478c70d494053a438e6be00f36ea48cced4c36; lines 213-215.
 * @Provenance Expected diagnostic: "Super outside class should fail". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to call a parent method at global scope.
 *
 * @Covers Syntax.Keywords
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	Super::BeginPlay();
}
