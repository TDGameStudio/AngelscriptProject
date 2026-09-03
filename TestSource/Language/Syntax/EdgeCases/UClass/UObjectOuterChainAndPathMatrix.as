/**
 * A three-level NewObject outer chain with its path matrix: each object's outer
 * is its parent, the outermost is the transient package, the depth is two, and
 * the name path spells out all three names.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.UObjectOuterChainAndPathMatrix
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.UObjectOuterChainAndPathMatrix
 * @Provenance C++: AngelscriptCoverageHandleTests.cpp::UObjectOuterChainAndPathMatrix
 * @Provenance sha256=ab666ffd5736e2e9ef0744ff2cff689d5821dc708053cfdbd70c20b382b257bd; lines 1136-1228.
 * @Provenance Oracle: ChainOutersMatched=true; ChainOutermostMatched=true; ChainPathContainsNames=true;
 * @Provenance ChainDepth=2; ChainNamePath="CoverageHandleChainLeaf>CoverageHandleChainChild>CoverageHandleChainRoot".
 * @Provenance Extra: objects null, flags false, depth 0, empty path. FixtureIsolated.
 */

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

	/**
	 * Counts an object's outer chain depth, stopping at the package.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the object to measure
	 * @Return the number of non-package outers
	 * @Param Obj the object whose chain is counted
	 */
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

	/**
	 * Collects an object's name and its outer names joined by '>'.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the object to name
	 * @Return the chain names joined by '>'
	 * @Param Obj the object whose chain is named
	 */
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

	/**
	 * Builds the chain and records the outer, depth and path matrix.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the properties record each measurement
	 */
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

	/**
	 * Observe that a locally constructed actor holds no chain.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the objects are null, flags false, depth 0 and path empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool UObjectOuterChainDefaultEmpty()
	{
		if (ChainRoot != nullptr)
		{
			return false;
		}

		if (ChainChild != nullptr)
		{
			return false;
		}

		if (ChainLeaf != nullptr)
		{
			return false;
		}

		if (ChainOutersMatched)
		{
			return false;
		}

		if (ChainDepth != 0)
		{
			return false;
		}

		return ChainNamePath.Len() == 0;
	}
}
