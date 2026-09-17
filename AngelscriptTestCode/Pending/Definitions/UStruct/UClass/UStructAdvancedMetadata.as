/**
 * @version v1
 * @summary DisplayName, ToolTip, Clamp, UI, and Units metadata on a USTRUCT. C++ compiles the module and reads Count/Ratio/Angle/Label on the generated struct. Keep the UPROPERTY name Data.
 * @topic Definitions
 */
/**
 * @version root
 * @summary DisplayName, ToolTip, Clamp, UI, and Units metadata on a USTRUCT. C++ compiles the module and reads Count/Ratio/Angle/Label on the generated struct. Keep the UPROPERTY name Data.
 * @topic Baseline
 */
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

	/**
	 * Observe the metadata carrier defaults on this actor.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAdvancedMetadata
	 * @Inputs an actor that has not begun play
	 * @Return true when Count is 3, Ratio is 0.5, Angle is 15.0, and Label is Initial
	 * @Boundary default values
	 */
	UFUNCTION()
	bool AdvancedMetadataMemberDefaults()
	{
		if (Data.Count != 3)
		{
			return false;
		}
		if (Data.Ratio != 0.5)
		{
			return false;
		}
		if (Data.Angle != 15.0)
		{
			return false;
		}
		return Data.Label == "Initial";
	}

	/**
	 * Observe the zero/empty write boundary.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAdvancedMetadata
	 * @Inputs a carrier whose members were cleared
	 * @Return true when Count/Ratio/Angle are 0 and Label is empty
	 * @Boundary zeros and empty string
	 */
	UFUNCTION()
	bool AdvancedMetadataEmptyZeroBoundary()
	{
		FStructMetadataCarrier Carrier;
		Carrier.Count = 0;
		Carrier.Ratio = 0.0;
		Carrier.Angle = 0.0;
		Carrier.Label = "";
		if (Carrier.Count != 0)
		{
			return false;
		}
		if (Carrier.Ratio != 0.0)
		{
			return false;
		}
		if (Carrier.Angle != 0.0)
		{
			return false;
		}
		return Carrier.Label == "";
	}

	/**
	 * Observe that copying the metadata carrier does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAdvancedMetadata
	 * @Inputs a copy whose members were cleared
	 * @Return true when the original keeps the defaults and the copy is cleared
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AdvancedMetadataCopyIndependence()
	{
		FStructMetadataCarrier Original;
		FStructMetadataCarrier Copy = Original;
		Copy.Count = 0;
		Copy.Ratio = 0.0;
		Copy.Angle = 0.0;
		Copy.Label = "";
		if (Original.Count != 3)
		{
			return false;
		}
		if (Original.Ratio != 0.5)
		{
			return false;
		}
		if (Original.Angle != 15.0)
		{
			return false;
		}
		if (Original.Label != "Initial")
		{
			return false;
		}
		if (Copy.Count != 0)
		{
			return false;
		}
		return Copy.Label == "";
	}
}
/** @end */
