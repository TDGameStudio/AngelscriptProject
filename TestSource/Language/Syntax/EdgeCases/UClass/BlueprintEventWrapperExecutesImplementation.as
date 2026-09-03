/**
 * A BlueprintEvent method whose wrapper dispatches to the script implementation.
 * Calling the method from a plain UFUNCTION must reach the same body that a
 * direct call reaches.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BlueprintEventWrapperExecutesImplementation
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.BlueprintEventWrapperExecutesImplementation
 * @Provenance C++: AngelscriptCompilerBlueprintEventWrapperTests.cpp::BlueprintEventWrapperExecutesImplementation
 * @Provenance sha256=924533a33320c352a15ba1d6e8fd721dd8e9cd3f9f0b6860326c004e87ab7b42; lines 82-98.
 * @Provenance Oracle: Entry() == Compute(21) == 42.
 * @Provenance Extra: Compute(0) == 21 is the zero boundary. DefaultSafe.
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
