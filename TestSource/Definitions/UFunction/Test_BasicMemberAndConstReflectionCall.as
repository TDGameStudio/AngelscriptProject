// Theme: Definitions.UFunction. WorldStory: plain member + const UFUNCTION reflection call.
// C++: AngelscriptCoverageUFunctionTests.cpp::BasicMemberAndConstReflectionCall
// Compile + spawn + SetStoredValue(123) then GetStoredValue. Oracle: 123.
// Extra: default StoredValue is 5; SetStoredValue(0) writes 0; second instance stays 5.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionBasicActor : AActor
{
	UPROPERTY()
	int StoredValue = 5;

	UFUNCTION()
	void SetStoredValue(int Value)
	{
		StoredValue = Value;
	}

	UFUNCTION()
	int GetStoredValue() const
	{
		return StoredValue;
	}
}

int Observe_BasicMember_SetThenGet(ACoverageUFunctionBasicActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BasicMemberAndConstReflectionCall setup: required Actor is null");
	}
	Actor.SetStoredValue(123);
	return Actor.GetStoredValue();
}

int Observe_BasicMember_DefaultFive(ACoverageUFunctionBasicActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BasicMemberAndConstReflectionCall setup: required Actor is null");
	}
	return Actor.GetStoredValue();
}

int Observe_BasicMember_ZeroBoundary(ACoverageUFunctionBasicActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BasicMemberAndConstReflectionCall setup: required Actor is null");
	}
	Actor.SetStoredValue(0);
	return Actor.GetStoredValue();
}

bool Observe_BasicMember_SecondInstanceIndependent(ACoverageUFunctionBasicActor First, ACoverageUFunctionBasicActor Second)
{
	if (First is null)
	{
		throw("Test_BasicMemberAndConstReflectionCall setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_BasicMemberAndConstReflectionCall setup: required Second is null");
	}
	First.SetStoredValue(123);
	return First.GetStoredValue() == 123 && Second.GetStoredValue() == 5;
}
