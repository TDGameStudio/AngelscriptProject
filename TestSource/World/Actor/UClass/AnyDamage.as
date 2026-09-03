/**
 * The AnyDamage BlueprintOverride recording the damage amount and the causer. C++
 * applies damage and verifies the recorded value, actor and call count by path.
 *
 * @Theme World.Actor
 * @Subject Actor.AnyDamage
 * @Harness UClass
 * @Tag World.Actor.AnyDamage
 * @Provenance Theme: World.Actor. WorldStory: AnyDamage BlueprintOverride routes damage and causer.
 * @Provenance C++: AngelscriptActorInteractionTests.cpp::AnyDamage
 * @Provenance Oracle: VerifyByPath LastFloatValue 55.0, LastActorRef is the actor, EventCallCount 1.
 * @Provenance Extra: EventCallCount 0, LastFloatValue 0, LastActorRef null until C++ applies damage.
 * @Provenance Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestActorAnyDamage : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	/**
	 * WorldStory: the damage override records the amount, the causer and the call.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.AnyDamage
	 * @Inputs the damage amount, its type, the instigating controller and the causer
	 * @Return LastFloatValue 55, LastActorRef the causer, EventCallCount 1
	 * @Param Damage the amount of damage applied
	 * @Param DamageType the type of damage applied
	 * @Param InstigatedBy the controller that instigated the damage
	 * @Param DamageCauser the actor that caused the damage
	 */
	UFUNCTION(BlueprintOverride)
	void AnyDamage(float Damage, const UDamageType DamageType, AController InstigatedBy, AActor DamageCauser)
	{
		LastFloatValue = Damage;
		LastActorRef = DamageCauser;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has received no damage.
	 *
	 * @Kind Observe
	 * @Covers Actor.AnyDamage
	 * @Inputs an actor that has not been damaged
	 * @Return true when the count is 0, the value is 0 and the causer is null
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
		return LastActorRef == nullptr;
	}
}
