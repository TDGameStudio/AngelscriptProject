/**
 * DefaultComponent Root/Attach/AttachSocket runtime matrix. C++ spawns the
 * actor and reads RootCreated, AttachmentsCreated and ScriptDefaultsCreated
 * after BeginPlay. The observers cover CDO flags, script-component marker
 * defaults, and copy independence.
 *
 * @Theme Feature.Attach
 * @Subject Attach.DefaultComponentRootAttachSocketRuntimeMatrix
 * @Harness UClass
 * @Tag Feature.Attach.DefaultComponentRootAttachSocketRuntimeMatrix
 * @Provenance Theme: Feature.Attach. WorldStory: DefaultComponent Root/Attach/AttachSocket runtime matrix.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentRootAttachSocketRuntimeMatrix.
 * @Provenance Oracle after BeginPlay: RootCreated/AttachmentsCreated/ScriptDefaultsCreated true;
 * @Provenance SceneMarker==17; LogicMarker==23.
 * @Provenance Extra: CDO bools false; SceneMarker/LogicMarker defaults; copy independence.
 * @Provenance FixtureIsolated. Keep RootCreated, AttachmentsCreated, ScriptDefaultsCreated.
 */

UCLASS()
class UCoverageUClassDefaultComponentScriptScene : USceneComponent
{
	UPROPERTY()
	int SceneMarker = 17;

	/**
	 * Observe the script scene marker default.
	 *
	 * @Kind Observe
	 * @Covers Attach.DefaultComponentRootAttachSocketRuntimeMatrix
	 * @Inputs a locally constructed script scene component
	 * @Return 17, the SceneMarker default
	 * @Boundary empty marker default
	 */
	UFUNCTION()
	int EmptyMarkerDefault()
	{
		return SceneMarker;
	}
}

UCLASS()
class UCoverageUClassDefaultComponentScriptLogic : UActorComponent
{
	UPROPERTY()
	int LogicMarker = 23;

	/**
	 * Observe the script logic marker default.
	 *
	 * @Kind Observe
	 * @Covers Attach.DefaultComponentRootAttachSocketRuntimeMatrix
	 * @Inputs a locally constructed script logic component
	 * @Return 23, the LogicMarker default
	 * @Boundary empty marker default
	 */
	UFUNCTION()
	int EmptyMarkerDefault()
	{
		return LogicMarker;
	}
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

	/**
	 * WorldStory: BeginPlay records whether Root, the attach tree and the script
	 * component defaults materialized on this actor.
	 *
	 * @Kind WorldStory
	 * @Covers Attach.DefaultComponentRootAttachSocketRuntimeMatrix
	 * @Inputs Root, Mesh, RootSocketChild, ScriptScene and Logic default components
	 * @Return RootCreated, AttachmentsCreated and ScriptDefaultsCreated true after spawn
	 */
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

	/**
	 * Observe that a locally constructed actor still holds the CDO flags.
	 *
	 * @Kind Observe
	 * @Covers Attach.DefaultComponentRootAttachSocketRuntimeMatrix
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when RootCreated, AttachmentsCreated and ScriptDefaultsCreated are all false
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RootCreated)
		{
			return false;
		}
		if (AttachmentsCreated)
		{
			return false;
		}
		return ScriptDefaultsCreated == false;
	}

	/**
	 * Observe that writing the second actor leaves this actor at its CDO flags.
	 *
	 * @Kind Observe
	 * @Covers Attach.DefaultComponentRootAttachSocketRuntimeMatrix
	 * @Inputs this actor plus a second actor
	 * @Return true when this stays at CDO flags and Second holds the written flags
	 * @Param Second the other actor, written then compared
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassDefaultComponentRootActor Second)
	{
		if (Second is null)
		{
			throw("DefaultComponentRootAttachSocketRuntimeMatrix setup: required Second is null");
		}
		Second.RootCreated = true;
		Second.AttachmentsCreated = true;
		if (RootCreated)
		{
			return false;
		}
		if (AttachmentsCreated)
		{
			return false;
		}
		if (!Second.RootCreated)
		{
			return false;
		}
		return Second.AttachmentsCreated;
	}
}
