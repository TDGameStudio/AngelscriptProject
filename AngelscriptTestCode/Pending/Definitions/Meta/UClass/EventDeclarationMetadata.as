/**
 * @version v1
 * @summary Plain event UPROPERTY declarations compile to multicast delegates. C++ looks up OnPlainEvent, OnAssignableEvent and OnCallableEvent on the generated class.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Plain event UPROPERTY declarations compile to multicast delegates. C++ looks up OnPlainEvent, OnAssignableEvent and OnCallableEvent on the generated class.
 * @topic Baseline
 */
/**
 * A parameterless multicast event used as a plain UPROPERTY.
 *
 * @Covers Meta.EventDeclarationMetadata
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageEventPlain();

/**
 * A parameterless multicast event used as an assignable UPROPERTY.
 *
 * @Covers Meta.EventDeclarationMetadata
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageEventAssignable();

/**
 * A multicast event that takes an integer payload.
 *
 * @Covers Meta.EventDeclarationMetadata
 * @Inputs the payload Value
 * @Return nothing when broadcast
 * @Param Value the integer payload
 */
event void FCoverageEventCallable(int Value);

UCLASS()
class ACoverageEventMetadataActor : AActor
{
	UPROPERTY()
	FCoverageEventPlain OnPlainEvent;

	UPROPERTY()
	FCoverageEventAssignable OnAssignableEvent;

	UPROPERTY()
	FCoverageEventCallable OnCallableEvent;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.EventDeclarationMetadata
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		ACoverageEventMetadataActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one unset handle aliases the other.
	 *
	 * @Kind Observe
	 * @Covers Meta.EventDeclarationMetadata
	 * @Inputs none
	 * @Return true when the assigned handles compare identical
	 * @Boundary assign aliases
	 */
	UFUNCTION()
	bool AssignAliases()
	{
		ACoverageEventMetadataActor First;
		ACoverageEventMetadataActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
