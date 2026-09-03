/**
 * A Blueprint child preserves script UFUNCTION dispatch. RecordExternalCall
 * increments ScriptCallCount and stores LastCallValue. Defaults are 0, a
 * call with 77 records that value, 0 is the zero-value boundary, and a
 * second instance stays at the defaults.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ScriptUFunctionCallable
 * @Harness UClass
 * @Tag Definitions.UFunction.ScriptUFunctionCallable
 * @Provenance Theme: Definitions.UFunction. WorldStory: BP child preserves script UFUNCTION dispatch.
 * @Provenance C++: AngelscriptBlueprintChildTests.cpp::ScriptUFunctionCallable
 * @Provenance Compile parent, create BP child, InvokeIntScriptFunction RecordExternalCall(77).
 * @Provenance Oracle: ScriptCallCount == 1, LastCallValue == 77.
 * @Provenance Extra: defaults are 0; RecordExternalCall(0) is the zero-value boundary.
 * @Provenance FixtureIsolated. Keep ScriptCallCount / LastCallValue. Runner owns spawn.
 */

UCLASS()
class ATestBPChildScriptUFunctionCallableParent : AActor
{
	UPROPERTY()
	int ScriptCallCount = 0;

	UPROPERTY()
	int LastCallValue = 0;

	/**
	 * Record an external call by incrementing ScriptCallCount and storing Value.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Value stored in LastCallValue
	 * @Inputs Value
	 * @Return void; ScriptCallCount increments and LastCallValue becomes Value
	 */
	UFUNCTION()
	void RecordExternalCall(int Value)
	{
		ScriptCallCount += 1;
		LastCallValue = Value;
	}

	/**
	 * Observe that ScriptCallCount and LastCallValue start at 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed actor
	 * @Return true when both properties are 0
	 * @Boundary defaults
	 */
	UFUNCTION()
	bool RecordExternalCallDefaults()
	{
		if (ScriptCallCount != 0)
		{
			return false;
		}
		return LastCallValue == 0;
	}

	/**
	 * Observe RecordExternalCall(77) updating both properties.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs RecordExternalCall(77)
	 * @Return true when ScriptCallCount is 1 and LastCallValue is 77
	 */
	UFUNCTION()
	bool RecordExternalCallSeventySeven()
	{
		RecordExternalCall(77);
		if (ScriptCallCount != 1)
		{
			return false;
		}
		return LastCallValue == 77;
	}

	/**
	 * Observe the zero-value boundary of RecordExternalCall.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs RecordExternalCall(0)
	 * @Return true when ScriptCallCount is 1 and LastCallValue is 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	bool RecordExternalCallZeroBoundary()
	{
		RecordExternalCall(0);
		if (ScriptCallCount != 1)
		{
			return false;
		}
		return LastCallValue == 0;
	}

	/**
	 * Observe that recording on this instance leaves another at the defaults.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Other Second actor that must stay at the defaults
	 * @Inputs RecordExternalCall(77) on this compared against Other
	 * @Return true when this recorded 77 and Other stays at 0
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool RecordExternalCallIsIndependentAcrossInstances(ATestBPChildScriptUFunctionCallableParent Other)
	{
		RecordExternalCall(77);
		if (ScriptCallCount != 1)
		{
			return false;
		}
		if (LastCallValue != 77)
		{
			return false;
		}
		if (Other.ScriptCallCount != 0)
		{
			return false;
		}
		return Other.LastCallValue == 0;
	}
}
