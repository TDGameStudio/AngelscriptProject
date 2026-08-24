// Theme: Feature.Delegates. WorldStory parameter-count, type, and return-value matrix.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateSignatureMatrix
// Oracle after BeginPlay: CountResult==15, TypeIntValue==42, TypeFloatValue==3.5,
// TypeBoolValue==true, TypeStringValue=="Label", TypeNameValue==n"NameTag",
// TypeVectorValue==(1,2,3), TypeVectorRefValue==(4,5,6), TypeActorValue is self,
// TypeEnumValue==Active, BoolReturnValue==true, IntReturnValue==36,
// FloatReturnValue==2.75, StringReturnValue=="delegate-string",
// VectorReturnValue==(7,8,9), CallbackValue==100, ConstRefCallbackValue==100.
// Extra: empty actor is null; pre-BeginPlay zeros / Idle / empty. FixtureIsolated.

UENUM()
enum ECoverageDelegateState
{
	Idle,
	Active
}

delegate void FSignatureNoParam();
delegate void FSignatureOneParam(int Value);
delegate void FSignatureTwoParams(int Value, const FString& Label);
delegate void FSignatureThreeParams(int Value, float Weight, bool bEnabled);
delegate void FSignatureFourParams(int Value, float Weight, bool bEnabled, const FString& Label);
delegate void FSignatureTypeMatrix(int Value, float Weight, bool bEnabled, const FString& Label, FName Tag, FVector Location, const FVector& Direction, AActor ActorValue, ECoverageDelegateState State);
delegate void FSignatureCallback(int Value);
delegate bool FSignatureBoolReturn();
delegate int FSignatureIntReturn(int Value);
delegate float FSignatureFloatReturn(float Value);
delegate FString FSignatureStringReturn();
delegate FVector FSignatureVectorReturn();

UCLASS()
class ACoverageDelegateSignatureMatrixActor : AActor
{
	UPROPERTY()
	int CountResult = 0;

	UPROPERTY()
	int TypeIntValue = 0;

	UPROPERTY()
	float TypeFloatValue = 0.0f;

	UPROPERTY()
	bool TypeBoolValue = false;

	UPROPERTY()
	FString TypeStringValue;

	UPROPERTY()
	FName TypeNameValue;

	UPROPERTY()
	FVector TypeVectorValue;

	UPROPERTY()
	FVector TypeVectorRefValue;

	UPROPERTY()
	AActor TypeActorValue;

	UPROPERTY()
	ECoverageDelegateState TypeEnumValue = ECoverageDelegateState::Idle;

	UPROPERTY()
	bool BoolReturnValue = false;

	UPROPERTY()
	int IntReturnValue = 0;

	UPROPERTY()
	float FloatReturnValue = 0.0f;

	UPROPERTY()
	FString StringReturnValue;

	UPROPERTY()
	FVector VectorReturnValue;

	UPROPERTY()
	int CallbackValue = 0;

	UPROPERTY()
	int ConstRefCallbackValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FSignatureNoParam NoParam;
		FSignatureOneParam OneParam;
		FSignatureTwoParams TwoParams;
		FSignatureThreeParams ThreeParams;
		FSignatureFourParams FourParams;

		NoParam.BindUFunction(this, n"HandleNoParam");
		OneParam.BindUFunction(this, n"HandleOneParam");
		TwoParams.BindUFunction(this, n"HandleTwoParams");
		ThreeParams.BindUFunction(this, n"HandleThreeParams");
		FourParams.BindUFunction(this, n"HandleFourParams");

		NoParam.Execute();
		OneParam.Execute(2);
		TwoParams.Execute(3, "two");
		ThreeParams.Execute(4, 1.5f, true);
		FourParams.Execute(5, 2.5f, false, "four");

		FSignatureTypeMatrix TypeMatrix;
		TypeMatrix.BindUFunction(this, n"HandleTypeMatrix");
		TypeMatrix.Execute(42, 3.5f, true, "Label", n"NameTag", FVector(1.0f, 2.0f, 3.0f), FVector(4.0f, 5.0f, 6.0f), this, ECoverageDelegateState::Active);

