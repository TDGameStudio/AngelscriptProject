/**
 * Circular mixin references are rejected. C++ compiles it as the module
 * ASSyntaxMixCircular and expects the diagnostic to name the cycle.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixCircular
 * @Harness CompileReject
 * @Tag Feature.Mixin.MixCircular
 * @Kind CompileReject
 * @Covers Mixin.MixCircular
 * @Inputs mixin class UMixinA applying UMixinB and UMixinB applying UMixinA
 * @Return does not compile; "Circular mixin reference should fail"
 * @Provenance Theme: Feature.Mixin. NegativeDiagnostic: circular mixin references.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Negative block 9 AssertFailsToCompile.
 * @Provenance Expected diagnostic: "Circular mixin reference should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * The isolated failing program: UMixinA applies UMixinB.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixCircular
 * @Inputs mixin class UMixinA applying UMixinB
 * @Return does not compile once the cycle closes
 */
mixin class UMixinA
{
	mixin UMixinB;
}

/**
 * The isolated failing program: UMixinB applies UMixinA, closing the cycle.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixCircular
 * @Inputs mixin class UMixinB applying UMixinA
 * @Return does not compile
 */
mixin class UMixinB
{
	mixin UMixinA;
}
