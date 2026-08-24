// Theme: Definitions.UStruct. WorldStory: USTRUCT(BlueprintType) member Value.
// C++: AngelscriptCoverageUStructTests.cpp::UStructSpecifiers
// lines 3214-3234;
// sha256=5938db877303b95de2098edd147aab8fa90594d5e0d986eba29ebe4c65034b52.
// Oracle after BeginPlay: BPData.Value=100. C++ also checks BlueprintType metadata == "true".
// Extra: FBlueprintTypeStruct default Value=10; copy-independence after mutate.
// FixtureIsolated.

USTRUCT(BlueprintType)
struct FBlueprintTypeStruct
{
	UPROPERTY()
	int Value = 10;
}

UCLASS()
class ACoverageStructSpecifierActor : AActor
{
	UPROPERTY()
	FBlueprintTypeStruct BPData;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BPData.Value = 100;
	}
}

bool Observe_BlueprintType_DefaultEmpty()
{
	FBlueprintTypeStruct BPData;
	return BPData.Value == 10;
}

int Observe_BlueprintType_BeginPlayOracle()
{
	FBlueprintTypeStruct BPData;
	BPData.Value = 100;
	return BPData.Value;
}

bool Observe_BlueprintType_CopyIndependence()
{
	FBlueprintTypeStruct Original;
	FBlueprintTypeStruct Copy = Original;
	Copy.Value = 0;
	return Original.Value == 10 && Copy.Value == 0;
}
