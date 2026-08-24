// Theme: Definitions.UFunction. WorldStory: dispatch subclass shapes by return/arg type.
// C++: AngelscriptCoverageUFunctionTests.cpp::FunctionDispatchSubclassShapeMatrix
// Compile + spawn + reflective calls. Oracle: ReturnVoid StoredValue 1; ReturnBool true;
// ReturnByte/Int 42; ReturnFloat/Double 42; ReturnString "shape"; AcceptInt 39;
// AcceptDouble 40; AcceptByte 41; AcceptRef writes 42.
// Extra: default StoredValue 0; AcceptInt(0) writes 0; ReturnObject aliases this.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionDispatchShapeActor : AActor
{
	UPROPERTY()
	int StoredValue = 0;

	UFUNCTION()
	void ReturnVoid()
	{
		StoredValue = 1;
	}

	UFUNCTION()
	bool ReturnBool()
	{
		return true;
	}

	UFUNCTION()
	uint8 ReturnByte()
	{
		return 42;
	}

	UFUNCTION()
	int ReturnInt()
	{
		return 42;
	}

	UFUNCTION()
	float ReturnFloat()
	{
		return 42.0f;
	}

	UFUNCTION()
	double ReturnDouble()
	{
		return 42.0;
	}

	UFUNCTION()
	AActor ReturnObject()
	{
		return this;
	}

	UFUNCTION()
	FString ReturnString()
	{
		return "shape";
	}

	UFUNCTION()
	void AcceptInt(int Value)
	{
		StoredValue = Value;
	}

	UFUNCTION()
	void AcceptDouble(double Value)
	{
		StoredValue = int(Value);
	}

	UFUNCTION()
	void AcceptByte(uint8 Value)
	{
		StoredValue = int(Value);
	}

	UFUNCTION()
	void AcceptRef(int&out Value)
	{
		Value = 42;
		StoredValue = Value;
	}
}

int Observe_DispatchShape_ReturnVoid(ACoverageUFunctionDispatchShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionDispatchSubclassShapeMatrix setup: required Actor is null");
	}
	Actor.ReturnVoid();
	return Actor.StoredValue;
}

bool Observe_DispatchShape_TypedReturns(ACoverageUFunctionDispatchShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionDispatchSubclassShapeMatrix setup: required Actor is null");
	}
	int OutValue = 0;
	Actor.AcceptRef(OutValue);
	return Actor.ReturnBool()
		&& Actor.ReturnByte() == 42
		&& Actor.ReturnInt() == 42
		&& Actor.ReturnFloat() == 42.0f
		&& Actor.ReturnDouble() == 42.0
		&& Actor.ReturnString() == "shape"
		&& OutValue == 42
		&& Actor.StoredValue == 42;
}

int Observe_DispatchShape_AcceptInt39(ACoverageUFunctionDispatchShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionDispatchSubclassShapeMatrix setup: required Actor is null");
	}
	Actor.AcceptInt(39);
	return Actor.StoredValue;
}

int Observe_DispatchShape_AcceptDouble40(ACoverageUFunctionDispatchShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionDispatchSubclassShapeMatrix setup: required Actor is null");
	}
	Actor.AcceptDouble(40.0);
	return Actor.StoredValue;
}

int Observe_DispatchShape_AcceptByte41(ACoverageUFunctionDispatchShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionDispatchSubclassShapeMatrix setup: required Actor is null");
	}
	Actor.AcceptByte(41);
	return Actor.StoredValue;
}

int Observe_DispatchShape_DefaultZero(ACoverageUFunctionDispatchShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionDispatchSubclassShapeMatrix setup: required Actor is null");
	}
	return Actor.StoredValue;
}

int Observe_DispatchShape_AcceptIntZeroBoundary(ACoverageUFunctionDispatchShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionDispatchSubclassShapeMatrix setup: required Actor is null");
	}
	Actor.AcceptInt(0);
	return Actor.StoredValue;
}

bool Observe_DispatchShape_ReturnObjectAlias(ACoverageUFunctionDispatchShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionDispatchSubclassShapeMatrix setup: required Actor is null");
	}
	return Actor.ReturnObject() == Actor;
}
