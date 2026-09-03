/**
 * Applying the same mixin twice to one class is rejected. C++ compiles it as
 * the module ASSyntaxMixDuplicate and expects the diagnostic to name the
 * duplicate application.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixDuplicate
 * @Harness CompileReject
 * @Tag Feature.Mixin.MixDuplicate
 * @Kind CompileReject
 * @Covers Mixin.MixDuplicate
 * @Inputs mixin UHealthMixinDup applied twice on AMixDupActor
 * @Return does not compile; "Duplicate mixin application should fail"
 * @Provenance Theme: Feature.Mixin. NegativeDiagnostic: the same mixin applied twice.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Negative block 4 AssertFailsToCompile.
 * @Provenance Expected diagnostic: "Duplicate mixin application should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A mixin class applied twice on the actor below.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixDuplicate
 * @Inputs mixin class UHealthMixinDup
 * @Return does not compile once applied twice
 */
mixin class UHealthMixinDup
{
	int Health = 100;
}

/**
 * The isolated failing program: the same mixin cannot be applied twice.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixDuplicate
 * @Inputs class AMixDupActor applying UHealthMixinDup twice
 * @Return does not compile
 */
class AMixDupActor : AActor
{
	mixin UHealthMixinDup;
	mixin UHealthMixinDup;
}
