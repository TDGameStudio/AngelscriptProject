/**
 * A component whose BeginPlay reads a value off its owning script actor. C++
 * spawns the owner, attaches the component and verifies ReadOwnerValue through
 * its path. The observers cover the local-construct default and copy
 * independence.
 *
 * @Theme World.Component
 * @Subject Component.ActorOwner
 * @Harness UClass
 * @Tag World.Component.ActorOwner
 * @Provenance Theme: World.Component. WorldStory: component BeginPlay reads owning script actor.
 * @Provenance C++: AngelscriptComponentTests.cpp::ActorOwner
 * @Provenance spawn ATestComponentOwnerActor + attach UTestComponentActorOwner, BeginPlay, then
 * @Provenance VerifyByPath ReadOwnerValue=42. Keep OwnerValue and ReadOwnerValue.
 * @Provenance sha256=c5e80fc7ffebdeba38e27d9ba30b129a3bb1341c8ca2f975d6eb3ff64358f16d; lines 267-291.
 * @Provenance Extra: local construct leaves ReadOwnerValue 0 (null owner path); copy writes stay independent.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ATestComponentOwnerActor : AActor
{
	UPROPERTY()
	int OwnerValue = 42;
}

UCLASS()
class UTestComponentActorOwner : UActorComponent
{
	UPROPERTY()
	int ReadOwnerValue = 0;

	/**
	 * WorldStory: BeginPlay reads OwnerValue off the owning script actor.
	 *
	 * @Kind WorldStory
	 * @Covers Component.ActorOwner
	 * @Inputs owning ATestComponentOwnerActor with OwnerValue 42
	 * @Return ReadOwnerValue == 42; stays 0 when the owner is not an ATestComponentOwnerActor
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ATestComponentOwnerActor OwnerActor = Cast<ATestComponentOwnerActor>(GetOwner());
		if (OwnerActor != null)
		{
			ReadOwnerValue = OwnerActor.OwnerValue;
		}
	}

	/**
	 * Observe that a locally constructed component leaves the value at zero.
	 *
	 * @Kind Observe
	 * @Covers Component.ActorOwner
	 * @Inputs a component that has not run BeginPlay against an owner
	 * @Return true when ReadOwnerValue is 0
	 * @Boundary null owner path
	 */
	UFUNCTION()
	bool DefaultReadZero()
	{
		return ReadOwnerValue == 0;
	}

	/**
	 * Observe that writing this instance leaves another instance untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.ActorOwner
	 * @Inputs this component plus a second component
	 * @Return true when this reads 42 and the other still reads 0
	 * @Param Second the other component, expected to stay at 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentActorOwner Second)
	{
		if (Second is null)
		{
			throw("ActorOwner setup: required Second is null");
		}
		ReadOwnerValue = 42;
		if (ReadOwnerValue != 42)
		{
			return false;
		}
		return Second.ReadOwnerValue == 0;
	}
}
