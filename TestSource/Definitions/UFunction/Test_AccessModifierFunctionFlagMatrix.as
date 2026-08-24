// Theme: Definitions.UFunction. WorldStory: private/protected/public UFUNCTION access matrix.
// C++: AngelscriptCoverageUFunctionTests.cpp::AccessModifierFunctionFlagMatrix
// Compile + spawn + CallAccessMatrix. Oracle: return 969, StoredValue 321.
// Extra: default StoredValue 0; a second instance stays 0 after the first dispatch.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionAccessActor : AActor
{
	UPROPERTY()
	int StoredValue = 0;

	UFUNCTION(BlueprintCallable, Category="Coverage|Access")
	private void PrivateCallable(int Value)
	{
		StoredValue += Value;
	}

	UFUNCTION(BlueprintPure, Category="Coverage|Access")
	private int PrivatePureValue() const
	{
		return StoredValue + 1;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Access")
	protected void ProtectedCallable(int Value)
	{
		StoredValue += Value * 10;
	}

	UFUNCTION(BlueprintPure, Category="Coverage|Access")
	protected int ProtectedPureValue() const
	{
		return StoredValue + 2;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Access")
	void PublicCallable(int Value)
	{
		StoredValue += Value * 100;
	}

	UFUNCTION(BlueprintPure, Category="Coverage|Access")
	int PublicPureValue() const
	{
		return StoredValue + 3;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Access")
	int CallAccessMatrix()
	{
		PrivateCallable(1);
		ProtectedCallable(2);
		PublicCallable(3);
		return PrivatePureValue() + ProtectedPureValue() + PublicPureValue();
	}
}

int Observe_AccessMatrix_Nominal(ACoverageUFunctionAccessActor Actor)
{
	if (Actor is null)
	{
		throw("Test_AccessModifierFunctionFlagMatrix setup: required Actor is null");
	}
	return Actor.CallAccessMatrix();
}

int Observe_AccessMatrix_StoredValue(ACoverageUFunctionAccessActor Actor)
{
	if (Actor is null)
	{
		throw("Test_AccessModifierFunctionFlagMatrix setup: required Actor is null");
	}
	Actor.CallAccessMatrix();
	return Actor.StoredValue;
}

int Observe_AccessMatrix_DefaultZero(ACoverageUFunctionAccessActor Actor)
{
	if (Actor is null)
	{
		throw("Test_AccessModifierFunctionFlagMatrix setup: required Actor is null");
	}
	return Actor.StoredValue;
}

bool Observe_AccessMatrix_SecondInstanceIndependent(ACoverageUFunctionAccessActor First, ACoverageUFunctionAccessActor Second)
{
	if (First is null)
	{
		throw("Test_AccessModifierFunctionFlagMatrix setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_AccessModifierFunctionFlagMatrix setup: required Second is null");
	}
	int FirstResult = First.CallAccessMatrix();
	return FirstResult == 969 && First.StoredValue == 321 && Second.StoredValue == 0;
}
