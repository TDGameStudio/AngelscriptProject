/**
 * @version v1
 * @summary A UCLASS carrying a UPROPERTY with an explicit zero initializer. The property must start at zero, accept writes, and stay independent across instances.
 * @topic Language
 */
/**
 * @version root
 * @summary A UCLASS carrying a UPROPERTY with an explicit zero initializer. The property must start at zero, accept writes, and stay independent across instances.
 * @topic Baseline
 */
UCLASS()
class AClassUCLASSActor : AActor
{
	UPROPERTY()
	int X = 0;

	/**
	 * Observe the initialized property default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the X value
	 */
	UFUNCTION()
	int UClassPropertyDefaultValue()
	{
		return X;
	}

	/**
	 * Observe that a write lands on the property.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs X set to 1
	 * @Return the X value
	 */
	UFUNCTION()
	int UClassPropertyWriteBoundary()
	{
		X = 1;
		return X;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds 7 and the other holds 0
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool UClassPropertyIsIndependentAcrossInstances()
	{
		AClassUCLASSActor Other;
		X = 7;
		Other.X = 0;

		if (X != 7)
		{
			return false;
		}

		return Other.X == 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassUCLASSActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int UClassActorDefaultsToNull()
	{
		AClassUCLASSActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
