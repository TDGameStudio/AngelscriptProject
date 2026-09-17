/**
 * @version v1
 * @summary Bitflags metadata plus integer-backed bitwise operators on a UENUM. C++ reads OrResult, AndResult, XorResult, NotResult, and CompoundResult by path after BeginPlay, so those names are kept.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Bitflags metadata plus integer-backed bitwise operators on a UENUM. C++ reads OrResult, AndResult, XorResult, NotResult, and CompoundResult by path after BeginPlay, so those names are kept.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: OR Read with Execute, then AND, XOR, NOT, and compound-OR Write.
	 *
	 * @Kind WorldStory
	 * @Covers UEnum.UEnumBitflagMetadataAndRuntimeOperators
	 * @Inputs none
	 * @Return OrResult 5, AndResult 1, XorResult 1, NotResult -2, CompoundResult 7
	 */
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

	/**
	 * Observe the BeginPlay oracle for the five bitwise results.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBitflagMetadataAndRuntimeOperators
	 * @Inputs this actor after BeginPlay
	 * @Return true when OR=5, AND=1, XOR=1, NOT=-2, compound=7
	 */
	UFUNCTION()
	bool BeginPlayOracle()
	{
		BeginPlay();
		if (OrResult != 5)
		{
			return false;
		}
		if (AndResult != 1)
		{
			return false;
		}
		if (XorResult != 1)
		{
			return false;
		}
		if (NotResult != -2)
		{
			return false;
		}
		return CompoundResult == 7;
	}

	/**
	 * Observe that None is the empty zero flag.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBitflagMetadataAndRuntimeOperators
	 * @Inputs None
	 * @Return 0
	 * @Boundary empty flags
	 */
	UFUNCTION()
	int NoneEmpty()
	{
		return int(ECoverageMacroFlagState::None);
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBitflagMetadataAndRuntimeOperators
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageMacrosEnumBitflagActor Actor = nullptr;
		return Actor == nullptr;
	}
}
/** @end */
