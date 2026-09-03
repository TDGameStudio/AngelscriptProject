/**
 * Parameter-count, type, and return-value delegate matrix. After BeginPlay,
 * CountResult is 15, TypeIntValue 42, TypeFloatValue 3.5, TypeBoolValue true,
 * TypeStringValue Label, TypeNameValue NameTag, TypeVectorValue (1,2,3),
 * TypeVectorRefValue (4,5,6), TypeActorValue is self, TypeEnumValue Active,
 * BoolReturnValue true, IntReturnValue 36, FloatReturnValue 2.75,
 * StringReturnValue delegate-string, VectorReturnValue (7,8,9), CallbackValue
 * 100, ConstRefCallbackValue 100. Empty actor is null. Pre-BeginPlay zeros.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateSignatureMatrix
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateSignatureMatrix
 * @Provenance Theme: Feature.Delegates. WorldStory parameter-count, type, and return-value matrix.
 * @Provenance C++: AngelscriptCoverageDelegateTests.cpp::DelegateSignatureMatrix
 * @Provenance Oracle after BeginPlay: CountResult==15, TypeIntValue==42, TypeFloatValue==3.5,
 * @Provenance TypeBoolValue==true, TypeStringValue=="Label", TypeNameValue==n"NameTag",
 * @Provenance TypeVectorValue==(1,2,3), TypeVectorRefValue==(4,5,6), TypeActorValue is self,
 * @Provenance TypeEnumValue==Active, BoolReturnValue==true, IntReturnValue==36,
 * @Provenance FloatReturnValue==2.75, StringReturnValue=="delegate-string",
 * @Provenance VectorReturnValue==(7,8,9), CallbackValue==100, ConstRefCallbackValue==100.
 * @Provenance Extra: empty actor is null; pre-BeginPlay zeros / Idle / empty. FixtureIsolated.
 */

UENUM()
enum ECoverageDelegateState
{
	Idle,
	Active
}

/**
 * A unicast with no parameters.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return void
 */
delegate void FSignatureNoParam();

/**
 * A unicast with one int parameter.
 *
 * @Covers Delegates.Execute
 * @Inputs Value
 * @Return void
 */
delegate void FSignatureOneParam(int Value);

/**
 * A unicast with an int and a const string &in.
 *
 * @Covers Delegates.Execute
 * @Inputs Value and Label
 * @Return void
 */
delegate void FSignatureTwoParams(int Value, const FString&in Label);

/**
 * A unicast with int, float, and bool parameters.
 *
 * @Covers Delegates.Execute
 * @Inputs Value, Weight, and bEnabled
 * @Return void
 */
delegate void FSignatureThreeParams(int Value, float Weight, bool bEnabled);

/**
 * A unicast with four mixed parameters.
 *
 * @Covers Delegates.Execute
 * @Inputs Value, Weight, bEnabled, and Label
 * @Return void
 */
delegate void FSignatureFourParams(int Value, float Weight, bool bEnabled, const FString&in Label);

/**
 * A unicast covering the mixed type matrix.
 *
 * @Covers Delegates.Execute
 * @Inputs Value, Weight, bEnabled, Label, Tag, Location, Direction, ActorValue, State
 * @Return void
 */
delegate void FSignatureTypeMatrix(int Value, float Weight, bool bEnabled, const FString&in Label, FName Tag, FVector Location, const FVector&in Direction, AActor ActorValue, ECoverageDelegateState State);

/**
 * A unicast callback that receives an int.
 *
 * @Covers Delegates.Execute
 * @Inputs Value
 * @Return void
 */
delegate void FSignatureCallback(int Value);

/**
 * A unicast that returns bool.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return bool
 */
delegate bool FSignatureBoolReturn();

/**
 * A unicast that returns int from a value.
 *
 * @Covers Delegates.Execute
 * @Inputs Value
 * @Return int
 */
delegate int FSignatureIntReturn(int Value);

/**
 * A unicast that returns float from a value.
 *
 * @Covers Delegates.Execute
 * @Inputs Value
 * @Return float
 */
delegate float FSignatureFloatReturn(float Value);

/**
 * A unicast that returns a string.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return FString
 */
delegate FString FSignatureStringReturn();

