// Theme: World.Actor. WorldStory: PointDamage BlueprintOverride routes damage, hit location, bone.
// C++: AngelscriptActorInteractionTests.cpp::PointDamage
// Oracle: VerifyByPath LastFloatValue 42.0, LastVectorValue (100,200,300), LastNameValue spine_01,
// EventCallCount 1 after ApplyPointDamage.
// Extra: EventCallCount 0, LastFloatValue 0, LastVectorValue ZeroVector, LastNameValue empty
// until C++ applies damage. Do not spawn from script. FixtureIsolated.

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
}
