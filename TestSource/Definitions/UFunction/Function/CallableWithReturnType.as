/**
 * BlueprintCallable with an int return. GetScore returns 42, a second
 * instance also returns 42, and a default handle is null.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.CallableWithReturnType
 * @Harness Function
 * @Tag Definitions.UFunction.CallableWithReturnType
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. WorldStory: BlueprintCallable with int return.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 11 AssertCompiles.
 * @Provenance sha256=d7dcd1dde07c6cfb21219a7deb74b3b69d7a29b6fd70a20986acef12d925b241; lines 163-169.
 * @Provenance Oracle: GetScore() returns 42. Extra: a second instance also returns 42;
 * @Provenance empty default handle is null.
 * @Provenance FixtureIsolated.
 */

class AUFuncReturnActor : AActor
{
	/**
	 * BlueprintCallable UFUNCTION that returns 42.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION(BlueprintCallable)
	int GetScore()
	{
		return 42;
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that GetScore returns 42 on a live actor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose GetScore is invoked, runner-owned when non-null
	 * @Inputs Actor.GetScore()
	 * @Return 42 when Actor is live; -1 when Actor is null
	 */
	UFUNCTION()
	int GetScoreReturnsFortyTwo(AUFuncReturnActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		return Actor.GetScore();
	}

	/**
	 * Observe that a second instance also returns 42.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Second Second actor whose GetScore is invoked, runner-owned when non-null
	 * @Inputs Second.GetScore() after constructing a first unused handle
	 * @Return 42 when Second is live; -1 when Second is null
	 */
	UFUNCTION()
	int SecondInstanceReturnsFortyTwo(AUFuncReturnActor Second)
	{
		if (Second == nullptr)
		{
			return -1;
		}
		AUFuncReturnActor First;
		return Second.GetScore();
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncReturnActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncReturnActor Unset;
		if (Unset == nullptr)
		{
			return 1;
		}
		return 0;
	}
}
