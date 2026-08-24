// Theme: World.Actor. WorldStory: UserConstructionScript Product = ValueA * ValueB.
// C++: AngelscriptActorLifecycleTests.cpp::ConstructionScript
// Oracle: ConstructionCallCount 1 Product 12, then after mutating values count 2 Product 30.
// Extra: ConstructionCallCount 0 and Product 0 until construction. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorConstructionScript : AActor
{
	UPROPERTY()
	int ConstructionCallCount = 0;

	UPROPERTY()
	int ValueA = 3;

	UPROPERTY()
	int ValueB = 4;

	UPROPERTY()
	int Product = 0;

	UFUNCTION(BlueprintOverride)
	void UserConstructionScript()
	{
		ConstructionCallCount += 1;
		Product = ValueA * ValueB;
	}
}
