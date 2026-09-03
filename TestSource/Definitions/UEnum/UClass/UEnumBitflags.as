/**
 * Integer-backed bitwise operators on a permission UENUM. C++ compiles these
 * bitwise enum ops (the CSV NegativeDiagnostic is wrong) and reads OrResult,
 * AndResult, XorResult, NotResult, and CompoundOrResult by path after BeginPlay.
 *
 * @Theme Definitions.UEnum
 * @Subject UEnum.UEnumBitflags
 * @Harness UClass
 * @Tag Definitions.UEnum.UEnumBitflags
 * @Provenance Theme: Definitions.UEnum. C++ compiles bitwise enum ops (CSV NegativeDiagnostic is wrong).
 * @Provenance C++: AngelscriptCoverageUEnumTests.cpp::UEnumBitflags
 * @Provenance Oracle after BeginPlay: OrResult=3, AndResult=1, XorResult=1, NotResult=-2, CompoundOrResult=5.
 * @Provenance Extra: None=0 empty flags; nullptr actor is the empty handle; Delete=8 is an unused bit boundary.
 * @Provenance FixtureIsolated. Keep OrResult/AndResult/XorResult/NotResult/CompoundOrResult names.
 */

UENUM()
enum EPermissionFlags
{
	None = 0,
	Read = 1,
	Write = 2,
	Execute = 4,
	Delete = 8
}

UCLASS()
class ACoverageUEnumBitflagsActor : AActor
{
	UPROPERTY()
	int OrResult = 0;

	UPROPERTY()
	int AndResult = 0;

	UPROPERTY()
	int XorResult = 0;

	UPROPERTY()
	int NotResult = 0;

	UPROPERTY()
	int CompoundOrResult = 0;

	/**
	 * WorldStory: OR Read with Write, then AND, XOR, NOT, and compound-OR Execute.
	 *
	 * @Kind WorldStory
	 * @Covers UEnum.UEnumBitflags
	 * @Inputs none
	 * @Return OrResult 3, AndResult 1, XorResult 1, NotResult -2, CompoundOrResult 5
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		int Flags1 = int(EPermissionFlags::Read) | int(EPermissionFlags::Write);
		check(Flags1 == 3);
		OrResult = Flags1;

		int Flags2 = Flags1 & int(EPermissionFlags::Read);
		check(Flags2 == 1);
		AndResult = Flags2;

		int Flags3 = Flags1 ^ int(EPermissionFlags::Write);
		check(Flags3 == 1);
		XorResult = Flags3;

		int Flags4 = ~int(EPermissionFlags::Read);
		check(Flags4 == -2);
		NotResult = Flags4;

		int Flags5 = int(EPermissionFlags::Read);
		Flags5 |= int(EPermissionFlags::Execute);
		check(Flags5 == 5);
		CompoundOrResult = Flags5;
	}

	/**
	 * Observe the BeginPlay oracle for the five bitwise results.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBitflags
	 * @Inputs this actor after BeginPlay
	 * @Return true when OR=3, AND=1, XOR=1, NOT=-2, compound-OR=5
	 */
	UFUNCTION()
	bool BeginPlayOracle()
	{
		BeginPlay();
		if (OrResult != 3)
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
		return CompoundOrResult == 5;
	}

	/**
	 * Observe that None is the empty zero flag.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBitflags
	 * @Inputs None
	 * @Return 0
	 * @Boundary empty flags
	 */
	UFUNCTION()
	int NoneEmpty()
	{
		return int(EPermissionFlags::None);
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBitflags
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumBitflagsActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that Delete is bit 8 and ORs with Read to 9.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBitflags
	 * @Inputs Read and Delete
	 * @Return true when Delete is 8 and Read|Delete is 9
	 * @Boundary unused Delete bit
	 */
	UFUNCTION()
	bool DeleteBoundary()
	{
		int WithDelete = int(EPermissionFlags::Read) | int(EPermissionFlags::Delete);
		if (WithDelete != 9)
		{
			return false;
		}
		return int(EPermissionFlags::Delete) == 8;
	}
}
