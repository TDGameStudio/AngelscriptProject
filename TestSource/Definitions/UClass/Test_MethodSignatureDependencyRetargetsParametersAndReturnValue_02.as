// Theme: Definitions.UClass. Reload version pair 02 (payload layout change). Positive method-signature dependency.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::MethodSignatureDependencyRetargetsParametersAndReturnValue ReloadSource.
// Oracle: Echo still returns the same Payload handle; AddedValue defaults to 2.
// Retained: Payload/SignatureUser types, Echo, Value. Replaced: Payload.AddedValue = 2.
// Extra: Echo(nullptr) stays nullptr; mutating AddedValue on one payload does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationPayload : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
}

UCLASS()
class UClassGeneratorPropagationSignatureUser : UObject
{
	UFUNCTION()
	UClassGeneratorPropagationPayload Echo(UClassGeneratorPropagationPayload Payload)
	{
		return Payload;
	}
}

UClassGeneratorPropagationPayload Observe_SignatureReload_EchoIdentity(UClassGeneratorPropagationSignatureUser User, UClassGeneratorPropagationPayload Payload)
{
	return User.Echo(Payload);
}

UClassGeneratorPropagationPayload Observe_SignatureReload_EchoNullDefault(UClassGeneratorPropagationSignatureUser User)
{
	return User.Echo(nullptr);
}

int Observe_SignatureReload_AddedValueDefault(UClassGeneratorPropagationPayload Payload)
{
	return Payload.AddedValue;
}

bool Observe_SignatureReload_CopyIndependent(UClassGeneratorPropagationPayload First, UClassGeneratorPropagationPayload Second)
{
	First.AddedValue = 0;
	return Second.AddedValue == 2;
}
