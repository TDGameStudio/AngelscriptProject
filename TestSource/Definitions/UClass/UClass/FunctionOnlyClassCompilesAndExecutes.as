/**
 * A function-only UObject with no user properties. GetValue returns 17;
 * C++ counts 0 declared user properties.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.FunctionOnlyClassCompilesAndExecutes
 * @Harness UClass
 * @Tag Definitions.UClass.FunctionOnlyClassCompilesAndExecutes
 * @Provenance Theme: Definitions.UClass. Positive function-only UObject, no user properties.
 * @Provenance C++: AngelscriptScriptClassStructureTests.cpp::FunctionOnlyClassCompilesAndExecutes
 * @Provenance Oracle: GetValue returns 17; 0 declared user properties.
 * @Provenance Extra: nullptr handle is the empty vector; repeating GetValue is stable.
 * @Provenance DefaultSafe.
 */

UCLASS()
class UFunctionOnlyScriptClass : UObject
{
	/**
	 * Observe GetValue: it returns 17.
	 *
	 * @Kind Observe
	 * @Covers UClass.FunctionOnly
	 * @Inputs none
	 * @Return 17
	 */
	UFUNCTION()
	int GetValue()
	{
		return 17;
	}

	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.FunctionOnly
	 * @Inputs UFunctionOnlyScriptClass Object = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UFunctionOnlyScriptClass Object = nullptr;
		return Object == nullptr;
	}

	/**
	 * Observe that repeating GetValue is stable.
	 *
	 * @Kind Observe
	 * @Covers UClass.FunctionOnly
	 * @Inputs two GetValue calls
	 * @Return true when both calls return 17
	 */
	UFUNCTION()
	bool RepeatCall()
	{
		int First = GetValue();
		int Second = GetValue();
		if (First != 17)
		{
			return false;
		}
		return Second == 17;
	}
}
