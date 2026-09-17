/**
 * @version v1
 * @summary Delegate and event signature metadata round-trip. The single-cast and multicast type names are substituted into C++; this carrier exists so the module compiles with zero diagnostics.
 * @topic Feature
 */
/**
 * @version root
 * @summary Delegate and event signature metadata round-trip. The single-cast and multicast type names are substituted into C++; this carrier exists so the module compiles with zero diagnostics.
 * @topic Baseline
 */
/**
 * A unicast whose name is the single-cast metadata substitution.
 *
 * @Covers Delegates.Declaration
 * @Inputs Value
 * @Return nothing when executed
 */
delegate void FCompilerSingleMetadataRoundTrip(int Value);

/**
 * A multicast whose name is the multicast metadata substitution.
 *
 * @Covers Delegates.Declaration
 * @Inputs TypeValue and Label
 * @Return nothing when broadcast
 */
event void FCompilerMultiMetadataRoundTrip(UClass TypeValue, FString Label);

UCLASS()
class UCompilerDelegateMetadataCarrier : UObject
{
	/**
	 * Observe that a default-constructed carrier handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local UCompilerDelegateMetadataCarrier
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UCompilerDelegateMetadataCarrier Carrier;
		return Carrier == nullptr;
	}
}
/** @end */
