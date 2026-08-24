// Theme: Feature.Asset. Value oracle for complex expressions in an asset block.
// C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetComplexInitialization ExpectGlobalInt 1.
// CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
// Oracle: TestComplexInitialization()==1 (Sum 60, Condition true, Position (1,2,3)).
// Extra: empty Sum==0 / Condition false / Position zero; copy independence.
// FixtureIsolated.

UCLASS()
class UComplexAssetCarrier : UObject
{
	UPROPERTY()
	int Sum = 0;

	UPROPERTY()
	bool Condition = false;

	UPROPERTY()
	FVector Position;
}

asset MyComplexAsset of UComplexAssetCarrier
{
	Sum = 10 + 20 + 30;
	Condition = (Sum > 50);
	Position = FVector(1.0, 2.0, 3.0);
}

int TestComplexInitialization()
{
	UComplexAssetCarrier Asset = GetMyComplexAsset();
	if (Asset == null)
	{
		return 0;
	}

	if (Asset.Sum != 60)
	{
		return 0;
	}

	if (!Asset.Condition)
	{
		return 0;
	}

	if (!Asset.Position.Equals(FVector(1.0, 2.0, 3.0), 0.001))
	{
		return 0;
	}

	return 1;
}

bool Observe_ComplexAsset_EmptyDefault(UComplexAssetCarrier Empty)
{
	if (Empty is null)
	{
		throw("Test_AssetComplexInitialization setup: required Empty is null");
	}
	return Empty.Sum == 0
		&& Empty.Condition == false
		&& Empty.Position.Equals(FVector::ZeroVector, 0.001);
}

bool Observe_ComplexAsset_CopyIndependence(UComplexAssetCarrier Original, UComplexAssetCarrier Copy)
{
	if (Original is null)
	{
		throw("Test_AssetComplexInitialization setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_AssetComplexInitialization setup: required Copy is null");
	}
	Copy.Sum = 9;
	Copy.Condition = true;
	Copy.Position = FVector(4.0, 5.0, 6.0);
	return Original.Sum == 0
		&& Original.Condition == false
		&& Original.Position.Equals(FVector::ZeroVector, 0.001)
		&& Copy.Sum == 9
		&& Copy.Condition
		&& Copy.Position.Equals(FVector(4.0, 5.0, 6.0), 0.001);
}
