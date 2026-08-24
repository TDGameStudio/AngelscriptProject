// Theme: Gameplay.Physics. Value oracle: physical material fields and HitResult phys-mat handle.
// C++: AngelscriptCoveragePhysicsTests.cpp::PhysicsMaterialHitResultReference
// Oracle: Run(Material) == 1 after Friction 0.6 / Restitution 0.4 / Density 1.2 setup.
// Extra: Run(nullptr) == 0; default flags false. DefaultSafe. Keep UPROPERTY names.

UCLASS()
class UCoveragePhysicsMaterialHarness : UObject
{
	UPROPERTY()
	bool MaterialFieldsRead = false;

	UPROPERTY()
	bool QueryParamsPhysicalMaterialFlagRoundTripped = false;

	UPROPERTY()
	bool HitResultPhysicalMaterialRoundTripped = false;

	UFUNCTION()
	int Run(UPhysicalMaterial Material)
	{
		if (Material == nullptr)
		{
			return 0;
		}

		MaterialFieldsRead =
			Material.Friction > 0.59f
			&& Material.Restitution > 0.39f
			&& Material.Density > 1.19f;

		FCollisionQueryParams QueryParams;
		QueryParams.bReturnPhysicalMaterial = true;
		QueryParamsPhysicalMaterialFlagRoundTripped = QueryParams.bReturnPhysicalMaterial;

		FHitResult Hit;
		Hit.SetPhysMaterial(Material);
		HitResultPhysicalMaterialRoundTripped = Hit.GetPhysMaterial() == Material;

		return MaterialFieldsRead && QueryParamsPhysicalMaterialFlagRoundTripped && HitResultPhysicalMaterialRoundTripped ? 1 : 0;
	}
}

bool Observe_PhysicsMaterial_NullMaterial(UCoveragePhysicsMaterialHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_PhysicsMaterialHitResultReference setup: required Harness is null");
	}
	return Harness.Run(nullptr) == 0;
}

bool Observe_PhysicsMaterial_Defaults(UCoveragePhysicsMaterialHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_PhysicsMaterialHitResultReference setup: required Harness is null");
	}
	return Harness.MaterialFieldsRead == false
		&& Harness.QueryParamsPhysicalMaterialFlagRoundTripped == false
		&& Harness.HitResultPhysicalMaterialRoundTripped == false;
}
