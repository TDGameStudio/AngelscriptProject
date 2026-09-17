/**
 * @version v1
 * @summary RPCs with typed parameters and a validation companion. C++ compiles the class and checks the signatures, so those names are part of the contract and are kept verbatim. The observers cover negative damage, a null target.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary RPCs with typed parameters and a validation companion. C++ compiles the class and checks the signatures, so those names are part of the contract and are kept verbatim. The observers cover negative damage, a null target.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingRPCParamsActor : AActor
{
	default SetReplicates(true);

	/**
	 * Server RPC taking one integer.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCWithParameters
	 * @Inputs an integer value
	 * @Return nothing; the declaration is the contract
	 * @Param Value the integer payload
	 */
	UFUNCTION(Server)
	void ServerActionWithInt(int Value)
	{
	}

	/**
	 * Server RPC taking an integer, a rate and a location.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCWithParameters
	 * @Inputs an integer, a rate and a location
	 * @Return nothing; the declaration is the contract
	 * @Param Value the integer payload
	 * @Param Rate the rate payload
	 * @Param Location the location payload
	 */
	UFUNCTION(Server)
	void ServerActionWithMultipleParams(int Value, float Rate, FVector Location)
	{
	}

	/**
	 * Client RPC taking a string message.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCWithParameters
	 * @Inputs a message string
	 * @Return nothing; the declaration is the contract
	 * @Param Message the string payload
	 */
	UFUNCTION(Client)
	void ClientNotifyWithString(FString Message)
	{
	}

	/**
	 * Unreliable NetMulticast RPC taking a location and a rotation.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCWithParameters
	 * @Inputs a location and a rotation
	 * @Return nothing; the declaration is the contract
	 * @Param Location the location payload
	 * @Param Rotation the rotation payload
	 */
	UFUNCTION(NetMulticast, Unreliable)
	void MulticastEventWithLocation(FVector Location, FRotator Rotation)
	{
	}

	/**
	 * Server WithValidation RPC taking damage and a target.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCWithParameters
	 * @Inputs a damage value and a target actor
	 * @Return nothing; the declaration is the contract
	 * @Param Damage the damage payload
	 * @Param Target the target actor
	 */
	UFUNCTION(Server, WithValidation)
	void ServerValidatedWithParams(int Damage, AActor Target)
	{
	}

	/**
	 * Validation companion that accepts non-negative damage and a non-null target.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCWithParameters
	 * @Inputs a damage value and a target actor
	 * @Return true when Damage is >= 0 and Target is non-null
	 * @Param Damage the damage payload
	 * @Param Target the target actor
	 */
	UFUNCTION()
	bool ServerValidatedWithParams_Validate(int Damage, AActor Target)
	{
		if (Damage < 0)
		{
			return false;
		}
		return Target != nullptr;
	}

	/**
	 * Observe that negative damage with a null target is refused.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCWithParameters
	 * @Inputs damage -1 and a null target
	 * @Return true when Validate returns false
	 * @Boundary negative damage
	 */
	UFUNCTION()
	bool ValidateNegativeDamage()
	{
		return ServerValidatedWithParams_Validate(-1, nullptr) == false;
	}

	/**
	 * Observe that zero damage with a null target is refused.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCWithParameters
	 * @Inputs damage 0 and a null target
	 * @Return true when Validate returns false
	 * @Boundary null target
	 */
	UFUNCTION()
	bool ValidateNullTargetBoundary()
	{
		return ServerValidatedWithParams_Validate(0, nullptr) == false;
	}

	/**
	 * Observe that empty location and empty string payloads are accepted as calls.
	 *
	 * @Kind Observe
	 * @Covers Net.RPCWithParameters
	 * @Inputs zero location and an empty string
	 * @Return true after the empty-payload calls
	 * @Boundary empty location and string
	 */
	UFUNCTION()
	bool EmptyLocationDefault()
	{
		ServerActionWithMultipleParams(0, 0.0f, FVector::ZeroVector);
		ClientNotifyWithString("");
		return true;
	}
}
/** @end */
