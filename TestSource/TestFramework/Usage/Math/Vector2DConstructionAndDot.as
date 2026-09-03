/**
 * FVector2D construction and DotProduct as Suite usage.
 *
 * @Theme TestFramework.Usage.Math
 * @Subject FVector2D.Construction
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Math.Vector2DConstructionAndDot
 * @Provenance TestSource/Math/FVector2D/Function/Vector2DConstruction.as
 * @Provenance TestSource/Math/FVector2D/Function/Vector2DDotProduct.as
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
