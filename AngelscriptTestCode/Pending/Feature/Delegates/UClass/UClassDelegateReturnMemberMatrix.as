/**
 * @version v1
 * @summary UCLASS delegate members returning typed values. After BeginPlay, bBoolReturnValue true, IntReturnInput 12, IntReturnValue 36, FloatReturnInput 2.0, FloatReturnValue 2.75, StringReturnValue UClassDelegateString.
 * @topic Feature
 */
/**
 * @version root
 * @summary UCLASS delegate members returning typed values. After BeginPlay, bBoolReturnValue true, IntReturnInput 12, IntReturnValue 36, FloatReturnInput 2.0, FloatReturnValue 2.75, StringReturnValue UClassDelegateString.
 * @topic Baseline
 */
/**
 * A unicast that returns bool.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return bool
 */
delegate bool FUClassPropertyBoolReturnDelegate();

/**
 * A unicast that returns int from a value.
 *
 * @Covers Delegates.Execute
 * @Inputs Value
 * @Return int
 */
delegate int FUClassPropertyIntReturnDelegate(int Value);

/**
 * A unicast that returns float from a value.
 *
 * @Covers Delegates.Execute
 * @Inputs Value
 * @Return float
 */
delegate float FUClassPropertyFloatReturnDelegate(float Value);

/**
 * A unicast that returns a string.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return FString
 */
delegate FString FUClassPropertyStringReturnDelegate();

/**
 * A unicast that returns a vector.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return FVector
 */
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

	/**
	 * WorldStory: BeginPlay binds and executes typed return delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return IntReturnValue 36, FloatReturnValue 2.75, StringReturnValue UClassDelegateString
	 */
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

	/**
	 * Return true.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool HandleBoolReturn()
	{
		return true;
	}

	/**
	 * Store IntReturnInput and return Value * 3.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Integer received by value
	 * @Inputs Value
	 * @Return Value * 3
	 */
	UFUNCTION()
	int HandleIntReturn(int Value)
	{
		IntReturnInput = Value;
		return Value * 3;
	}

	/**
	 * Store FloatReturnInput and return Value + 0.75.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Float received by value
	 * @Inputs Value
	 * @Return Value + 0.75f
	 */
	UFUNCTION()
	float HandleFloatReturn(float Value)
	{
		FloatReturnInput = Value;
		return Value + 0.75f;
	}

	/**
	 * Return UClassDelegateString.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return "UClassDelegateString"
	 */
	UFUNCTION()
	FString HandleStringReturn()
	{
		return "UClassDelegateString";
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
	FVector HandleVectorReturn()
	{
		return FVector(7.0f, 8.0f, 9.0f);
	}

	/**
	 * Observe the default bBoolReturnValue.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return true when bBoolReturnValue is false
	 * @Boundary default bool return
	 */
	UFUNCTION()
	bool BoolReturnValueDefaultFalse()
	{
		return !bBoolReturnValue;
	}

	/**
	 * Observe the default IntReturnValue.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default int return
	 */
	UFUNCTION()
	int IntReturnValueDefaultZero()
	{
		return IntReturnValue;
	}

	/**
	 * Observe the default StringReturnValue.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return true when StringReturnValue is empty
	 * @Boundary default string return
	 */
	UFUNCTION()
	bool StringReturnValueDefaultEmpty()
	{
		return StringReturnValue.Len() == 0;
	}

	/**
	 * Observe the default VectorReturnValue.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return the default VectorReturnValue
	 * @Boundary default vector return
	 */
	UFUNCTION()
	FVector VectorReturnValueDefaultZero()
	{
		return VectorReturnValue;
	}

	/**
	 * Observe that mutating a vector copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Original (7,8,9) and a zeroed copy
	 * @Return true when Original.X is 7 and Copy.X is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool VectorCopyIndependence()
	{
		FVector Original = FVector(7.0f, 8.0f, 9.0f);
		FVector Copy = Original;
		Copy = FVector(0.0f, 0.0f, 0.0f);
		if (Original.X != 7.0f)
		{
			return false;
		}
		return Copy.X == 0.0f;
	}
}
/** @end */
