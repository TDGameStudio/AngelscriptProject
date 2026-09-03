/**
 * A mixin class inheriting another mixin is rejected. C++ compiles it as the
 * module ASSyntaxMixInheritMixin and expects the diagnostic to name the mixin
 * inheritance.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixInheritMixin
 * @Harness CompileReject
 * @Tag Feature.Mixin.MixInheritMixin
 * @Kind CompileReject
 * @Covers Mixin.MixInheritMixin
 * @Inputs mixin class UChildMixin : UBaseMixin
 * @Return does not compile; "Mixin inheriting mixin should fail"
 * @Provenance Theme: Feature.Mixin. NegativeDiagnostic: mixin inheriting another mixin.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Negative block 7 AssertFailsToCompile.
 * @Provenance Expected diagnostic: "Mixin inheriting mixin should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A base mixin class used only so a child mixin can try to inherit it.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixInheritMixin
 * @Inputs mixin class UBaseMixin
 * @Return does not compile once inherited by another mixin
 */
mixin class UBaseMixin
{
	int X = 0;
}

/**
 * The isolated failing program: mixin classes cannot inherit mixins.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixInheritMixin
 * @Inputs mixin class UChildMixin deriving from UBaseMixin
 * @Return does not compile
 */
mixin class UChildMixin : UBaseMixin
{
	int Y = 0;
}
