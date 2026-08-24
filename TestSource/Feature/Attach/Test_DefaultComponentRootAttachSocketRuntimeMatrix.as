// Theme: Feature.Attach. WorldStory: DefaultComponent Root/Attach/AttachSocket runtime matrix.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentRootAttachSocketRuntimeMatrix.
// Oracle after BeginPlay: RootCreated/AttachmentsCreated/ScriptDefaultsCreated true;
// SceneMarker==17; LogicMarker==23.
// Extra: CDO bools false; SceneMarker/LogicMarker defaults; copy independence.
// FixtureIsolated. Keep RootCreated, AttachmentsCreated, ScriptDefaultsCreated.

UCLASS()
class UCoverageUClassDefaultComponentScriptScene : USceneComponent
{
	UPROPERTY()
	int SceneMarker = 17;
}

UCLASS()
class UCoverageUClassDefaultComponentScriptLogic : UActorComponent
{
	UPROPERTY()
	int LogicMarker = 23;
}

UCLASS()
class ACoverageUClassDefaultComponentRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, AttachSocket="MeshSocket")
	UStaticMeshComponent Mesh;

	UPROPERTY(DefaultComponent, AttachSocket="RootSocket")
	USceneComponent RootSocketChild;

	UPROPERTY(DefaultComponent, Attach=Mesh)
	UCoverageUClassDefaultComponentScriptScene ScriptScene;

	UPROPERTY(DefaultComponent)
	UCoverageUClassDefaultComponentScriptLogic Logic;

	UPROPERTY()
	bool RootCreated = false;

	UPROPERTY()
	bool AttachmentsCreated = false;

	UPROPERTY()
	bool ScriptDefaultsCreated = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RootCreated =
			Root != nullptr &&
			Root.GetOwner() == this &&
			Root.GetAttachParent() == nullptr;

		AttachmentsCreated =
			Mesh != nullptr &&
			RootSocketChild != nullptr &&
			ScriptScene != nullptr &&
			Mesh.GetAttachParent() == Root &&
			Mesh.GetAttachSocketName() == n"MeshSocket" &&
			RootSocketChild.GetAttachParent() == Root &&
			RootSocketChild.GetAttachSocketName() == n"RootSocket" &&
			ScriptScene.GetAttachParent() == Mesh;

		ScriptDefaultsCreated =
			ScriptScene != nullptr &&
			Logic != nullptr &&
			ScriptScene.GetOwner() == this &&
			Logic.GetOwner() == this &&
			ScriptScene.SceneMarker == 17 &&
			Logic.LogicMarker == 23;
	}
}

bool Observe_DefaultComponentMatrix_CDODefaults(ACoverageUClassDefaultComponentRootActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultComponentRootAttachSocketRuntimeMatrix setup: required Actor is null");
	}
	return Actor.RootCreated == false
		&& Actor.AttachmentsCreated == false
		&& Actor.ScriptDefaultsCreated == false;
}

int Observe_ScriptScene_EmptyMarkerDefault(UCoverageUClassDefaultComponentScriptScene Scene)
{
	if (Scene is null)
	{
		throw("Test_DefaultComponentRootAttachSocketRuntimeMatrix setup: required Scene is null");
	}
	return Scene.SceneMarker;
}

int Observe_ScriptLogic_EmptyMarkerDefault(UCoverageUClassDefaultComponentScriptLogic Logic)
{
	if (Logic is null)
	{
		throw("Test_DefaultComponentRootAttachSocketRuntimeMatrix setup: required Logic is null");
	}
	return Logic.LogicMarker;
}

bool Observe_DefaultComponentMatrix_CopyIndependence(ACoverageUClassDefaultComponentRootActor Original, ACoverageUClassDefaultComponentRootActor Copy)
{
	if (Original is null)
	{
		throw("Test_DefaultComponentRootAttachSocketRuntimeMatrix setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_DefaultComponentRootAttachSocketRuntimeMatrix setup: required Copy is null");
	}
	Copy.RootCreated = true;
	Copy.AttachmentsCreated = true;
	return Original.RootCreated == false
		&& Original.AttachmentsCreated == false
		&& Copy.RootCreated
		&& Copy.AttachmentsCreated;
}
