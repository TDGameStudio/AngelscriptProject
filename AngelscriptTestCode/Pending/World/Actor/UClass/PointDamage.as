/**
 * @version v1
 * @summary The PointDamage BlueprintOverride recording the amount, hit location and bone name. C++ applies point damage and verifies all four recorded values by path.
 * @topic World
 */
/**
 * @version root
 * @summary The PointDamage BlueprintOverride recording the amount, hit location and bone name. C++ applies point damage and verifies all four recorded values by path.
 * @topic Baseline
 */
UCLASS()
class ATestActorPointDamage : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UPROPERTY()
	FVector LastVectorValue = FVector::ZeroVector;

	UPROPERTY()
	FName LastNameValue;

	/**
	 * WorldStory: the point damage override records the amount, location and bone.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.PointDamage
	 * @Inputs the damage amount, its type, the hit geometry, the bone, the shot
	 * direction, the instigator, the causer and the full hit result
	 * @Return LastFloatValue 42, LastVectorValue (100, 200, 300), LastNameValue spine_01, EventCallCount 1
	 * @Param Damage the amount of damage applied
	 * @Param DamageType the type of damage applied
	 * @Param HitLocation where the hit landed
	 * @Param HitNormal the surface normal at the hit
	 * @Param HitComponent the component that was hit
	 * @Param BoneName the bone that was hit
	 * @Param ShotFromDirection the direction the shot came from
	 * @Param InstigatedBy the controller that instigated the damage
	 * @Param DamageCauser the actor that caused the damage
	 * @Param HitInfo the full hit result
	 */
	UFUNCTION(BlueprintOverride)
	void PointDamage(float Damage, const UDamageType DamageType, FVector HitLocation,
		FVector HitNormal, UPrimitiveComponent HitComponent, FName BoneName,
		FVector ShotFromDirection, AController InstigatedBy,
		AActor DamageCauser, FHitResult HitInfo)
	{
		LastFloatValue = Damage;
		LastVectorValue = HitLocation;
		LastNameValue = BoneName;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has received no damage.
	 *
	 * @Kind Observe
	 * @Covers Actor.PointDamage
	 * @Inputs an actor that has not been damaged
	 * @Return true when the count is 0, the value is 0, the vector is zero and the name is empty
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		if (LastFloatValue != 0.0)
		{
			return false;
		}
		if (!LastVectorValue.Equals(FVector::ZeroVector))
		{
			return false;
		}
		return LastNameValue.IsNone();
	}
}
/** @end */
