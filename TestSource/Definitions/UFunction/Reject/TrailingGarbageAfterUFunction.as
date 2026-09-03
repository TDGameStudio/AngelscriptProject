/**
 * Tokens may not appear between UFUNCTION() and the method it annotates. The
 * garbage identifier is illegal. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.TrailingGarbageAfterUFunction
 * @Harness CompileReject
 * @Tag Definitions.UFunction.TrailingGarbageAfterUFunction
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION() garbage void Foo()
 * @Return does not compile; diagnostic "Trailing garbage after UFUNCTION should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: trailing garbage after UFUNCTION().
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 9 AssertFailsToCompile.
 * @Provenance sha256=293b845769e1e0c5d4c638400932a12e06bac3a95e2348f5a23b099b426c645f; lines 292-297.
 * @Provenance Expected compile failure: "Trailing garbage after UFUNCTION should fail".
 * @Provenance Keep the garbage token so the program stays failing. DiagnosticOnly.
 */

class AUFuncGarbageActor : AActor
{
	/**
	 * Illegal UFUNCTION with a garbage token between the annotation and the method.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION() garbage void Foo()
	 * @Return does not compile
	 */
	UFUNCTION() garbage void Foo() { }
}
