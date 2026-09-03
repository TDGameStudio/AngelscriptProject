/**
 * An unnamed UFUNCTION parameter is valid. Foo(int) compiles without a
 * parameter name, Foo(0) is the zero boundary, and a default handle is null.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UnnamedParameter
 * @Harness Function
 * @Tag Definitions.UFunction.UnnamedParameter
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. WorldStory: unnamed UFUNCTION parameter is valid.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_UnnamedParameter AssertCompiles.
 * @Provenance sha256=8ac274b1c8f3d998b5c4fbb6839c9c683da51194a65b6e4a9f7c5f8bdc354a89; lines 366-372.
 * @Provenance Oracle: AUFuncPNoNameActor.Foo(int) compiles without a parameter name.
 * @Provenance Extra: Foo(0) is the zero boundary; empty default handle is null.
 * @Provenance FixtureIsolated.
 */

class AUFuncPNoNameActor : AActor
{
	/**
	 * UFUNCTION whose parameter has a type but no name.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs an unnamed int
	 * @Return void
	 */
	UFUNCTION()
	void Foo(int)
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that Foo can be invoked with a named value.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Actor Actor whose Foo is invoked, runner-owned when non-null
	 * @Inputs Actor.Foo(7)
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int UnnamedParamCallCompletes(AUFuncPNoNameActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.Foo(7);
		return 0;
	}

	/**
	 * Observe the zero boundary of the unnamed parameter.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Actor Actor whose Foo is invoked, runner-owned when non-null
	 * @Inputs Actor.Foo(0)
	 * @Return 0 when the call completes; -1 when Actor is null
	 * @Boundary zero argument
	 */
	UFUNCTION()
	int UnnamedParamZeroBoundary(AUFuncPNoNameActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.Foo(0);
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a default-constructed AUFuncPNoNameActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncPNoNameActor Unset;
		if (Unset == nullptr)
		{
			return 1;
		}
		return 0;
	}
}
