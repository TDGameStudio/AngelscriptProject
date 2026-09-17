/**
 * @version v1
 * @summary A script-level constructor that assigns a member. The constructor must run at construction time, so the member is neither left at zero nor clobbered by a later write.
 * @topic Language
 */
/**
 * @version root
 * @summary A script-level constructor that assigns a member. The constructor must run at construction time, so the member is neither left at zero nor clobbered by a later write.
 * @topic Baseline
 */
class AClassCtorActor : AActor
{
	int X;

	/**
	 * Initializes the member at construction time.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return a new AClassCtorActor with X set to 10
	 */
	AClassCtorActor()
	{
		X = 10;
	}

	/**
	 * Observe the value the constructor stored.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the X value
	 */
	UFUNCTION()
	int ConstructorStoredValue()
	{
		return X;
	}

	/**
	 * Observe that the member was not left at the zero default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the X value, or 0 if it is still zero
	 * @Boundary non-zero after construction
	 */
	UFUNCTION()
	int ConstructorNotLeftAtZero()
	{
		if (X == 0)
		{
			return 0;
		}
		return X;
	}

	/**
	 * Observe that a later write replaces the constructed value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs X set to 1 after construction
	 * @Return the X value
	 * @Boundary post-construction write
	 */
	UFUNCTION()
	int ConstructorWriteAfterConstruct()
	{
		X = 1;
		return X;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassCtorActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int ConstructorActorDefaultsToNull()
	{
		AClassCtorActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
