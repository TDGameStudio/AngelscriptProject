// Theme: Definitions.UEnum. WorldStory UMETA DisplayName/ToolTip/Hidden on enumerators.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumMeta
// Oracle: Value default OptionA; four entries; Hidden on OptionC only. Metadata is C++ reflection-side.
// Extra: nullptr actor is the empty handle; OptionD has no UMETA as a boundary; mutating First does not write Second.
// FixtureIsolated. Keep Value.

UENUM(BlueprintType)
enum EMetaEnum
{
	OptionA UMETA(DisplayName="Option Alpha", ToolTip="This is option A"),
	OptionB UMETA(DisplayName="Option Beta"),
	OptionC UMETA(Hidden),
	OptionD
}

UCLASS()
class ACoverageUEnumMetaActor : AActor
{
	UPROPERTY()
	EMetaEnum Value = EMetaEnum::OptionA;
}

bool Observe_MetaEnum_NominalDefault(ACoverageUEnumMetaActor Actor)
{
	return Actor.Value == EMetaEnum::OptionA && int(Actor.Value) == 0;
}

bool Observe_MetaEnum_NullDefault()
{
	ACoverageUEnumMetaActor Actor = nullptr;
	return Actor == nullptr;
}

int Observe_MetaEnum_OptionDBoundary()
{
	return int(EMetaEnum::OptionD);
}

bool Observe_MetaEnum_CopyIndependent(ACoverageUEnumMetaActor First, ACoverageUEnumMetaActor Second)
{
	First.Value = EMetaEnum::OptionC;
	return Second.Value == EMetaEnum::OptionA && First.Value == EMetaEnum::OptionC;
}
