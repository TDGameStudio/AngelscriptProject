/**
 * Deriving from a class marked final is rejected. C++ currently wraps this
 * AssertFailsToCompile in #if 0 because the structural validation is absent,
 * but the case remains a reject by intent.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Keywords.InheritFromFinalClass
 * @Harness CompileReject
 * @Tag Language.Syntax.Keywords.InheritFromFinalClass
 * @Kind CompileReject
 * @Covers Syntax.Keywords
 * @Inputs a final class and a class deriving from it
 * @Return does not compile; diagnostic "Inheriting from final class should fail"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Negative block 2 AssertFailsToCompile.
 * @Provenance sha256=429e23b9646de9f6fa589a625f500533d680b7d9269069b3f2c5d9da472bcccb; lines 186-189.
 * @Provenance Expected diagnostic: "Inheriting from final class should fail".
 * @Provenance C++ currently wraps this AssertFailsToCompile in #if 0 (structural-validation-absent).
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A final class, which cannot be used as a base.
 *
 * @Covers Syntax.Keywords
 * @Inputs none
 * @Return does not compile once derived from
 */
class AFinalActorInhN : AActor final
{
}

/**
 * Attempt to derive from the final class above.
 *
 * @Covers Syntax.Keywords
 * @Inputs AFinalActorInhN as a base
 * @Return does not compile
 */
class AChildActorInhN : AFinalActorInhN
{
}
