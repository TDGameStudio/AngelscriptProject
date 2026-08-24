// Theme: Feature.PropertyAccess. WorldStory BlueprintGetter/Setter UFUNCTION matrix.
// C++: AngelscriptCoverageUFunctionTests.cpp::PropertyAccessorCallbackUFunctionMatrix
// Spawn + GetAccessorValue==20; SetAccessorValue(35) then Get==35,
// SetterCallCount==1, GetReadonlyValue==42 (7+35).
// Extra: default SetterCallCount 0; GetReadonlyValue default 27; Set 0.
// FixtureIsolated. Keep AccessorValue / ReadonlyValue / SetterCallCount.

UCLASS()
class ACoverageUFunctionAccessorActor : AActor
{
	UPROPERTY(BlueprintReadWrite, BlueprintGetter=GetAccessorValue, BlueprintSetter=SetAccessorValue)
	int AccessorValue = 20;

	UPROPERTY(BlueprintReadOnly, BlueprintGetter=GetReadonlyValue)
	int ReadonlyValue = 7;

	UPROPERTY()
	int SetterCallCount = 0;

	UFUNCTION(BlueprintPure, Category="Coverage|Accessor")
	int GetAccessorValue() const
	{
		return AccessorValue;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Accessor")
	void SetAccessorValue(int NewValue)
	{
		SetterCallCount += 1;
		AccessorValue = NewValue;
	}

	UFUNCTION(BlueprintPure, Category="Coverage|Accessor")
	int GetReadonlyValue() const
	{
		return ReadonlyValue + AccessorValue;
	}
}

int Observe_Accessor_DefaultGet(ACoverageUFunctionAccessorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PropertyAccessorCallbackUFunctionMatrix setup: required Actor is null");
	}
	return Actor.GetAccessorValue();
}

int Observe_Accessor_SetThenGet(ACoverageUFunctionAccessorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PropertyAccessorCallbackUFunctionMatrix setup: required Actor is null");
	}
	Actor.SetAccessorValue(35);
	return Actor.GetAccessorValue();
}

int Observe_Accessor_SetterCallCount(ACoverageUFunctionAccessorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PropertyAccessorCallbackUFunctionMatrix setup: required Actor is null");
	}
	Actor.SetAccessorValue(35);
	return Actor.SetterCallCount;
}

int Observe_Accessor_ReadonlyAfterSet(ACoverageUFunctionAccessorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PropertyAccessorCallbackUFunctionMatrix setup: required Actor is null");
	}
	Actor.SetAccessorValue(35);
	return Actor.GetReadonlyValue();
}

int Observe_Accessor_DefaultSetterCount(ACoverageUFunctionAccessorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PropertyAccessorCallbackUFunctionMatrix setup: required Actor is null");
	}
	return Actor.SetterCallCount;
}

int Observe_Accessor_ZeroBoundary(ACoverageUFunctionAccessorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PropertyAccessorCallbackUFunctionMatrix setup: required Actor is null");
	}
	Actor.SetAccessorValue(0);
	return Actor.GetAccessorValue();
}

int Observe_Accessor_DefaultReadonly(ACoverageUFunctionAccessorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PropertyAccessorCallbackUFunctionMatrix setup: required Actor is null");
	}
	return Actor.GetReadonlyValue();
}
