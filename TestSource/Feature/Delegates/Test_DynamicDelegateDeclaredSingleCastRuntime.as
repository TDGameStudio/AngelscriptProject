// Theme: Feature.Delegates. WorldStory: declared single-cast delegates bind and execute.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateDeclaredSingleCastRuntime
// Spawn + BeginPlay oracle: bNoParamBound/bValueBound/bRetValBound true; Counter==18
// (1 + 17); ReceivedValue==17; ReturnResult==36 (25+11).
// Extra: defaults 0/false; unbound flags false. Keep Counter, ReceivedValue, ReturnResult.
// FixtureIsolated.

delegate void FCoverageDeclaredNoParam();
delegate void FCoverageDeclaredValue(int Value);
delegate int FCoverageDeclaredRetVal(int Value);

UCLASS()
class ACoverageDynamicDeclaredRuntimeActor : AActor
{
	UPROPERTY()
	FCoverageDeclaredNoParam OnNoParam;

	UPROPERTY()
	FCoverageDeclaredValue OnValue;

	UPROPERTY()
	FCoverageDeclaredRetVal OnRetVal;

	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	int ReceivedValue = 0;

	UPROPERTY()
	int ReturnResult = 0;

	UPROPERTY()
	bool bNoParamBound = false;

	UPROPERTY()
	bool bValueBound = false;

	UPROPERTY()
	bool bRetValBound = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnNoParam.BindUFunction(this, n"HandleNoParam");
		OnValue.BindUFunction(this, n"HandleValue");
		OnRetVal.BindUFunction(this, n"HandleRetVal");

		bNoParamBound = OnNoParam.IsBound();
		bValueBound = OnValue.IsBound();
		bRetValBound = OnRetVal.IsBound();

		OnNoParam.Execute();
		OnValue.Execute(17);
		ReturnResult = OnRetVal.Execute(25);
	}

	UFUNCTION()
	void HandleNoParam()
	{
		Counter += 1;
	}

	UFUNCTION()
	void HandleValue(int Value)
	{
		ReceivedValue = Value;
		Counter += Value;
	}

	UFUNCTION()
	int HandleRetVal(int Value)
	{
		return Value + 11;
	}
}

int Observe_Counter_DefaultZero(ACoverageDynamicDeclaredRuntimeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DynamicDelegateDeclaredSingleCastRuntime setup: required Actor is null");
	}
	return Actor.Counter;
}

bool Observe_BoundFlags_DefaultFalse(ACoverageDynamicDeclaredRuntimeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DynamicDelegateDeclaredSingleCastRuntime setup: required Actor is null");
	}
	return !Actor.bNoParamBound && !Actor.bValueBound && !Actor.bRetValBound;
}

int Observe_RetVal_ZeroBoundary()
{
	return 0 + 11;
}
