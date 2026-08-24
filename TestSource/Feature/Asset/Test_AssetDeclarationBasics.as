// Theme: Feature.Asset. Value oracle for literal asset property initialization.
// C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetDeclarationBasics ExpectGlobalInt.
// CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
// Oracle: GetAssetValue()==42; CheckAssetName()==1.
// Extra: empty carrier Value==0 / Name empty; copy independence.
// FixtureIsolated.

UCLASS()
class UBasicAssetCarrier : UObject
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	FString Name;
}

asset MyBasicAsset of UBasicAssetCarrier
{
	Value = 42;
	Name = "TestAsset";
}

int GetAssetValue()
{
	UBasicAssetCarrier Asset = GetMyBasicAsset();
	return Asset != null ? Asset.Value : -1;
}

int CheckAssetName()
{
	UBasicAssetCarrier Asset = GetMyBasicAsset();
	return (Asset != null && Asset.Name == "TestAsset") ? 1 : 0;
}

int Observe_BasicAsset_EmptyCarrierDefault(UBasicAssetCarrier Empty)
{
	if (Empty is null)
	{
		throw("Test_AssetDeclarationBasics setup: required Empty is null");
	}
	return Empty.Value;
}

FString Observe_BasicAsset_EmptyNameDefault(UBasicAssetCarrier Empty)
{
	if (Empty is null)
	{
		throw("Test_AssetDeclarationBasics setup: required Empty is null");
	}
	return Empty.Name;
}

bool Observe_BasicAsset_CopyIndependence(UBasicAssetCarrier Original, UBasicAssetCarrier Copy)
{
	if (Original is null)
	{
		throw("Test_AssetDeclarationBasics setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_AssetDeclarationBasics setup: required Copy is null");
	}
	Copy.Value = 7;
	Copy.Name = "Mutated";
	return Original.Value == 0 && Original.Name.IsEmpty() && Copy.Value == 7 && Copy.Name == "Mutated";
}
