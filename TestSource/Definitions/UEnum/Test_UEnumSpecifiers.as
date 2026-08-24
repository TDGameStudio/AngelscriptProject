// Theme: Definitions.UEnum. WorldStory BlueprintType plus Category/DisplayName/ToolTip specifiers.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumSpecifiers
// Oracle: actor compiles and spawns; BPType default BPOption1; MultiSpec default Value2.
// Extra: nullptr actor is the empty handle; last enumerators BPOption3/Value3 are the boundary.
// FixtureIsolated. Keep BPType / MultiSpec names.

UENUM(BlueprintType)
enum EBlueprintTypeEnum
{
	BPOption1,
	BPOption2,
	BPOption3
}

UENUM(Category="MyCategory", DisplayName="My Enum Display", ToolTip="Enum with multiple specifiers")
enum EMultiSpecifierEnum
{
	Value1,
	Value2,
	Value3
}

UCLASS()
class ACoverageUEnumSpecifiersActor : AActor
{
	UPROPERTY()
	EBlueprintTypeEnum BPType = EBlueprintTypeEnum::BPOption1;

	UPROPERTY()
	EMultiSpecifierEnum MultiSpec = EMultiSpecifierEnum::Value2;
}

bool Observe_Specifiers_NominalDefaults(ACoverageUEnumSpecifiersActor Actor)
{
	return Actor.BPType == EBlueprintTypeEnum::BPOption1
		&& Actor.MultiSpec == EMultiSpecifierEnum::Value2
		&& int(Actor.BPType) == 0
		&& int(Actor.MultiSpec) == 1;
}

bool Observe_Specifiers_NullDefault()
{
	ACoverageUEnumSpecifiersActor Actor = nullptr;
	return Actor == nullptr;
}

int Observe_Specifiers_LastEnumeratorBoundary()
{
	return int(EBlueprintTypeEnum::BPOption3) + int(EMultiSpecifierEnum::Value3);
}
