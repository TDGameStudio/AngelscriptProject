/**
 * Multi-level script inheritance plus a Blueprint child CDO. C++ verifies
 * GrandParentValue==100, GetGrandParentValue()==100, GetParentValue()==200 and
 * child BeginPlay writes BeginPlayChain==10 (no Super).
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.MultiLevelScriptInheritance
 * @Harness UClass
 * @Tag Feature.Inheritance.MultiLevelScriptInheritance
 * @Provenance Theme: Feature.Inheritance. WorldStory multi-level script inheritance + BP child CDO.
 * @Provenance C++: AngelscriptBlueprintChildTests.cpp::MultiLevelScriptInheritance
 * @Provenance Oracle: GrandParentValue==100; GetGrandParentValue()==100; GetParentValue()==200;
 * @Provenance child BeginPlay writes BeginPlayChain==10 (no Super).
 * @Provenance Extra: empty handle null; default BeginPlayChain 0. FixtureIsolated.
 * @Provenance Keep GrandParentValue/BeginPlayChain/ParentValue.
 */

UCLASS()
class ATestBPMultiLevelGrandParent : AActor
{
	UPROPERTY()
	int GrandParentValue = 100;

	UPROPERTY()
	int BeginPlayChain = 0;

	/**
	 * WorldStory: grandparent BeginPlay adds 1 to BeginPlayChain.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelScriptInheritance
	 * @Inputs none
	 * @Return BeginPlayChain += 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayChain += 1;
	}

	/**
	 * Return the grandparent value a child must still see.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MultiLevelScriptInheritance
	 * @Inputs none
	 * @Return GrandParentValue, expected to be 100
	 */
	UFUNCTION()
	int GetGrandParentValue()
	{
		return GrandParentValue;
	}
}

UCLASS()
class ATestBPMultiLevelParent : ATestBPMultiLevelGrandParent
{
	UPROPERTY()
	int ParentValue = 200;

	/**
	 * WorldStory: parent BeginPlay adds 10 and does not call Super.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.MultiLevelScriptInheritance
	 * @Inputs none
	 * @Return BeginPlayChain += 10
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayChain += 10;
	}

	/**
	 * Return the parent value a Blueprint child must still see.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MultiLevelScriptInheritance
	 * @Inputs none
	 * @Return ParentValue, expected to be 200
	 */
	UFUNCTION()
	int GetParentValue()
	{
		return ParentValue;
	}

	/**
	 * Observe BeginPlayChain before the world has begun play.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MultiLevelScriptInheritance
	 * @Inputs an actor that has not begun play
	 * @Return BeginPlayChain, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int BeginPlayChainBefore()
	{
		return BeginPlayChain;
	}

	/**
	 * Observe BeginPlayChain after the world has begun play.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MultiLevelScriptInheritance
	 * @Inputs an actor whose BeginPlay has run
	 * @Return BeginPlayChain, expected to be 10
	 */
	UFUNCTION()
	int BeginPlayChainAfter()
	{
		return BeginPlayChain;
	}

	/**
	 * Observe that writing values on this instance leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MultiLevelScriptInheritance
	 * @Inputs this actor plus a second actor
	 * @Return true when the other stays GrandParentValue 100 and ParentValue 200
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestBPMultiLevelParent Second)
	{
		if (Second == nullptr)
		{
			throw("MultiLevelScriptInheritance setup: required Second is null");
		}
		GrandParentValue = 0;
		ParentValue = 0;
		if (Second.GrandParentValue != 100)
		{
			return false;
		}
		return Second.ParentValue == 200;
	}
}