		FSignatureBoolReturn BoolReturn;
		FSignatureIntReturn IntReturn;
		FSignatureFloatReturn FloatReturn;
		FSignatureStringReturn StringReturn;
		FSignatureVectorReturn VectorReturn;

		BoolReturn.BindUFunction(this, n"ReturnBool");
		IntReturn.BindUFunction(this, n"ReturnInt");
		FloatReturn.BindUFunction(this, n"ReturnFloat");
		StringReturn.BindUFunction(this, n"ReturnString");
		VectorReturn.BindUFunction(this, n"ReturnVector");

		BoolReturnValue = BoolReturn.Execute();
		IntReturnValue = IntReturn.Execute(12);
		FloatReturnValue = FloatReturn.Execute(2.0f);
		StringReturnValue = StringReturn.Execute();
		VectorReturnValue = VectorReturn.Execute();

		FSignatureCallback Callback;
		Callback.BindUFunction(this, n"HandleCallback");
		UseCallback(Callback);
		UseCallbackConstRef(Callback);
	}

	UFUNCTION()
	void HandleNoParam()
	{
		CountResult += 1;
	}

	UFUNCTION()
	void HandleOneParam(int Value)
	{
		CountResult += Value;
	}

	UFUNCTION()
	void HandleTwoParams(int Value, const FString& Label)
	{
		if (Label == "two")
		{
			CountResult += Value;
		}
	}

	UFUNCTION()
	void HandleThreeParams(int Value, float Weight, bool bEnabled)
	{
		if (bEnabled && Weight == 1.5f)
		{
			CountResult += Value;
		}
	}

	UFUNCTION()
	void HandleFourParams(int Value, float Weight, bool bEnabled, const FString& Label)
	{
		if (!bEnabled && Weight == 2.5f && Label == "four")
		{
			CountResult += Value;
		}
	}

	UFUNCTION()
	void HandleTypeMatrix(int Value, float Weight, bool bEnabled, const FString& Label, FName Tag, FVector Location, const FVector& Direction, AActor ActorValue, ECoverageDelegateState State)
	{
		TypeIntValue = Value;
		TypeFloatValue = Weight;
		TypeBoolValue = bEnabled;
		TypeStringValue = Label;
		TypeNameValue = Tag;
		TypeVectorValue = Location;
		TypeVectorRefValue = Direction;
		TypeActorValue = ActorValue;
		TypeEnumValue = State;
	}

	UFUNCTION()
	bool ReturnBool()
	{
		return true;
	}

	UFUNCTION()
	int ReturnInt(int Value)
	{
		return Value * 3;
	}

	UFUNCTION()
	float ReturnFloat(float Value)
	{
		return Value + 0.75f;
	}

	UFUNCTION()
	FString ReturnString()
	{
		return "delegate-string";
	}

	UFUNCTION()
	FVector ReturnVector()
	{
		return FVector(7.0f, 8.0f, 9.0f);
	}

	void UseCallback(FSignatureCallback Callback)
	{
		Callback.Execute(70);
	}

	void UseCallbackConstRef(const FSignatureCallback&in Callback)
	{
		Callback.Execute(30);
	}

	UFUNCTION()
	void HandleCallback(int Value)
	{
		CallbackValue += Value;
		ConstRefCallbackValue += Value;
	}
}

bool Observe_SignatureMatrix_EmptyDefaultIsNull()
{
	ACoverageDelegateSignatureMatrixActor Actor;
	return Actor == nullptr;
}

int Observe_SignatureMatrix_CountDefault(ACoverageDelegateSignatureMatrixActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0022 setup: required ACoverageDelegateSignatureMatrixActor is null");
	}
	return Actor.CountResult;
}

bool Observe_SignatureMatrix_TypeActorDefaultNull(ACoverageDelegateSignatureMatrixActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0022 setup: required ACoverageDelegateSignatureMatrixActor is null");
	}
	return Actor.TypeActorValue == nullptr;
}
