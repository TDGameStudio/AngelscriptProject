/**
 * @version v1
 * @summary A fixture for the ProcessChunks and PostProcessCode compilation events: one class, one property and one function, so the events fire with a summary that describes exactly those. The observers confirm the accessor default.
 * @topic Language
 */
/**
 * @version root
 * @summary A fixture for the ProcessChunks and PostProcessCode compilation events: one class, one property and one function, so the events fire with a summary that describes exactly those. The observers confirm the accessor default.
 * @topic Baseline
 */
UCLASS()
class UCompilationEventsHookMoments : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Reads back the property value.
	 *
	 * @Covers Preprocessor.Events
	 * @Inputs the carrier's Value
	 * @Return the stored value
	 */
	UFUNCTION()
	int Entry()
	{
		return Value;
	}

	/**
	 * Observe the default state of the accessor.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Events
	 * @Inputs a freshly constructed carrier
	 * @Return true when Entry reports 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool CompilationEventsValueDefaultsToZero()
	{
		return Entry() == 0;
	}

	/**
	 * Observe that an assignment writes back through the accessor.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Events
	 * @Inputs Value assigned to 5, then Entry
	 * @Return true when the accessor reports 5
	 * @Boundary assigned value
	 */
	UFUNCTION()
	bool CompilationEventsValueWritesBack()
	{
		Value = 5;
		return Entry() == 5;
	}
}
/** @end */
