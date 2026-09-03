/**
 * A BlueprintType struct inherited by a Blueprint child. C++ reads Payload and
 * RuntimeCopy after BeginPlay. Keep those UPROPERTY names and RuntimeCount.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructBlueprintGeneratedClassBoundary
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructBlueprintGeneratedClassBoundary
 * @Provenance Theme: Definitions.UStruct. WorldStory: BlueprintType struct inherited by a Blueprint child.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructBlueprintGeneratedClassBoundary
 * @Provenance lines 3284-3316;
 * @Provenance sha256=22e434c4c9e47bbd55c7e76dfe239da1f2f3f650d15a0d3c464f6c12134359e1.
 * @Provenance Oracle: Payload.Count=23 Label=StructDefault; after BeginPlay RuntimeCopy.Count=28
 * @Provenance Label=StructDefault_Runtime, RuntimeCount=28. Keep those UPROPERTY names.
 * @Provenance Extra: local FBlueprintBoundaryStruct default 23/"StructDefault"; copy-independence.
 * @Provenance FixtureIsolated.
 */

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

	/**
	 * WorldStory: BeginPlay copies Payload, mutates the copy, and records RuntimeCount.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructBlueprintGeneratedClassBoundary
	 * @Inputs none
	 * @Return RuntimeCopy.Count 28, Label StructDefault_Runtime, RuntimeCount 28
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RuntimeCopy = Payload;
		RuntimeCopy.Count += 5;
		RuntimeCopy.Label = Payload.Label + "_Runtime";
		RuntimeCount = RuntimeCopy.Count;
	}

	/**
	 * Observe the BlueprintType struct default.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructBlueprintGeneratedClassBoundary
	 * @Inputs a default-constructed FBlueprintBoundaryStruct
	 * @Return true when Count is 23 and Label is StructDefault
	 * @Boundary default values
	 */
	UFUNCTION()
	bool BoundaryStructDefaultEmpty()
	{
		FBlueprintBoundaryStruct LocalPayload;
		if (LocalPayload.Count != 23)
		{
			return false;
		}
		return LocalPayload.Label == "StructDefault";
	}

	/**
	 * Observe the runtime mutation of a copy without rewriting the original.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructBlueprintGeneratedClassBoundary
	 * @Inputs a copy whose Count was increased by 5
	 * @Return true when Payload stays 23/StructDefault and the copy is 28/StructDefault_Runtime
	 */
	UFUNCTION()
	bool BoundaryStructRuntimeMutation()
	{
		FBlueprintBoundaryStruct LocalPayload;
		FBlueprintBoundaryStruct LocalCopy = LocalPayload;
		LocalCopy.Count += 5;
		LocalCopy.Label = LocalPayload.Label + "_Runtime";
		int LocalRuntimeCount = LocalCopy.Count;
		if (LocalPayload.Count != 23)
		{
			return false;
		}
		if (LocalPayload.Label != "StructDefault")
		{
			return false;
		}
		if (LocalCopy.Count != 28)
		{
			return false;
		}
		if (LocalCopy.Label != "StructDefault_Runtime")
		{
			return false;
		}
		return LocalRuntimeCount == 28;
	}

	/**
	 * Observe that copying the boundary struct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructBlueprintGeneratedClassBoundary
	 * @Inputs a copy whose Count and Label were cleared
	 * @Return true when the original keeps 23/StructDefault and the copy is empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BoundaryStructCopyIndependence()
	{
		FBlueprintBoundaryStruct Original;
		FBlueprintBoundaryStruct Copy = Original;
		Copy.Count = 0;
		Copy.Label = "";
		if (Original.Count != 23)
		{
			return false;
		}
		if (Original.Label != "StructDefault")
		{
			return false;
		}
		if (Copy.Count != 0)
		{
			return false;
		}
		return Copy.Label.IsEmpty();
	}
}
