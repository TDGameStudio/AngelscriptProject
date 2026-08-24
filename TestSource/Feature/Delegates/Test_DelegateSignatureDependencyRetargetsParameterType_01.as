// Theme: Feature.Delegates. HotReload version pair Before (payload Value only).
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::DelegateSignatureDependencyRetargetsParameterType
// sha256 from theme-refs TS-FEAT-0247; lines 583-599.
// Oracle: initial compile; Signal property exists; Payload param targets this class.
// Retained after reload: FClassGeneratorPropagationSignal and owner Signal.
// Replaced later: payload layout gains AddedValue (full reload). Extra: Value default 1;
// zero assignment; two payload locals independent. DefaultSafe.

UCLASS()
class UClassGeneratorPropagationSignalPayload : UObject
{
	UPROPERTY()
	int Value = 1;
}

delegate void FClassGeneratorPropagationSignal(UClassGeneratorPropagationSignalPayload Payload);

UCLASS()
class UClassGeneratorPropagationSignalOwner : UObject
{
	UPROPERTY()
	FClassGeneratorPropagationSignal Signal;
}

int Observe_DelegatePayloadV1_DefaultValue(UClassGeneratorPropagationSignalPayload Payload)
{
	if (Payload is null)
	{
		throw("Test_DelegateSignatureDependencyRetargetsParameterType_01 setup: required Payload is null");
	}
	return Payload.Value;
}

int Observe_DelegatePayloadV1_ZeroBoundary(UClassGeneratorPropagationSignalPayload Payload)
{
	if (Payload is null)
	{
		throw("Test_DelegateSignatureDependencyRetargetsParameterType_01 setup: required Payload is null");
	}
	Payload.Value = 0;
	return Payload.Value;
}

bool Observe_DelegateOwnerV1_DefaultUnbound(UClassGeneratorPropagationSignalOwner Owner)
{
	if (Owner is null)
	{
		throw("Test_DelegateSignatureDependencyRetargetsParameterType_01 setup: required Owner is null");
	}
	return !Owner.Signal.IsBound();
}
