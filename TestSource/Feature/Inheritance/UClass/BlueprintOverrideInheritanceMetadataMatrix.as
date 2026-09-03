/**
 * BlueprintOverride metadata plus virtual dispatch. C++ verifies
 * DecoratedCompute(20,"direct")==30, DispatchDecoratedCompute(32,"dispatch")==42,
 * BaseCallCount==0, ChildCallCount==2 and LastLabel=="dispatch:child". The parent
 * body stays unused.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.BlueprintOverrideInheritanceMetadataMatrix
 * @Harness UClass
 * @Tag Feature.Inheritance.BlueprintOverrideInheritanceMetadataMatrix
 * @Provenance Theme: Feature.Inheritance. WorldStory BlueprintOverride metadata + virtual dispatch.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintOverrideInheritanceMetadataMatrix
 * @Provenance Oracle: DecoratedCompute(20,"direct")==30; DispatchDecoratedCompute(32,"dispatch")==42;
 * @Provenance BaseCallCount==0, ChildCallCount==2, LastLabel=="dispatch:child".
 * @Provenance Extra: empty handle null; empty Label; parent body stays unused.
 * @Provenance FixtureIsolated. Keep BaseCallCount/ChildCallCount/LastLabel.
 */

UCLASS()
class ACoverageUFunctionMetadataBase : AActor
{
	UPROPERTY()
	int BaseCallCount = 0;

	UPROPERTY()
	int ChildCallCount = 0;

	UPROPERTY()
	FString LastLabel;

	/**
	 * Parent BlueprintEvent whose metadata is copied onto the override.
	 *
	 * @Kind Action
	 * @Covers Inheritance.BlueprintOverrideInheritanceMetadataMatrix
	 * @Inputs Value and Label
	 * @Return Value + 1 when the parent body runs
	 * @Param Value the compute input
	 * @Param Label stored on LastLabel
	 */
	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|Override", meta=(DisplayName="Decorated Compute", Keywords="coverage override metadata", AdvancedDisplay="Label", ToolTip="Parent metadata copied to override"))
	int DecoratedCompute(int Value, FString Label)
	{
		BaseCallCount += 1;
		LastLabel = Label;
		return Value + 1;
	}

	/**
	 * Dispatch through the virtual DecoratedCompute so the child override is hit.
	 *
	 * @Kind Action
	 * @Covers Inheritance.BlueprintOverrideInheritanceMetadataMatrix
	 * @Inputs Value and Label
	 * @Return DecoratedCompute(Value, Label)
	 * @Param Value the compute input
	 * @Param Label forwarded to DecoratedCompute
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Override")
	int DispatchDecoratedCompute(int Value, FString Label)
	{
		return DecoratedCompute(Value, Label);
	}
}

UCLASS()
class ACoverageUFunctionMetadataChild : ACoverageUFunctionMetadataBase
{
	/**
	 * Child BlueprintOverride that replaces the parent body.
	 *
	 * @Kind Action
	 * @Covers Inheritance.BlueprintOverrideInheritanceMetadataMatrix
	 * @Inputs Value and Label
	 * @Return Value + 10; LastLabel becomes Label + ":child"
	 * @Param Value the compute input
	 * @Param Label stored with a :child suffix
	 */
	UFUNCTION(BlueprintOverride)
	int DecoratedCompute(int Value, FString Label)
	{
		ChildCallCount += 1;
		LastLabel = Label + ":child";
		return Value + 10;
	}

	/**
	 * Observe a direct child DecoratedCompute(20, "direct").
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideInheritanceMetadataMatrix
	 * @Inputs DecoratedCompute(20, "direct")
	 * @Return 30
	 */
	UFUNCTION()
	int DirectChild()
	{
		return DecoratedCompute(20, "direct");
	}

	/**
	 * Observe DispatchDecoratedCompute(32, "dispatch") hitting the child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideInheritanceMetadataMatrix
	 * @Inputs DispatchDecoratedCompute(32, "dispatch")
	 * @Return 42
	 */
	UFUNCTION()
	int DispatchChild()
	{
		return DispatchDecoratedCompute(32, "dispatch");
	}

	/**
	 * Observe that two child dispatches leave BaseCallCount at 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideInheritanceMetadataMatrix
	 * @Inputs DecoratedCompute(20, "direct") then DispatchDecoratedCompute(32, "dispatch")
	 * @Return true when BaseCallCount is 0, ChildCallCount is 2 and LastLabel is "dispatch:child"
	 */
	UFUNCTION()
	bool DispatchState()
	{
		DecoratedCompute(20, "direct");
		DispatchDecoratedCompute(32, "dispatch");
		if (BaseCallCount != 0)
		{
			return false;
		}
		if (ChildCallCount != 2)
		{
			return false;
		}
		return LastLabel == "dispatch:child";
	}

	/**
	 * Observe DecoratedCompute with an empty Label.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideInheritanceMetadataMatrix
	 * @Inputs DecoratedCompute(0, "")
	 * @Return LastLabel, expected to be ":child"
	 * @Boundary empty label
	 */
	UFUNCTION()
	FString EmptyLabelBoundary()
	{
		DecoratedCompute(0, "");
		return LastLabel;
	}
}
