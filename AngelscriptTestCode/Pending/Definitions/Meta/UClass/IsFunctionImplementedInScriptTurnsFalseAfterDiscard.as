/**
 * @version v1
 * @summary A generated script function exists before C++ discards the module. ComputeValue returns 7. The observers cover the nominal return, a repeated call and copy independence.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A generated script function exists before C++ discards the module. ComputeValue returns 7. The observers cover the nominal return, a repeated call and copy independence.
 * @topic Baseline
 */
UCLASS()
class UMetadataDiscardCarrier : UObject
{
	/**
	 * Return the constant that C++ records before discarding the module.
	 *
	 * @Kind Observe
	 * @Covers Meta.IsFunctionImplementedInScriptTurnsFalseAfterDiscard
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int ComputeValue()
	{
		return 7;
	}

	/**
	 * Observe that ComputeValue reports 7.
	 *
	 * @Kind Observe
	 * @Covers Meta.IsFunctionImplementedInScriptTurnsFalseAfterDiscard
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int ComputeValueNominal()
	{
		return ComputeValue();
	}

	/**
	 * Observe that repeating ComputeValue is stable.
	 *
	 * @Kind Observe
	 * @Covers Meta.IsFunctionImplementedInScriptTurnsFalseAfterDiscard
	 * @Inputs none
	 * @Return true when both calls report 7
	 * @Boundary repeated call
	 */
	UFUNCTION()
	bool RepeatCall()
	{
		if (ComputeValue() != 7)
		{
			return false;
		}
		return ComputeValue() == 7;
	}

	/**
	 * Observe that two carriers are distinct and both report 7.
	 *
	 * @Kind Observe
	 * @Covers Meta.IsFunctionImplementedInScriptTurnsFalseAfterDiscard
	 * @Inputs a second carrier
	 * @Return true when both report 7 and the handles differ
	 * @Param Second the other carrier
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UMetadataDiscardCarrier Second)
	{
		if (Second is null)
		{
			throw("IsFunctionImplementedInScriptTurnsFalseAfterDiscard setup: required Second is null");
		}
		if (ComputeValue() != 7)
		{
			return false;
		}
		if (Second.ComputeValue() != 7)
		{
			return false;
		}
		return !(this is Second);
	}
}
/** @end */
