// Theme: Feature.Asset. Value oracle for literal asset singleton identity.
// C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetSingletonBehavior ExpectGlobalInt 1.
// CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
// Oracle: TestSingletonIdentity()==1 (same pointer; AccessCount 1 then 99).
// Extra: empty AccessCount==0; false identity when comparing a fresh carrier.
// FixtureIsolated.

UCLASS()
class USingletonAssetCarrier : UObject
{
	UPROPERTY()
	int AccessCount = 0;
}

asset MySingletonAsset of USingletonAssetCarrier
{
	AccessCount = 1;
}

int TestSingletonIdentity()
{
	USingletonAssetCarrier First = GetMySingletonAsset();
	USingletonAssetCarrier Second = GetMySingletonAsset();

	if (First != Second)
	{
		return 0;
	}

	if (First.AccessCount != 1)
	{
		return 0;
	}

	First.AccessCount = 99;
	return Second.AccessCount == 99 ? 1 : 0;
}

int Observe_SingletonAsset_EmptyDefault(USingletonAssetCarrier Empty)
{
	if (Empty is null)
	{
		throw("Test_AssetSingletonBehavior setup: required Empty is null");
	}
	return Empty.AccessCount;
}

bool Observe_SingletonAsset_FreshNotSameInstance()
{
	USingletonAssetCarrier Fresh;
	USingletonAssetCarrier Asset = GetMySingletonAsset();
	return Fresh != Asset;
}
