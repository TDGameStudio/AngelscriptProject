/**
 * Network specifiers plus callable/authority metadata. Runtime oracle is
 * ClientValidatedNotify_Validate. Empty Label is false. Value 0 with a
 * non-empty Label is true. Negative Value is false.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.NetworkSpecifierCallableAuthorityAndMetadataMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.NetworkSpecifierCallableAuthorityAndMetadataMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: network specifiers plus callable/authority metadata.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::NetworkSpecifierCallableAuthorityAndMetadataMatrix
 * @Provenance Compile + inspect FUNC_Net / BlueprintCallable / BlueprintAuthorityOnly metadata.
 * @Provenance Runtime oracle: ClientValidatedNotify_Validate(Value, Label).
 * @Provenance Extra: empty Label is false; Value 0 with non-empty Label is true; negative Value is false.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionNetworkMetaActor : AActor
{
	default SetReplicates(true);

	/**
	 * Empty authority-only Server action used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Unused payload
	 * @Param Reason Unused advanced-display reason
	 * @Inputs Value and Reason
	 * @Return void
	 */
	UFUNCTION(Server, BlueprintAuthorityOnly, Category="Coverage|NetworkMeta", meta=(DisplayName="Authority Server Action", AdvancedDisplay="Reason"))
	void ServerAuthorityAction(int Value, FString Reason)
	{
	}

	/**
	 * Empty hidden Client+CallInEditor notify used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Unused payload
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION(Client, NotBlueprintCallable, CallInEditor, Category="Coverage|NetworkMeta")
	void ClientHiddenEditorNotify(int Value)
	{
	}

	/**
	 * Empty unreliable multicast used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Unused payload
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION(NetMulticast, BlueprintCallable, Unreliable, Category="Coverage|NetworkMeta", meta=(Keywords="multicast unreliable"))
	void MulticastCallableUnreliable(int Value)
	{
	}

	/**
	 * Empty Client WithValidation notify whose companion is ClientValidatedNotify_Validate.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Validated non-negative payload
	 * @Param Label Validated non-empty payload
	 * @Inputs Value and Label
	 * @Return void
	 */
	UFUNCTION(Client, BlueprintCallable, WithValidation, Category="Coverage|NetworkMeta")
	void ClientValidatedNotify(int Value, FString Label)
	{
	}

	/**
	 * Validate Value >= 0 and a non-empty Label.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Must be non-negative
	 * @Param Label Must be non-empty
	 * @Inputs Value and Label
	 * @Return true when Value >= 0 and Label is not empty
	 */
	UFUNCTION()
	bool ClientValidatedNotify_Validate(int Value, FString Label)
	{
		if (Value < 0)
		{
			return false;
		}
		return !Label.IsEmpty();
	}

	/**
	 * Observe ClientValidatedNotify_Validate(0, "ok").
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ClientValidatedNotify_Validate(0, "ok")
	 * @Return true
	 */
	UFUNCTION()
	bool NetworkMetaValidateNominal()
	{
		return ClientValidatedNotify_Validate(0, "ok");
	}

	/**
	 * Observe ClientValidatedNotify_Validate(0, "").
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ClientValidatedNotify_Validate(0, "")
	 * @Return true when validation fails
	 * @Boundary empty Label
	 */
	UFUNCTION()
	bool NetworkMetaValidateEmptyLabel()
	{
		return !ClientValidatedNotify_Validate(0, "");
	}

	/**
	 * Observe ClientValidatedNotify_Validate(-1, "ok").
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ClientValidatedNotify_Validate(-1, "ok")
	 * @Return true when validation fails
	 * @Boundary negative Value
	 */
	UFUNCTION()
	bool NetworkMetaValidateNegativeValue()
	{
		return !ClientValidatedNotify_Validate(-1, "ok");
	}
}
