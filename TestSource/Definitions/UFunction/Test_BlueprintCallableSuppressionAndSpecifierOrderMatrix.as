// Theme: Definitions.UFunction. WorldStory: last specifier wins for BlueprintCallable/Pure.
// C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintCallableSuppressionAndSpecifierOrderMatrix
// Compile + spawn + reflective calls. Oracle: CallableThenHidden(10)->11, HiddenThenCallable(20)->22,
// HiddenExecCommand(30)->35, PureThenHidden(4)->42, HiddenThenPure(5)->44.
// Extra: default StoredValue 0; PureThenHidden(0) at default is 3; second instance stays 0.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionCallableOrderActor : AActor
{
	UPROPERTY()
	int StoredValue = 0;

	UFUNCTION(BlueprintCallable, NotBlueprintCallable, Category="Coverage|CallableOrder")
	void CallableThenHidden(int Value)
	{
		StoredValue = Value + 1;
	}

	UFUNCTION(NotBlueprintCallable, BlueprintCallable, Category="Coverage|CallableOrder")
	void HiddenThenCallable(int Value)
	{
		StoredValue = Value + 2;
	}

	UFUNCTION(BlueprintPure, NotBlueprintCallable, Category="Coverage|CallableOrder")
	int PureThenHidden(int Value) const
	{
		return StoredValue + Value + 3;
	}

	UFUNCTION(NotBlueprintCallable, BlueprintPure, Category="Coverage|CallableOrder")
	int HiddenThenPure(int Value) const
	{
		return StoredValue + Value + 4;
	}

	UFUNCTION(NotBlueprintCallable, Exec, Category="Coverage|CallableOrder")
	void HiddenExecCommand(int Value)
	{
		StoredValue = Value + 5;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|CallableOrder")
	int ReadStoredValue() const
	{
		return StoredValue;
	}
}

int Observe_CallableOrder_VoidSequence(ACoverageUFunctionCallableOrderActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintCallableSuppressionAndSpecifierOrderMatrix setup: required Actor is null");
	}
	Actor.CallableThenHidden(10);
	if (Actor.ReadStoredValue() != 11)
	{
		return -1;
	}
	Actor.HiddenThenCallable(20);
	if (Actor.ReadStoredValue() != 22)
	{
		return -2;
	}
	Actor.HiddenExecCommand(30);
	return Actor.ReadStoredValue();
}

int Observe_CallableOrder_PureAfterExec(ACoverageUFunctionCallableOrderActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintCallableSuppressionAndSpecifierOrderMatrix setup: required Actor is null");
	}
	Actor.HiddenExecCommand(30);
	return Actor.PureThenHidden(4);
}

int Observe_CallableOrder_HiddenThenPureAfterExec(ACoverageUFunctionCallableOrderActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintCallableSuppressionAndSpecifierOrderMatrix setup: required Actor is null");
	}
	Actor.HiddenExecCommand(30);
	return Actor.HiddenThenPure(5);
}

int Observe_CallableOrder_DefaultZero(ACoverageUFunctionCallableOrderActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintCallableSuppressionAndSpecifierOrderMatrix setup: required Actor is null");
	}
	return Actor.ReadStoredValue();
}

int Observe_CallableOrder_PureAtDefaultZero(ACoverageUFunctionCallableOrderActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintCallableSuppressionAndSpecifierOrderMatrix setup: required Actor is null");
	}
	return Actor.PureThenHidden(0);
}

bool Observe_CallableOrder_SecondInstanceIndependent(ACoverageUFunctionCallableOrderActor First, ACoverageUFunctionCallableOrderActor Second)
{
	if (First is null)
	{
		throw("Test_BlueprintCallableSuppressionAndSpecifierOrderMatrix setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_BlueprintCallableSuppressionAndSpecifierOrderMatrix setup: required Second is null");
	}
	First.CallableThenHidden(10);
	return First.ReadStoredValue() == 11 && Second.ReadStoredValue() == 0;
}
