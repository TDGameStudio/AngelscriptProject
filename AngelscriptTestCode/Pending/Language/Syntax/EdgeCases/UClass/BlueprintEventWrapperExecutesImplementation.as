/**
 * @version v1
 * @summary A BlueprintEvent method whose wrapper dispatches to the script implementation. Calling the method from a plain UFUNCTION must reach the same body that a direct call reaches.
 * @topic Language
 */
/**
 * @version root
 * @summary A BlueprintEvent method whose wrapper dispatches to the script implementation. Calling the method from a plain UFUNCTION must reach the same body that a direct call reaches.
 * @topic Baseline
 */
UCLASS()
class UCompilerBlueprintEventWrapperCarrier : UObject
{
	/**
	 * The BlueprintEvent body the wrapper must route to.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an integer addend
	 * @Return the value plus 21
	 * @Param Value the value to offset
	 */
	UFUNCTION(BlueprintEvent)
	int Compute(int Value)
	{
		return Value + 21;
	}

	/**
	 * Calls the BlueprintEvent method from a plain method.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int Entry()
	{
		return Compute(21);
	}

	/**
	 * Observe that the wrapped call and the direct call agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry() and Compute(21)
	 * @Return true when both report 42
	 */
	UFUNCTION()
	bool BlueprintEventWrapperReachesImplementation()
	{
		if (Entry() != 42)
		{
			return false;
		}

		return Compute(21) == 42;
	}

	/**
	 * Observe the zero boundary through the wrapped method.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Compute(0)
	 * @Return true when the result is 21
	 * @Boundary zero argument
	 */
	UFUNCTION()
	bool BlueprintEventWrapperZeroBoundary()
	{
		return Compute(0) == 21;
	}

	/**
	 * Observe that two carriers do not share state.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier and a second carrier
	 * @Return true when each reports its own expected value
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool BlueprintEventWrapperInstancesAreIndependent()
	{
		UCompilerBlueprintEventWrapperCarrier Other =
			Cast<UCompilerBlueprintEventWrapperCarrier>(
				NewObject(GetTransientPackage(), UCompilerBlueprintEventWrapperCarrier::StaticClass(), n"CompilerBlueprintEventWrapperCarrierOther"));
		if (Other == nullptr)
		{
			throw("TS-LANG-0001 setup: NewObject returned null");
		}

		if (Compute(1) != 22)
		{
			return false;
		}

		return Other.Entry() == 42;
	}
}
/** @end */
