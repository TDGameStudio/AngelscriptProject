// Theme: Definitions.UEnum. WorldStory meta=(Bitflags, BitmaskEnum) plus UPROPERTY Bitmask.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumMetaBitflags
// Oracle: Value default FlagB=2; ActiveFlags default 0; metadata is C++ reflection-side.
// Extra: nullptr actor is the empty handle; FlagC=4 is a bit boundary; mutating First does not write Second.
// FixtureIsolated. Keep Value / ActiveFlags names.

UENUM(meta = (Bitflags, BitmaskEnum = "EFlagMetaEnum"))
enum EFlagMetaEnum
{
	FlagA = 1,
	FlagB = 2,
	FlagC = 4
}

UCLASS()
class ACoverageUEnumMetaBitflagsActor : AActor
{
	UPROPERTY()
	EFlagMetaEnum Value = EFlagMetaEnum::FlagB;

	UPROPERTY(meta = (Bitmask, BitmaskEnum = "EFlagMetaEnum"))
	int ActiveFlags = 0;
}

bool Observe_MetaBitflags_Nominal(ACoverageUEnumMetaBitflagsActor Actor)
{
	return Actor.Value == EFlagMetaEnum::FlagB && int(Actor.Value) == 2 && Actor.ActiveFlags == 0;
}

bool Observe_MetaBitflags_NullDefault()
{
	ACoverageUEnumMetaBitflagsActor Actor = nullptr;
	return Actor == nullptr;
}

int Observe_MetaBitflags_FlagCBoundary()
{
	return int(EFlagMetaEnum::FlagC);
}

bool Observe_MetaBitflags_CopyIndependent(
	ACoverageUEnumMetaBitflagsActor First,
	ACoverageUEnumMetaBitflagsActor Second)
{
	First.ActiveFlags = int(EFlagMetaEnum::FlagA) | int(EFlagMetaEnum::FlagC);
	return Second.ActiveFlags == 0 && First.ActiveFlags == 5;
}
