/**
 * @version v1
 * @summary An Abstract Blueprintable base plus a concrete subclass. The base carries CLASS_Abstract; the concrete actor spawns and ApplyShieldDamage(10) leaves Shield=15 and DamageApplied=10.
 * @topic Definitions
 */
/**
 * @version root
 * @summary An Abstract Blueprintable base plus a concrete subclass. The base carries CLASS_Abstract; the concrete actor spawns and ApplyShieldDamage(10) leaves Shield=15 and DamageApplied=10.
 * @topic Baseline
 */
UCLASS(Abstract, Blueprintable)
class ACoverageClassFeaturesAbstractGameplayBase : AActor
{
	UPROPERTY()
	int BaseHealth = 100;

	UPROPERTY()
	int BaseArmor = 50;

	/**
	 * Observe the base health getter used by C++ reflection.
	 *
	 * @Kind Observe
	 * @Covers UClass.Abstract
	 * @Inputs BaseHealth default 100
	 * @Return BaseHealth
	 */
	UFUNCTION()
	int GetBaseHealth()
	{
		return BaseHealth;
	}

	/**
	 * Observe that an unset abstract handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Abstract
	 * @Inputs an unset ACoverageClassFeaturesAbstractGameplayBase handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageClassFeaturesAbstractGameplayBase Actor;
		return Actor == nullptr;
	}
}

UCLASS()
class ACoverageClassFeaturesConcreteGameplayActor : ACoverageClassFeaturesAbstractGameplayBase
{
	UPROPERTY()
	int Shield = 25;

	UPROPERTY()
	int DamageApplied = 0;

	/**
	 * WorldStory: apply damage against Shield and record DamageApplied.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Abstract
	 * @Param Damage Amount subtracted from Shield when Shield > 0
	 * @Inputs Shield and DamageApplied
	 * @Return Shield reduced when Shield > 0; DamageApplied set to Damage
	 */
	UFUNCTION()
	void ApplyShieldDamage(int Damage)
	{
		if (Shield > 0)
		{
			Shield -= Damage;
		}
		DamageApplied = Damage;
	}

	/**
	 * Observe the inherited GetBaseHealth default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Abstract
	 * @Inputs a freshly constructed concrete actor
	 * @Return GetBaseHealth()
	 */
	UFUNCTION()
	int DefaultBaseHealth()
	{
		return GetBaseHealth();
	}

	/**
	 * Observe ApplyShieldDamage(10): Shield 25 becomes 15.
	 *
	 * @Kind Observe
	 * @Covers UClass.Abstract
	 * @Inputs Shield=25, DamageApplied=0, ApplyShieldDamage(10)
	 * @Return Shield after the call
	 */
	UFUNCTION()
	int ApplyShieldDamageNominal()
	{
		Shield = 25;
		DamageApplied = 0;
		ApplyShieldDamage(10);
		return Shield;
	}

	/**
	 * Observe ApplyShieldDamage(0): Shield stays 25.
	 *
	 * @Kind Observe
	 * @Covers UClass.Abstract
	 * @Inputs Shield=25, ApplyShieldDamage(0)
	 * @Return Shield after the call
	 * @Boundary zero damage
	 */
	UFUNCTION()
	int ApplyShieldDamageZeroBoundary()
	{
		Shield = 25;
		ApplyShieldDamage(0);
		return Shield;
	}
}
/** @end */
