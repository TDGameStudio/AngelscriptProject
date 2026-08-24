// Theme: Feature.Inheritance. WorldStory IsA/Cast After of the reload pair.
// C++: AngelscriptInheritanceFunctionalTests.cpp::IsA AnalyzeReloadFromMemory succeeds;
// full-reload required. VerifyBaseCast returns 1 on a derived instance, 0 on a failed cast.
// Extra: empty handle null; Cast of null stays 0. FixtureIsolated.

UCLASS()
class ATestInheritanceIsABase : AActor
{
}

UCLASS()
class ATestInheritanceIsADerived : ATestInheritanceIsABase
{
	UFUNCTION()
	int VerifyBaseCast()
	{
		ATestInheritanceIsABase BaseRef = Cast<ATestInheritanceIsABase>(this);
		return BaseRef == null ? 0 : 1;
	}
}

bool Observe_IsAAfter_EmptyHandleIsNull()
{
	ATestInheritanceIsADerived Actor;
	return Actor == nullptr;
}

int Observe_IsAAfter_VerifyBaseCast(ATestInheritanceIsADerived Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0217 setup: required ATestInheritanceIsADerived is null");
	}
	return Actor.VerifyBaseCast();
}

int Observe_IsAAfter_NullCastBoundary()
{
	ATestInheritanceIsABase BaseRef = Cast<ATestInheritanceIsABase>(nullptr);
	return BaseRef == null ? 0 : 1;
}
