/**
 * An empty AActor subclass. The class must compile and behave as an AActor, with
 * its handle null until assigned.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EmptyActorSubclass
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.EmptyActorSubclass
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 1 AssertCompiles.
 * @Provenance sha256=b2ce12b964b1e99c4b2d7d98cfc0d492edbed6c0889a80883afc7e90183797ec; lines 50-52.
 * @Provenance Oracle: AClassBasicActor is an AActor subclass; default handle is null until assigned.
 * @Provenance Extra: empty default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated.
 */

class AClassBasicActor : AActor
{
	/**
	 * Observe that the empty subclass is still an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AClassBasicActor handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int EmptySubclassIsAnActor()
	{
		AClassBasicActor Actor;
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
	 * @Inputs an unset AClassBasicActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptySubclassDefaultsToNull()
	{
		AClassBasicActor Unset;
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
	bool EmptySubclassAssignAliases()
	{
		AClassBasicActor First;
		AClassBasicActor Second;
		First = Second;
		return First is Second;
	}
}
