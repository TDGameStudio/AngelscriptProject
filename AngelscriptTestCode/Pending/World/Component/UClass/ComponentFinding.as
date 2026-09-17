/**
 * @version v1
 * @summary GetComponentByClass and GetComponentsByClass over a root, two attached scene children and one plain logic component. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this actor and verifies the results by.
 * @topic World
 */
/**
 * @version root
 * @summary GetComponentByClass and GetComponentsByClass over a root, two attached scene children and one plain logic component. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this actor and verifies the results by.
 * @topic Baseline
 */
UCLASS()
class UCoverageFindingLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentFindingActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child1;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child2;

	UPROPERTY(DefaultComponent)
	UCoverageFindingLogicComponent LogicComp;

	UPROPERTY()
	bool FoundSingleComponent = false;

	UPROPERTY()
	int SceneComponentCount = 0;

	/**
	 * WorldStory: BeginPlay resolves one arbitrary component and counts the scene
	 * components.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Finding
	 * @Inputs four default components
	 * @Return FoundSingleComponent true and SceneComponentCount == 3
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UActorComponent FoundComp = GetComponentByClass(UActorComponent::StaticClass());
		FoundSingleComponent = (FoundComp != nullptr);

		TArray<USceneComponent> SceneComps;
		GetComponentsByClass(USceneComponent::StaticClass(), SceneComps);
		SceneComponentCount = SceneComps.Num();
	}

	/**
	 * Observe that a locally constructed actor found nothing and has no components.
	 *
	 * @Kind Observe
	 * @Covers Component.Finding
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the flag is clear, the count is 0 and all four handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (FoundSingleComponent)
		{
			return false;
		}
		if (SceneComponentCount != 0)
		{
			return false;
		}
		if (Root != nullptr)
		{
			return false;
		}
		if (Child1 != nullptr)
		{
			return false;
		}
		if (Child2 != nullptr)
		{
			return false;
		}
		return LogicComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.Finding
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the found state and the other holds nothing
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentFindingActor Second)
	{
		if (Second is null)
		{
			throw("ComponentFinding setup: required Second is null");
		}
		FoundSingleComponent = true;
		SceneComponentCount = 3;

		if (!FoundSingleComponent)
		{
			return false;
		}
		if (SceneComponentCount != 3)
		{
			return false;
		}
		if (Second.FoundSingleComponent)
		{
			return false;
		}
		return Second.SceneComponentCount == 0;
	}
}
/** @end */
