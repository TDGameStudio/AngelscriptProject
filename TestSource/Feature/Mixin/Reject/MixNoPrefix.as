/**
 * A mixin class whose name has no U prefix is rejected. C++ compiles it as
 * the module ASSyntaxMixNoPrefix and expects the diagnostic to name the missing
 * prefix.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixNoPrefix
 * @Harness CompileReject
 * @Tag Feature.Mixin.MixNoPrefix
 * @Kind CompileReject
 * @Covers Mixin.MixNoPrefix
 * @Inputs mixin class HealthMixin
 * @Return does not compile; "Mixin without U prefix should fail"
 * @Provenance Theme: Feature.Mixin. NegativeDiagnostic: mixin class without a U prefix.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Negative block 1 AssertFailsToCompile.
 * @Provenance Expected diagnostic: "Mixin without U prefix should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * The isolated failing program: mixin class names must start with U.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixNoPrefix
 * @Inputs mixin class HealthMixin with Health = 100
 * @Return does not compile
 */
mixin class HealthMixin
{
	int Health = 100;
}
