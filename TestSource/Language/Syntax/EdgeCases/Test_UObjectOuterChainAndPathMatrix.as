// Theme: Language.Syntax.EdgeCases. WorldStory nested NewObject outer/path matrix.
// C++: AngelscriptCoverageHandleTests.cpp::UObjectOuterChainAndPathMatrix
// sha256=ab666ffd5736e2e9ef0744ff2cff689d5821dc708053cfdbd70c20b382b257bd; lines 1136-1228.
// Oracle: ChainOutersMatched=true; ChainOutermostMatched=true; ChainPathContainsNames=true;
// ChainDepth=2; ChainNamePath="CoverageHandleChainLeaf>CoverageHandleChainChild>CoverageHandleChainRoot".
// Extra: objects null, flags false, depth 0, empty path. FixtureIsolated.

UCLASS()
class ACoverageHandleUObjectOuterChainActor : AActor
{
	UPROPERTY()
	UObject ChainRoot;

	UPROPERTY()
	UObject ChainChild;

	UPROPERTY()
	UObject ChainLeaf;

	UPROPERTY()
	bool ChainOutersMatched = false;

	UPROPERTY()
	bool ChainOutermostMatched = false;

	UPROPERTY()
	bool ChainPathContainsNames = false;

	UPROPERTY()
	int ChainDepth = 0;

	UPROPERTY()
	FString ChainNamePath = "";

	int CountOuterDepth(UObject Obj)
	{
		int Depth = 0;
		UObject Current = Obj;
		for (int Step = 0; Step < 20; ++Step)
		{
			UObject Outer = Current.GetOuter();
			if (Outer == nullptr)
			{
				break;
			}
			if (Outer.IsA(UPackage::StaticClass()))
			{
				break;
			}
			Depth++;
			Current = Outer;
		}
		return Depth;
	}

	FString CollectChainNames(UObject Obj)
	{
		FString Result = Obj.GetName().ToString();
		UObject Current = Obj;
		for (int Step = 0; Step < 20; ++Step)
		{
			UObject Outer = Current.GetOuter();
			if (Outer == nullptr)
			{
				break;
			}
			if (Outer.IsA(UPackage::StaticClass()))
			{
				break;
			}
			Result += ">" + Outer.GetName().ToString();
			Current = Outer;
		}
		return Result;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ChainRoot = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageHandleChainRoot");
		ChainChild = NewObject(ChainRoot, UTexture2D::StaticClass(), n"CoverageHandleChainChild");
		ChainLeaf = NewObject(ChainChild, UTexture2D::StaticClass(), n"CoverageHandleChainLeaf");

		ChainOutersMatched =
			ChainRoot.GetOuter() == GetTransientPackage() &&
			ChainChild.GetOuter() == ChainRoot &&
			ChainLeaf.GetOuter() == ChainChild;
		ChainOutermostMatched = ChainLeaf.GetOutermost() == GetTransientPackage();
		ChainDepth = CountOuterDepth(ChainLeaf);
		ChainNamePath = CollectChainNames(ChainLeaf);

		FString LeafPath = ChainLeaf.GetPathName();
		ChainPathContainsNames =
			LeafPath.Contains("CoverageHandleChainRoot") &&
			LeafPath.Contains("CoverageHandleChainChild") &&
			LeafPath.Contains("CoverageHandleChainLeaf");
	}
}

bool Observe_UObjectOuterChain_DefaultEmpty(ACoverageHandleUObjectOuterChainActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UObjectOuterChainAndPathMatrix setup: required Actor is null");
	}
	return Actor.ChainRoot == nullptr && Actor.ChainChild == nullptr && Actor.ChainLeaf == nullptr && !Actor.ChainOutersMatched && Actor.ChainDepth == 0 && Actor.ChainNamePath.Len() == 0;
}
