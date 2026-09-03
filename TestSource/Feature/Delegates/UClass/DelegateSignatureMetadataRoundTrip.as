/**
 * Delegate and event signature metadata round-trip. The single-cast and
 * multicast type names are substituted into C++; this carrier exists so the
 * module compiles with zero diagnostics.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateSignatureMetadataRoundTrip
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateSignatureMetadataRoundTrip
 * @Provenance Theme: Feature.Delegates. Positive delegate/event signature metadata round-trip.
 * @Provenance C++: AngelscriptCompilerDelegateTests.cpp::DelegateSignatureMetadataRoundTrip
 * @Provenance $ARG substitutions: FCompilerSingleMetadataRoundTrip / FCompilerMultiMetadataRoundTrip.
 * @Provenance Oracle: compile FullyHandled with zero diagnostics; single-cast vs multicast metadata.
 * @Provenance Extra: empty carrier is null. DefaultSafe.
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
