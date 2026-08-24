// Theme: Feature.Delegates. WorldStory unicast IsBound on an empty delegate.
// C++: AngelscriptDelegateTests.cpp::IsBoundReturnsFalseWhenUnbound
// sha256=084e2e3e1aaf1a267f97d67bc1c2721946db8085240518131e5aef3954928b3c; lines 123-140.
// Oracle: RunIsBoundTest returns 1 (unbound path). Extra: default IsBound is false;
// a second local stays unbound. FixtureIsolated.

delegate void FSimpleNotify();

UCLASS()
class ATestDelegateIsBound : AActor
{
	UPROPERTY()
	FSimpleNotify OnNotify;

	UFUNCTION()
	int RunIsBoundTest()
	{
		if (OnNotify.IsBound())
		{
			return 10;
		}
		return 1;
	}
}

int Observe_IsBound_UnboundReturnsOne(ATestDelegateIsBound Actor)
{
	if (Actor is null)
	{
		throw("Test_IsBoundReturnsFalseWhenUnbound setup: required Actor is null");
	}
	return Actor.RunIsBoundTest();
}

bool Observe_IsBound_DefaultUnbound(ATestDelegateIsBound Actor)
{
	if (Actor is null)
	{
		throw("Test_IsBoundReturnsFalseWhenUnbound setup: required Actor is null");
	}
	return !Actor.OnNotify.IsBound();
}

bool Observe_IsBound_TwoLocalsIndependent(ATestDelegateIsBound First, ATestDelegateIsBound Second)
{
	if (First is null)
	{
		throw("Test_IsBoundReturnsFalseWhenUnbound setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_IsBoundReturnsFalseWhenUnbound setup: required Second is null");
	}
	return First.RunIsBoundTest() == 1 && Second.RunIsBoundTest() == 1;
}
