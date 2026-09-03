/**
 * Private, protected, and public access inside a UCLASS. After BeginPlay,
 * TestResult is 1 on the base and DerivedTestResult is 1 on the derived actor.
 * Keep those UPROPERTY names; C++ VerifyByPath reads them.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.AccessModifiers
 * @Harness UClass
 * @Tag Definitions.UClass.AccessModifiers
 * @Provenance Theme: Definitions.UClass. WorldStory private/protected/public access inside UCLASS.
 * @Provenance C++: AngelscriptCoverageClassFeaturesTests.cpp::AccessModifiers compiles then VerifyByPath.
 * @Provenance CSV NegativeDiagnostic is wrong for this block (the public-keyword fail is PublicKeywordBoundary).
 * @Provenance Oracle: TestResult=1 after base BeginPlay; DerivedTestResult=1 after derived BeginPlay.
 * @Provenance Extra: unset handles are null; pre-BeginPlay counters stay 0. FixtureIsolated.
 */

UCLASS()
class AAccessModifierBase : AActor
{
	private int PrivateValue = 100;

	protected int ProtectedValue = 200;

	int PublicValue = 300;

	UPROPERTY()
	int TestResult = 0;

	/**
	 * WorldStory: same-class access writes private, protected, and public members.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Access
	 * @Inputs PrivateValue, ProtectedValue, PublicValue
	 * @Return TestResult = 1 when all three writes land
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		PrivateValue = 111;
		ProtectedValue = 222;
		PublicValue = 333;

		if (PrivateValue == 111)
		{
			if (ProtectedValue == 222)
			{
				if (PublicValue == 333)
				{
					TestResult = 1;
				}
			}
		}
	}

	/**
	 * Observe that an unset base handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Access
	 * @Inputs an unset AAccessModifierBase handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		AAccessModifierBase Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe TestResult before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.Access
	 * @Inputs a freshly constructed base actor
	 * @Return TestResult
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int TestResultDefault()
	{
		return TestResult;
	}
}

UCLASS()
class AAccessModifierDerived : AAccessModifierBase
{
	UPROPERTY()
	int DerivedTestResult = 0;

	/**
	 * WorldStory: derived BeginPlay may write protected and public members.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Access
	 * @Inputs Super::BeginPlay, ProtectedValue, PublicValue
	 * @Return DerivedTestResult = 1 when both writes land
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();

		ProtectedValue = 444;
		PublicValue = 555;

		if (ProtectedValue == 444)
		{
			if (PublicValue == 555)
			{
				DerivedTestResult = 1;
			}
		}
	}

	/**
	 * Observe DerivedTestResult before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.Access
	 * @Inputs a freshly constructed derived actor
	 * @Return DerivedTestResult
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int DerivedTestResultDefault()
	{
		return DerivedTestResult;
	}
}
