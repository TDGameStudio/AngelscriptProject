/**
 * Isolated compile-fail: TSet Union / Intersect / Difference / Includes / FilterByPredicate
 * aliases have no matching signatures. C++ compiles TSetSetOperations block 2 with
 * CompileAndExpectFailure.
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.TSetSetOperationAliasesUnsupported
 * @Harness CompileReject
 * @Tag Feature.PropertyAccess.TSetSetOperationAliasesUnsupported
 * @Provenance Theme: Feature.PropertyAccess. Isolated compile-fail: TSet set-operation aliases.
 * @Provenance C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetSetOperations block 2
 * @Provenance CompileAndExpectFailure. Expected diagnostics:
 * @Provenance TSet::Union / Intersect / Difference / Includes / FilterByPredicate
 * @Provenance have no matching signatures.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class ACoverageTSetSetOperationAliasesActor : AActor
{
	/**
	 * The isolated failing program: the five set-operation aliases are not script-facing.
	 *
	 * @Kind CompileReject
	 * @Covers PropertyAccess.TSetSetOperationAliasesUnsupported
	 * @Inputs two TSet<int> values; Union, Intersect, Difference, Includes, FilterByPredicate
	 * @Return does not compile; those aliases have no matching signatures
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TSet<int> Values;
		TSet<int> Other;
		Values.Union(Other);
		Values.Intersect(Other);
		Values.Difference(Other);
		Values.Includes(Other);
		Values.FilterByPredicate(1);
	}
}
