/**
 * @version v1
 * @summary Enum-to-int and int-to-enum conversion through ValueTwenty and ValueTen. C++ reads EnumToIntResult and IntToEnumResult by path after BeginPlay, so those names are kept.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Enum-to-int and int-to-enum conversion through ValueTwenty and ValueTen. C++ reads EnumToIntResult and IntToEnumResult by path after BeginPlay, so those names are kept.
 * @topic Baseline
 */
UENUM()
enum EConversionEnum
{
	ValueZero = 0,
	ValueTen = 10,
	ValueTwenty = 20
}

UCLASS()
class ACoverageUEnumConversionActor : AActor
{
	UPROPERTY()
	int EnumToIntResult = 0;

	UPROPERTY()
	EConversionEnum IntToEnumResult = EConversionEnum::ValueZero;

	/**
	 * WorldStory: convert ValueTwenty to int 20, then convert 10 back to ValueTen.
	 *
	 * @Kind WorldStory
	 * @Covers UEnum.UEnumConversion
	 * @Inputs none
	 * @Return EnumToIntResult 20 and IntToEnumResult ValueTen
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EConversionEnum EnumVal = EConversionEnum::ValueTwenty;
		int IntVal = int(EnumVal);
		check(IntVal == 20);
		EnumToIntResult = IntVal;

		int SourceInt = 10;
		EConversionEnum ConvertedEnum = EConversionEnum(SourceInt);
		check(ConvertedEnum == EConversionEnum::ValueTen);
		IntToEnumResult = ConvertedEnum;
	}

	/**
	 * Observe the BeginPlay oracle for enum-to-int and int-to-enum.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumConversion
	 * @Inputs this actor after BeginPlay
	 * @Return true when EnumToIntResult is 20 and IntToEnumResult is ValueTen
	 */
	UFUNCTION()
	bool BeginPlayOracle()
	{
		BeginPlay();
		if (EnumToIntResult != 20)
		{
			return false;
		}
		return IntToEnumResult == EConversionEnum::ValueTen;
	}

	/**
	 * Observe that ValueZero converts both ways through 0.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumConversion
	 * @Inputs ValueZero and integer 0
	 * @Return true when both conversions yield zero
	 * @Boundary empty zero
	 */
	UFUNCTION()
	bool EmptyZero()
	{
		if (int(EConversionEnum::ValueZero) != 0)
		{
			return false;
		}
		return EConversionEnum(0) == EConversionEnum::ValueZero;
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumConversion
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumConversionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that ValueTwenty converts both ways through 20.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumConversion
	 * @Inputs ValueTwenty and integer 20
	 * @Return true when both conversions yield twenty
	 * @Boundary ValueTwenty
	 */
	UFUNCTION()
	bool TwentyBoundary()
	{
		if (int(EConversionEnum::ValueTwenty) != 20)
		{
			return false;
		}
		return EConversionEnum(20) == EConversionEnum::ValueTwenty;
	}
}
/** @end */
