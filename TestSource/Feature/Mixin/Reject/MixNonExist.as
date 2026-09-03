/**
 * Applying a mixin type that does not exist is rejected. C++ compiles it as
 * the module ASSyntaxMixNonExist and expects the diagnostic to name the missing
 * mixin.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixNonExist
 * @Harness CompileReject
 * @Tag Feature.Mixin.MixNonExist
 * @Kind CompileReject
 * @Covers Mixin.MixNonExist
 * @Inputs mixin UNonExistentMixin on AMixNonExistActor
 * @Return does not compile; "Using non-existent mixin should fail"
 * @Provenance Theme: Feature.Mixin. NegativeDiagnostic: mixin of a type that does not exist.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Negative block 2 AssertFailsToCompile.
 * @Provenance Expected diagnostic: "Using non-existent mixin should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * The isolated failing program: the applied mixin type is never declared.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixNonExist
 * @Inputs class AMixNonExistActor applying UNonExistentMixin
 * @Return does not compile
 */
class AMixNonExistActor : AActor
{
	mixin UNonExistentMixin;
}
