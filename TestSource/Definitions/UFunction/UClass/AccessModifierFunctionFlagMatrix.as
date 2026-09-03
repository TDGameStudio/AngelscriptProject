/**
 * Private, protected, and public UFUNCTION access matrix. CallAccessMatrix
 * returns 969 and StoredValue 321. Default StoredValue is 0, and a second
 * instance stays 0 after the first dispatch.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.AccessModifierFunctionFlagMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.AccessModifierFunctionFlagMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: private/protected/public UFUNCTION access matrix.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::AccessModifierFunctionFlagMatrix
 * @Provenance Compile + spawn + CallAccessMatrix. Oracle: return 969, StoredValue 321.
 * @Provenance Extra: default StoredValue 0; a second instance stays 0 after the first dispatch.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionAccessActor : AActor
{
	UPROPERTY()
	int StoredValue = 0;

	/**
	 * Private callable that adds Value to StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Addend
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Access")
	private void PrivateCallable(int Value)
	{
		StoredValue += Value;
	}

	/**
	 * Private pure getter that returns StoredValue + 1.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StoredValue
	 * @Return StoredValue + 1
	 */
	UFUNCTION(BlueprintPure, Category="Coverage|Access")
	private int PrivatePureValue() const
	{
		return StoredValue + 1;
	}

	/**
	 * Protected callable that adds Value * 10 to StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Scaled addend
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Access")
	protected void ProtectedCallable(int Value)
	{
		StoredValue += Value * 10;
	}

	/**
	 * Protected pure getter that returns StoredValue + 2.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StoredValue
	 * @Return StoredValue + 2
	 */
	UFUNCTION(BlueprintPure, Category="Coverage|Access")
	protected int ProtectedPureValue() const
	{
		return StoredValue + 2;
	}

	/**
	 * Public callable that adds Value * 100 to StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Scaled addend
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Access")
	void PublicCallable(int Value)
	{
		StoredValue += Value * 100;
	}

	/**
	 * Public pure getter that returns StoredValue + 3.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StoredValue
	 * @Return StoredValue + 3
	 */
	UFUNCTION(BlueprintPure, Category="Coverage|Access")
	int PublicPureValue() const
	{
		return StoredValue + 3;
	}

	/**
	 * Dispatch private, protected, and public callables then sum the pure getters.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs PrivateCallable(1), ProtectedCallable(2), PublicCallable(3)
	 * @Return the sum of the three pure getters
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Access")
	int CallAccessMatrix()
	{
		PrivateCallable(1);
		ProtectedCallable(2);
		PublicCallable(3);
		return PrivatePureValue() + ProtectedPureValue() + PublicPureValue();
	}

	/**
	 * Observe CallAccessMatrix returning 969.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs CallAccessMatrix()
	 * @Return 969
	 */
	UFUNCTION()
	int AccessMatrixResult()
	{
		return CallAccessMatrix();
	}

	/**
	 * Observe StoredValue after CallAccessMatrix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs CallAccessMatrix()
	 * @Return 321
	 */
	UFUNCTION()
	int AccessMatrixStoredValue()
	{
		CallAccessMatrix();
		return StoredValue;
	}

	/**
	 * Observe the default StoredValue of 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default StoredValue
	 */
	UFUNCTION()
	int DefaultStoredValue()
	{
		return StoredValue;
	}

	/**
	 * Observe that dispatching this instance leaves another at 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Other Second actor that must stay at 0
	 * @Inputs CallAccessMatrix on this compared against Other
	 * @Return true when this is 969/321 and Other stays 0
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool AccessMatrixIsIndependentAcrossInstances(ACoverageUFunctionAccessActor Other)
	{
		int FirstResult = CallAccessMatrix();
		if (FirstResult != 969)
		{
			return false;
		}
		if (StoredValue != 321)
		{
			return false;
		}
		return Other.StoredValue == 0;
	}
}
