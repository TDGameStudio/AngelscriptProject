// Theme: Feature.Delegates. WorldStory GetUObject null when unbound, this when bound.
// C++: AngelscriptDelegateTests.cpp::GetUObjectReturnsTarget
// sha256 from theme-refs TS-FEAT-0201; lines 226-254.
// Oracle: RunGetUObjectTest returns 1. Extra: default GetUObject is null; second local
// stays unbound. FixtureIsolated.

delegate void FSimpleNotify();

UCLASS()
class ATestDelegateGetUObject : AActor
{
	UPROPERTY()
	FSimpleNotify OnNotify;

	UFUNCTION()
	void HandleNotify()
	{
	}

	UFUNCTION()
	int RunGetUObjectTest()
	{
		if (OnNotify.GetUObject() != nullptr)
		{
			return 10;
		}

		OnNotify.BindUFunction(this, n"HandleNotify");
		UObject Target = OnNotify.GetUObject();
		if (Target == nullptr)
		{
			return 20;
		}
		if (Target != this)
		{
			return 30;
		}

		return 1;
	}
}

int Observe_GetUObject_Nominal(ATestDelegateGetUObject Actor)
{
	if (Actor is null)
	{
		throw("Test_GetUObjectReturnsTarget setup: required Actor is null");
	}
	return Actor.RunGetUObjectTest();
}

bool Observe_GetUObject_DefaultNull(ATestDelegateGetUObject Actor)
{
	if (Actor is null)
	{
		throw("Test_GetUObjectReturnsTarget setup: required Actor is null");
	}
	return Actor.OnNotify.GetUObject() == nullptr;
}

bool Observe_GetUObject_TwoLocalsIndependent(ATestDelegateGetUObject First, ATestDelegateGetUObject Second)
{
	if (First is null)
	{
		throw("Test_GetUObjectReturnsTarget setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_GetUObjectReturnsTarget setup: required Second is null");
	}
	int FirstResult = First.RunGetUObjectTest();
	return FirstResult == 1 && Second.OnNotify.GetUObject() == nullptr;
}
