/**
 * Three UFUNCTION parameters may not share a name. A is declared three times
 * as int, so the signature is illegal. This file is the illegal program
 * itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.TripleDuplicateParameterNames
 * @Harness CompileReject
 * @Tag Definitions.UFunction.TripleDuplicateParameterNames
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void Foo(int A, int A, int A)
 * @Return does not compile; diagnostic "Three parameters with same name should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: three parameters with the same name.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 11 AssertFailsToCompile.
 * @Provenance sha256=11dba41b215d19b0c0dc343ef38d271643c8610a61f98e0904c34fcd16e3a1f0; lines 497-503.
 * @Provenance Expected compile failure: "Three parameters with same name should fail".
 */

class AUFuncPNTripleDupActor : AActor
{
	/**
	 * Illegal UFUNCTION that reuses the parameter name A three times.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs int A, int A, int A
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(int A, int A, int A)
	{
	}
}
