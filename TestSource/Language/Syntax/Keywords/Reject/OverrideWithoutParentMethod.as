/**
 * The override keyword requires a matching method on the parent. Declaring it on
 * a method the parent does not have is rejected.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Keywords.OverrideWithoutParentMethod
 * @Harness CompileReject
 * @Tag Language.Syntax.Keywords.OverrideWithoutParentMethod
 * @Kind CompileReject
 * @Covers Syntax.Keywords
 * @Inputs a method marked override with no parent counterpart
 * @Return does not compile; diagnostic "override without matching parent method should fail"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Negative block 3 AssertFailsToCompile.
 * @Provenance sha256=de657735ede245fab9f87295194c89b163be0bc5598012f809eaf94248c5f7a3; lines 194-199.
 * @Provenance Expected diagnostic: "override without matching parent method should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A class declaring an override that no parent method matches.
 *
 * @Covers Syntax.Keywords
 * @Inputs none
 * @Return does not compile
 */
class AActorOvrdNoParent : AActor
{
	/**
	 * Attempt to override a method the parent does not declare.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs none
	 * @Return does not compile
	 */
	void NonExistentMethod() override
	{
	}
}
