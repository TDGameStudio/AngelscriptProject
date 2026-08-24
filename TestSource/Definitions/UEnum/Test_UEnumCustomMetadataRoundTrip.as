// Theme: Definitions.UEnum. WorldStory custom UENUM/UMETA keys round-trip; runtime index is Beta=1.
// C++: AngelscriptCoverageMacrosTests.cpp::UEnumCustomMetadataRoundTrip
// Oracle: GetStateIndex() == 1 for default Beta; metadata is C++ reflection-side.
// Extra: nullptr actor is the empty handle; Alpha is 0; Gamma Hidden is 2.
// FixtureIsolated. Keep State.

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

	UFUNCTION()
	int GetStateIndex() const
	{
		return int(State);
	}
}

bool Observe_CustomMetadata_NominalBeta(ACoverageMacrosEnumCustomMetadataActor Actor)
{
	return Actor.GetStateIndex() == 1 && Actor.State == ECoverageMacroCustomMetadataState::Beta;
}

bool Observe_CustomMetadata_NullDefault()
{
	ACoverageMacrosEnumCustomMetadataActor Actor = nullptr;
	return Actor == nullptr;
}

int Observe_CustomMetadata_AlphaEmpty()
{
	return int(ECoverageMacroCustomMetadataState::Alpha);
}

int Observe_CustomMetadata_GammaBoundary()
{
	return int(ECoverageMacroCustomMetadataState::Gamma);
}
