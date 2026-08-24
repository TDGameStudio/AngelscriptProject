// Theme: Definitions.UStruct. WorldStory ScriptName / DeprecatedProperty metadata.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMetadataAliasAndDeprecationMatrix
// CompileScriptModule: native names NativeCount/DeprecatedCount/NativeLabel; CDO 4 / 9 / "AliasDefault".
// Extra: empty label; zero counts; copy independence. FixtureIsolated. Keep UPROPERTY name Data.

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
}

bool Observe_MetadataAlias_CDODefaults(ACoverageStructMetadataAliasActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMetadataAliasAndDeprecationMatrix setup: required Actor is null");
	}
	return Actor.Data.NativeCount == 4
		&& Actor.Data.DeprecatedCount == 9
		&& Actor.Data.NativeLabel == "AliasDefault";
}

bool Observe_MetadataAlias_EmptyAndZeroBoundary()
{
	FStructMetadataAliasCarrier Carrier;
	Carrier.NativeCount = 0;
	Carrier.DeprecatedCount = 0;
	Carrier.NativeLabel = "";
	return Carrier.NativeCount == 0 && Carrier.DeprecatedCount == 0 && Carrier.NativeLabel == "";
}

bool Observe_MetadataAlias_CopyIndependence()
{
	FStructMetadataAliasCarrier Original;
	FStructMetadataAliasCarrier Copy = Original;
	Copy.NativeCount = 0;
	Copy.DeprecatedCount = 0;
	Copy.NativeLabel = "";
	return Original.NativeCount == 4 && Original.DeprecatedCount == 9
		&& Original.NativeLabel == "AliasDefault"
		&& Copy.NativeCount == 0 && Copy.NativeLabel == "";
}
