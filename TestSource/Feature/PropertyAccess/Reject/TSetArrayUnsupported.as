/**
 * Isolated compile-fail: TSet.Array() is not a script-facing signature. C++ compiles
 * TSetArrayConversion block 2 with CompileAndExpectFailure and expects
 * "No matching signatures to 'TSet::Array()'".
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.TSetArrayUnsupported
 * @Harness CompileReject
 * @Tag Feature.PropertyAccess.TSetArrayUnsupported
 * @Provenance Theme: Feature.PropertyAccess. Isolated compile-fail: TSet.Array() is unsupported.
 * @Provenance C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetArrayConversion block 2
 * @Provenance CompileAndExpectFailure. Expected diagnostic:
 * @Provenance "No matching signatures to 'TSet::Array()'".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class ACoverageTSetArrayConversionUnsupportedActor : AActor
{
	/**
	 * The isolated failing program: TSet.Array() has no matching script signature.
	 *
	 * @Kind CompileReject
	 * @Covers PropertyAccess.TSetArrayUnsupported
	 * @Inputs TSet<int> with 1 added; Values.Array()
	 * @Return does not compile; "No matching signatures to 'TSet::Array()'"
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TSet<int> Values;
		Values.Add(1);
		TArray<int> Converted = Values.Array();
	}
}
