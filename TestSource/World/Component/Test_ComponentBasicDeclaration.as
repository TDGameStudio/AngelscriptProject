// Theme: World.Component. WorldStory: DefaultComponent Root/Child/LogicComponent declaration.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentBasicDeclaration
// Oracle: VerifyByPath RootIsValid, ChildIsValid, LogicComponentIsValid, ChildIsAttached true.
// Extra: all validity flags default false until BeginPlay. Do not spawn from script. FixtureIsolated.

UCLASS()
class UCoverageBasicLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentBasicActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child;

	UPROPERTY(DefaultComponent)
	UCoverageBasicLogicComponent LogicComponent;

	UPROPERTY()
	bool RootIsValid = false;

	UPROPERTY()
	bool ChildIsValid = false;

	UPROPERTY()
	bool ChildIsAttached = false;

	UPROPERTY()
	bool LogicComponentIsValid = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RootIsValid = (Root != nullptr);
		ChildIsValid = (Child != nullptr);
		LogicComponentIsValid = (LogicComponent != nullptr);

		if (Child != nullptr && Root != nullptr)
		{
			ChildIsAttached = Child.IsAttachedTo(Root);
		}
	}
}
