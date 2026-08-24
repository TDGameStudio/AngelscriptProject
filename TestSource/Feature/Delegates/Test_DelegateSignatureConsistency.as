// Theme: Feature.Delegates. Positive single-cast vs multicast signature consistency.
// C++: AngelscriptCompilerEndToEndTests.cpp::DelegateSignatureConsistency
// Oracle: FCompilerSingleCastSignature is not multicast; FCompilerMultiCastSignature is multicast.
// Extra: empty carrier is null. DefaultSafe.

delegate void FCompilerSingleCastSignature(int Value);
event void FCompilerMultiCastSignature(UClass TypeValue, FString Label);

UCLASS()
class UCompilerDelegateCarrier : UObject
{
}

bool Observe_SignatureCarrier_EmptyDefaultIsNull()
{
	UCompilerDelegateCarrier Carrier;
	return Carrier == nullptr;
}
