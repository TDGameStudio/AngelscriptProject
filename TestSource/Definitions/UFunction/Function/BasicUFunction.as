/**
 * A basic UFUNCTION() on an actor method. DoSomething is a valid empty
 * method, a default handle is null, and assigning one handle to another
 * aliases the same object.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BasicUFunction
 * @Harness Function
 * @Tag Definitions.UFunction.BasicUFunction
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. WorldStory: basic UFUNCTION() on an actor method.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 1 AssertCompiles.
 * @Provenance sha256=a7be9bc20fe5596a379bf95f5299c4fc1a2ac874cbae7346a4d07851c88e2926; lines 50-56.
 * @Provenance Oracle: AUFuncBasicActor.DoSomething() is a valid empty UFUNCTION.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated.
 */

class AUFuncBasicActor : AActor
{
	/**
	 * Empty UFUNCTION used to prove the specifier compiles and is callable.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION()
	void DoSomething()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that DoSomething can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose DoSomething is invoked, runner-owned when non-null
	 * @Inputs Actor.DoSomething()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int DoSomethingCallCompletes(AUFuncBasicActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.DoSomething();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncBasicActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncBasicActor Unset;
		if (Unset == nullptr)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases the same object.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs two default handles; First = Second
	 * @Return true when First is Second
	 */
	UFUNCTION()
	bool AssignAliasesHandle()
	{
		AUFuncBasicActor First;
		AUFuncBasicActor Second;
		First = Second;
		return First is Second;
	}
}
