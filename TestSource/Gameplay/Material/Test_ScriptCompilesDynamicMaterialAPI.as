// Theme: Gameplay.Material. WorldStory: UMaterialInstanceDynamic scalar/vector parameters.
// C++: AngelscriptRenderingDynamicMaterialTests.cpp::ScriptCompilesDynamicMaterialAPI
// Oracle: class compiles; Mesh is UStaticMeshComponent; DynamicMaterial is UMaterialInstanceDynamic.
// BeginPlay CreateDynamicMaterialInstance(0) then Opacity 0.5 and Color (1.0, 0.5, 0.0, 1.0).
// Extra: default DynamicMaterial is null. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class AFunctionalDynamicMaterialActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent Mesh;

	UPROPERTY()
	UMaterialInstanceDynamic DynamicMaterial;

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
}

bool Observe_DynamicMaterial_DefaultNull(AFunctionalDynamicMaterialActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ScriptCompilesDynamicMaterialAPI setup: required Actor is null");
	}
	return Actor.DynamicMaterial == nullptr;
}

bool Observe_DynamicMaterial_NullMeshBoundary(AFunctionalDynamicMaterialActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ScriptCompilesDynamicMaterialAPI setup: required Actor is null");
	}
	if (Actor.Mesh == nullptr)
	{
		return Actor.DynamicMaterial == nullptr;
	}

	return Actor.DynamicMaterial == nullptr;
}
