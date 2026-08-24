// Theme: Language.Syntax.Keywords. NegativeDiagnostic: override without a parent method.
// C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Negative block 3 AssertFailsToCompile.
// sha256=de657735ede245fab9f87295194c89b163be0bc5598012f809eaf94248c5f7a3; lines 194-199.
// Expected diagnostic: "override without matching parent method should fail".
// Isolate this failing program. DiagnosticOnly.

class AActorOvrdNoParent : AActor
{
	void NonExistentMethod() override
	{
	}
}
