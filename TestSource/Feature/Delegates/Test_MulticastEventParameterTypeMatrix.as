// Theme: Feature.Delegates. WorldStory: multicast event parameter type matrix.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastEventParameterTypeMatrix
// Spawn + BeginPlay oracle: PrimitiveScore==132 (7+100+25), TextResult=="Score_handled",
// NameResult==ReadyTag, VectorValueResult==(11,12,13), VectorRefResult==(8,10,12),
// bObjectMatched==true.
// Extra: default score 0 / empty text / zero vectors / false match; copy independence.
// Keep PrimitiveScore, TextResult, NameResult, Vector*Result, bObjectMatched.
// FixtureIsolated.

event void FCoveragePrimitiveSignal(int Value, bool bEnabled, float Scale);
event void FCoverageTextSignal(const FString& Text, FName Tag);
event void FCoverageVectorValueSignal(FVector Location);
event void FCoverageVectorRefSignal(const FVector& Direction);
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

	UFUNCTION()
	void HandleText(const FString& Text, FName Tag)
	{
		TextResult = Text + "_handled";
		NameResult = Tag;
	}

	UFUNCTION()
	void HandleVectorValue(FVector Location)
	{
		VectorValueResult = Location + FVector(10.0, 10.0, 10.0);
	}

	UFUNCTION()
	void HandleVectorRef(const FVector& Direction)
	{
		VectorRefResult = Direction * 2.0;
	}

	UFUNCTION()
	void HandleObject(AActor ActorValue)
	{
		bObjectMatched = ActorValue == this;
	}
}

int Observe_PrimitiveScore_DefaultZero(ACoverageMulticastParameterTypeMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastEventParameterTypeMatrix setup: required Actor is null");
	}
	return Actor.PrimitiveScore;
}

bool Observe_TextAndMatch_Defaults(ACoverageMulticastParameterTypeMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastEventParameterTypeMatrix setup: required Actor is null");
	}
	return Actor.TextResult.Len() == 0 && !Actor.bObjectMatched;
}

bool Observe_Vector_CopyIndependence()
{
	FVector Original = FVector(1.0, 2.0, 3.0);
	FVector Copy = Original;
	Copy = Copy + FVector(10.0, 10.0, 10.0);
	return Original.X == 1.0 && Copy.X == 11.0;
}

int Observe_Primitive_FalseScaleBoundary()
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