/**
 * A unicast that returns a vector.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return FVector
 */
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

	/**
	 * WorldStory: BeginPlay binds and executes the signature matrix.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return CountResult 15 and typed Last* members from the oracle
	 */
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

	/**
	 * Add 1 to CountResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION()
	void HandleNoParam()
	{
		CountResult += 1;
	}

	/**
	 * Add Value to CountResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Integer received by value
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void HandleOneParam(int Value)
	{
		CountResult += Value;
	}

	/**
	 * Add Value when Label is "two".
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Integer received by value
	 * @Param Label String received as const FString&in
	 * @Inputs Value and Label
	 * @Return void
	 */
	UFUNCTION()
	void HandleTwoParams(int Value, const FString&in Label)
	{
		if (Label == "two")
		{
			CountResult += Value;
		}
	}

	/**
	 * Add Value when bEnabled and Weight is 1.5.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Integer received by value
	 * @Param Weight Float received by value
	 * @Param bEnabled Bool received by value
	 * @Inputs Value, Weight, and bEnabled
	 * @Return void
	 */
	UFUNCTION()
	void HandleThreeParams(int Value, float Weight, bool bEnabled)
	{
		if (bEnabled && Weight == 1.5f)
		{
			CountResult += Value;
		}
	}

	/**
	 * Add Value when !bEnabled, Weight 2.5, and Label four.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Integer received by value
	 * @Param Weight Float received by value
	 * @Param bEnabled Bool received by value
	 * @Param Label String received as const FString&in
	 * @Inputs Value, Weight, bEnabled, and Label
	 * @Return void
	 */
	UFUNCTION()
	void HandleFourParams(int Value, float Weight, bool bEnabled, const FString&in Label)
	{
		if (!bEnabled && Weight == 2.5f && Label == "four")
		{
			CountResult += Value;
		}
	}

	/**
	 * Store the mixed type-matrix arguments.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Integer received by value
	 * @Param Weight Float received by value
	 * @Param bEnabled Bool received by value
	 * @Param Label String received as const FString&in
	 * @Param Tag Name received by value
	 * @Param Location Vector received by value
	 * @Param Direction Vector received as const FVector&in
	 * @Param ActorValue Actor received by value
	 * @Param State Enum received by value
	 * @Inputs the type-matrix arguments
	 * @Return void
	 */
	UFUNCTION()
	void HandleTypeMatrix(int Value, float Weight, bool bEnabled, const FString&in Label, FName Tag, FVector Location, const FVector&in Direction, AActor ActorValue, ECoverageDelegateState State)
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

	/**
	 * Return true.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool ReturnBool()
	{
		return true;
	}

	/**
	 * Return Value * 3.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Integer received by value
	 * @Inputs Value
	 * @Return Value * 3
	 */
	UFUNCTION()
	int ReturnInt(int Value)
	{
		return Value * 3;
	}

	/**
	 * Return Value + 0.75.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Float received by value
	 * @Inputs Value
	 * @Return Value + 0.75f
	 */
	UFUNCTION()
	float ReturnFloat(float Value)
	{
		return Value + 0.75f;
	}

	/**
	 * Return "delegate-string".
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return "delegate-string"
	 */
	UFUNCTION()
	FString ReturnString()
	{
		return "delegate-string";
	}

	/**
	 * Return (7,8,9).
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return FVector(7,8,9)
	 */
	UFUNCTION()
	FVector ReturnVector()
	{
		return FVector(7.0f, 8.0f, 9.0f);
	}

	/**
	 * Execute Callback with 70.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Callback Unicast received by value
	 * @Inputs Callback
	 * @Return void
	 */
	void UseCallback(FSignatureCallback Callback)
	{
		Callback.Execute(70);
	}

	/**
	 * Execute Callback with 30 through const &in.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Callback Unicast received as const FSignatureCallback&in
	 * @Inputs Callback
	 * @Return void
	 */
	void UseCallbackConstRef(const FSignatureCallback&in Callback)
	{
		Callback.Execute(30);
	}

	/**
	 * Add Value to CallbackValue and ConstRefCallbackValue.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Integer received by value
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void HandleCallback(int Value)
	{
		CallbackValue += Value;
		ConstRefCallbackValue += Value;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a default-constructed handle
	 * @Return true when the handle is null
	 * @Boundary empty actor
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDelegateSignatureMatrixActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the default CountResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default CountResult
	 */
	UFUNCTION()
	int CountDefault()
	{
		return CountResult;
	}

	/**
	 * Observe the default TypeActorValue.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return true when TypeActorValue is null
	 * @Boundary default TypeActorValue
	 */
	UFUNCTION()
	bool TypeActorDefaultNull()
	{
		return TypeActorValue == nullptr;
	}
}
