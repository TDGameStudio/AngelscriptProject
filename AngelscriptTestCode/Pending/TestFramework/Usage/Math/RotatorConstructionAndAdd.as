/**
 * @version v1
 * @summary FRotator construction and add as Suite usage.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary FRotator construction and add as Suite usage.
 * @topic Baseline
 */
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class URotatorConstructionAndAddScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void DefaultThreeParamAndZeroConstant()
	{
		AssertEquals(FRotator::ZeroRotator, FRotator());
		AssertEquals(FRotator(10, 20, 30), FRotator(10, 20, 30));
	}

	UFUNCTION(meta=(AngelscriptTest))
	void AddTwoRotators()
	{
		AssertEquals(
			FRotator(15, 30, 45),
			FRotator(10, 20, 30) + FRotator(5, 10, 15));
	}
}
/** @end */
