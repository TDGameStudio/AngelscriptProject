/**
 * @version v1
 * @summary Server/Client/NetMulticast reliability and WithValidation. Runtime oracle lives on ServerValidatedReliable_Validate. Validate(0) is true. Validate(-1) is false. RPC bodies are empty and leave no state.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Server/Client/NetMulticast reliability and WithValidation. Runtime oracle lives on ServerValidatedReliable_Validate. Validate(0) is true. Validate(-1) is false. RPC bodies are empty and leave no state.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionNetworkActor : AActor
{
	default SetReplicates(true);

	/**
	 * Empty reliable Server RPC used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(Server)
	void ServerReliableDefault()
	{
	}

	/**
	 * Empty unreliable Server RPC used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(Server, Unreliable)
	void ServerUnreliableExplicit()
	{
	}

	/**
	 * Empty reliable Client RPC used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(Client)
	void ClientReliableDefault()
	{
	}

	/**
	 * Empty unreliable Client RPC used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(Client, Unreliable)
	void ClientUnreliableExplicit()
	{
	}

	/**
	 * Empty reliable NetMulticast RPC used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(NetMulticast)
	void MulticastReliableExplicit()
	{
	}

	/**
	 * Empty unreliable NetMulticast RPC used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(NetMulticast, Unreliable)
	void MulticastUnreliableExplicit()
	{
	}

	/**
	 * Empty Server WithValidation RPC whose companion is ServerValidatedReliable_Validate.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Validated non-negative payload
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION(Server, WithValidation)
	void ServerValidatedReliable(int Value)
	{
	}

	/**
	 * Validate Value >= 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Must be non-negative
	 * @Inputs Value
	 * @Return true when Value >= 0
	 */
	UFUNCTION()
	bool ServerValidatedReliable_Validate(int Value)
	{
		return Value >= 0;
	}

	/**
	 * Observe ServerValidatedReliable_Validate(0).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ServerValidatedReliable_Validate(0)
	 * @Return true
	 * @Boundary zero Value
	 */
	UFUNCTION()
	bool NetworkFlagsValidateNonNegative()
	{
		return ServerValidatedReliable_Validate(0);
	}

	/**
	 * Observe ServerValidatedReliable_Validate(-1).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ServerValidatedReliable_Validate(-1)
	 * @Return true when validation fails
	 * @Boundary negative Value
	 */
	UFUNCTION()
	bool NetworkFlagsValidateNegativeBoundary()
	{
		return !ServerValidatedReliable_Validate(-1);
	}

	/**
	 * Observe ServerValidatedReliable_Validate(7).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ServerValidatedReliable_Validate(7)
	 * @Return true
	 */
	UFUNCTION()
	bool NetworkFlagsValidatePositive()
	{
		return ServerValidatedReliable_Validate(7);
	}
}
/** @end */
