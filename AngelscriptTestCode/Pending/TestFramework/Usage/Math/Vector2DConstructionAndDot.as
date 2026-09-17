/**
 * @version v1
 * @summary FVector2D construction and DotProduct as Suite usage.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary FVector2D construction and DotProduct as Suite usage.
 * @topic Baseline
 */
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UVector2DConstructionAndDotScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void DefaultTwoParamAndZeroConstant()
	{
		AssertEquals(FVector2D::ZeroVector, FVector2D());
		FVector2D Pair = FVector2D(3.5, 7.2);
		AssertEquals(3.5, Pair.X);
		AssertEquals(7.2, Pair.Y);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void OrthogonalDotIsZero()
	{
		AssertEquals(0.0, FVector2D(1.0, 0.0).DotProduct(FVector2D(0.0, 1.0)));
	}
}
/** @end */
