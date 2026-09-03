/**
 * Primitive, FString, and FVector unicast parameters. After BeginPlay,
 * IntValue is 42, FloatValue is 3.14, BoolValue is true, StringValue is
 * "Hello", and VectorValue is (1,2,3).
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateParameterTypes
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateParameterTypes
 * @Provenance Theme: Feature.Delegates. WorldStory primitive, FString, and FVector parameters.
 * @Provenance C++: AngelscriptCoverageDelegateTests.cpp::DelegateParameterTypes
 * @Provenance Oracle after BeginPlay: IntValue==42, FloatValue==3.14, BoolValue==true,
 * @Provenance StringValue=="Hello", VectorValue==(1,2,3). Extra: empty actor is null;
 * @Provenance pre-BeginPlay zeros / false / empty. FixtureIsolated.
 */

/**
 * A unicast that takes int, float, and bool.
 *
 * @Covers Delegates.Execute
 * @Inputs I, F, and B
 * @Return nothing when executed
 */
delegate void FCoverageIntFloatBoolDelegate(int I, float F, bool B);

/**
 * A unicast that takes an FString.
 *
 * @Covers Delegates.Execute
 * @Inputs S
 * @Return nothing when executed
 */
delegate void FCoverageStringDelegate(FString S);

/**
 * A unicast that takes an FVector.
 *
 * @Covers Delegates.Execute
 * @Inputs V
 * @Return nothing when executed
 */
delegate void FCoverageVectorDelegate(FVector V);

UCLASS()
class ACoverageDelegateParamTypesActor : AActor
{
	UPROPERTY()
	int IntValue = 0;

	UPROPERTY()
	float FloatValue = 0.0f;

	UPROPERTY()
	bool BoolValue = false;

	UPROPERTY()
	FString StringValue;

	UPROPERTY()
	FVector VectorValue;

	FCoverageIntFloatBoolDelegate OnIntFloatBoolDelegate;
	FCoverageStringDelegate OnStringDelegate;
	FCoverageVectorDelegate OnVectorDelegate;

	/**
	 * Binds and executes the primitive, string, and vector unicasts.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return nothing; IntValue ends at 42 and StringValue is "Hello"
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnIntFloatBoolDelegate.BindUFunction(this, n"HandleIntFloatBool");
		OnIntFloatBoolDelegate.Execute(42, 3.14f, true);

		OnStringDelegate.BindUFunction(this, n"HandleString");
		OnStringDelegate.Execute("Hello");

		OnVectorDelegate.BindUFunction(this, n"HandleVector");
		OnVectorDelegate.Execute(FVector(1.0f, 2.0f, 3.0f));
	}

	/**
	 * Stores the primitive payload.
	 *
	 * @Covers Delegates.Execute
	 * @Param I the int payload
	 * @Param F the float payload
	 * @Param B the bool payload
	 * @Inputs I, F, and B
	 * @Return nothing; IntValue, FloatValue, and BoolValue are written
	 */
	UFUNCTION()
	void HandleIntFloatBool(int I, float F, bool B)
	{
		IntValue = I;
		FloatValue = F;
		BoolValue = B;
	}

	/**
	 * Stores the string payload.
	 *
	 * @Covers Delegates.Execute
	 * @Param S the string payload
	 * @Inputs S
	 * @Return nothing; StringValue is written
	 */
	UFUNCTION()
	void HandleString(FString S)
	{
		StringValue = S;
	}

	/**
	 * Stores the vector payload.
	 *
	 * @Covers Delegates.Execute
	 * @Param V the vector payload
	 * @Inputs V
	 * @Return nothing; VectorValue is written
	 */
	UFUNCTION()
	void HandleVector(FVector V)
	{
		VectorValue = V;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a local ACoverageDelegateParamTypesActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDelegateParamTypesActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay IntValue.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs this
	 * @Return 0
	 * @Boundary default IntValue
	 */
	UFUNCTION()
	int IntDefault()
	{
		return IntValue;
	}

	/**
	 * Observe that BoolValue starts false.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs this
	 * @Return BoolValue
	 * @Boundary default false
	 */
	UFUNCTION()
	bool BoolDefaultFalse()
	{
		return BoolValue;
	}
}
