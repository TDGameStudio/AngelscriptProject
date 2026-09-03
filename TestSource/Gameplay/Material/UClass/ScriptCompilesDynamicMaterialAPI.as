/**
 * A dynamic material actor that creates a UMaterialInstanceDynamic on its mesh and writes
 * Opacity and Color. C++ compiles the class and verifies Mesh and DynamicMaterial by path,
 * so those UPROPERTY names are part of the contract and are kept verbatim. The observers
 * cover the null default and the null-mesh boundary.
 *
 * @Theme Gameplay.Material
 * @Subject Material.ScriptCompilesDynamicMaterialAPI
 * @Harness UClass
 * @Tag Gameplay.Material.ScriptCompilesDynamicMaterialAPI
 * @Provenance Theme: Gameplay.Material. WorldStory: UMaterialInstanceDynamic scalar/vector parameters.
 * @Provenance C++: AngelscriptRenderingDynamicMaterialTests.cpp::ScriptCompilesDynamicMaterialAPI
 * @Provenance Oracle: class compiles; Mesh is UStaticMeshComponent; DynamicMaterial is UMaterialInstanceDynamic.
 * @Provenance BeginPlay CreateDynamicMaterialInstance(0) then Opacity 0.5 and Color (1.0, 0.5, 0.0, 1.0).
 * @Provenance Extra: default DynamicMaterial is null. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class AFunctionalDynamicMaterialActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent Mesh;

	UPROPERTY()
	UMaterialInstanceDynamic DynamicMaterial;

	/**
	 * WorldStory: BeginPlay creates a dynamic material instance and writes Opacity and Color.
	 *
	 * @Kind WorldStory
	 * @Covers Material.ScriptCompilesDynamicMaterialAPI
	 * @Inputs none
	 * @Return DynamicMaterial created with Opacity 0.5 and Color (1.0, 0.5, 0.0, 1.0) when non-null
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DynamicMaterial = Mesh.CreateDynamicMaterialInstance(0);
		if (DynamicMaterial != nullptr)
		{
			DynamicMaterial.SetScalarParameterValue(n"Opacity", 0.5);
			DynamicMaterial.SetVectorParameterValue(n"Color", FLinearColor(1.0, 0.5, 0.0, 1.0));
		}
	}

	/**
	 * Observe that an untouched actor holds a null dynamic material.
	 *
	 * @Kind Observe
	 * @Covers Material.ScriptCompilesDynamicMaterialAPI
	 * @Inputs none
	 * @Return true when DynamicMaterial is null
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		return DynamicMaterial == nullptr;
	}

	/**
	 * Observe that a missing mesh still leaves the dynamic material null before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Material.ScriptCompilesDynamicMaterialAPI
	 * @Inputs none
	 * @Return true when DynamicMaterial is null, whether or not Mesh is present
	 * @Boundary null mesh
	 */
	UFUNCTION()
	bool NullMeshBoundary()
	{
		if (Mesh == nullptr)
		{
			return DynamicMaterial == nullptr;
		}
		return DynamicMaterial == nullptr;
	}
}
