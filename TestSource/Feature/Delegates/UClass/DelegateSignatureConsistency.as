/**
 * Single-cast versus multicast signature consistency. FCompilerSingleCastSignature
 * is not multicast; FCompilerMultiCastSignature is multicast. The carrier is an
 * empty UObject so reflection can name the types.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateSignatureConsistency
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateSignatureConsistency
 * @Provenance Theme: Feature.Delegates. Positive single-cast vs multicast signature consistency.
 * @Provenance C++: AngelscriptCompilerEndToEndTests.cpp::DelegateSignatureConsistency
 * @Provenance Oracle: FCompilerSingleCastSignature is not multicast; FCompilerMultiCastSignature is multicast.
 * @Provenance Extra: empty carrier is null. DefaultSafe.
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
