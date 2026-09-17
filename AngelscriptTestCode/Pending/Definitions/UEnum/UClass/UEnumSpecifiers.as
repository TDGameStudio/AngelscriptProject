/**
 * @version v1
 * @summary BlueprintType plus Category, DisplayName, and ToolTip specifiers on UENUM. C++ reads BPType and MultiSpec by path, so those names are kept.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintType plus Category, DisplayName, and ToolTip specifiers on UENUM. C++ reads BPType and MultiSpec by path, so those names are kept.
 * @topic Baseline
 */
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

	/**
	 * Observe that BPType defaults to BPOption1 and MultiSpec to Value2.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumSpecifiers
	 * @Inputs a locally constructed actor
	 * @Return true when BPType is 0 and MultiSpec is 1
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool PropertyDefaults()
	{
		if (BPType != EBlueprintTypeEnum::BPOption1)
		{
			return false;
		}
		if (MultiSpec != EMultiSpecifierEnum::Value2)
		{
			return false;
		}
		if (int(BPType) != 0)
		{
			return false;
		}
		return int(MultiSpec) == 1;
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumSpecifiers
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumSpecifiersActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that the last enumerators of both enums are 2.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumSpecifiers
	 * @Inputs BPOption3 and Value3
	 * @Return 4, the sum of both last enumerators
	 * @Boundary last enumerators
	 */
	UFUNCTION()
	int LastEnumeratorBoundary()
	{
		return int(EBlueprintTypeEnum::BPOption3) + int(EMultiSpecifierEnum::Value3);
	}
}
/** @end */
