// Theme: Feature.Delegates. WorldStory primitive, FString, and FVector parameters.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateParameterTypes
// Oracle after BeginPlay: IntValue==42, FloatValue==3.14, BoolValue==true,
// StringValue=="Hello", VectorValue==(1,2,3). Extra: empty actor is null;
// pre-BeginPlay zeros / false / empty. FixtureIsolated.

delegate void FCoverageIntFloatBoolDelegate(int I, float F, bool B);
delegate void FCoverageStringDelegate(FString S);
delegate void FCoverageVectorDelegate(FVector V);

UCLASS()
class ACoverageDelegateParamTypesActor : AActor
{
	UPROPERTY()
	int IntValue = 0;

	UPROPERTY()
	float FloatValue = 0.0f;

	UPROPERTY()
	bool BoolValue = false;

	UPROPERTY()
	FString StringValue;

	UPROPERTY()
	FVector VectorValue;

	FCoverageIntFloatBoolDelegate OnIntFloatBoolDelegate;
	FCoverageStringDelegate OnStringDelegate;
	FCoverageVectorDelegate OnVectorDelegate;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnIntFloatBoolDelegate.BindUFunction(this, n"HandleIntFloatBool");
		OnIntFloatBoolDelegate.Execute(42, 3.14f, true);

		OnStringDelegate.BindUFunction(this, n"HandleString");
		OnStringDelegate.Execute("Hello");

		OnVectorDelegate.BindUFunction(this, n"HandleVector");
		OnVectorDelegate.Execute(FVector(1.0f, 2.0f, 3.0f));
	}

	UFUNCTION()
	void HandleIntFloatBool(int I, float F, bool B)
	{
		IntValue = I;
		FloatValue = F;
		BoolValue = B;
	}

	UFUNCTION()
	void HandleString(FString S)
	{
		StringValue = S;
	}

	UFUNCTION()
	void HandleVector(FVector V)
	{
		VectorValue = V;
	}
}

bool Observe_ParamTypes_EmptyDefaultIsNull()
{
	ACoverageDelegateParamTypesActor Actor;
	return Actor == nullptr;
}

int Observe_ParamTypes_IntDefault(ACoverageDelegateParamTypesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0025 setup: required ACoverageDelegateParamTypesActor is null");
	}
	return Actor.IntValue;
}

bool Observe_ParamTypes_BoolDefaultFalse(ACoverageDelegateParamTypesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0025 setup: required ACoverageDelegateParamTypesActor is null");
	}
	return Actor.BoolValue;
}
