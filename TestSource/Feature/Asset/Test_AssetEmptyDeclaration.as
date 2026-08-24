// Theme: Feature.Asset. Value oracle for an empty literal asset block.
// C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetEmptyDeclaration ExpectGlobalInt 123.
// CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
// Oracle: GetEmptyAssetDefaultValue()==123.
// Extra: empty carrier still 123; null getter path returns -1.
// FixtureIsolated.

UCLASS()
class UEmptyAssetCarrier : UObject
{
	UPROPERTY()
	int DefaultValue = 123;
}

asset MyEmptyAsset of UEmptyAssetCarrier
{
}

int GetEmptyAssetDefaultValue()
{
	UEmptyAssetCarrier Asset = GetMyEmptyAsset();
	return Asset != null ? Asset.DefaultValue : -1;
}

int Observe_EmptyAsset_ClassDefault(UEmptyAssetCarrier Empty)
{
	if (Empty is null)
	{
		throw("Test_AssetEmptyDeclaration setup: required Empty is null");
	}
	return Empty.DefaultValue;
}

bool Observe_EmptyAsset_CopyIndependence(UEmptyAssetCarrier Original, UEmptyAssetCarrier Copy)
{
	if (Original is null)
	{
		throw("Test_AssetEmptyDeclaration setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_AssetEmptyDeclaration setup: required Copy is null");
	}
	Copy.DefaultValue = 0;
	return Original.DefaultValue == 123 && Copy.DefaultValue == 0;
}
