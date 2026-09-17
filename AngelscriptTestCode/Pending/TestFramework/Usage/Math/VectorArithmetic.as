/**
 * @version v1
 * @summary FVector add, subtract, scale, and equality as Suite usage.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary FVector add, subtract, scale, and equality as Suite usage.
 * @topic Baseline
 */
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UVectorArithmeticScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void AddSubtractAndScale()
	{
		AssertEquals(FVector(5, 7, 9), FVector(1, 2, 3) + FVector(4, 5, 6));
		AssertEquals(FVector(9, 18, 27), FVector(10, 20, 30) - FVector(1, 2, 3));
		AssertEquals(FVector(6, 9, 12), FVector(2, 3, 4) * 3.0);
		AssertEquals(FVector(10, 20, 30), FVector(20, 40, 60) / 2.0);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void EqualityMatchesAndDiffers()
	{
		AssertTrue(FVector(1, 2, 3) == FVector(1, 2, 3));
		AssertFalse(FVector(1, 2, 3) == FVector(4, 5, 6));
		AssertTrue(FVector(1, 2, 3) != FVector(4, 5, 6));
		AssertTrue(FVector() == FVector::ZeroVector);
	}
}
/** @end */
