/**
 * meta=(Bitflags, BitmaskEnum) plus a UPROPERTY Bitmask integer. Metadata is C++
 * reflection-side. C++ reads Value and ActiveFlags by path, so those names are
 * kept.
 *
 * @Theme Definitions.UEnum
 * @Subject UEnum.UEnumMetaBitflags
 * @Harness UClass
 * @Tag Definitions.UEnum.UEnumMetaBitflags
 * @Provenance Theme: Definitions.UEnum. WorldStory meta=(Bitflags, BitmaskEnum) plus UPROPERTY Bitmask.
 * @Provenance C++: AngelscriptCoverageUEnumTests.cpp::UEnumMetaBitflags
 * @Provenance Oracle: Value default FlagB=2; ActiveFlags default 0; metadata is C++ reflection-side.
 * @Provenance Extra: nullptr actor is the empty handle; FlagC=4 is a bit boundary; mutating First does not write Second.
 * @Provenance FixtureIsolated. Keep Value / ActiveFlags names.
 */

UENUM(meta = (Bitflags, BitmaskEnum = "EFlagMetaEnum"))
enum EFlagMetaEnum
{
	FlagA = 1,
	FlagB = 2,
	FlagC = 4
}

UCLASS()
class ACoverageUEnumMetaBitflagsActor : AActor
{
	UPROPERTY()
	EFlagMetaEnum Value = EFlagMetaEnum::FlagB;

	UPROPERTY(meta = (Bitmask, BitmaskEnum = "EFlagMetaEnum"))
	int ActiveFlags = 0;

	/**
	 * Observe that Value defaults to FlagB at 2 and ActiveFlags is 0.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumMetaBitflags
	 * @Inputs a locally constructed actor
	 * @Return true when Value is FlagB (2) and ActiveFlags is 0
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool PropertyDefaults()
	{
		if (Value != EFlagMetaEnum::FlagB)
		{
			return false;
		}
		if (int(Value) != 2)
		{
			return false;
		}
		return ActiveFlags == 0;
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumMetaBitflags
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumMetaBitflagsActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that FlagC is bit 4.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumMetaBitflags
	 * @Inputs FlagC
	 * @Return 4
	 * @Boundary FlagC bit
	 */
	UFUNCTION()
	int FlagCBoundary()
	{
		return int(EFlagMetaEnum::FlagC);
	}

	/**
	 * Observe that writing this actor's ActiveFlags leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumMetaBitflags
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds 5 and the other stays at 0
	 * @Param Second the other actor, expected to stay at its default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(ACoverageUEnumMetaBitflagsActor Second)
	{
		if (Second == nullptr)
		{
			throw("UEnumMetaBitflags setup: required Second is null");
		}
		ActiveFlags = int(EFlagMetaEnum::FlagA) | int(EFlagMetaEnum::FlagC);
		if (Second.ActiveFlags != 0)
		{
			return false;
		}
		return ActiveFlags == 5;
	}
}
