/**
 * @version v1
 * @summary Recursive UFUNCTION plus virtual BlueprintOverride dispatch. C++ verifies base DispatchVirtual(7)==8 TraceValue==1, child DispatchVirtual(7)==17 TraceValue==2 and Factorial(5)==120. Factorial(1) and Factorial(0) are the.
 * @topic Feature
 */
/**
 * @version root
 * @summary Recursive UFUNCTION plus virtual BlueprintOverride dispatch. C++ verifies base DispatchVirtual(7)==8 TraceValue==1, child DispatchVirtual(7)==17 TraceValue==2 and Factorial(5)==120. Factorial(1) and Factorial(0) are the.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionVirtualBase : AActor
{
	UPROPERTY()
	int TraceValue = 0;

	/**
	 * Parent BlueprintEvent that traces 1 and returns Value + 1.
	 *
	 * @Kind Action
	 * @Covers Inheritance.RecursionAndVirtualOverrideDispatch
	 * @Inputs Value
	 * @Return Value + 1; TraceValue = TraceValue * 10 + 1
	 * @Param Value the virtual input
	 */
	UFUNCTION(BlueprintEvent)
	int ComputeVirtual(int Value)
	{
		TraceValue = TraceValue * 10 + 1;
		return Value + 1;
	}

	/**
	 * Recursive factorial with base case Value <= 1.
	 *
	 * @Kind Action
	 * @Covers Inheritance.RecursionAndVirtualOverrideDispatch
	 * @Inputs a non-negative Value
	 * @Return 1 when Value <= 1, otherwise Value * Factorial(Value - 1)
	 * @Param Value the factorial argument
	 */
	UFUNCTION()
	int Factorial(int Value)
	{
		if (Value <= 1)
		{
			return 1;
		}

		return Value * Factorial(Value - 1);
	}

	/**
	 * Dispatch through the virtual ComputeVirtual.
	 *
	 * @Kind Action
	 * @Covers Inheritance.RecursionAndVirtualOverrideDispatch
	 * @Inputs Value
	 * @Return ComputeVirtual(Value)
	 * @Param Value forwarded to ComputeVirtual
	 */
	UFUNCTION()
	int DispatchVirtual(int Value)
	{
		return ComputeVirtual(Value);
	}

	/**
	 * Observe DispatchVirtual(7) on a base instance.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.RecursionAndVirtualOverrideDispatch
	 * @Inputs DispatchVirtual(7)
	 * @Return 8
	 */
	UFUNCTION()
	int BaseReturn()
	{
		return DispatchVirtual(7);
	}

	/**
	 * Observe TraceValue after DispatchVirtual(7) on a base instance.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.RecursionAndVirtualOverrideDispatch
	 * @Inputs DispatchVirtual(7)
	 * @Return TraceValue, expected to be 1
	 */
	UFUNCTION()
	int BaseTrace()
	{
		DispatchVirtual(7);
		return TraceValue;
	}
}

UCLASS()
class ACoverageUFunctionVirtualChild : ACoverageUFunctionVirtualBase
{
	/**
	 * Child BlueprintOverride that traces 2 and returns Value + 10.
	 *
	 * @Kind Action
	 * @Covers Inheritance.RecursionAndVirtualOverrideDispatch
	 * @Inputs Value
	 * @Return Value + 10; TraceValue = TraceValue * 10 + 2
	 * @Param Value the virtual input
	 */
	UFUNCTION(BlueprintOverride)
	int ComputeVirtual(int Value)
	{
		TraceValue = TraceValue * 10 + 2;
		return Value + 10;
	}

	/**
	 * Observe DispatchVirtual(7) on a child instance.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.RecursionAndVirtualOverrideDispatch
	 * @Inputs DispatchVirtual(7)
	 * @Return 17
	 */
	UFUNCTION()
	int ChildReturn()
	{
		return DispatchVirtual(7);
	}

	/**
	 * Observe TraceValue after DispatchVirtual(7) on a child instance.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.RecursionAndVirtualOverrideDispatch
	 * @Inputs DispatchVirtual(7)
	 * @Return TraceValue, expected to be 2
	 */
	UFUNCTION()
	int ChildTrace()
	{
		DispatchVirtual(7);
		return TraceValue;
	}

	/**
	 * Observe Factorial(5) on the child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.RecursionAndVirtualOverrideDispatch
	 * @Inputs Factorial(5)
	 * @Return 120
	 */
	UFUNCTION()
	int FactorialFive()
	{
		return Factorial(5);
	}

	/**
	 * Observe Factorial(1) + Factorial(0) base cases.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.RecursionAndVirtualOverrideDispatch
	 * @Inputs Factorial(1) and Factorial(0)
	 * @Return 2
	 * @Boundary factorial base cases
	 */
	UFUNCTION()
	int FactorialBaseCases()
	{
		return Factorial(1) + Factorial(0);
	}
}
/** @end */
