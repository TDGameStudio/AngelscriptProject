/**
 * FVector constructors and named constants as Suite usage.
 *
 * @Theme TestFramework.Usage.Math
 * @Subject FVector.Construction
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Math.VectorConstruction
 * @Provenance TestSource/Math/FVector/Function/FVectorConstruction.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UVectorConstructionScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void DefaultAndConstants()
	{
		AssertEquals(FVector::ZeroVector, FVector());
		AssertEquals(FVector(0, 0, 0), FVector::ZeroVector);
		AssertEquals(FVector(1, 1, 1), FVector::OneVector);
		AssertEquals(FVector(1, 0, 0), FVector::ForwardVector);
		AssertEquals(FVector(0, 1, 0), FVector::RightVector);
		AssertEquals(FVector(0, 0, 1), FVector::UpVector);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void ThreeParamAndBroadcast()
	{
		FVector Three = FVector(1, 2, 3);
		AssertEquals(1.0, Three.X);
		AssertEquals(2.0, Three.Y);
		AssertEquals(3.0, Three.Z);
		FVector Broadcast = FVector(5);
		AssertEquals(5.0, Broadcast.X);
		AssertEquals(5.0, Broadcast.Y);
		AssertEquals(5.0, Broadcast.Z);
	}
}
