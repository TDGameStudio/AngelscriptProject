/**
 * @version v1
 * @summary Single-cast versus multicast signature consistency. FCompilerSingleCastSignature is not multicast; FCompilerMultiCastSignature is multicast. The carrier is an empty UObject so reflection can name the types.
 * @topic Feature
 */
/**
 * @version root
 * @summary Single-cast versus multicast signature consistency. FCompilerSingleCastSignature is not multicast; FCompilerMultiCastSignature is multicast. The carrier is an empty UObject so reflection can name the types.
 * @topic Baseline
 */
/**
 * A unicast that takes an int.
 *
 * @Covers Delegates.Declaration
 * @Inputs Value
 * @Return nothing when executed
 */
delegate void FCompilerSingleCastSignature(int Value);

/**
 * A multicast that takes a UClass and a label.
 *
 * @Covers Delegates.Declaration
 * @Inputs TypeValue and Label
 * @Return nothing when broadcast
 */
event void FCompilerMultiCastSignature(UClass TypeValue, FString Label);

UCLASS()
class UCompilerDelegateCarrier : UObject
{
	/**
	 * Observe that a default-constructed carrier handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local UCompilerDelegateCarrier
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UCompilerDelegateCarrier Carrier;
		return Carrier == nullptr;
	}
}
/** @end */
