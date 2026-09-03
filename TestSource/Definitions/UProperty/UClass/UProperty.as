/**
 * A spawned actor keeps UPROPERTY defaults. C++ verifies Health and DisplayName
 * by path, so those names are kept. The empty sibling carries Health 0 and an
 * empty DisplayName so the two defaults stay independent.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UProperty
 * @Harness UClass
 * @Tag Definitions.UProperty.UProperty
 * @Provenance Theme: Definitions.UProperty. WorldStory: spawned actor keeps UPROPERTY defaults.
 * @Provenance C++: VerifyByPath Health 100; DisplayName TestActor.
 * @Provenance Extra: empty sibling Health 0 / empty DisplayName is independent of the defaults. FixtureIsolated.
 */

UCLASS()
class ATestActorUProperty : AActor
{
	UPROPERTY()
	int Health = 100;

	UPROPERTY()
	FString DisplayName = "TestActor";

	/**
	 * Observe that empty Health 0 is independent of the 100 default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UProperty
	 * @Inputs local Health 100 and EmptyHealth 0
	 * @Return 0 when the empty value differs, otherwise -1
	 * @Boundary empty default
	 */
	UFUNCTION()
	int UPropertyEmptyHealthIndependent()
	{
		int Health = 100;
		int EmptyHealth = 0;
		return EmptyHealth != Health ? EmptyHealth : -1;
	}

	/**
	 * Observe that an empty DisplayName has Len 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UProperty
	 * @Inputs a default-constructed FString
	 * @Return true when Len is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool UPropertyEmptyDisplayName()
	{
		FString DisplayName;
		return DisplayName.Len() == 0;
	}
}

/**
 * The sibling that keeps Health 0 and an empty DisplayName.
 *
 * @Covers UProperty.UProperty
 * @Inputs none
 * @Return an actor with empty Health and DisplayName
 * @Boundary empty sibling
 */
UCLASS()
class ATestActorUPropertyEmpty : AActor
{
	UPROPERTY()
	int Health = 0;

	UPROPERTY()
	FString DisplayName;
}
