/**
 * Dispatch subclass shapes by return and argument type. ReturnVoid writes
 * StoredValue 1. ReturnBool is true. ReturnByte/Int are 42. ReturnFloat/Double
 * are 42. ReturnString is "shape". AcceptInt 39, AcceptDouble 40, AcceptByte
 * 41, AcceptRef writes 42. Default StoredValue is 0. AcceptInt(0) writes 0.
 * ReturnObject aliases this.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.FunctionDispatchSubclassShapeMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.FunctionDispatchSubclassShapeMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: dispatch subclass shapes by return/arg type.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::FunctionDispatchSubclassShapeMatrix
 * @Provenance Compile + spawn + reflective calls. Oracle: ReturnVoid StoredValue 1; ReturnBool true;
 * @Provenance ReturnByte/Int 42; ReturnFloat/Double 42; ReturnString "shape"; AcceptInt 39;
 * @Provenance AcceptDouble 40; AcceptByte 41; AcceptRef writes 42.
 * @Provenance Extra: default StoredValue 0; AcceptInt(0) writes 0; ReturnObject aliases this.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionDispatchShapeActor : AActor
{
	UPROPERTY()
	int StoredValue = 0;

	/**
	 * Void return that writes StoredValue 1.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION()
	void ReturnVoid()
	{
		StoredValue = 1;
	}

	/**
	 * Bool return of true.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool ReturnBool()
	{
		return true;
	}

	/**
	 * Byte return of 42.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	uint8 ReturnByte()
	{
		return 42;
	}

	/**
	 * Int return of 42.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int ReturnInt()
	{
		return 42;
	}

	/**
	 * Float return of 42.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return 42.0f
	 */
	UFUNCTION()
	float ReturnFloat()
	{
		return 42.0f;
	}

	/**
	 * Double return of 42.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return 42.0
	 */
	UFUNCTION()
	double ReturnDouble()
	{
		return 42.0;
	}

	/**
	 * Object return of this.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return this
	 */
	UFUNCTION()
	AActor ReturnObject()
	{
		return this;
	}

	/**
	 * String return of "shape".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return "shape"
	 */
	UFUNCTION()
	FString ReturnString()
	{
		return "shape";
	}

	/**
	 * Accept an int into StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Value Stored value
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void AcceptInt(int Value)
	{
		StoredValue = Value;
	}

	/**
	 * Accept a double truncated into StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Value Stored value
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void AcceptDouble(double Value)
	{
		StoredValue = int(Value);
	}

	/**
	 * Accept a byte into StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Value Stored value
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void AcceptByte(uint8 Value)
	{
		StoredValue = int(Value);
	}

	/**
	 * Write 42 to an out integer and StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Value Destination received as int&out
	 * @Inputs an empty out slot
	 * @Return void
	 */
	UFUNCTION()
	void AcceptRef(int&out Value)
	{
		Value = 42;
		StoredValue = Value;
	}

	/**
	 * Observe ReturnVoid writing StoredValue 1.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnVoid()
	 * @Return 1
	 */
	UFUNCTION()
	int ReturnVoidStoredValue()
	{
		ReturnVoid();
		return StoredValue;
	}

	/**
	 * Observe typed returns plus AcceptRef writing 42.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnBool/Byte/Int/Float/Double/String and AcceptRef
	 * @Return true when every typed return and AcceptRef match the oracle
	 */
	UFUNCTION()
	bool TypedReturns()
	{
		int OutValue = 0;
		AcceptRef(OutValue);
		if (!ReturnBool())
		{
			return false;
		}
		if (ReturnByte() != 42)
		{
			return false;
		}
		if (ReturnInt() != 42)
		{
			return false;
		}
		if (ReturnFloat() != 42.0f)
		{
			return false;
		}
		if (ReturnDouble() != 42.0)
		{
			return false;
		}
		if (ReturnString() != "shape")
		{
			return false;
		}
		if (OutValue != 42)
		{
			return false;
		}
		return StoredValue == 42;
	}

	/**
	 * Observe AcceptInt(39).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AcceptInt(39)
	 * @Return 39
	 */
	UFUNCTION()
	int AcceptIntThirtyNine()
	{
		AcceptInt(39);
		return StoredValue;
	}

	/**
	 * Observe AcceptDouble(40.0).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AcceptDouble(40.0)
	 * @Return 40
	 */
	UFUNCTION()
	int AcceptDoubleForty()
	{
		AcceptDouble(40.0);
		return StoredValue;
	}

	/**
	 * Observe AcceptByte(41).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AcceptByte(41)
	 * @Return 41
	 */
	UFUNCTION()
	int AcceptByteFortyOne()
	{
		AcceptByte(41);
		return StoredValue;
	}

	/**
	 * Observe the default StoredValue of 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default StoredValue
	 */
	UFUNCTION()
	int DefaultZero()
	{
		return StoredValue;
	}

	/**
	 * Observe AcceptInt(0).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AcceptInt(0)
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	int AcceptIntZeroBoundary()
	{
		AcceptInt(0);
		return StoredValue;
	}

	/**
	 * Observe that ReturnObject aliases this.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnObject()
	 * @Return true when the result is this
	 */
	UFUNCTION()
	bool ReturnObjectAlias()
	{
		return ReturnObject() == this;
	}
}
