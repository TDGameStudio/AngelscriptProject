/**
 * @version v1
 * @summary FTransform UPROPERTY declaration defaults read off a spawned actor. Non-identity declaration initializers are a spawn boundary, so every reflected property materializes as the identity regardless of what its initializer.
 * @topic Math
 */
/**
 * @version root
 * @summary FTransform UPROPERTY declaration defaults read off a spawned actor. Non-identity declaration initializers are a spawn boundary, so every reflected property materializes as the identity regardless of what its initializer.
 * @topic Baseline
 */
UCLASS()
class ACoverageFTransformDefaultsActor : AActor
{
	UPROPERTY()
	FTransform IdentityTransform = FTransform::Identity;

	UPROPERTY()
	FTransform CustomTransform = FTransform(FVector(100, 200, 300));

	UPROPERTY()
	FTransform NoDefaultTransform;

	UPROPERTY()
	FTransform FullTransform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2));

	/**
	 * Observe that the identity-declared property reads as the identity transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.DeclarationDefaults
	 * @Inputs none
	 * @Return true when the translation is the origin and the scale is all ones
	 */
	UFUNCTION()
	bool IdentityTransformSpawned()
	{
		if (IdentityTransform.GetLocation().X != 0.0)
		{
			return false;
		}
		if (IdentityTransform.GetLocation().Y != 0.0)
		{
			return false;
		}
		if (IdentityTransform.GetLocation().Z != 0.0)
		{
			return false;
		}
		if (IdentityTransform.GetScale3D().X != 1.0)
		{
			return false;
		}
		if (IdentityTransform.GetScale3D().Y != 1.0)
		{
			return false;
		}
		return IdentityTransform.GetScale3D().Z == 1.0;
	}

	/**
	 * Observe that a property declared without an initialiser is the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.DeclarationDefaults
	 * @Inputs none
	 * @Return true when the translation is zero and the scale is one
	 * @Boundary no declared default
	 */
	UFUNCTION()
	bool NoDefaultTransformEmptyIdentity()
	{
		if (NoDefaultTransform.GetLocation().X != 0.0)
		{
			return false;
		}
		return NoDefaultTransform.GetScale3D().X == 1.0;
	}

	/**
	 * Observe that both non-identity initializers still materialize as the identity, which
	 * is the spawn boundary this test pins down.
	 *
	 * @Kind Observe
	 * @Covers FTransform.DeclarationDefaults
	 * @Inputs none
	 * @Return true when both properties read as the identity transform
	 * @Boundary non-identity initializer
	 */
	UFUNCTION()
	bool CustomAndFullSpawnedIdentityBoundary()
	{
		if (CustomTransform.GetLocation().X != 0.0)
		{
			return false;
		}
		if (CustomTransform.GetLocation().Y != 0.0)
		{
			return false;
		}
		if (CustomTransform.GetLocation().Z != 0.0)
		{
			return false;
		}
		if (CustomTransform.GetScale3D().X != 1.0)
		{
			return false;
		}
		if (FullTransform.GetLocation().X != 0.0)
		{
			return false;
		}
		if (FullTransform.GetLocation().Y != 0.0)
		{
			return false;
		}
		if (FullTransform.GetLocation().Z != 0.0)
		{
			return false;
		}
		if (FullTransform.GetScale3D().X != 1.0)
		{
			return false;
		}
		if (FullTransform.GetScale3D().Y != 1.0)
		{
			return false;
		}
		return FullTransform.GetScale3D().Z == 1.0;
	}
}
/** @end */
