/**
 * Trailing tokens after a UPROPERTY() macro are rejected. This file is the
 * illegal program itself; do not remove the garbage token.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.TrailingGarbageAfterUProperty
 * @Harness CompileReject
 * @Tag Definitions.UProperty.TrailingGarbageAfterUProperty
 * @Kind CompileReject
 * @Covers UProperty.TrailingGarbageAfterUProperty
 * @Inputs UPROPERTY() garbage int X
 * @Return does not compile; diagnostic "Trailing garbage after UPROPERTY should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: trailing garbage after UPROPERTY.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
 * @Provenance UPropSN_TrailingGarbage; lines 310-315;
 * @Provenance sha256=d1cd452484a41895aea1caa4081ee27daa456e69342446f30ac1260a021c6ee8.
 * @Provenance Expected diagnostic: Trailing garbage after UPROPERTY should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropGarbageActor : AActor
{
	UPROPERTY() garbage int X = 0;
}
