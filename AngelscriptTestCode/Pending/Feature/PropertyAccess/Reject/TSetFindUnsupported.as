/**
 * @version v1
 * @summary Isolated compile-fail: TSet.Find is not a script-facing signature. C++ compiles TSetAdvancedOperations block 2 with CompileAndExpectFailure and expects "No matching signatures to 'TSet::Find(const int)'".
 * @topic Feature
 */
/**
 * @version root
 * @summary Isolated compile-fail: TSet.Find is not a script-facing signature. C++ compiles TSetAdvancedOperations block 2 with CompileAndExpectFailure and expects "No matching signatures to 'TSet::Find(const int)'".
 * @topic Negative
 */
UCLASS()
class ACoverageTSetFindUnsupportedActor : AActor
{
	/**
	 * The isolated failing program: TSet.Find has no matching script signature.
	 *
	 * @Kind CompileReject
	 * @Covers PropertyAccess.TSetFindUnsupported
	 * @Inputs TSet<int> with 1 added; Find(1)
	 * @Return does not compile; "No matching signatures to 'TSet::Find(const int)'"
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TSet<int> Values;
		Values.Add(1);
		Values.Find(1);
	}
}
/** @end */
