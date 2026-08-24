// Theme: Feature.Delegates. Positive delegate/event signature metadata round-trip.
// C++: AngelscriptCompilerDelegateTests.cpp::DelegateSignatureMetadataRoundTrip
// $ARG substitutions: FCompilerSingleMetadataRoundTrip / FCompilerMultiMetadataRoundTrip.
// Oracle: compile FullyHandled with zero diagnostics; single-cast vs multicast metadata.
// Extra: empty carrier is null. DefaultSafe.

delegate void FCompilerSingleMetadataRoundTrip(int Value);
event void FCompilerMultiMetadataRoundTrip(UClass TypeValue, FString Label);

UCLASS()
class UCompilerDelegateMetadataCarrier : UObject
{
}

bool Observe_MetadataCarrier_EmptyDefaultIsNull()
{
	UCompilerDelegateMetadataCarrier Carrier;
	return Carrier == nullptr;
}
