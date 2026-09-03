/**
 * FVector, FString, and int pass through dynamic delegates. After BeginPlay,
 * ReceivedVector is (10,20,30), ReceivedString is "Complex", and ReceivedInt is 42.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DynamicDelegateComplexParameters
 * @Harness UClass
 * @Tag Feature.Delegates.DynamicDelegateComplexParameters
 * @Provenance Theme: Feature.Delegates. WorldStory: FVector/FString/int pass through dynamic delegates.
 * @Provenance C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateComplexParameters
 * @Provenance Spawn + BeginPlay oracle: ReceivedVector==(10,20,30) after complex broadcast overwrites
 * @Provenance the earlier (1,2,3) Execute; ReceivedString=="Complex"; ReceivedInt==42.
 * @Provenance Extra: default vector zero / empty string / 0; zero vector vs filled. Keep Received*.
 * @Provenance FixtureIsolated.
 */

/**
 * A unicast that takes an FVector.
 *
 * @Covers Delegates.Dynamic
 * @Inputs V
 * @Return nothing when executed
 */
delegate void FCoverageDynamicVectorEvent(FVector V);

/**
 * A multicast that takes FVector, FString, and int.
 *
 * @Covers Delegates.Dynamic
 * @Inputs V, S, and I
 * @Return nothing when broadcast
 */
event void FCoverageDynamicVectorStringIntEvent(FVector V, FString S, int I);

UCLASS()
class ACoverageDynamicComplexParamsActor : AActor
{
	UPROPERTY()
	FVector ReceivedVector;

	UPROPERTY()
	FString ReceivedString;

	UPROPERTY()
	int ReceivedInt = 0;

	FCoverageDynamicVectorEvent OnVectorEvent;
	FCoverageDynamicVectorStringIntEvent OnComplexEvent;

	/**
	 * Executes the vector unicast, then broadcasts the complex multicast.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Dynamic
	 * @Inputs none
	 * @Return nothing; ReceivedVector ends at (10,20,30)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// FVector parameter
		OnVectorEvent.BindUFunction(this, n"HandleVectorEvent");
		OnVectorEvent.Execute(FVector(1.0f, 2.0f, 3.0f));

		// Multiple complex parameters
		OnComplexEvent.AddUFunction(this, n"HandleComplexEvent");
		OnComplexEvent.Broadcast(FVector(10.0f, 20.0f, 30.0f), "Complex", 42);
	}

	/**
	 * Stores the vector payload.
	 *
	 * @Covers Delegates.Dynamic
	 * @Param V the vector payload
	 * @Inputs V
	 * @Return nothing; ReceivedVector is written
	 */
	UFUNCTION()
	void HandleVectorEvent(FVector V)
	{
		ReceivedVector = V;
	}

	/**
	 * Stores the complex payload.
	 *
	 * @Covers Delegates.Dynamic
	 * @Param V the vector payload
	 * @Param S the string payload
	 * @Param I the int payload
	 * @Inputs V, S, and I
	 * @Return nothing; Received* members are written
	 */
	UFUNCTION()
	void HandleComplexEvent(FVector V, FString S, int I)
	{
		ReceivedVector = V;
		ReceivedString = S;
		ReceivedInt = I;
	}

	/**
	 * Observe the default ReceivedVector.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs this
	 * @Return the default FVector
	 * @Boundary default zero
	 */
	UFUNCTION()
	FVector ReceivedVectorDefaultZero()
	{
		return ReceivedVector;
	}

	/**
	 * Observe the default ReceivedInt.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs this
	 * @Return 0
	 * @Boundary default zero
	 */
	UFUNCTION()
	int ReceivedIntDefaultZero()
	{
		return ReceivedInt;
	}

	/**
	 * Observe that ReceivedString starts empty.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs this
	 * @Return true when ReceivedString is empty
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool ReceivedStringDefaultEmpty()
	{
		return ReceivedString.Len() == 0;
	}

	/**
	 * Observe that copying a vector and overwriting the copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs Original (1,2,3); Copy (10,20,30)
	 * @Return true when Original.X is 1 and Copy.X is 10
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool VectorCopyIndependence()
	{
		FVector Original = FVector(1.0f, 2.0f, 3.0f);
		FVector Copy = Original;
		Copy = FVector(10.0f, 20.0f, 30.0f);
		if (Original.X != 1.0f)
		{
			return false;
		}
		return Copy.X == 10.0f;
	}
}
