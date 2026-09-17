/**
 * @version v1
 * @summary Event declarations register multicast metadata. FCoverageMetadataEvent and FCoverageMetadataValueEvent are multicast; OnNoParam and OnValue are FMulticastDelegateProperty.
 * @topic Feature
 */
/**
 * @version root
 * @summary Event declarations register multicast metadata. FCoverageMetadataEvent and FCoverageMetadataValueEvent are multicast; OnNoParam and OnValue are FMulticastDelegateProperty.
 * @topic Baseline
 */
/**
 * A parameterless multicast event.
 *
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageMetadataEvent();

/**
 * A multicast event carrying an int payload.
 *
 * @Covers Delegates.Declaration
 * @Inputs Value
 * @Return nothing when broadcast
 */
event void FCoverageMetadataValueEvent(int Value);

UCLASS()
class ACoverageMulticastMetadataActor : AActor
{
	UPROPERTY()
	FCoverageMetadataEvent OnNoParam;

	UPROPERTY()
	FCoverageMetadataValueEvent OnValue;

	/**
	 * Observe that a default-constructed actor handle is non-null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local ACoverageMulticastMetadataActor
	 * @Return true when the handle is non-null
	 * @Boundary default construct
	 */
	UFUNCTION()
	bool DefaultNonNull()
	{
		ACoverageMulticastMetadataActor Actor;
		return Actor != nullptr;
	}

	/**
	 * Observe that assigning nullptr yields a null handle.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary nullptr assignment
	 */
	UFUNCTION()
	bool NullBoundary()
	{
		ACoverageMulticastMetadataActor Actor = nullptr;
		return Actor == nullptr;
	}
}
/** @end */
