/**
 * UPARAM is a C++ UHT spelling, not a script UFUNCTION parameter modifier, so this
 * program is rejected. Isolate the failing construct; do not strip UPARAM to make
 * it compile.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.UParamModifiers
 * @Harness CompileReject
 * @Tag Definitions.Meta.UParamModifiers
 * @Provenance Theme: Definitions.Meta. Isolated compile-fail: UPARAM is a C++ UHT spelling, not script UFUNCTION params.
 * @Provenance C++: UParamModifiers CompileAndExpectFailure. CSV WorldStory is wrong.
 * @Provenance Expected diagnostic: "Expected identifier" / "Instead found '('".
 * @Provenance Isolate this failing program; do not strip UPARAM to make it compile.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class ACoverageMacrosUParamActor : AActor
{
	/**
	 * The isolated failing program: UPARAM is not legal on script parameters.
	 *
	 * @Kind CompileReject
	 * @Covers Meta.UParamModifiers
	 * @Inputs UPARAM DisplayName on InValue and OutResult
	 * @Return does not compile; "Expected identifier" / "Instead found '('"
	 * @Param InValue the input number
	 * @Param OutResult the output result
	 */
	UFUNCTION(BlueprintCallable, Category="Testing")
	void ProcessValue(
		UPARAM(DisplayName="Input Number") int InValue,
		UPARAM(DisplayName="Result", ref) int&out OutResult)
	{
	}
}
