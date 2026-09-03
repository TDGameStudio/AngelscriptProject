/**
 * A runtime Billboard attached to an #if EDITOR parent still compiles with a
 * VerifyClass diagnostic. CSV is not a hard fail; bCompiled is true. RootScene
 * remains the runtime root.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.NonEditorComponentCannotAttachToEditorOnlyParent
 * @Harness UClass
 * @Tag Definitions.Meta.NonEditorComponentCannotAttachToEditorOnlyParent
 * @Provenance Theme: Definitions.Meta. WorldStory: runtime Billboard attached to #if EDITOR parent still compiles with VerifyClass diagnostic.
 * @Provenance C++: NonEditorComponentCannotAttachToEditorOnlyParent; bCompiled true (CSV is not a hard fail).
 * @Provenance Extra: default handle is null; RootScene remains the runtime root. FixtureIsolated.
 */

UCLASS()
class AComponentVerifyClassEditorOnlyParentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	/**
	 * EDITOR keeps EditorParent attached to RootScene.
	 *
	 * @Covers Meta.NonEditorComponentCannotAttachToEditorOnlyParent
	 * @Inputs the flag EDITOR
	 * @Return EditorParent is declared
	 */
#if EDITOR
	UPROPERTY(DefaultComponent, Attach = RootScene)
	USceneComponent EditorParent;
#endif

	UPROPERTY(DefaultComponent, Attach = EditorParent)
	UBillboardComponent RuntimeBillboard;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.NonEditorComponentCannotAttachToEditorOnlyParent
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		AComponentVerifyClassEditorOnlyParentActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that RootScene is present.
	 *
	 * @Kind Observe
	 * @Covers Meta.NonEditorComponentCannotAttachToEditorOnlyParent
	 * @Inputs none
	 * @Return true when RootScene is not null
	 */
	UFUNCTION()
	bool RootPresent()
	{
		return RootScene != nullptr;
	}

	/**
	 * Observe that RuntimeBillboard is present.
	 *
	 * @Kind Observe
	 * @Covers Meta.NonEditorComponentCannotAttachToEditorOnlyParent
	 * @Inputs none
	 * @Return true when RuntimeBillboard is not null
	 */
	UFUNCTION()
	bool RuntimeBillboardPresent()
	{
		return RuntimeBillboard != nullptr;
	}
}
