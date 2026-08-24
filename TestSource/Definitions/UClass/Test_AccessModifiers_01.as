// Theme: Definitions.UClass. WorldStory private/protected/public access inside UCLASS.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::AccessModifiers compiles then VerifyByPath.
// CSV NegativeDiagnostic is wrong for this block (the public-keyword fail is Test_AccessModifiers_02).
// Oracle: TestResult=1 after base BeginPlay; DerivedTestResult=1 after derived BeginPlay.
// Extra: unset handles are null; pre-BeginPlay counters stay 0. FixtureIsolated.

UCLASS()
class AAccessModifierBase : AActor
{
	private int PrivateValue = 100;

	protected int ProtectedValue = 200;

	int PublicValue = 300;

	UPROPERTY()
	int TestResult = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test access within same class
		PrivateValue = 111;
		ProtectedValue = 222;
		PublicValue = 333;

		if (PrivateValue == 111 && ProtectedValue == 222 && PublicValue == 333)
		{
			TestResult = 1;
		}
	}
}

UCLASS()
class AAccessModifierDerived : AAccessModifierBase
{
	UPROPERTY()
	int DerivedTestResult = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();

		// Derived class can access protected members
		ProtectedValue = 444;

		// Derived class can access default-public members
		PublicValue = 555;

		if (ProtectedValue == 444 && PublicValue == 555)
		{
			DerivedTestResult = 1;
		}
	}
}

bool Observe_AccessModifierBase_EmptyDefaultIsNull()
{
	AAccessModifierBase Actor;
	return Actor == nullptr;
}

int Observe_AccessModifierBase_TestResultDefault(AAccessModifierBase Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0030 setup: required AAccessModifierBase is null");
	}
	return Actor.TestResult;
}

int Observe_AccessModifierDerived_DerivedTestResultDefault(AAccessModifierDerived Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0030 setup: required AAccessModifierDerived is null");
	}
	return Actor.DerivedTestResult;
}
