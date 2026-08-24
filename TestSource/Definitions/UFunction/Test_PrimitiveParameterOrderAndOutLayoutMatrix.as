// Theme: Definitions.UFunction. WorldStory: ordered primitive/enum/object + out score.
// C++: AngelscriptCoverageUFunctionTests.cpp::PrimitiveParameterOrderAndOutLayoutMatrix
// Oracle: ConsumeOrdered(true, 4, Active=2, 25.0, this) writes LastOutScore 42 and returns 42.
// Extra: all false/0/null scores 0; default LastOutScore 0.
// FixtureIsolated. Runner owns World teardown.

UENUM(BlueprintType)
enum ECoverageUFunctionOrderState
{
	OrderStateIdle = 0,
	OrderStateActive = 2
}

UCLASS()
class ACoverageUFunctionPrimitiveOrderActor : AActor
{
	UPROPERTY()
	int LastOutScore = 0;

	UFUNCTION(BlueprintCallable, Category="Coverage|Layout", meta=(DisplayName="Ordered Parameter Matrix", AdvancedDisplay="Ratio,ObjectValue"))
	int ConsumeOrdered(bool bEnabled, uint8 ByteValue, ECoverageUFunctionOrderState State, double Ratio, UObject ObjectValue, int&out OutScore)
	{
		OutScore = (bEnabled ? 1 : 0) + int(ByteValue) + int(State) + int(Ratio) + (ObjectValue != nullptr ? 10 : 0);
		LastOutScore = OutScore;
		return OutScore;
	}
}

int Observe_PrimitiveOrder_NominalSelf(ACoverageUFunctionPrimitiveOrderActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveParameterOrderAndOutLayoutMatrix setup: required Actor is null");
	}
	int OutScore = 0;
	int Result = Actor.ConsumeOrdered(true, 4, ECoverageUFunctionOrderState::OrderStateActive, 25.0, Actor, OutScore);
	if (OutScore != 42 || Actor.LastOutScore != 42)
	{
		return -1;
	}
	return Result;
}

int Observe_PrimitiveOrder_EmptyNullBoundary(ACoverageUFunctionPrimitiveOrderActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveParameterOrderAndOutLayoutMatrix setup: required Actor is null");
	}
	int OutScore = -1;
	int Result = Actor.ConsumeOrdered(false, 0, ECoverageUFunctionOrderState::OrderStateIdle, 0.0, nullptr, OutScore);
	if (OutScore != 0 || Actor.LastOutScore != 0)
	{
		return -1;
	}
	return Result;
}

int Observe_PrimitiveOrder_DefaultScore(ACoverageUFunctionPrimitiveOrderActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveParameterOrderAndOutLayoutMatrix setup: required Actor is null");
	}
	return Actor.LastOutScore;
}
