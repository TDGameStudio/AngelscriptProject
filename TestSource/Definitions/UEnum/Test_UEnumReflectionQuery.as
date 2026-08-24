// Theme: Definitions.UEnum. WorldStory explicit values plus UMETA query surface.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumReflectionQuery
// Oracle: None=0 Alpha=3 Beta=8; Value default Alpha; MetaValue default AlphaChoice.
// Extra: nullptr actor is the empty handle; mutating First does not write Second.
// FixtureIsolated. Keep Value / MetaValue names.

UENUM(BlueprintType)
enum EReflectionValueEnum
{
	None = 0,
	Alpha = 3,
	Beta = 8
}

UENUM(BlueprintType)
enum EReflectionMetaEnum
{
	NoSelection UMETA(DisplayName="No Selection"),
	AlphaChoice UMETA(DisplayName="Alpha Choice", ToolTip="Alpha tooltip"),
	BetaHidden UMETA(Hidden)
}

UCLASS()
class ACoverageUEnumReflectionQueryActor : AActor
{
	UPROPERTY()
	EReflectionValueEnum Value = EReflectionValueEnum::Alpha;

	UPROPERTY()
	EReflectionMetaEnum MetaValue = EReflectionMetaEnum::AlphaChoice;
}

bool Observe_ReflectionQuery_Nominal(ACoverageUEnumReflectionQueryActor Actor)
{
	return Actor.Value == EReflectionValueEnum::Alpha
		&& int(Actor.Value) == 3
		&& Actor.MetaValue == EReflectionMetaEnum::AlphaChoice
		&& int(Actor.MetaValue) == 1;
}

bool Observe_ReflectionQuery_EmptyAndBoundary()
{
	return int(EReflectionValueEnum::None) == 0
		&& int(EReflectionValueEnum::Beta) == 8
		&& int(EReflectionMetaEnum::NoSelection) == 0;
}

bool Observe_ReflectionQuery_NullDefault()
{
	ACoverageUEnumReflectionQueryActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_ReflectionQuery_CopyIndependent(
	ACoverageUEnumReflectionQueryActor First,
	ACoverageUEnumReflectionQueryActor Second)
{
	First.Value = EReflectionValueEnum::None;
	return Second.Value == EReflectionValueEnum::Alpha && First.Value == EReflectionValueEnum::None;
}
