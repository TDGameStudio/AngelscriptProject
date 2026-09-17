/**
 * @version v1
 * @summary Physical-material fields and a HitResult phys-mat handle. C++ treats Run(Material) == 1 after Friction 0.6 / Restitution 0.4 / Density 1.2 as the oracle, so the UCLASS, UFUNCTION and UPROPERTY names are part of the.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Physical-material fields and a HitResult phys-mat handle. C++ treats Run(Material) == 1 after Friction 0.6 / Restitution 0.4 / Density 1.2 as the oracle, so the UCLASS, UFUNCTION and UPROPERTY names are part of the.
 * @topic Baseline
 */
UCLASS()
class UCoveragePhysicsMaterialHarness : UObject
{
	UPROPERTY()
	bool MaterialFieldsRead = false;

	UPROPERTY()
	bool QueryParamsPhysicalMaterialFlagRoundTripped = false;

	UPROPERTY()
	bool HitResultPhysicalMaterialRoundTripped = false;

	/**
	 * Read material fields, set bReturnPhysicalMaterial on query params, and attach
	 * the material to a hit result.
	 *
	 * @Kind Action
	 * @Covers Physics.PhysicsMaterialHitResultReference
	 * @Inputs a physical material, or null
	 * @Return 1 when MaterialFieldsRead, QueryParamsPhysicalMaterialFlagRoundTripped
	 * and HitResultPhysicalMaterialRoundTripped are true, otherwise 0
	 * @Param Material the physical material to read and attach; null returns 0
	 * @Boundary null material
	 */
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

		if (!MaterialFieldsRead)
		{
			return 0;
		}
		if (!QueryParamsPhysicalMaterialFlagRoundTripped)
		{
			return 0;
		}
		if (!HitResultPhysicalMaterialRoundTripped)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that Run with a null material returns 0.
	 *
	 * @Kind Observe
	 * @Covers Physics.PhysicsMaterialHitResultReference
	 * @Inputs a null physical material
	 * @Return true when Run returns 0
	 * @Boundary null material
	 */
	UFUNCTION()
	bool NullMaterial()
	{
		return Run(nullptr) == 0;
	}

	/**
	 * Observe that an untouched harness holds every flag false.
	 *
	 * @Kind Observe
	 * @Covers Physics.PhysicsMaterialHitResultReference
	 * @Inputs a harness that has not run
	 * @Return true when MaterialFieldsRead, QueryParamsPhysicalMaterialFlagRoundTripped
	 * and HitResultPhysicalMaterialRoundTripped are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (MaterialFieldsRead)
		{
			return false;
		}
		if (QueryParamsPhysicalMaterialFlagRoundTripped)
		{
			return false;
		}
		return HitResultPhysicalMaterialRoundTripped == false;
	}
}
/** @end */
