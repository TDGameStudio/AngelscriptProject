// Theme: Feature.Delegates. WorldStory: UCLASS delegate members returning typed values.
// C++: AngelscriptCoverageUClassPropertyTests.cpp::UClassDelegateReturnMemberMatrix
// Spawn + BeginPlay oracle: bBoolReturnValue true, IntReturnInput 12, IntReturnValue 36,
// FloatReturnInput 2.0, FloatReturnValue 2.75, StringReturnValue "UClassDelegateString",
// VectorReturnValue (7,8,9); all bound flags true.
// Extra: defaults false/0/empty/zero vector. Keep *ReturnValue names.
// FixtureIsolated. PlannedSymbols include FVector.

delegate bool FUClassPropertyBoolReturnDelegate();
delegate int FUClassPropertyIntReturnDelegate(int Value);
delegate float FUClassPropertyFloatReturnDelegate(float Value);
delegate FString FUClassPropertyStringReturnDelegate();
delegate FVector FUClassPropertyVectorReturnDelegate();

UCLASS()
class ACoverageUClassDelegateReturnActor : AActor
{
	UPROPERTY()
	FUClassPropertyBoolReturnDelegate BoolReturn;

	UPROPERTY()
	FUClassPropertyIntReturnDelegate IntReturn;

	UPROPERTY()
	FUClassPropertyFloatReturnDelegate FloatReturn;

	UPROPERTY()
	FUClassPropertyStringReturnDelegate StringReturn;

	UPROPERTY()
	FUClassPropertyVectorReturnDelegate VectorReturn;

	UPROPERTY()
	bool bBoolReturnBound = false;

	UPROPERTY()
	bool bBoolReturnValue = false;

	UPROPERTY()
	bool bIntReturnBound = false;

	UPROPERTY()
	int IntReturnInput = 0;

	UPROPERTY()
	int IntReturnValue = 0;

	UPROPERTY()
	bool bFloatReturnBound = false;

	UPROPERTY()
	float FloatReturnInput = 0.0f;

	UPROPERTY()
	float FloatReturnValue = 0.0f;

	UPROPERTY()
	bool bStringReturnBound = false;

	UPROPERTY()
	FString StringReturnValue;

	UPROPERTY()
	bool bVectorReturnBound = false;

	UPROPERTY()
	FVector VectorReturnValue;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BoolReturn.BindUFunction(this, n"HandleBoolReturn");
		bBoolReturnBound = BoolReturn.IsBound();
		bBoolReturnValue = BoolReturn.Execute();

		IntReturn.BindUFunction(this, n"HandleIntReturn");
		bIntReturnBound = IntReturn.IsBound();
		IntReturnValue = IntReturn.Execute(12);

		FloatReturn.BindUFunction(this, n"HandleFloatReturn");
		bFloatReturnBound = FloatReturn.IsBound();
		FloatReturnValue = FloatReturn.Execute(2.0f);

		StringReturn.BindUFunction(this, n"HandleStringReturn");
		bStringReturnBound = StringReturn.IsBound();
		StringReturnValue = StringReturn.Execute();

		VectorReturn.BindUFunction(this, n"HandleVectorReturn");
		bVectorReturnBound = VectorReturn.IsBound();
		VectorReturnValue = VectorReturn.Execute();
	}

	UFUNCTION()
	bool HandleBoolReturn()
	{
		return true;
	}

	UFUNCTION()
	int HandleIntReturn(int Value)
	{
		IntReturnInput = Value;
		return Value * 3;
	}

	UFUNCTION()
	float HandleFloatReturn(float Value)
	{
		FloatReturnInput = Value;
		return Value + 0.75f;
	}

	UFUNCTION()
	FString HandleStringReturn()
	{
		return "UClassDelegateString";
	}

	UFUNCTION()
	FVector HandleVectorReturn()
	{
		return FVector(7.0f, 8.0f, 9.0f);
	}
}

bool Observe_BoolReturnValue_DefaultFalse(ACoverageUClassDelegateReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateReturnMemberMatrix setup: required Actor is null");
	}
	return !Actor.bBoolReturnValue;
}

int Observe_IntReturnValue_DefaultZero(ACoverageUClassDelegateReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateReturnMemberMatrix setup: required Actor is null");
	}
	return Actor.IntReturnValue;
}

bool Observe_StringReturnValue_DefaultEmpty(ACoverageUClassDelegateReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateReturnMemberMatrix setup: required Actor is null");
	}
	return Actor.StringReturnValue.Len() == 0;
}

FVector Observe_VectorReturnValue_DefaultZero(ACoverageUClassDelegateReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateReturnMemberMatrix setup: required Actor is null");
	}
	return Actor.VectorReturnValue;
}

bool Observe_Vector_CopyIndependence()
{
	FVector Original = FVector(7.0f, 8.0f, 9.0f);
	FVector Copy = Original;
	Copy = FVector(0.0f, 0.0f, 0.0f);
	return Original.X == 7.0f && Copy.X == 0.0f;
}
