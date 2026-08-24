// Theme: Definitions.UStruct. WorldStory: BlueprintType struct inherited by a Blueprint child.
// C++: AngelscriptCoverageUStructTests.cpp::UStructBlueprintGeneratedClassBoundary
// lines 3284-3316;
// sha256=22e434c4c9e47bbd55c7e76dfe239da1f2f3f650d15a0d3c464f6c12134359e1.
// Oracle: Payload.Count=23 Label=StructDefault; after BeginPlay RuntimeCopy.Count=28
// Label=StructDefault_Runtime, RuntimeCount=28. Keep those UPROPERTY names.
// Extra: local FBlueprintBoundaryStruct default 23/"StructDefault"; copy-independence.
// FixtureIsolated.

USTRUCT(BlueprintType)
struct FBlueprintBoundaryStruct
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	int Count = 23;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString Label = "StructDefault";
}

UCLASS()
class ACoverageStructBlueprintBoundaryActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FBlueprintBoundaryStruct Payload;

	UPROPERTY()
	FBlueprintBoundaryStruct RuntimeCopy;

	UPROPERTY()
	int RuntimeCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RuntimeCopy = Payload;
		RuntimeCopy.Count += 5;
		RuntimeCopy.Label = Payload.Label + "_Runtime";
		RuntimeCount = RuntimeCopy.Count;
	}
}

bool Observe_BoundaryStruct_DefaultEmpty()
{
	FBlueprintBoundaryStruct Payload;
	return Payload.Count == 23 && Payload.Label == "StructDefault";
}

bool Observe_BoundaryStruct_RuntimeMutation()
{
	FBlueprintBoundaryStruct Payload;
	FBlueprintBoundaryStruct RuntimeCopy = Payload;
	RuntimeCopy.Count += 5;
	RuntimeCopy.Label = Payload.Label + "_Runtime";
	int RuntimeCount = RuntimeCopy.Count;
	return Payload.Count == 23 && Payload.Label == "StructDefault"
		&& RuntimeCopy.Count == 28 && RuntimeCopy.Label == "StructDefault_Runtime"
		&& RuntimeCount == 28;
}

bool Observe_BoundaryStruct_CopyIndependence()
{
	FBlueprintBoundaryStruct Original;
	FBlueprintBoundaryStruct Copy = Original;
	Copy.Count = 0;
	Copy.Label = "";
	return Original.Count == 23 && Original.Label == "StructDefault"
		&& Copy.Count == 0 && Copy.Label.IsEmpty();
}
