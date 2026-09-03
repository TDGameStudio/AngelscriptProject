/**
 * A Super:: call made from inside a BlueprintOverride. C++ currently wraps this
 * AssertCompiles in #if 0 because of how Super:: interacts with
 * BlueprintOverride, but the source itself is the positive fixture.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Keywords.SuperCallInBlueprintOverride
 * @Harness UClass
 * @Tag Language.Syntax.Keywords.SuperCallInBlueprintOverride
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Positive block 2 AssertCompiles.
 * @Provenance sha256=7f40fdd5ab66666a8ce5dcb2e887de710e575814354b7e6dd9d32cc1c24cc67d; lines 124-133.
 * @Provenance C++ currently wraps this AssertCompiles in #if 0 (#as-engine-behavior Super:: + BlueprintOverride).
 * @Provenance Oracle: AActorSuper is an AActor subclass. Extra: default handle is null; assigning aliases.
 * @Provenance FixtureIsolated.
 */

class AActorSuper : AActor
{
	/**
	 * Chains to the parent implementation through Super::.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
	}

	/**
	 * Observe that the handle typed as this class is usable as an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs a default-constructed AActorSuper handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int SuperHandleIsAnActor()
	{
		AActorSuper Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs an unset AActorSuper handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int SuperHandleDefaultsToNull()
	{
		AActorSuper Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool SuperHandleAssignAliases()
	{
		AActorSuper First;
		AActorSuper Second;
		First = Second;
		return First is Second;
	}
}
