/**
 * @version v1
 * @summary BlueprintEvent override, recursion and Super::. C++ verifies DispatchVirtual(7) base==8 child==17, Factorial(5)==120, CallParentCompute(7)==111, base TraceValue 1 and child TraceValue 24 after dispatch then.
 * @topic Feature
 */
/**
 * @version root
 * @summary BlueprintEvent override, recursion and Super::. C++ verifies DispatchVirtual(7) base==8 child==17, Factorial(5)==120, CallParentCompute(7)==111, base TraceValue 1 and child TraceValue 24 after dispatch then.
 * @topic Baseline
 */
UCLASS()
class ACoverageMacrosFunctionVirtualBase : AActor
{
	UPROPERTY()
	int TraceValue = 0;

	/**
	 * Parent BlueprintEvent that traces 1 and returns Value + 1.
	 *
	 * @Kind Action
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
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
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
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
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
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
	 * Parent-only compute that traces 4 and returns Value + 4.
	 *
	 * @Kind Action
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
	 * @Inputs Value
	 * @Return Value + 4; TraceValue = TraceValue * 10 + 4
	 * @Param Value the parent-only input
	 */
	UFUNCTION()
	int BaseOnlyCompute(int Value)
	{
		TraceValue = TraceValue * 10 + 4;
		return Value + 4;
	}

	/**
	 * Observe DispatchVirtual(7) on a base instance.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
	 * @Inputs DispatchVirtual(7)
	 * @Return 8
	 */
	UFUNCTION()
	int BaseDispatchSeven()
	{
		return DispatchVirtual(7);
	}
}

UCLASS()
class ACoverageMacrosFunctionVirtualChild : ACoverageMacrosFunctionVirtualBase
{
	/**
	 * Child BlueprintOverride that traces 2 and returns Value + 10.
	 *
	 * @Kind Action
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
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
	 * Super-call BaseOnlyCompute and add 100.
	 *
	 * @Kind Action
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
	 * @Inputs Value
	 * @Return Super::BaseOnlyCompute(Value) + 100
	 * @Param Value forwarded to Super::BaseOnlyCompute
	 */
	UFUNCTION()
	int CallParentCompute(int Value)
	{
		return Super::BaseOnlyCompute(Value) + 100;
	}

	/**
	 * Observe the default TraceValue on a child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
	 * @Inputs a freshly constructed child
	 * @Return TraceValue, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int DefaultTrace()
	{
		return TraceValue;
	}

	/**
	 * Observe Factorial(0) on the child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
	 * @Inputs Factorial(0)
	 * @Return 1
	 * @Boundary factorial zero
	 */
	UFUNCTION()
	int FactorialZeroBoundary()
	{
		return Factorial(0);
	}

	/**
	 * Observe Factorial(1) on the child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
	 * @Inputs Factorial(1)
	 * @Return 1
	 * @Boundary factorial one
	 */
	UFUNCTION()
	int FactorialOne()
	{
		return Factorial(1);
	}

	/**
	 * Observe Factorial(5) on the child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
	 * @Inputs Factorial(5)
	 * @Return 120
	 */
	UFUNCTION()
	int FactorialFive()
	{
		return Factorial(5);
	}

	/**
	 * Observe DispatchVirtual(7) on a child instance.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
	 * @Inputs DispatchVirtual(7)
	 * @Return 17
	 */
	UFUNCTION()
	int ChildDispatchSeven()
	{
		return DispatchVirtual(7);
	}

	/**
	 * Observe CallParentCompute(7) Super-calling BaseOnlyCompute.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UFunctionRecursiveVirtualOverrideAndSuperCall
	 * @Inputs CallParentCompute(7)
	 * @Return 111
	 */
	UFUNCTION()
	int CallParentComputeSeven()
	{
		return CallParentCompute(7);
	}
}
/** @end */
