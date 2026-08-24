// Theme: Definitions.UClass. WorldStory runtime NewObject/attach/detach/DestroyComponent on script components.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentRuntimeOperationSurface
// Oracle after BeginPlay: DefaultSceneFoundByClass/DefaultLogicFoundByClass and runtime created/attached/detached flags.
// Extra: unset handle is null; pre-BeginPlay flags stay false. FixtureIsolated.

UCLASS()
class UCoverageUClassRuntimeSceneComponent : USceneComponent
{
	UPROPERTY()
	int Marker = 17;
}

UCLASS()
class UCoverageUClassRuntimeLogicComponent : UActorComponent
{
	UPROPERTY()
	int Marker = 23;
}

UCLASS()
class ACoverageUClassComponentRuntimeActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageUClassRuntimeSceneComponent DefaultScene;

	UPROPERTY(DefaultComponent)
	UCoverageUClassRuntimeLogicComponent DefaultLogic;

	UPROPERTY()
	UCoverageUClassRuntimeSceneComponent RuntimeScene;

	UPROPERTY()
	UCoverageUClassRuntimeLogicComponent RuntimeLogic;

	UPROPERTY()
	bool DefaultSceneFoundByClass = false;

	UPROPERTY()
	bool DefaultLogicFoundByClass = false;

	UPROPERTY()
	bool RuntimeSceneCreated = false;

	UPROPERTY()
	bool RuntimeLogicCreated = false;

	UPROPERTY()
	bool RuntimeSceneInitiallyDetached = false;

	UPROPERTY()
	bool RuntimeSceneAttached = false;

	UPROPERTY()
	bool RuntimeSceneDetached = false;

	UPROPERTY()
	bool RuntimeSceneRegistered = false;

	UPROPERTY()
	bool RuntimeSceneFoundByClass = false;

	UPROPERTY()
	bool RuntimeSceneIncludedInAllComponents = false;

	UPROPERTY()
	bool RuntimeLogicRegistered = false;

	UPROPERTY()
	bool RuntimeLogicFoundByClass = false;

	UPROPERTY()
	bool RuntimeLogicIncludedInAllComponents = false;

	UPROPERTY()
	bool RuntimeSceneDestroyed = false;

	UPROPERTY()
	bool RuntimeLogicDestroyed = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DefaultSceneFoundByClass = Cast<UCoverageUClassRuntimeSceneComponent>(
			GetComponentByClass(UCoverageUClassRuntimeSceneComponent::StaticClass())) == DefaultScene;
		DefaultLogicFoundByClass = Cast<UCoverageUClassRuntimeLogicComponent>(
			GetComponentByClass(UCoverageUClassRuntimeLogicComponent::StaticClass())) == DefaultLogic;

		RuntimeScene = Cast<UCoverageUClassRuntimeSceneComponent>(
			NewObject(this, UCoverageUClassRuntimeSceneComponent::StaticClass(), n"CoverageRuntimeScene", true));
		RuntimeLogic = Cast<UCoverageUClassRuntimeLogicComponent>(
			NewObject(this, UCoverageUClassRuntimeLogicComponent::StaticClass(), n"CoverageRuntimeLogic", true));
		RuntimeSceneCreated = RuntimeScene != nullptr && RuntimeScene.GetOwner() == this && RuntimeScene.GetWorld() == GetWorld();
		RuntimeLogicCreated = RuntimeLogic != nullptr && RuntimeLogic.GetOwner() == this && RuntimeLogic.GetWorld() == GetWorld();
		if (RuntimeScene == nullptr || RuntimeLogic == nullptr)
		{
			return;
		}

		RuntimeSceneInitiallyDetached = !RuntimeScene.IsAttachedTo(Root);
		RuntimeScene.AttachToComponent(Root, n"RuntimeSocket",
			EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, false);
		RuntimeSceneAttached = RuntimeScene.IsAttachedTo(Root) &&
			RuntimeScene.GetAttachSocketName() == n"RuntimeSocket";

		RuntimeScene.DetachFromComponent(EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, false);
		RuntimeSceneDetached = !RuntimeScene.IsAttachedTo(Root);

		RuntimeScene.AttachToComponent(Root, NAME_None,
			EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, false);
		RuntimeSceneFoundByClass = Cast<UCoverageUClassRuntimeSceneComponent>(
			GetComponentByClass(UCoverageUClassRuntimeSceneComponent::StaticClass())) != nullptr;
		RuntimeLogicFoundByClass = Cast<UCoverageUClassRuntimeLogicComponent>(
			GetComponentByClass(UCoverageUClassRuntimeLogicComponent::StaticClass())) != nullptr;

		RuntimeScene.DestroyComponent();
		RuntimeLogic.DestroyComponent();
		RuntimeSceneDestroyed = RuntimeScene.IsBeingDestroyed();
		RuntimeLogicDestroyed = RuntimeLogic.IsBeingDestroyed();
	}
}

bool Observe_ComponentRuntimeActor_EmptyDefaultIsNull()
{
	ACoverageUClassComponentRuntimeActor Actor;
	return Actor == nullptr;
}

bool Observe_ComponentRuntimeActor_FlagsDefaultFalse(ACoverageUClassComponentRuntimeActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0153 setup: required ACoverageUClassComponentRuntimeActor is null");
	}
	return Actor.DefaultSceneFoundByClass == false
		&& Actor.RuntimeSceneCreated == false
		&& Actor.RuntimeSceneDestroyed == false
		&& Actor.RuntimeLogicDestroyed == false;
}

int Observe_RuntimeScene_MarkerDefault(UCoverageUClassRuntimeSceneComponent Comp)
{
	if (Comp == nullptr)
	{
		throw("TS-DEF-0153 setup: required UCoverageUClassRuntimeSceneComponent is null");
	}
	return Comp.Marker;
}

int Observe_RuntimeLogic_MarkerDefault(UCoverageUClassRuntimeLogicComponent Comp)
{
	if (Comp == nullptr)
	{
		throw("TS-DEF-0153 setup: required UCoverageUClassRuntimeLogicComponent is null");
	}
	return Comp.Marker;
}
