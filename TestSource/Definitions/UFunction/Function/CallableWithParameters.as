/**
 * BlueprintCallable with parameters. SetHealth(int, bool) is a valid
 * parameterized UFUNCTION, SetHealth(0, false) is the zero/false boundary,
 * and a default handle is null.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.CallableWithParameters
 * @Harness Function
 * @Tag Definitions.UFunction.CallableWithParameters
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. WorldStory: BlueprintCallable with parameters.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 12 AssertCompiles.
 * @Provenance sha256=4fe0fd0cddb535a2de97d03671b59fafb5514fd37eadb906523f59baa87101f7; lines 174-180.
 * @Provenance Oracle: SetHealth(int, bool) is a valid parameterized UFUNCTION.
 * @Provenance Extra: SetHealth(0, false) is the zero/false boundary; empty default handle is null.
 * @Provenance FixtureIsolated.
 */

class AUFuncParamsActor : AActor
{
	/**
	 * BlueprintCallable UFUNCTION with int and bool parameters.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param NewHealth Health value to set
	 * @Param bNotify Whether to notify listeners
	 * @Inputs NewHealth and bNotify
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void SetHealth(int NewHealth, bool bNotify)
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that SetHealth can be invoked with a live value pair.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose SetHealth is invoked, runner-owned when non-null
	 * @Inputs Actor.SetHealth(100, true)
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int SetHealthCallCompletes(AUFuncParamsActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.SetHealth(100, true);
		return 0;
	}

	/**
	 * Observe the zero/false boundary of SetHealth.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose SetHealth is invoked, runner-owned when non-null
	 * @Inputs Actor.SetHealth(0, false)
	 * @Return 0 when the call completes; -1 when Actor is null
	 * @Boundary zero health and false notify
	 */
	UFUNCTION()
	int SetHealthZeroFalseBoundary(AUFuncParamsActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.SetHealth(0, false);
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncParamsActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncParamsActor Unset;
		if (Unset == nullptr)
		{
			return 1;
		}
		return 0;
	}
}
