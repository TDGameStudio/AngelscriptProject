/**
 * DefaultComponent declaration of a root, an attached child and a plain logic
 * component. C++ verifies the four outcome flags by path. All flags stay false
 * until BeginPlay runs.
 *
 * @Theme World.Component
 * @Subject Component.BasicDeclaration
 * @Harness UClass
 * @Tag World.Component.ComponentBasicDeclaration
 * @Provenance Theme: World.Component. WorldStory: DefaultComponent Root/Child/LogicComponent declaration.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::ComponentBasicDeclaration
 * @Provenance Oracle: VerifyByPath RootIsValid, ChildIsValid, LogicComponentIsValid, ChildIsAttached true.
 * @Provenance Extra: all validity flags default false until BeginPlay. Do not spawn from script. FixtureIsolated.
 */

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

	/**
	 * WorldStory: BeginPlay records that all three components exist and that the
	 * child really is attached to the root.
	 *
	 * @Kind WorldStory
	 * @Covers Component.BasicDeclaration
	 * @Inputs three default components
	 * @Return all four flags true
	 */
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
