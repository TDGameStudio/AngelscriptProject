/**
 * A parent UPROPERTY flows to the child and GetValue override dispatches. C++
 * verifies child ParentValue==21, parent GetValue()==21 and child GetValue()==217.
 * A zero assign is copy-independent.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.ScriptInheritancePreservesParentPropertyAndOverride
 * @Harness UClass
 * @Tag Feature.Inheritance.ScriptInheritancePreservesParentPropertyAndOverride
 * @Provenance Theme: Feature.Inheritance. WorldStory parent UPROPERTY flows to child; GetValue override dispatches.
 * @Provenance C++: AngelscriptScriptClassShapeTests.cpp::ScriptInheritancePreservesParentPropertyAndOverride
 * @Provenance Oracle: child CDO/instance ParentValue==21; parent GetValue()==21; child GetValue()==217.
 * @Provenance Extra: empty handle null; ParentValue 0 mutation is copy-independent. FixtureIsolated.
 * @Provenance Keep ParentValue.
 */

UCLASS()
class ATestScriptInheritanceParent : AActor
{
	UPROPERTY()
	int ParentValue = 21;

	/**
	 * Parent BlueprintEvent that returns ParentValue.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptInheritancePreservesParentPropertyAndOverride
	 * @Inputs none
	 * @Return ParentValue, expected to be 21 on a parent instance
	 */
	UFUNCTION(BlueprintEvent)
	int GetValue()
	{
		return ParentValue;
	}

	/**
	 * Observe parent GetValue on a parent instance.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptInheritancePreservesParentPropertyAndOverride
	 * @Inputs GetValue() on a parent instance
	 * @Return GetValue(), expected to be 21
	 */
	UFUNCTION()
	int ParentGetValue()
	{
		return GetValue();
	}
}

UCLASS()
class ATestScriptInheritanceChild : ATestScriptInheritanceParent
{
	/**
	 * Child BlueprintOverride that returns ParentValue * 10 + 7.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptInheritancePreservesParentPropertyAndOverride
	 * @Inputs none
	 * @Return ParentValue * 10 + 7, expected to be 217
	 */
	UFUNCTION(BlueprintOverride)
	int GetValue()
	{
		return ParentValue * 10 + 7;
	}

	/**
	 * Observe the inherited ParentValue on the child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptInheritancePreservesParentPropertyAndOverride
	 * @Inputs a freshly constructed child
	 * @Return ParentValue, expected to be 21
	 */
	UFUNCTION()
	int InheritedParentValue()
	{
		return ParentValue;
	}

	/**
	 * Observe child GetValue dispatch.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptInheritancePreservesParentPropertyAndOverride
	 * @Inputs GetValue() on a child instance
	 * @Return GetValue(), expected to be 217
	 */
	UFUNCTION()
	int ChildGetValue()
	{
		return GetValue();
	}

	/**
	 * Observe that writing ParentValue on this child leaves another child untouched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptInheritancePreservesParentPropertyAndOverride
	 * @Inputs this child plus a second child
	 * @Return true when this GetValue is 7 and the other ParentValue stays 21
	 * @Param Second the other child, expected to stay at its default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptInheritanceChild Second)
	{
		if (Second == nullptr)
		{
			throw("ScriptInheritancePreservesParentPropertyAndOverride setup: required Second is null");
		}
		ParentValue = 0;
		if (Second.ParentValue != 21)
		{
			return false;
		}
		return GetValue() == 7;
	}
}
