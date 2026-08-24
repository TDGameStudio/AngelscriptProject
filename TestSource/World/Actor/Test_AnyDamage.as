// Theme: World.Actor. WorldStory: AnyDamage BlueprintOverride routes damage and causer.
// C++: AngelscriptActorInteractionTests.cpp::AnyDamage
// Oracle: VerifyByPath LastFloatValue 55.0, LastActorRef is the actor, EventCallCount 1.
// Extra: EventCallCount 0, LastFloatValue 0, LastActorRef null until C++ applies damage.
// Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorAnyDamage : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	UFUNCTION(BlueprintOverride)
	void AnyDamage(float Damage, const UDamageType DamageType, AController InstigatedBy, AActor DamageCauser)
	{
		LastFloatValue = Damage;
		LastActorRef = DamageCauser;
		EventCallCount += 1;
	}
}
