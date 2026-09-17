/**
 * @version v1
 * @summary The WithValidation companion shares the RPC parameter list. Validate(0, 0.0, ZeroVector, live Target) is true. Damage < 0, Scale < 0 or a null Target is false.
 * @topic Definitions
 */
/**
 * @version root
 * @summary The WithValidation companion shares the RPC parameter list. Validate(0, 0.0, ZeroVector, live Target) is true. Damage < 0, Scale < 0 or a null Target is false.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingRPCValidationSignatureActor : AActor
{
	default SetReplicates(true);

	/**
	 * Server RPC whose companion validate shares this parameter list.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCValidationSignatureMetadata
	 * @Inputs damage, scale, hit location and target
	 * @Return nothing
	 * @Param Damage the damage payload
	 * @Param Scale the scale payload
	 * @Param HitLocation the hit location
	 * @Param Target the target actor
	 */
	UFUNCTION(Server, WithValidation)
	void ServerValidatedPayload(int Damage, float Scale, FVector HitLocation, AActor Target)
	{
	}

	/**
	 * Companion validate: Damage and Scale must be non-negative and Target must be live.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCValidationSignatureMetadata
	 * @Inputs damage, scale, hit location and target
	 * @Return true when Damage >= 0, Scale >= 0 and Target is not null
	 * @Param Damage the damage payload
	 * @Param Scale the scale payload
	 * @Param HitLocation the hit location
	 * @Param Target the target actor
	 */
	UFUNCTION()
	bool ServerValidatedPayload_Validate(int Damage, float Scale, FVector HitLocation, AActor Target)
	{
		if (Damage < 0)
		{
			return false;
		}
		if (Scale < 0.0f)
		{
			return false;
		}
		return Target != nullptr;
	}

	/**
	 * Observe the nominal validate with a live target.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCValidationSignatureMetadata
	 * @Inputs a live target
	 * @Return true
	 * @Param Target the live target
	 */
	UFUNCTION()
	bool ValidateNominal(AActor Target)
	{
		return ServerValidatedPayload_Validate(0, 0.0f, FVector::ZeroVector, Target);
	}

	/**
	 * Observe that negative damage fails validation.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCValidationSignatureMetadata
	 * @Inputs a live target
	 * @Return false
	 * @Param Target the live target
	 * @Boundary negative damage
	 */
	UFUNCTION()
	bool NegativeDamageBoundary(AActor Target)
	{
		return ServerValidatedPayload_Validate(-1, 1.0f, FVector::ZeroVector, Target);
	}

	/**
	 * Observe that negative scale fails validation.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCValidationSignatureMetadata
	 * @Inputs a live target
	 * @Return false
	 * @Param Target the live target
	 * @Boundary negative scale
	 */
	UFUNCTION()
	bool NegativeScaleBoundary(AActor Target)
	{
		return ServerValidatedPayload_Validate(1, -0.5f, FVector::ZeroVector, Target);
	}

	/**
	 * Observe that a null target fails validation.
	 *
	 * @Kind Observe
	 * @Covers Meta.RPCValidationSignatureMetadata
	 * @Inputs none
	 * @Return false
	 * @Boundary null target
	 */
	UFUNCTION()
	bool NullTargetBoundary()
	{
		AActor Missing;
		return ServerValidatedPayload_Validate(1, 1.0f, FVector::ZeroVector, Missing);
	}
}
/** @end */
