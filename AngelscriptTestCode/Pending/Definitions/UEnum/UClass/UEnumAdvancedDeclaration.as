/**
 * @version v1
 * @summary UENUM(BlueprintType) plus DisplayName/Hidden metadata on enumerators. C++ reads TestResult, AdvancedValue, and DisplayValue by path after BeginPlay, so those names are kept.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UENUM(BlueprintType) plus DisplayName/Hidden metadata on enumerators. C++ reads TestResult, AdvancedValue, and DisplayValue by path after BeginPlay, so those names are kept.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: switch on Option_B to write TestResult 2, then set DisplayValue
	 * to High.
	 *
	 * @Kind WorldStory
	 * @Covers UEnum.UEnumAdvancedDeclaration
	 * @Inputs none
	 * @Return AdvancedValue Option_B, TestResult 2, DisplayValue High
	 */
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

	/**
	 * Observe that Option_A, Medium, and TestResult 0 are the defaults before play.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumAdvancedDeclaration
	 * @Inputs a locally constructed actor
	 * @Return true when AdvancedValue is Option_A, DisplayValue is Medium, and TestResult is 0
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultsBeforePlay()
	{
		if (AdvancedValue != EAdvancedEnum::Option_A)
		{
			return false;
		}
		if (DisplayValue != EDisplayEnum::Medium)
		{
			return false;
		}
		return TestResult == 0;
	}

	/**
	 * Observe the BeginPlay oracle for Option_B, TestResult 2, and High.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumAdvancedDeclaration
	 * @Inputs this actor after BeginPlay
	 * @Return true when AdvancedValue is Option_B, TestResult is 2, and DisplayValue is High
	 */
	UFUNCTION()
	bool BeginPlayOracle()
	{
		BeginPlay();
		if (AdvancedValue != EAdvancedEnum::Option_B)
		{
			return false;
		}
		if (TestResult != 2)
		{
			return false;
		}
		if (DisplayValue != EDisplayEnum::High)
		{
			return false;
		}
		return int(DisplayValue) == 2;
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumAdvancedDeclaration
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageMacrosUEnumActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that Option_C alone selects switch case 3.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumAdvancedDeclaration
	 * @Inputs Option_C
	 * @Return 3 when Option_C matches its case
	 * @Boundary Option_C
	 */
	UFUNCTION()
	int OptionCBoundary()
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
}
/** @end */
