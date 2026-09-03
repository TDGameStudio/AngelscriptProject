/**
 * Applying a non-mixin class as a mixin is rejected. C++ compiles it as the
 * module ASSyntaxMixNonMixin and expects the diagnostic to name the ordinary
 * class used as a mixin.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixNonMixin
 * @Harness CompileReject
 * @Tag Feature.Mixin.MixNonMixin
 * @Kind CompileReject
 * @Covers Mixin.MixNonMixin
 * @Inputs mixin ABaseMixN on AChildMixN
 * @Return does not compile; "Using non-mixin class as mixin should fail"
 * @Provenance Theme: Feature.Mixin. NegativeDiagnostic: mixin of a non-mixin class.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Negative block 6 AssertFailsToCompile.
 * @Provenance Expected diagnostic: "Using non-mixin class as mixin should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * An ordinary actor class, not a mixin.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixNonMixin
 * @Inputs class ABaseMixN
 * @Return does not compile once used as a mixin
 */
class ABaseMixN : AActor
{
}

/**
 * The isolated failing program: only mixin classes can be applied with mixin.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixNonMixin
 * @Inputs class AChildMixN applying ABaseMixN
 * @Return does not compile
 */
class AChildMixN : AActor
{
	mixin ABaseMixN;
}
