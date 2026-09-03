/**
 * Custom UENUM/UMETA keys round-trip; the runtime index for default Beta is 1.
 * Metadata is C++ reflection-side. C++ reads State by path, so that name is kept.
 *
 * @Theme Definitions.UEnum
 * @Subject UEnum.UEnumCustomMetadataRoundTrip
 * @Harness UClass
 * @Tag Definitions.UEnum.UEnumCustomMetadataRoundTrip
 * @Provenance Theme: Definitions.UEnum. WorldStory custom UENUM/UMETA keys round-trip; runtime index is Beta=1.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::UEnumCustomMetadataRoundTrip
 * @Provenance Oracle: GetStateIndex() == 1 for default Beta; metadata is C++ reflection-side.
 * @Provenance Extra: nullptr actor is the empty handle; Alpha is 0; Gamma Hidden is 2.
 * @Provenance FixtureIsolated. Keep State.
 */

UENUM(BlueprintType, meta=(CoverageEnumKey="EnumValue", CoverageEnumMode="Strict"))
enum ECoverageMacroCustomMetadataState
{
	Alpha UMETA(DisplayName="Alpha Visible", CoverageEntryKey="AlphaValue"),
	Beta UMETA(ToolTip="Beta tooltip", CoverageEntryKey="BetaValue"),
	Gamma UMETA(Hidden, CoverageEntryKey="GammaValue")
}

UCLASS()
class ACoverageMacrosEnumCustomMetadataActor : AActor
{
	UPROPERTY()
	ECoverageMacroCustomMetadataState State = ECoverageMacroCustomMetadataState::Beta;

	/**
	 * Return the integer index of the stored enumerator.
	 *
	 * @Covers UEnum.UEnumCustomMetadataRoundTrip
	 * @Inputs the State property
	 * @Return int(State)
	 */
	UFUNCTION()
	int GetStateIndex() const
	{
		return int(State);
	}

	/**
	 * Observe that default Beta has index 1.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumCustomMetadataRoundTrip
	 * @Inputs a locally constructed actor
	 * @Return true when GetStateIndex is 1 and State is Beta
	 * @Boundary default Beta
	 */
	UFUNCTION()
	bool DefaultBeta()
	{
		if (GetStateIndex() != 1)
		{
			return false;
		}
		return State == ECoverageMacroCustomMetadataState::Beta;
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumCustomMetadataRoundTrip
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageMacrosEnumCustomMetadataActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that Alpha is the empty zero enumerator.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumCustomMetadataRoundTrip
	 * @Inputs Alpha
	 * @Return 0
	 * @Boundary empty Alpha
	 */
	UFUNCTION()
	int AlphaEmpty()
	{
		return int(ECoverageMacroCustomMetadataState::Alpha);
	}

	/**
	 * Observe that Hidden Gamma is enumerator 2.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumCustomMetadataRoundTrip
	 * @Inputs Gamma
	 * @Return 2
	 * @Boundary Hidden Gamma
	 */
	UFUNCTION()
	int GammaBoundary()
	{
		return int(ECoverageMacroCustomMetadataState::Gamma);
	}
}
