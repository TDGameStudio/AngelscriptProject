// Theme: World.Actor. WorldStory: RadialDamage BlueprintOverride with a sphere root.
// C++: AngelscriptActorInteractionTests.cpp::RadialDamage
// Oracle: VerifyByPath LastFloatValue 24.0, LastVectorValue equals actor location, EventCallCount 1.
// Extra: EventCallCount 0, LastFloatValue 0, LastVectorValue ZeroVector until C++ applies damage.
// Do not spawn from script. FixtureIsolated.

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

	UFUNCTION(BlueprintOverride)
	void RadialDamage(float DamageReceived, const UDamageType DamageType, FVector Origin,
		FHitResult HitInfo, AController InstigatedBy, AActor DamageCauser)
	{
		LastFloatValue = DamageReceived;
		LastVectorValue = Origin;
		EventCallCount += 1;
	}
}
