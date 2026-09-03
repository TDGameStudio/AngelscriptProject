/**
 * FVector DotProduct, CrossProduct, and Size as Suite usage.
 *
 * @Theme TestFramework.Usage.Math
 * @Subject FVector.DotAndCross
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Math.VectorDotCrossAndSize
 * @Provenance TestSource/Math/FVector/Function/FVectorDotAndCross.as
 * @Provenance TestSource/Math/FVector/Function/FVectorMethods.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UVectorDotCrossAndSizeScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void OrthogonalDotIsZeroAndForwardCrossRightIsUp()
	{
		AssertEquals(0.0, FVector(1, 0, 0).DotProduct(FVector(0, 1, 0)));
		AssertEquals(56.0, FVector(2, 3, 4).DotProduct(FVector(5, 6, 7)));
		AssertEquals(FVector(0, 0, 1), FVector(1, 0, 0).CrossProduct(FVector(0, 1, 0)));
	}

	UFUNCTION(meta=(AngelscriptTest))
	void SizeOfThreeFourFive()
	{
		FVector Hypotenuse = FVector(3, 4, 0);
		AssertEquals(5.0, Hypotenuse.Size());
		AssertEquals(25.0, Hypotenuse.SizeSquared());
		AssertTrue(FVector::ZeroVector.IsZero());
	}
}
