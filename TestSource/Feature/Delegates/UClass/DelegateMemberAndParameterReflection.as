/**
 * Delegate UPROPERTY and UFUNCTION parameter reflection. ExecuteCallbackPath
 * returns 42 from DoubleValue(21). An unbound ConsumeCallback returns -1.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateMemberAndParameterReflection
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateMemberAndParameterReflection
 * @Provenance Theme: Feature.Delegates. Positive delegate UPROPERTY and UFUNCTION parameter reflection.
 * @Provenance C++: AngelscriptCoverageDelegateTests.cpp::DelegateMemberAndParameterReflection
 * @Provenance Oracle: ExecuteCallbackPath()==42 (DoubleValue(21)). Extra: empty object is null;
 * @Provenance unbound ConsumeCallback returns -1. DefaultSafe.
 */

/**
 * A multicast that reports a value and a label.
 *
 * @Covers Delegates.Reflection
 * @Inputs Value and Label
 * @Return nothing when broadcast
 */
delegate void FCoverageDelegateMemberSignal(int Value, const FString&in Label);

/**
 * A unicast that returns an int from a value.
 *
 * @Covers Delegates.Reflection
 * @Inputs Value
 * @Return an int from the bound handler
 */
delegate int FCoverageDelegateCallback(int Value);

UCLASS()
class UCoverageDelegateReflectionObject : UObject
{
	UPROPERTY()
	FCoverageDelegateMemberSignal OnMemberSignal;

	/**
	 * Executes Callback with 21, or -1 when unbound.
	 *
	 * @Covers Delegates.Reflection
	 * @Param Callback the unicast to execute
	 * @Inputs Callback
	 * @Return Callback.Execute(21), or -1 when unbound
	 * @Boundary unbound callback
	 */
	UFUNCTION()
	int ConsumeCallback(FCoverageDelegateCallback Callback)
	{
		if (!Callback.IsBound())
		{
			return -1;
		}

		return Callback.Execute(21);
	}

	/**
	 * Doubles Value.
	 *
	 * @Covers Delegates.Reflection
	 * @Param Value the input
	 * @Inputs Value
	 * @Return Value * 2
	 */
	UFUNCTION()
	int DoubleValue(int Value)
	{
		return Value * 2;
	}

	/**
	 * Binds DoubleValue and consumes the callback.
	 *
	 * @Covers Delegates.Reflection
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int ExecuteCallbackPath()
	{
		FCoverageDelegateCallback Callback;
		Callback.BindUFunction(this, n"DoubleValue");
		return ConsumeCallback(Callback);
	}

	/**
	 * Observe that a default-constructed object handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Reflection
	 * @Inputs a local UCoverageDelegateReflectionObject
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UCoverageDelegateReflectionObject Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe the DoubleValue callback path.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Reflection
	 * @Inputs ExecuteCallbackPath()
	 * @Return 42
	 */
	UFUNCTION()
	int CallbackPathReturnsFortyTwo()
	{
		return ExecuteCallbackPath();
	}

	/**
	 * Observe that an unbound ConsumeCallback returns -1.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Reflection
	 * @Inputs an unbound FCoverageDelegateCallback
	 * @Return -1
	 * @Boundary unbound consume
	 */
	UFUNCTION()
	int UnboundConsumeReturnsMinusOne()
	{
		FCoverageDelegateCallback Callback;
		return ConsumeCallback(Callback);
	}
}
