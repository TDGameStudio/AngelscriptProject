// Theme: Definitions.UEnum. WorldStory plain enum, default increment, explicit values, namespace enum.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumBasicDeclaration
// Oracle: DefaultValue Second==1; ExplicitValue Medium==5; First=0 Second=1 Third=2; Low=1 Medium=5 High=10; NSValueB=1; PlainB=1.
// Extra: First/PlainA/NSValueA empty first enumerators; nullptr actor is the empty handle.
// FixtureIsolated. Keep DefaultValue / ExplicitValue names.

enum EPlainEnum
{
	PlainA,
	PlainB,
	PlainC
}

UENUM()
enum EDefaultIncrement
{
	First,
	Second,
	Third
}

UENUM()
enum EExplicitValues
{
	Low = 1,
	Medium = 5,
	High = 10
}

namespace CoverageNS
{
	enum ENamespaceEnum
	{
		NSValueA,
		NSValueB
	}
}

UCLASS()
class ACoverageUEnumBasicActor : AActor
{
	UPROPERTY()
	EDefaultIncrement DefaultValue = EDefaultIncrement::Second;

	UPROPERTY()
	EExplicitValues ExplicitValue = EExplicitValues::Medium;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		int FirstVal = int(EDefaultIncrement::First);
		int SecondVal = int(EDefaultIncrement::Second);
		int ThirdVal = int(EDefaultIncrement::Third);
		check(FirstVal == 0);
		check(SecondVal == 1);
		check(ThirdVal == 2);

		check(int(EExplicitValues::Low) == 1);
		check(int(EExplicitValues::Medium) == 5);
		check(int(EExplicitValues::High) == 10);

		CoverageNS::ENamespaceEnum NSVal = CoverageNS::ENamespaceEnum::NSValueB;
		check(int(NSVal) == 1);

		EPlainEnum PlainVal = EPlainEnum::PlainB;
		check(int(PlainVal) == 1);
	}
}

bool Observe_BasicEnum_PropertyDefaults(ACoverageUEnumBasicActor Actor)
{
	return Actor.DefaultValue == EDefaultIncrement::Second
		&& int(Actor.DefaultValue) == 1
		&& Actor.ExplicitValue == EExplicitValues::Medium
		&& int(Actor.ExplicitValue) == 5;
}

bool Observe_BasicEnum_EmptyFirstEnumerators()
{
	return int(EDefaultIncrement::First) == 0
		&& int(EPlainEnum::PlainA) == 0
		&& int(CoverageNS::ENamespaceEnum::NSValueA) == 0;
}

bool Observe_BasicEnum_ExplicitHighBoundary()
{
	return int(EExplicitValues::High) == 10 && int(EExplicitValues::Low) == 1;
}

bool Observe_BasicEnum_NullDefault()
{
	ACoverageUEnumBasicActor Actor = nullptr;
	return Actor == nullptr;
}
