/**
 * Using the this keyword outside any class has no referent, so the program is
 * rejected. This file is the illegal program itself; do not wrap it in a class,
 * since being outside one is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Keywords.ThisOutsideClass
 * @Harness CompileReject
 * @Tag Language.Syntax.Keywords.ThisOutsideClass
 * @Kind CompileReject
 * @Covers Syntax.Keywords
 * @Inputs the this keyword at global scope
 * @Return does not compile; diagnostic "this outside class should fail"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Negative block 1 AssertFailsToCompile.
 * @Provenance sha256=ab6b0688e98283e61eeb8924445366b21acd4e99f12bd7fd76b30e5d540261d1; lines 178-180.
 * @Provenance Expected diagnostic: "this outside class should fail". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to capture this at global scope, where no instance exists.
 *
 * @Covers Syntax.Keywords
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	auto X = this;
}
