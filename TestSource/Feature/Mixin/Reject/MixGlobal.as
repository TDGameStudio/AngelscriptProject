/**
 * A mixin application at global scope is rejected. C++ compiles it as the
 * module ASSyntaxMixGlobal and expects the diagnostic to name the global
 * mixin statement.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixGlobal
 * @Harness CompileReject
 * @Tag Feature.Mixin.MixGlobal
 * @Kind CompileReject
 * @Covers Mixin.MixGlobal
 * @Inputs mixin UHealthMixinGlobal at file scope
 * @Return does not compile; "Mixin at global scope should fail"
 * @Provenance Theme: Feature.Mixin. NegativeDiagnostic: mixin statement at global scope.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Negative block 5 AssertFailsToCompile.
 * @Provenance Expected diagnostic: "Mixin at global scope should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A mixin class used only so it can be applied at global scope below.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixGlobal
 * @Inputs mixin class UHealthMixinGlobal
 * @Return does not compile once applied at global scope
 */
mixin class UHealthMixinGlobal
{
	int Health = 100;
}

mixin UHealthMixinGlobal;
