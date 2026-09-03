/**
 * Client on an actor method. ClientReceiveData is a valid Client UFUNCTION, a
 * default handle is null, and assigning one handle to another aliases the
 * same object.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ClientSpecifier
 * @Harness Function
 * @Tag Definitions.UFunction.ClientSpecifier
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. WorldStory: Client specifier.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 9 AssertCompiles.
 * @Provenance sha256=cb665a04f043fdd47d43547a8a18bee313d623be5ba8513f943d50ac86cff497; lines 141-147.
 * @Provenance Oracle: AUFuncClientActor.ClientReceiveData() is a valid Client UFUNCTION.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated.
 */

class AUFuncClientActor : AActor
{
	/**
	 * Client UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(Client)
	void ClientReceiveData()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that ClientReceiveData can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose ClientReceiveData is invoked, runner-owned when non-null
	 * @Inputs Actor.ClientReceiveData()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int ClientReceiveDataCallCompletes(AUFuncClientActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.ClientReceiveData();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncClientActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncClientActor Unset;
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
		AUFuncClientActor First;
		AUFuncClientActor Second;
		First = Second;
		return First is Second;
	}
}
