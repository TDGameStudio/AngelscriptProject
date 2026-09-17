/**
 * @version v1
 * @summary A UDataAsset whose properties must register and carry their CDO defaults, together with an actor holding a pointer to that asset. The observers read the asset's defaults and confirm the actor's config pointer starts.
 * @topic Language
 */
/**
 * @version root
 * @summary A UDataAsset whose properties must register and carry their CDO defaults, together with an actor holding a pointer to that asset. The observers read the asset's defaults and confirm the actor's config pointer starts.
 * @topic Baseline
 */
UCLASS()
class UFunctionalWeaponData : UDataAsset
{
	UPROPERTY(EditAnywhere)
	FString WeaponName;

	UPROPERTY(EditAnywhere, meta = (ClampMin = "0"))
	float BaseDamage = 10.0;

	UPROPERTY(EditAnywhere)
	float FireRate = 0.5;

	UPROPERTY(EditAnywhere)
	int32 MaxAmmo = 30;

	UPROPERTY(EditAnywhere)
	TArray<FName> AllowedAttachments;

	/**
	 * Observe that every registered property holds its CDO default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed asset
	 * @Return true when all five properties match their defaults
	 * @Boundary default values
	 */
	UFUNCTION()
	bool WeaponDataHoldsCDODefaults()
	{
		if (WeaponName.Len() != 0)
		{
			return false;
		}

		if (!Math::IsNearlyEqual(BaseDamage, 10.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FireRate, 0.5))
		{
			return false;
		}

		if (MaxAmmo != 30)
		{
			return false;
		}

		return AllowedAttachments.Num() == 0;
	}

	/**
	 * Observe that writing this asset leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this asset written to, compared against a second asset
	 * @Return true when this asset holds the write and the other keeps defaults
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool WeaponDataInstancesAreIndependent()
	{
		UFunctionalWeaponData Other =
			Cast<UFunctionalWeaponData>(
				NewObject(GetTransientPackage(), UFunctionalWeaponData::StaticClass(), n"FunctionalWeaponDataOther"));
		if (Other == nullptr)
		{
			throw("Test_CompilesAndRegistersProperties setup: NewObject returned null");
		}

		WeaponName = "Rifle";
		MaxAmmo = 7;

		if (WeaponName != "Rifle")
		{
			return false;
		}

		if (Other.WeaponName.Len() != 0)
		{
			return false;
		}

		return Other.MaxAmmo == 30;
	}
}

UCLASS()
class AFunctionalWeaponActor : AActor
{
	UPROPERTY(EditAnywhere)
	UFunctionalWeaponData WeaponConfig;

	/**
	 * Observe that the config pointer starts null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when WeaponConfig is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool WeaponActorConfigDefaultsToNull()
	{
		return WeaponConfig == nullptr;
	}
}
/** @end */
