// Theme: Definitions.UEnum. WorldStory UENUM(BlueprintType) plus DisplayName/Hidden metadata.
// C++: AngelscriptCoverageMacrosTests.cpp::UEnumAdvancedDeclaration
// Oracle: After BeginPlay, AdvancedValue is Option_B and TestResult == 2; DisplayValue High == 2.
// Extra: nullptr actor is the empty handle; Option_A default TestResult 0 before play; Option_C writes 3.
// FixtureIsolated. Keep TestResult / AdvancedValue / DisplayValue names.

UENUM(BlueprintType)
enum EAdvancedEnum
{
	Option_A UMETA(DisplayName="First Option", ToolTip="This is the first option"),
	Option_B UMETA(DisplayName="Second Option", ToolTip="This is the second option"),
	Option_C UMETA(DisplayName="Third Option", Hidden),
	Option_MAX UMETA(Hidden)
}

UENUM(BlueprintType)
enum EDisplayEnum
{
	Low UMETA(DisplayName="Low Priority"),
	Medium UMETA(DisplayName="Medium Priority"),
	High UMETA(DisplayName="High Priority")
}

UCLASS()
class ACoverageMacrosUEnumActor : AActor
{
	UPROPERTY(BlueprintReadWrite, Category="Enums")
	EAdvancedEnum AdvancedValue = EAdvancedEnum::Option_A;

	UPROPERTY(BlueprintReadWrite, Category="Enums")
	EDisplayEnum DisplayValue = EDisplayEnum::Medium;

	UPROPERTY()
	int TestResult = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AdvancedValue = EAdvancedEnum::Option_B;
		check(AdvancedValue == EAdvancedEnum::Option_B);

		switch (AdvancedValue)
		{
			case EAdvancedEnum::Option_A:
				TestResult = 1;
				break;
			case EAdvancedEnum::Option_B:
				TestResult = 2;
				break;
			case EAdvancedEnum::Option_C:
				TestResult = 3;
				break;
			default:
				TestResult = 0;
		}

		DisplayValue = EDisplayEnum::High;
		check(int(DisplayValue) == 2);
	}
}

bool Observe_AdvancedEnum_DefaultsBeforePlay(ACoverageMacrosUEnumActor Actor)
{
	return Actor.AdvancedValue == EAdvancedEnum::Option_A
		&& Actor.DisplayValue == EDisplayEnum::Medium
		&& Actor.TestResult == 0;
}

bool Observe_AdvancedEnum_BeginPlayOracle(ACoverageMacrosUEnumActor Actor)
{
	Actor.BeginPlay();
	return Actor.AdvancedValue == EAdvancedEnum::Option_B
		&& Actor.TestResult == 2
		&& Actor.DisplayValue == EDisplayEnum::High
		&& int(Actor.DisplayValue) == 2;
}

bool Observe_AdvancedEnum_NullDefault()
{
	ACoverageMacrosUEnumActor Actor = nullptr;
	return Actor == nullptr;
}

int Observe_AdvancedEnum_OptionCBoundary()
{
	switch (EAdvancedEnum::Option_C)
	{
		case EAdvancedEnum::Option_A:
			return 1;
		case EAdvancedEnum::Option_B:
			return 2;
		case EAdvancedEnum::Option_C:
			return 3;
		default:
			return 0;
	}
}
