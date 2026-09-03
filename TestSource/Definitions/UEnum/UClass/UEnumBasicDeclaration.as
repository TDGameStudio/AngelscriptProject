/**
 * Plain enum, default-increment UENUM, explicit values, and a namespace enum.
 * C++ reads DefaultValue and ExplicitValue by path after BeginPlay, so those
 * property names are kept. The observers cover first enumerators, the High
 * boundary, and a null handle of this actor type.
 *
 * @Theme Definitions.UEnum
 * @Subject UEnum.UEnumBasicDeclaration
 * @Harness UClass
 * @Tag Definitions.UEnum.UEnumBasicDeclaration
 * @Provenance Theme: Definitions.UEnum. WorldStory plain enum, default increment, explicit values, namespace enum.
 * @Provenance C++: AngelscriptCoverageUEnumTests.cpp::UEnumBasicDeclaration
 * @Provenance Oracle: DefaultValue Second==1; ExplicitValue Medium==5; First=0 Second=1 Third=2; Low=1 Medium=5 High=10; NSValueB=1; PlainB=1.
 * @Provenance Extra: First/PlainA/NSValueA empty first enumerators; nullptr actor is the empty handle.
 * @Provenance FixtureIsolated. Keep DefaultValue / ExplicitValue names.
 */

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

	/**
	 * WorldStory: convert enumerators to int and check default increment,
	 * explicit values, the namespace enum, and the plain enum.
	 *
	 * @Kind WorldStory
	 * @Covers UEnum.UEnumBasicDeclaration
	 * @Inputs none
	 * @Return nothing; checks record the enumerator values
	 */
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

	/**
	 * Observe that DefaultValue is Second and ExplicitValue is Medium.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBasicDeclaration
	 * @Inputs a locally constructed actor
	 * @Return true when both properties hold their declared defaults
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool PropertyDefaults()
	{
		if (DefaultValue != EDefaultIncrement::Second)
		{
			return false;
		}
		if (int(DefaultValue) != 1)
		{
			return false;
		}
		if (ExplicitValue != EExplicitValues::Medium)
		{
			return false;
		}
		return int(ExplicitValue) == 5;
	}

	/**
	 * Observe that the first enumerator of each enum is zero.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBasicDeclaration
	 * @Inputs First, PlainA, and NSValueA
	 * @Return true when all three first enumerators convert to 0
	 * @Boundary empty first enumerators
	 */
	UFUNCTION()
	bool EmptyFirstEnumerators()
	{
		if (int(EDefaultIncrement::First) != 0)
		{
			return false;
		}
		if (int(EPlainEnum::PlainA) != 0)
		{
			return false;
		}
		return int(CoverageNS::ENamespaceEnum::NSValueA) == 0;
	}

	/**
	 * Observe the explicit High and Low enumerator values.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBasicDeclaration
	 * @Inputs High and Low
	 * @Return true when High is 10 and Low is 1
	 * @Boundary explicit High
	 */
	UFUNCTION()
	bool ExplicitHighBoundary()
	{
		if (int(EExplicitValues::High) != 10)
		{
			return false;
		}
		return int(EExplicitValues::Low) == 1;
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumBasicDeclaration
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumBasicActor Actor = nullptr;
		return Actor == nullptr;
	}
}
