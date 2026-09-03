/**
 * A final AActor subclass. The modifier must yield a valid type whose handle is
 * null until assigned and aliases correctly when copied.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FinalActorSubclass
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.FinalActorSubclass
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 8 AssertCompiles.
 * @Provenance sha256=2c453367cc12e334400fb5e738ff0f4fbbecde0937b542f33d2035f08f76a248; lines 111-113.
 * @Provenance Oracle: AFinalClassActor : AActor final is a valid type.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated.
 */

class AFinalClassActor : AActor final
{
	/**
	 * Observe that the final class is still an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AFinalClassActor handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int FinalActorIsAnActor()
	{
		AFinalClassActor Actor;
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
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AFinalClassActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int FinalActorDefaultsToNull()
	{
		AFinalClassActor Unset;
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
	 * @Covers Syntax.EdgeCases
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool FinalActorAssignAliases()
	{
		AFinalClassActor First;
		AFinalClassActor Second;
		First = Second;
		return First is Second;
	}
}
