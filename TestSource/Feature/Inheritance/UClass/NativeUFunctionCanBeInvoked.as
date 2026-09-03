/**
 * A native CallFunctionByNameWithArguments path into ReceiveNativeValue. C++
 * invokes 77 and verifies NativeInvokeObserved==1 and LastNativeValue==77. The
 * observers cover the default zero and the zero-value boundary.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.NativeUFunctionCanBeInvoked
 * @Harness UClass
 * @Tag Feature.Inheritance.NativeUFunctionCanBeInvoked
 * @Provenance Theme: Feature.Inheritance. WorldStory native CallFunctionByNameWithArguments into script UFUNCTION.
 * @Provenance C++: AngelscriptActorScriptOverrideTests.cpp::NativeUFunctionCanBeInvoked
 * @Provenance Oracle after ReceiveNativeValue(77): NativeInvokeObserved==1, LastNativeValue==77.
 * @Provenance Extra: empty handle null; default LastNativeValue 0. FixtureIsolated.
 * @Provenance Keep NativeInvokeObserved/LastNativeValue.
 */

UCLASS()
class ATestScriptActorNativeUFunctionCanBeInvoked : AActor
{
	UPROPERTY()
	int NativeInvokeObserved = 0;

	UPROPERTY()
	int LastNativeValue = 0;

	/**
	 * Record a native invoke by storing the value and setting the observed flag.
	 *
	 * @Kind Action
	 * @Covers Inheritance.NativeUFunctionCanBeInvoked
	 * @Inputs the value passed from native CallFunctionByNameWithArguments
	 * @Return NativeInvokeObserved == 1 and LastNativeValue == Value
	 * @Param Value the native payload
	 */
	UFUNCTION()
	void ReceiveNativeValue(int Value)
	{
		NativeInvokeObserved = 1;
		LastNativeValue = Value;
	}

	/**
	 * Observe that a locally constructed actor has received no native value.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeUFunctionCanBeInvoked
	 * @Inputs an actor that has not been invoked
	 * @Return LastNativeValue, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int DefaultLastValue()
	{
		return LastNativeValue;
	}

	/**
	 * Observe ReceiveNativeValue(77) writing LastNativeValue.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeUFunctionCanBeInvoked
	 * @Inputs ReceiveNativeValue(77)
	 * @Return LastNativeValue, expected to be 77
	 */
	UFUNCTION()
	int Receive77()
	{
		ReceiveNativeValue(77);
		return LastNativeValue;
	}

	/**
	 * Observe ReceiveNativeValue(0) writing the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeUFunctionCanBeInvoked
	 * @Inputs ReceiveNativeValue(0)
	 * @Return LastNativeValue, expected to be 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		ReceiveNativeValue(0);
		return LastNativeValue;
	}
}
