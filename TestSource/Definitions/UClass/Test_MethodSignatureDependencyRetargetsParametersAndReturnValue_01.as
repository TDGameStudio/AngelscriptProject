// Theme: Definitions.UClass. Reload version pair 01 (initial). Positive method-signature dependency.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::MethodSignatureDependencyRetargetsParametersAndReturnValue InitialSource.
// Oracle: Echo returns the same Payload handle; Payload.Value defaults to 1.
// Retained after reload: Payload/SignatureUser types and Echo. Replaced in 02: Payload.AddedValue.
// Extra: Echo(nullptr) stays nullptr; mutating the echoed payload does not write a second payload.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationPayload : UObject
{
	UPROPERTY()
	int Value = 1;
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

UClassGeneratorPropagationPayload Observe_SignatureInitial_EchoIdentity(UClassGeneratorPropagationSignatureUser User, UClassGeneratorPropagationPayload Payload)
{
	return User.Echo(Payload);
}

UClassGeneratorPropagationPayload Observe_SignatureInitial_EchoNullDefault(UClassGeneratorPropagationSignatureUser User)
{
	return User.Echo(nullptr);
}

int Observe_SignatureInitial_PayloadDefaultValue(UClassGeneratorPropagationPayload Payload)
{
	return Payload.Value;
}

bool Observe_SignatureInitial_CopyIndependent(UClassGeneratorPropagationPayload First, UClassGeneratorPropagationPayload Second)
{
	First.Value = 0;
	return Second.Value == 1;
}
