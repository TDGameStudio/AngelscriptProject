/**
 * A mixin keyword typo `mixn` is rejected. C++ compiles it as the module
 * ASSyntaxMixTypo and expects the diagnostic to name the unknown keyword.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixTypo
 * @Harness CompileReject
 * @Tag Feature.Mixin.MixTypo
 * @Kind CompileReject
 * @Covers Mixin.MixTypo
 * @Inputs mixn class UBadMixin
 * @Return does not compile; "Mixin keyword typo should fail"
 * @Provenance Theme: Feature.Mixin. NegativeDiagnostic: mixin keyword typo `mixn`.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Negative block 10 AssertFailsToCompile.
 * @Provenance Expected diagnostic: "Mixin keyword typo should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * The isolated failing program: mixn is not the mixin keyword.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixTypo
 * @Inputs mixn class UBadMixin
 * @Return does not compile
 */
mixn class UBadMixin
{
	int X = 0;
}
