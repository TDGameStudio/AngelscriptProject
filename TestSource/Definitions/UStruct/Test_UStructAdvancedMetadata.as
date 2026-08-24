// Theme: Definitions.UStruct. WorldStory DisplayName/ToolTip/Clamp/UI/Units metadata.
// C++: AngelscriptCoverageUStructTests.cpp::UStructAdvancedMetadata
// CompileScriptModule: Count==3, Ratio==0.5, Angle==15.0, Label=="Initial" on generated struct.
// Extra: zeros/empty string; copy independence. FixtureIsolated. Keep UPROPERTY name Data.

USTRUCT(meta=(DisplayName="Coverage Metadata Struct", ToolTip="Struct tooltip text", ShortToolTip="Struct short tooltip", CoverageStructKey="StructValue"))
struct FStructMetadataCarrier
{
	UPROPERTY(EditAnywhere, Category="Coverage|StructMeta", meta=(DisplayName="Count Value", ToolTip="Count tooltip text", ShortToolTip="Count short tooltip", CoveragePropertyKey="CountValue", ClampMin="1", ClampMax="9"))
	int Count = 3;

	UPROPERTY(EditAnywhere, Category="Coverage|StructMeta", meta=(DisplayName="Ratio Value", UIMin="0.0", UIMax="1.0", Units="Percent"))
	float Ratio = 0.5;

	UPROPERTY(EditAnywhere, Category="Coverage|StructMeta", meta=(ClampMin="-180.0", ClampMax="180.0", UIMin="-90.0", UIMax="90.0", Units="Degrees"))
	float Angle = 15.0;

	UPROPERTY(BlueprintReadOnly, meta=(DisplayName="Label Value", ToolTip="Label tooltip text"))
	FString Label = "Initial";
}

UCLASS()
class ACoverageStructMetadataActor : AActor
{
	UPROPERTY()
	FStructMetadataCarrier Data;
}

bool Observe_AdvancedMetadata_MemberDefaults(ACoverageStructMetadataActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructAdvancedMetadata setup: required Actor is null");
	}
	return Actor.Data.Count == 3
		&& Actor.Data.Ratio == 0.5
		&& Actor.Data.Angle == 15.0
		&& Actor.Data.Label == "Initial";
}

bool Observe_AdvancedMetadata_EmptyZeroBoundary()
{
	FStructMetadataCarrier Carrier;
	Carrier.Count = 0;
	Carrier.Ratio = 0.0;
	Carrier.Angle = 0.0;
	Carrier.Label = "";
	return Carrier.Count == 0 && Carrier.Ratio == 0.0
		&& Carrier.Angle == 0.0 && Carrier.Label == "";
}

bool Observe_AdvancedMetadata_CopyIndependence()
{
	FStructMetadataCarrier Original;
	FStructMetadataCarrier Copy = Original;
	Copy.Count = 0;
	Copy.Ratio = 0.0;
	Copy.Angle = 0.0;
	Copy.Label = "";
	return Original.Count == 3 && Original.Ratio == 0.5
		&& Original.Angle == 15.0 && Original.Label == "Initial"
		&& Copy.Count == 0 && Copy.Label == "";
}
