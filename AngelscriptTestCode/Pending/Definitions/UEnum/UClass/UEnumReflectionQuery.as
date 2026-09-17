/**
 * @version v1
 * @summary Explicit enumerator values plus a UMETA query surface. C++ reads Value and MetaValue by path, so those names are kept. Metadata is C++ reflection-side.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Explicit enumerator values plus a UMETA query surface. C++ reads Value and MetaValue by path, so those names are kept. Metadata is C++ reflection-side.
 * @topic Baseline
 */
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

	/**
	 * Observe that Value defaults to Alpha at 3 and MetaValue to AlphaChoice at 1.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumReflectionQuery
	 * @Inputs a locally constructed actor
	 * @Return true when both properties hold their declared defaults
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool PropertyDefaults()
	{
		if (Value != EReflectionValueEnum::Alpha)
		{
			return false;
		}
		if (int(Value) != 3)
		{
			return false;
		}
		if (MetaValue != EReflectionMetaEnum::AlphaChoice)
		{
			return false;
		}
		return int(MetaValue) == 1;
	}

	/**
	 * Observe the empty None/NoSelection enumerators and the Beta boundary.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumReflectionQuery
	 * @Inputs None, Beta, and NoSelection
	 * @Return true when None is 0, Beta is 8, and NoSelection is 0
	 * @Boundary empty and Beta
	 */
	UFUNCTION()
	bool EmptyAndBoundary()
	{
		if (int(EReflectionValueEnum::None) != 0)
		{
			return false;
		}
		if (int(EReflectionValueEnum::Beta) != 8)
		{
			return false;
		}
		return int(EReflectionMetaEnum::NoSelection) == 0;
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumReflectionQuery
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumReflectionQueryActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that writing this actor's Value leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumReflectionQuery
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds None and the other stays at Alpha
	 * @Param Second the other actor, expected to stay at its default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(ACoverageUEnumReflectionQueryActor Second)
	{
		if (Second == nullptr)
		{
			throw("UEnumReflectionQuery setup: required Second is null");
		}
		Value = EReflectionValueEnum::None;
		if (Second.Value != EReflectionValueEnum::Alpha)
		{
			return false;
		}
		return Value == EReflectionValueEnum::None;
	}
}
/** @end */
