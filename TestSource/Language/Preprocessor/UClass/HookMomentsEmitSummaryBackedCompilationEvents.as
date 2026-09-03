/**
 * A fixture for the ProcessChunks and PostProcessCode compilation events: one
 * class, one property and one function, so the events fire with a summary that
 * describes exactly those. The observers confirm the accessor default and that
 * an assignment is visible through it.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.HookMomentsEmitSummaryBackedCompilationEvents
 * @Harness UClass
 * @Tag Language.Preprocessor.HookMomentsEmitSummaryBackedCompilationEvents
 * @Provenance C++: AngelscriptPreprocessorCompilationEventsTests.cpp::HookMomentsEmitSummaryBackedCompilationEvents
 * @Provenance lines 53-66;
 * @Provenance sha256=224a5135d0ac5cb3b28e77d4ab05564452a86af3709e37a6c8d7f249aeaea6ed.
 * @Provenance Oracle: Entry() returns Value. Default Value is 0. Assigned Value writes back.
 * @Provenance Extra: default zero Value; non-zero assignment is the boundary.
 * @Provenance DefaultSafe. Keep UPROPERTY name Value.
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
