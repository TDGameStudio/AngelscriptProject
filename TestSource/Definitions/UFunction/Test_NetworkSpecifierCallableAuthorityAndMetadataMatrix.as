// Theme: Definitions.UFunction. WorldStory: network specifiers plus callable/authority metadata.
// C++: AngelscriptCoverageUFunctionTests.cpp::NetworkSpecifierCallableAuthorityAndMetadataMatrix
// Compile + inspect FUNC_Net / BlueprintCallable / BlueprintAuthorityOnly metadata.
// Runtime oracle: ClientValidatedNotify_Validate(Value, Label).
// Extra: empty Label is false; Value 0 with non-empty Label is true; negative Value is false.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionNetworkMetaActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server, BlueprintAuthorityOnly, Category="Coverage|NetworkMeta", meta=(DisplayName="Authority Server Action", AdvancedDisplay="Reason"))
	void ServerAuthorityAction(int Value, FString Reason)
	{
	}

	UFUNCTION(Client, NotBlueprintCallable, CallInEditor, Category="Coverage|NetworkMeta")
	void ClientHiddenEditorNotify(int Value)
	{
	}

	UFUNCTION(NetMulticast, BlueprintCallable, Unreliable, Category="Coverage|NetworkMeta", meta=(Keywords="multicast unreliable"))
	void MulticastCallableUnreliable(int Value)
	{
	}

	UFUNCTION(Client, BlueprintCallable, WithValidation, Category="Coverage|NetworkMeta")
	void ClientValidatedNotify(int Value, FString Label)
	{
	}

	UFUNCTION()
	bool ClientValidatedNotify_Validate(int Value, FString Label)
	{
		return Value >= 0 && !Label.IsEmpty();
	}
}

bool Observe_NetworkMeta_ValidateNominal(ACoverageUFunctionNetworkMetaActor Actor)
{
	if (Actor is null)
	{
		throw("Test_NetworkSpecifierCallableAuthorityAndMetadataMatrix setup: required Actor is null");
	}
	return Actor.ClientValidatedNotify_Validate(0, "ok");
}

bool Observe_NetworkMeta_ValidateEmptyLabel(ACoverageUFunctionNetworkMetaActor Actor)
{
	if (Actor is null)
	{
		throw("Test_NetworkSpecifierCallableAuthorityAndMetadataMatrix setup: required Actor is null");
	}
	return !Actor.ClientValidatedNotify_Validate(0, "");
}

bool Observe_NetworkMeta_ValidateNegativeValue(ACoverageUFunctionNetworkMetaActor Actor)
{
	if (Actor is null)
	{
		throw("Test_NetworkSpecifierCallableAuthorityAndMetadataMatrix setup: required Actor is null");
	}
	return !Actor.ClientValidatedNotify_Validate(-1, "ok");
}
