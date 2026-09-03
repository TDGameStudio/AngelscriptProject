/**
 * UMETA DisplayName, ToolTip, and Hidden on enumerators. Metadata is C++
 * reflection-side. C++ reads Value by path, so that name is kept.
 *
 * @Theme Definitions.UEnum
 * @Subject UEnum.UEnumMeta
 * @Harness UClass
 * @Tag Definitions.UEnum.UEnumMeta
 * @Provenance Theme: Definitions.UEnum. WorldStory UMETA DisplayName/ToolTip/Hidden on enumerators.
 * @Provenance C++: AngelscriptCoverageUEnumTests.cpp::UEnumMeta
 * @Provenance Oracle: Value default OptionA; four entries; Hidden on OptionC only. Metadata is C++ reflection-side.
 * @Provenance Extra: nullptr actor is the empty handle; OptionD has no UMETA as a boundary; mutating First does not write Second.
 * @Provenance FixtureIsolated. Keep Value.
 */

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

	/**
	 * Observe that Value defaults to OptionA at 0.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumMeta
	 * @Inputs a locally constructed actor
	 * @Return true when Value is OptionA and converts to 0
	 * @Boundary declared default
	 */
	UFUNCTION()
	bool PropertyDefaults()
	{
		if (Value != EMetaEnum::OptionA)
		{
			return false;
		}
		return int(Value) == 0;
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumMeta
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumMetaActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that OptionD has no UMETA and is enumerator 3.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumMeta
	 * @Inputs OptionD
	 * @Return 3
	 * @Boundary OptionD without UMETA
	 */
	UFUNCTION()
	int OptionDBoundary()
	{
		return int(EMetaEnum::OptionD);
	}

	/**
	 * Observe that writing this actor leaves another actor's Value untouched.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumMeta
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds OptionC and the other stays at OptionA
	 * @Param Second the other actor, expected to stay at its default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(ACoverageUEnumMetaActor Second)
	{
		if (Second == nullptr)
		{
			throw("UEnumMeta setup: required Second is null");
		}
		Value = EMetaEnum::OptionC;
		if (Second.Value != EMetaEnum::OptionA)
		{
			return false;
		}
		return Value == EMetaEnum::OptionC;
	}
}
