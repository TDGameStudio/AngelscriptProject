/**
 * @version v1
 * @summary Server WithValidation caches the companion validate function. Validate(0) is true and Validate(-1) is false.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Server WithValidation caches the companion validate function. Validate(0) is true and Validate(-1) is false.
 * @topic Baseline
 */
UCLASS()
class AASFunctionNetValidateCache : AActor
{
	/**
	 * Server RPC whose companion validate function is cached.
	 *
	 * @Kind Observe
	 * @Covers Meta.NetValidateCachesValidateFunction
	 * @Inputs the replicated value
	 * @Return nothing
	 * @Param Value the replicated value
	 */
	UFUNCTION(Server, WithValidation)
	void Server_SetValue(int Value)
	{
	}

	/**
	 * Companion validate: Value must be non-negative.
	 *
	 * @Kind Observe
	 * @Covers Meta.NetValidateCachesValidateFunction
	 * @Inputs the replicated value
	 * @Return true when Value >= 0
	 * @Param Value the replicated value
	 */
	UFUNCTION()
	bool Server_SetValue_Validate(int Value)
	{
		return Value >= 0;
	}

	/**
	 * Observe that Validate(0) is true.
	 *
	 * @Kind Observe
	 * @Covers Meta.NetValidateCachesValidateFunction
	 * @Inputs none
	 * @Return true
	 * @Boundary zero
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		return Server_SetValue_Validate(0);
	}

	/**
	 * Observe that Validate(-1) is false.
	 *
	 * @Kind Observe
	 * @Covers Meta.NetValidateCachesValidateFunction
	 * @Inputs none
	 * @Return false
	 * @Boundary negative
	 */
	UFUNCTION()
	bool NegativeBoundary()
	{
		return Server_SetValue_Validate(-1);
	}

	/**
	 * Observe that Validate(12) is true.
	 *
	 * @Kind Observe
	 * @Covers Meta.NetValidateCachesValidateFunction
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool PositiveNominal()
	{
		return Server_SetValue_Validate(12);
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.NetValidateCachesValidateFunction
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		AASFunctionNetValidateCache Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
