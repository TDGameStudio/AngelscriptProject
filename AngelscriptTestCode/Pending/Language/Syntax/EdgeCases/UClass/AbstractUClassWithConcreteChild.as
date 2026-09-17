/**
 * @version v1
 * @summary An Abstract UCLASS paired with a concrete child. The abstract type is declared but not instantiated; the child carries a member that starts at zero and accepts writes.
 * @topic Language
 */
/**
 * @version root
 * @summary An Abstract UCLASS paired with a concrete child. The abstract type is declared but not instantiated; the child carries a member that starts at zero and accepts writes.
 * @topic Baseline
 */
UCLASS(Abstract)
class AMyAbstract : AActor
{
}

UCLASS()
class AMyAbstractConcrete : AMyAbstract
{
	int EmptyFlag = 0;

	/**
	 * Observe the child's initialized member default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed child
	 * @Return the EmptyFlag value
	 */
	UFUNCTION()
	int ConcreteChildDefaultFlag()
	{
		return EmptyFlag;
	}

	/**
	 * Observe that a write lands on the child's member.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EmptyFlag set to 1
	 * @Return the EmptyFlag value
	 * @Boundary non-zero write
	 */
	UFUNCTION()
	int ConcreteChildFlagWriteBoundary()
	{
		EmptyFlag = 1;
		return EmptyFlag;
	}

	/**
	 * Observe that an unset abstract handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AMyAbstract handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int AbstractHandleDefaultsToNull()
	{
		AMyAbstract Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
