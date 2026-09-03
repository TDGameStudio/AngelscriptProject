/**
 * ScriptName and DeprecatedProperty metadata on USTRUCT members. C++ reads
 * native names NativeCount/DeprecatedCount/NativeLabel. Keep the UPROPERTY
 * name Data.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructMetadataAliasAndDeprecationMatrix
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructMetadataAliasAndDeprecationMatrix
 * @Provenance Theme: Definitions.UStruct. WorldStory ScriptName / DeprecatedProperty metadata.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMetadataAliasAndDeprecationMatrix
 * @Provenance CompileScriptModule: native names NativeCount/DeprecatedCount/NativeLabel; CDO 4 / 9 / "AliasDefault".
 * @Provenance Extra: empty label; zero counts; copy independence. FixtureIsolated. Keep UPROPERTY name Data.
 */

USTRUCT(BlueprintType)
struct FStructMetadataAliasCarrier
{
	UPROPERTY(EditAnywhere, meta=(ScriptName="AliasCount"))
	int NativeCount = 4;

	UPROPERTY(EditAnywhere, meta=(DeprecatedProperty, DeprecationMessage="Use NativeCount instead"))
	int DeprecatedCount = 9;

	UPROPERTY(EditAnywhere, meta=(ScriptName="AliasLabel", DeprecatedProperty, DeprecationMessage="Use AliasLabel instead"))
	FString NativeLabel = "AliasDefault";
}

UCLASS()
class ACoverageStructMetadataAliasActor : AActor
{
	UPROPERTY()
	FStructMetadataAliasCarrier Data;

	/**
	 * Observe CDO alias and deprecation defaults.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructMetadataAliasAndDeprecationMatrix
	 * @Inputs an actor that has not begun play
	 * @Return true when NativeCount is 4, DeprecatedCount is 9, and NativeLabel is AliasDefault
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool MetadataAliasCDODefaults()
	{
		if (Data.NativeCount != 4)
		{
			return false;
		}
		if (Data.DeprecatedCount != 9)
		{
			return false;
		}
		return Data.NativeLabel == "AliasDefault";
	}

	/**
	 * Observe the zero/empty write boundary.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructMetadataAliasAndDeprecationMatrix
	 * @Inputs a carrier whose members were cleared
	 * @Return true when counts are 0 and NativeLabel is empty
	 * @Boundary zeros and empty string
	 */
	UFUNCTION()
	bool MetadataAliasEmptyAndZeroBoundary()
	{
		FStructMetadataAliasCarrier Carrier;
		Carrier.NativeCount = 0;
		Carrier.DeprecatedCount = 0;
		Carrier.NativeLabel = "";
		if (Carrier.NativeCount != 0)
		{
			return false;
		}
		if (Carrier.DeprecatedCount != 0)
		{
			return false;
		}
		return Carrier.NativeLabel == "";
	}

	/**
	 * Observe that copying the alias carrier does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructMetadataAliasAndDeprecationMatrix
	 * @Inputs a copy whose members were cleared
	 * @Return true when the original keeps 4/9/AliasDefault and the copy is empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool MetadataAliasCopyIndependence()
	{
		FStructMetadataAliasCarrier Original;
		FStructMetadataAliasCarrier Copy = Original;
		Copy.NativeCount = 0;
		Copy.DeprecatedCount = 0;
		Copy.NativeLabel = "";
		if (Original.NativeCount != 4)
		{
			return false;
		}
		if (Original.DeprecatedCount != 9)
		{
			return false;
		}
		if (Original.NativeLabel != "AliasDefault")
		{
			return false;
		}
		if (Copy.NativeCount != 0)
		{
			return false;
		}
		return Copy.NativeLabel == "";
	}
}
