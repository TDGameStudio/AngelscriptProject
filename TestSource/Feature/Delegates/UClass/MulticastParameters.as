/**
 * Multicast broadcasts of int and FString payloads. After BeginPlay, IntSum is
 * 190 and ConcatenatedString is "TestTest".
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MulticastParameters
 * @Harness UClass
 * @Tag Feature.Delegates.MulticastParameters
 * @Provenance Theme: Feature.Delegates. WorldStory: multicast broadcasts int and FString payloads.
 * @Provenance C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastParameters
 * @Provenance Spawn + BeginPlay oracle: IntSum==190 (50+100 + 10+30), ConcatenatedString=="TestTest".
 * @Provenance Extra: default IntSum 0 / empty string; empty vs "Test" copy independence. Keep IntSum.
 * @Provenance FixtureIsolated.
 */

/**
 * A multicast that takes one int.
 *
 * @Covers Delegates.Multicast
 * @Inputs Value
 * @Return nothing when broadcast
 */
event void FCoverageMcIntSignal(int Value);

/**
 * A multicast that takes an int and an FString.
 *
 * @Covers Delegates.Multicast
 * @Inputs IntValue and StringValue
 * @Return nothing when broadcast
 */
event void FCoverageMcIntStringSignal(int IntValue, FString StringValue);

UCLASS()
class ACoverageMulticastParamsActor : AActor
{
	UPROPERTY()
	int IntSum = 0;

	UPROPERTY()
	FString ConcatenatedString;

	UPROPERTY()
	FCoverageMcIntSignal OnIntMulticast;

	UPROPERTY()
	FCoverageMcIntStringSignal OnIntStringMulticast;

	/**
	 * Binds two int listeners and two int/string listeners, then broadcasts.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; IntSum ends at 190 and ConcatenatedString is "TestTest"
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// One parameter
		OnIntMulticast.AddUFunction(this, n"HandleInt1");
		OnIntMulticast.AddUFunction(this, n"HandleInt2");
		OnIntMulticast.Broadcast(50);

		// Two parameters
		OnIntStringMulticast.AddUFunction(this, n"HandleIntString1");
		OnIntStringMulticast.AddUFunction(this, n"HandleIntString2");
		OnIntStringMulticast.Broadcast(10, "Test");
	}

	/**
	 * Adds Value to IntSum.
	 *
	 * @Covers Delegates.Multicast
	 * @Param Value the payload
	 * @Inputs Value
	 * @Return nothing; IntSum gains Value
	 */
	UFUNCTION()
	void HandleInt1(int Value)
	{
		IntSum += Value;
	}

	/**
	 * Adds Value * 2 to IntSum.
	 *
	 * @Covers Delegates.Multicast
	 * @Param Value the payload
	 * @Inputs Value
	 * @Return nothing; IntSum gains Value * 2
	 */
	UFUNCTION()
	void HandleInt2(int Value)
	{
		IntSum += Value * 2;
	}

	/**
	 * Adds IntValue and appends StringValue.
	 *
	 * @Covers Delegates.Multicast
	 * @Param IntValue the int payload
	 * @Param StringValue the string payload
	 * @Inputs IntValue and StringValue
	 * @Return nothing; IntSum and ConcatenatedString are written
	 */
	UFUNCTION()
	void HandleIntString1(int IntValue, FString StringValue)
	{
		IntSum += IntValue;
		ConcatenatedString += StringValue;
	}

	/**
	 * Adds IntValue * 3 and appends StringValue.
	 *
	 * @Covers Delegates.Multicast
	 * @Param IntValue the int payload
	 * @Param StringValue the string payload
	 * @Inputs IntValue and StringValue
	 * @Return nothing; IntSum and ConcatenatedString are written
	 */
	UFUNCTION()
	void HandleIntString2(int IntValue, FString StringValue)
	{
		IntSum += IntValue * 3;
		ConcatenatedString += StringValue;
	}

	/**
	 * Observe the default IntSum.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs this
	 * @Return 0
	 * @Boundary default IntSum
	 */
	UFUNCTION()
	int IntSumDefaultZero()
	{
		return IntSum;
	}

	/**
	 * Observe that ConcatenatedString starts empty.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs this
	 * @Return true when ConcatenatedString is empty
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool ConcatenatedStringDefaultEmpty()
	{
		return ConcatenatedString.Len() == 0;
	}

	/**
	 * Observe that appending to a copy leaves the original "Test".
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs Original "Test"; Copy += "Test"
	 * @Return true when Original is "Test" and Copy is "TestTest"
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool StringCopyIndependence()
	{
		FString Original = "Test";
		FString Copy = Original;
		Copy += "Test";
		if (Original != "Test")
		{
			return false;
		}
		return Copy == "TestTest";
	}
}
