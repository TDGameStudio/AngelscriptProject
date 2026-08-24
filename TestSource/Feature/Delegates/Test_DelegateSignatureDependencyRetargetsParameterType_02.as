// Theme: Feature.Delegates. HotReload version pair After (payload adds AddedValue).
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::DelegateSignatureDependencyRetargetsParameterType
// sha256 from theme-refs TS-FEAT-0248; lines 601-620.
// Oracle after full reload: Payload and Owner classes exist; Signal kept; Payload param
// retargets the reloaded class. Retained: Value and Signal. Replaced: layout now includes
// AddedValue==2. Extra: zeros; two locals independent. DefaultSafe.

UCLASS()
class UClassGeneratorPropagationSignalPayload : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
}

delegate void FClassGeneratorPropagationSignal(UClassGeneratorPropagationSignalPayload Payload);

UCLASS()
class UClassGeneratorPropagationSignalOwner : UObject
{
	UPROPERTY()
	FClassGeneratorPropagationSignal Signal;
}

int Observe_DelegatePayloadV2_DefaultValue(UClassGeneratorPropagationSignalPayload Payload)
{
	if (Payload is null)
	{
		throw("Test_DelegateSignatureDependencyRetargetsParameterType_02 setup: required Payload is null");
	}
	return Payload.Value;
}

int Observe_DelegatePayloadV2_DefaultAddedValue(UClassGeneratorPropagationSignalPayload Payload)
{
	if (Payload is null)
	{
		throw("Test_DelegateSignatureDependencyRetargetsParameterType_02 setup: required Payload is null");
	}
	return Payload.AddedValue;
}

bool Observe_DelegatePayloadV2_ZeroAndIndependence(UClassGeneratorPropagationSignalPayload First, UClassGeneratorPropagationSignalPayload Second)
{
	if (First is null)
	{
		throw("Test_DelegateSignatureDependencyRetargetsParameterType_02 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_DelegateSignatureDependencyRetargetsParameterType_02 setup: required Second is null");
	}
	First.Value = 0;
	First.AddedValue = 0;
	return First.Value == 0 && First.AddedValue == 0 && Second.Value == 1 && Second.AddedValue == 2;
}
