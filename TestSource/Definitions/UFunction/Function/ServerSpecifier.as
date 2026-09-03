/**
 * Server on an actor method. ServerDoAction is a valid Server UFUNCTION, a
 * default handle is null, and assigning one handle to another aliases the
 * same object.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ServerSpecifier
 * @Harness Function
 * @Tag Definitions.UFunction.ServerSpecifier
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. WorldStory: Server specifier.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 8 AssertCompiles.
 * @Provenance sha256=b39eecc8662abbcc9fe6ee3640fc0991aecd23654a15a6db24ffae72c7cfd7ac; lines 130-136.
 * @Provenance Oracle: AUFuncServerActor.ServerDoAction() is a valid Server UFUNCTION.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated.
 */

class AUFuncServerActor : AActor
{
	/**
	 * Server UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(Server)
	void ServerDoAction()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that ServerDoAction can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose ServerDoAction is invoked, runner-owned when non-null
	 * @Inputs Actor.ServerDoAction()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int ServerDoActionCallCompletes(AUFuncServerActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.ServerDoAction();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncServerActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncServerActor Unset;
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
		AUFuncServerActor First;
		AUFuncServerActor Second;
		First = Second;
		return First is Second;
	}
}
