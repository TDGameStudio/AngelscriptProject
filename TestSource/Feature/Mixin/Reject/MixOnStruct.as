/**
 * Applying a mixin to a struct is rejected. C++ compiles it as the module
 * ASSyntaxMixOnStruct and expects the diagnostic to name the struct application.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixOnStruct
 * @Harness CompileReject
 * @Tag Feature.Mixin.MixOnStruct
 * @Kind CompileReject
 * @Covers Mixin.MixOnStruct
 * @Inputs mixin UHealthMixinOnStruct applied to struct FMixStruct
 * @Return does not compile; "Mixin on struct should fail"
 * @Provenance Theme: Feature.Mixin. NegativeDiagnostic: mixin applied to a struct.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Negative block 3 AssertFailsToCompile.
 * @Provenance Expected diagnostic: "Mixin on struct should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A mixin class used only so it can be applied to a struct below.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixOnStruct
 * @Inputs mixin class UHealthMixinOnStruct
 * @Return does not compile once applied to a struct
 */
mixin class UHealthMixinOnStruct
{
	int Health = 100;
}

/**
 * The isolated failing program: mixins cannot be applied to structs.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixOnStruct
 * @Inputs struct FMixStruct applying UHealthMixinOnStruct
 * @Return does not compile
 */
struct FMixStruct
{
	mixin UHealthMixinOnStruct;
}
