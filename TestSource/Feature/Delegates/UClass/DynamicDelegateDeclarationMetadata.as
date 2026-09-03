/**
 * Delegate versus event metadata on a UObject carrier. Single-cast delegates,
 * multicast events, and named members are the reflection oracle.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DynamicDelegateDeclarationMetadata
 * @Harness UClass
 * @Tag Feature.Delegates.DynamicDelegateDeclarationMetadata
 * @Provenance Theme: Feature.Delegates. Positive: delegate vs event metadata on a UObject carrier.
 * @Provenance C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateDeclarationMetadata
 * @Provenance Compile + reflection oracle: single-cast delegates, multicast events, named members.
 * @Provenance Extra: default-constructed object is non-null; nullptr assignment is the null boundary.
 * @Provenance DefaultSafe.
 */

/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FCoverageDynamicNoParam();

/**
 * A unicast that takes an int.
 *
 * @Covers Delegates.Declaration
 * @Inputs Value
 * @Return nothing when executed
 */
delegate void FCoverageDynamicValue(int Value);

/**
 * A unicast that returns bool.
 *
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return the bound handler's bool
 */
delegate bool FCoverageDynamicBoolResult();

/**
 * A parameterless multicast event.
 *
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageDynamicEvent();

/**
 * A multicast event carrying an int payload.
 *
 * @Covers Delegates.Declaration
 * @Inputs NewValue
 * @Return nothing when broadcast
 */
event void FCoverageDynamicValueEvent(int NewValue);

UCLASS()
class UCoverageDynamicDelegateMetadataObject : UObject
{
	UPROPERTY()
	FCoverageDynamicNoParam SingleNoParam;

	UPROPERTY()
	FCoverageDynamicValue SingleValue;

	UPROPERTY()
	FCoverageDynamicBoolResult SingleBoolResult;

	UPROPERTY()
	FCoverageDynamicEvent AssignableEvent;

	UPROPERTY()
	FCoverageDynamicValueEvent CallableValueEvent;

	/**
	 * Observe that a default-constructed handle is non-null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local UCoverageDynamicDelegateMetadataObject
	 * @Return true when the handle is non-null
	 * @Boundary default construct
	 */
	UFUNCTION()
	bool DefaultNonNull()
	{
		UCoverageDynamicDelegateMetadataObject Obj;
		return Obj != nullptr;
	}

	/**
	 * Observe that assigning nullptr yields a null handle.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs Obj = nullptr
	 * @Return true when the handle is null
	 * @Boundary nullptr assignment
	 */
	UFUNCTION()
	bool NullBoundary()
	{
		UCoverageDynamicDelegateMetadataObject Obj = nullptr;
		return Obj == nullptr;
	}
}
