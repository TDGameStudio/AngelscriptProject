/**
 * The RadialDamage BlueprintOverride recording the amount and the blast origin.
 * C++ applies radial damage and verifies the recorded values by path. The sphere
 * root is sized in the class defaults.
 *
 * @Theme World.Actor
 * @Subject Actor.RadialDamage
 * @Harness UClass
 * @Tag World.Actor.RadialDamage
 * @Provenance Theme: World.Actor. WorldStory: RadialDamage BlueprintOverride with a sphere root.
 * @Provenance C++: AngelscriptActorInteractionTests.cpp::RadialDamage
 * @Provenance Oracle: VerifyByPath LastFloatValue 24.0, LastVectorValue equals actor location, EventCallCount 1.
 * @Provenance Extra: EventCallCount 0, LastFloatValue 0, LastVectorValue ZeroVector until C++ applies damage.
 * @Provenance Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class UTestActorRadialDamageSphere : USphereComponent
{
}

UCLASS()
class ATestActorRadialDamage : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestActorRadialDamageSphere DamageSphere;

	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UPROPERTY()
	FVector LastVectorValue = FVector::ZeroVector;

	default DamageSphere.SetSphereRadius(64.0f);

	/**
	 * WorldStory: the radial damage override records the amount and the blast origin.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.RadialDamage
	 * @Inputs the damage amount, its type, the blast origin, the hit result, the
	 * instigator and the causer
	 * @Return LastFloatValue 24, LastVectorValue the actor location, EventCallCount 1
	 * @Param DamageReceived the amount of damage applied
	 * @Param DamageType the type of damage applied
	 * @Param Origin where the blast originated
	 * @Param HitInfo the full hit result
	 * @Param InstigatedBy the controller that instigated the damage
	 * @Param DamageCauser the actor that caused the damage
	 */
	UFUNCTION(BlueprintOverride)
	void RadialDamage(float DamageReceived, const UDamageType DamageType, FVector Origin,
		FHitResult HitInfo, AController InstigatedBy, AActor DamageCauser)
	{
		LastFloatValue = DamageReceived;
		LastVectorValue = Origin;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has received no damage.
	 *
	 * @Kind Observe
	 * @Covers Actor.RadialDamage
	 * @Inputs an actor that has not been damaged
	 * @Return true when the count is 0, the value is 0, the vector is zero and the sphere is null
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
		return DamageSphere == nullptr;
	}
}
