// Theme: Definitions.UEnum. WorldStory Bitflags metadata plus integer-backed bitwise operators.
// C++: AngelscriptCoverageMacrosTests.cpp::UEnumBitflagMetadataAndRuntimeOperators
// Oracle after BeginPlay: OrResult=5, AndResult=1, XorResult=1, NotResult=-2, CompoundResult=7.
// Extra: None=0 empty flags; nullptr actor is the empty handle.
// FixtureIsolated. Keep OrResult/AndResult/XorResult/NotResult/CompoundResult names.

UENUM(meta=(Bitflags, BitmaskEnum="ECoverageMacroFlagState"))
enum ECoverageMacroFlagState
{
	None = 0,
	Read = 1,
	Write = 2,
	Execute = 4
}

UENUM()
enum ECoverageMacroFlagMetadataState
{
	NoFlags UMETA(DisplayName="No Flags", ToolTip="No flag selected"),
	ReadFlag UMETA(DisplayName="Read Flag"),
	WriteFlag UMETA(ToolTip="Write permission"),
	ExecuteFlag UMETA(Hidden)
}

UCLASS()
class ACoverageMacrosEnumBitflagActor : AActor
{
	UPROPERTY()
	ECoverageMacroFlagState ReflectedFlag = ECoverageMacroFlagState::Read;

	UPROPERTY()
	ECoverageMacroFlagMetadataState ReflectedEntry = ECoverageMacroFlagMetadataState::ReadFlag;

	UPROPERTY()
	int OrResult = 0;

	UPROPERTY()
	int AndResult = 0;

	UPROPERTY()
	int XorResult = 0;

	UPROPERTY()
	int NotResult = 0;

	UPROPERTY()
	int CompoundResult = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		int Flags = int(ECoverageMacroFlagState::Read) | int(ECoverageMacroFlagState::Execute);
		OrResult = Flags;
		AndResult = Flags & int(ECoverageMacroFlagState::Read);
		XorResult = Flags ^ int(ECoverageMacroFlagState::Execute);
		NotResult = ~int(ECoverageMacroFlagState::Read);

		Flags |= int(ECoverageMacroFlagState::Write);
		CompoundResult = Flags;
	}
}

bool Observe_Bitflag_BeginPlayOracle(ACoverageMacrosEnumBitflagActor Actor)
{
	Actor.BeginPlay();
	return Actor.OrResult == 5
		&& Actor.AndResult == 1
		&& Actor.XorResult == 1
		&& Actor.NotResult == -2
		&& Actor.CompoundResult == 7;
}

int Observe_Bitflag_NoneEmpty()
{
	return int(ECoverageMacroFlagState::None);
}

bool Observe_Bitflag_NullDefault()
{
	ACoverageMacrosEnumBitflagActor Actor = nullptr;
	return Actor == nullptr;
}
