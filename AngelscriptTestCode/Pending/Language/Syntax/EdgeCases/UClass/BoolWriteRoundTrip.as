/**
 * @version v1
 * @summary A boolean UPROPERTY written through the true/false/true cycle. The observers confirm the starting default, that each write reads back, and that writing one actor leaves another untouched.
 * @topic Language
 */
/**
 * @version root
 * @summary A boolean UPROPERTY written through the true/false/true cycle. The observers confirm the starting default, that each write reads back, and that writing one actor leaves another untouched.
 * @topic Baseline
 */
UCLASS()
class ACoverageBoolWriteActor : AActor
{
	UPROPERTY()
	bool BoolValue;

	/**
	 * Observe that the property starts false.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when BoolValue is false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool BoolWriteDefaultsToFalse()
	{
		return BoolValue == false;
	}

	/**
	 * Observe that each write in the cycle reads back.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BoolValue written true, then false, then true
	 * @Return true when every step reads back its written value
	 */
	UFUNCTION()
	bool BoolWriteRoundTripsThroughValues()
	{
		BoolValue = true;
		if (BoolValue != true)
		{
			return false;
		}

		BoolValue = false;
		if (BoolValue != false)
		{
			return false;
		}

		BoolValue = true;
		return BoolValue == true;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds true and the other stays false
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool BoolWriteIsIndependentAcrossInstances()
	{
		ACoverageBoolWriteActor Other =
			Cast<ACoverageBoolWriteActor>(
				NewObject(GetTransientPackage(), ACoverageBoolWriteActor::StaticClass(), n"CoverageBoolWriteActorOther"));
		if (Other == nullptr)
		{
			throw("Test_BoolWriteRoundTrip setup: NewObject returned null");
		}

		BoolValue = true;

		if (BoolValue != true)
		{
			return false;
		}

		return Other.BoolValue == false;
	}
}
/** @end */
