/**
 * Ordered primitive/enum/object parameters plus an out score. C++ verifies
 * ConsumeOrdered(true, 4, Active=2, 25.0, this) writes LastOutScore 42, so those names
 * are part of the contract and are kept verbatim.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.PrimitiveParameterOrderAndOutLayoutMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.PrimitiveParameterOrderAndOutLayoutMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: ordered primitive/enum/object + out score.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::PrimitiveParameterOrderAndOutLayoutMatrix
 * @Provenance Oracle: ConsumeOrdered(true, 4, Active=2, 25.0, this) writes LastOutScore 42 and returns 42.
 * @Provenance Extra: all false/0/null scores 0; default LastOutScore 0.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

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

	/**
	 * Consume ordered primitive/enum/object arguments and write OutScore.
	 *
	 * @Kind Observe
	 * @Covers UFunction.PrimitiveParameterOrderAndOutLayoutMatrix
	 * @Inputs enabled, byte, state, ratio, object
	 * @Return OutScore, also stored in LastOutScore
	 * @Param bEnabled whether the enabled bit is set
	 * @Param ByteValue the byte contribution
	 * @Param State the enum contribution
	 * @Param Ratio the ratio contribution
	 * @Param ObjectValue the optional object
	 * @Param OutScore the written score
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Layout", meta=(DisplayName="Ordered Parameter Matrix", AdvancedDisplay="Ratio,ObjectValue"))
	int ConsumeOrdered(bool bEnabled, uint8 ByteValue, ECoverageUFunctionOrderState State, double Ratio, UObject ObjectValue, int&out OutScore)
	{
		OutScore = (bEnabled ? 1 : 0) + int(ByteValue) + int(State) + int(Ratio) + (ObjectValue != nullptr ? 10 : 0);
		LastOutScore = OutScore;
		return OutScore;
	}

	/**
	 * Observe that the nominal self call scores 42.
	 *
	 * @Kind Observe
	 * @Covers UFunction.PrimitiveParameterOrderAndOutLayoutMatrix
	 * @Inputs none
	 * @Return 42, or -1 when the out score mismatches
	 */
	UFUNCTION()
	int NominalSelf()
	{
		int OutScore = 0;
		int Result = ConsumeOrdered(true, 4, ECoverageUFunctionOrderState::OrderStateActive, 25.0, this, OutScore);
		if (OutScore != 42)
		{
			return -1;
		}
		if (LastOutScore != 42)
		{
			return -1;
		}
		return Result;
	}

	/**
	 * Observe that false/0/null arguments score 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.PrimitiveParameterOrderAndOutLayoutMatrix
	 * @Inputs none
	 * @Return 0, or -1 when the out score mismatches
	 * @Boundary empty/null
	 */
	UFUNCTION()
	int EmptyNullBoundary()
	{
		int OutScore = -1;
		int Result = ConsumeOrdered(false, 0, ECoverageUFunctionOrderState::OrderStateIdle, 0.0, nullptr, OutScore);
		if (OutScore != 0)
		{
			return -1;
		}
		if (LastOutScore != 0)
		{
			return -1;
		}
		return Result;
	}

	/**
	 * Observe that an untouched actor has LastOutScore 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.PrimitiveParameterOrderAndOutLayoutMatrix
	 * @Inputs none
	 * @Return LastOutScore
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultScore()
	{
		return LastOutScore;
	}
}
