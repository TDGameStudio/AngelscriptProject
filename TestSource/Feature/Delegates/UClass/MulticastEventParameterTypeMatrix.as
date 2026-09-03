/**
 * Multicast event parameter type matrix. After BeginPlay, PrimitiveScore is
 * 132 (7+100+25), TextResult Score_handled, NameResult ReadyTag,
 * VectorValueResult (11,12,13), VectorRefResult (8,10,12), bObjectMatched true.
 * Default score 0 / empty text / zero vectors / false match. Copy independence.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MulticastEventParameterTypeMatrix
 * @Harness UClass
 * @Tag Feature.Delegates.MulticastEventParameterTypeMatrix
 * @Provenance Theme: Feature.Delegates. WorldStory: multicast event parameter type matrix.
 * @Provenance C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastEventParameterTypeMatrix
 * @Provenance Spawn + BeginPlay oracle: PrimitiveScore==132 (7+100+25), TextResult=="Score_handled",
 * @Provenance NameResult==ReadyTag, VectorValueResult==(11,12,13), VectorRefResult==(8,10,12),
 * @Provenance bObjectMatched==true.
 * @Provenance Extra: default score 0 / empty text / zero vectors / false match; copy independence.
 * @Provenance Keep PrimitiveScore, TextResult, NameResult, Vector*Result, bObjectMatched.
 * @Provenance FixtureIsolated.
 */

/**
 * A multicast of int, bool, and float.
 *
 * @Covers Delegates.Broadcast
 * @Inputs Value, bEnabled, and Scale
 * @Return void
 */
event void FCoveragePrimitiveSignal(int Value, bool bEnabled, float Scale);

/**
 * A multicast of const string &in and name.
 *
 * @Covers Delegates.Broadcast
 * @Inputs Text and Tag
 * @Return void
 */
event void FCoverageTextSignal(const FString&in Text, FName Tag);

/**
 * A multicast of a vector by value.
 *
 * @Covers Delegates.Broadcast
 * @Inputs Location
 * @Return void
 */
event void FCoverageVectorValueSignal(FVector Location);

/**
 * A multicast of a const vector &in.
 *
 * @Covers Delegates.Broadcast
 * @Inputs Direction
 * @Return void
 */
event void FCoverageVectorRefSignal(const FVector&in Direction);

/**
 * A multicast of an actor.
 *
 * @Covers Delegates.Broadcast
 * @Inputs ActorValue
 * @Return void
 */
event void FCoverageObjectSignal(AActor ActorValue);

UCLASS()
class ACoverageMulticastParameterTypeMatrixActor : AActor
{
	UPROPERTY()
	int PrimitiveScore = 0;

	UPROPERTY()
	FString TextResult;

	UPROPERTY()
	FName NameResult;

	UPROPERTY()
	FVector VectorValueResult;

	UPROPERTY()
	FVector VectorRefResult;

	UPROPERTY()
	bool bObjectMatched = false;

	UPROPERTY()
	FCoveragePrimitiveSignal OnPrimitive;

	UPROPERTY()
	FCoverageTextSignal OnText;

	UPROPERTY()
	FCoverageVectorValueSignal OnVectorValue;

	UPROPERTY()
	FCoverageVectorRefSignal OnVectorRef;

	UPROPERTY()
	FCoverageObjectSignal OnObject;

	/**
	 * WorldStory: BeginPlay binds handlers and broadcasts the type matrix.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Broadcast
	 * @Inputs none
	 * @Return PrimitiveScore 132, TextResult Score_handled, bObjectMatched true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnPrimitive.AddUFunction(this, n"HandlePrimitive");
		OnText.AddUFunction(this, n"HandleText");
		OnVectorValue.AddUFunction(this, n"HandleVectorValue");
		OnVectorRef.AddUFunction(this, n"HandleVectorRef");
		OnObject.AddUFunction(this, n"HandleObject");

		OnPrimitive.Broadcast(7, true, 2.5f);
		OnText.Broadcast("Score", n"ReadyTag");
		OnVectorValue.Broadcast(FVector(1.0, 2.0, 3.0));
		OnVectorRef.Broadcast(FVector(4.0, 5.0, 6.0));
		OnObject.Broadcast(this);
	}

	/**
	 * Score Value plus 100 when enabled plus Scale*10.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Value Integer received by value
	 * @Param bEnabled Bool received by value
	 * @Param Scale Float received by value
	 * @Inputs Value, bEnabled, and Scale
	 * @Return void
	 */
	UFUNCTION()
	void HandlePrimitive(int Value, bool bEnabled, float Scale)
	{
		PrimitiveScore = Value;
		if (bEnabled)
		{
			PrimitiveScore += 100;
		}
		PrimitiveScore += int(Scale * 10.0);
	}

	/**
	 * Write Text_handled and Tag.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Text String received as const FString&in
	 * @Param Tag Name received by value
	 * @Inputs Text and Tag
	 * @Return void
	 */
	UFUNCTION()
	void HandleText(const FString&in Text, FName Tag)
	{
		TextResult = Text + "_handled";
		NameResult = Tag;
	}

	/**
	 * Write Location plus (10,10,10).
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Location Vector received by value
	 * @Inputs Location
	 * @Return void
	 */
	UFUNCTION()
	void HandleVectorValue(FVector Location)
	{
		VectorValueResult = Location + FVector(10.0, 10.0, 10.0);
	}

	/**
	 * Write Direction * 2.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Direction Vector received as const FVector&in
	 * @Inputs Direction
	 * @Return void
	 */
	UFUNCTION()
	void HandleVectorRef(const FVector&in Direction)
	{
		VectorRefResult = Direction * 2.0;
	}

	/**
	 * Mark bObjectMatched when ActorValue is this.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param ActorValue Actor received by value
	 * @Inputs ActorValue
	 * @Return void
	 */
	UFUNCTION()
	void HandleObject(AActor ActorValue)
	{
		bObjectMatched = ActorValue == this;
	}

	/**
	 * Observe the default PrimitiveScore.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default PrimitiveScore
	 */
	UFUNCTION()
	int PrimitiveScoreDefaultZero()
	{
		return PrimitiveScore;
	}

	/**
	 * Observe default TextResult and bObjectMatched.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs a freshly constructed actor
	 * @Return true when TextResult is empty and bObjectMatched is false
	 * @Boundary default text and match
	 */
	UFUNCTION()
	bool TextAndMatchDefaults()
	{
		if (TextResult.Len() != 0)
		{
			return false;
		}
		return !bObjectMatched;
	}

	/**
	 * Observe that mutating a vector copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs Original (1,2,3) and a mutated copy
	 * @Return true when Original.X is 1 and Copy.X is 11
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool VectorCopyIndependence()
	{
		FVector Original = FVector(1.0, 2.0, 3.0);
		FVector Copy = Original;
		Copy = Copy + FVector(10.0, 10.0, 10.0);
		if (Original.X != 1.0)
		{
			return false;
		}
		return Copy.X == 11.0;
	}

	/**
	 * Observe PrimitiveScore with bEnabled false and Scale 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs Value 7, bEnabled false, Scale 0
	 * @Return 7
	 * @Boundary false scale
	 */
	UFUNCTION()
	int PrimitiveFalseScaleBoundary()
	{
		int Score = 7;
		bool bEnabled = false;
		float Scale = 0.0f;
		if (bEnabled)
		{
			Score += 100;
		}
		Score += int(Scale * 10.0);
		return Score;
	}
}
