/**
 * Applying a UPROPERTY mixin to a plain class is rejected. C++ compiles it as
 * the module ASSyntaxMixUPropNonActor and expects the diagnostic to name the
 * non-actor host.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixUPropNonActor
 * @Harness CompileReject
 * @Tag Feature.Mixin.MixUPropNonActor
 * @Kind CompileReject
 * @Covers Mixin.MixUPropNonActor
 * @Inputs mixin UHealthMixinUPropN on class FMyPlainClass
 * @Return does not compile; "Mixin with UPROPERTY on non-actor should fail"
 * @Provenance Theme: Feature.Mixin. NegativeDiagnostic: UPROPERTY mixin on a plain class.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Negative block 8 AssertFailsToCompile.
 * @Provenance Expected diagnostic: "Mixin with UPROPERTY on non-actor should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A mixin that carries a UPROPERTY, which cannot land on a plain class.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixUPropNonActor
 * @Inputs mixin class UHealthMixinUPropN
 * @Return does not compile once applied to a non-actor
 */
mixin class UHealthMixinUPropN
{
	UPROPERTY()
	int Health = 100;
}

/**
 * The isolated failing program: a UPROPERTY mixin cannot be applied to a plain class.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixUPropNonActor
 * @Inputs class FMyPlainClass applying UHealthMixinUPropN
 * @Return does not compile
 */
class FMyPlainClass
{
	mixin UHealthMixinUPropN;
}
