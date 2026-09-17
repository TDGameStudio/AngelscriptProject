/**
 * @version v1
 * @summary Raw-field access on the carrier actor. C++ invokes CheckRawFieldAccess; oracle Result==1 (Field 17 then 23, bEnabled true). Observers cover default Field and the bEnabled false return of 20.
 * @topic Feature
 */
/**
 * @version root
 * @summary Raw-field access on the carrier actor. C++ invokes CheckRawFieldAccess; oracle Result==1 (Field 17 then 23, bEnabled true). Observers cover default Field and the bEnabled false return of 20.
 * @topic Baseline
 */
#if EDITOR
UCLASS()
class AAutoAccessorRawFieldScriptActor : AAngelscriptPropertyAccessorCarrier
{
	/**
	 * WorldStory: Field starts at 17, bEnabled must be true, then Field is written to 23.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.RawFieldAccessCompilesAndRuns
	 * @Inputs Field and bEnabled on the carrier
	 * @Return 1 when Field 17 then 23 and bEnabled is true; 10/20/30 on the matching guard
	 */
	UFUNCTION()
	int32 CheckRawFieldAccess()
	{
		if (Field != 17)
		{
			return 10;
		}
		if (!bEnabled)
		{
			return 20;
		}

		Field = 23;
		if (Field != 23)
		{
			return 30;
		}

		return 1;
	}

	/**
	 * Observe the raw-field path when Field and bEnabled are the carrier defaults.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.RawFieldAccessCompilesAndRuns
	 * @Inputs Field 17 and bEnabled true
	 * @Return CheckRawFieldAccess()
	 */
	UFUNCTION()
	int RawFieldAccessNominal()
	{
		return CheckRawFieldAccess();
	}

	/**
	 * Observe the default Field without writing it.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.RawFieldAccessCompilesAndRuns
	 * @Inputs Field at its carrier default
	 * @Return Field
	 * @Boundary default Field
	 */
	UFUNCTION()
	int RawFieldAccess_DefaultField()
	{
		return Field;
	}

	/**
	 * Observe the bEnabled false guard.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.RawFieldAccessCompilesAndRuns
	 * @Inputs bEnabled written to false
	 * @Return 20 from the disabled guard
	 * @Boundary bEnabled false
	 */
	UFUNCTION()
	int RawFieldAccess_DisabledBoundary()
	{
		bEnabled = false;
		return CheckRawFieldAccess();
	}
}
#endif
/** @end */
