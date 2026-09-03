/**
 * BlueprintEvent on an actor method. OnDamageReceived is a valid event
 * UFUNCTION, a default handle is null, and assigning one handle to another
 * aliases the same object.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintEventSpecifier
 * @Harness Function
 * @Tag Definitions.UFunction.BlueprintEventSpecifier
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. WorldStory: BlueprintEvent specifier.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 4 AssertCompiles.
 * @Provenance sha256=169627921c217451afa3e3dc5cdef410cb63ad927233446da504cbd7dd651d2d; lines 83-89.
 * @Provenance Oracle: AUFuncBPEventActor.OnDamageReceived() is a valid BlueprintEvent UFUNCTION.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated.
 */

class AUFuncBPEventActor : AActor
{
	/**
	 * BlueprintEvent UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(BlueprintEvent)
	void OnDamageReceived()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that OnDamageReceived can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose OnDamageReceived is invoked, runner-owned when non-null
	 * @Inputs Actor.OnDamageReceived()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int OnDamageReceivedCallCompletes(AUFuncBPEventActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.OnDamageReceived();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncBPEventActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncBPEventActor Unset;
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
		AUFuncBPEventActor First;
		AUFuncBPEventActor Second;
		First = Second;
		return First is Second;
	}
}
