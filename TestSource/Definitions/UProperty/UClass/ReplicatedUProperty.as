/**
 * A Replicated UPROPERTY compiles. The empty sibling carries Health 0 so the two
 * defaults stay independent.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.ReplicatedUProperty
 * @Harness UClass
 * @Tag Definitions.UProperty.ReplicatedUProperty
 * @Provenance Theme: Definitions.UProperty. WorldStory: Replicated UPROPERTY compiles.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles UPropSP_Replicated.
 * @Provenance Extra: empty sibling Health 0 is independent. FixtureIsolated.
 */

class AUPropRepActor : AActor
{
	UPROPERTY(Replicated)
	int Health = 100;

	/**
	 * Observe the default Health of 100.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ReplicatedUProperty
	 * @Inputs none
	 * @Return 100
	 */
	UFUNCTION()
	int DefaultHealth()
	{
		return 100;
	}

	/**
	 * Observe that empty Health 0 is independent of the 100 default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ReplicatedUProperty
	 * @Inputs local Health 100 and EmptyHealth 0
	 * @Return 0 when the empty value differs, otherwise -1
	 * @Boundary empty default
	 */
	UFUNCTION()
	int EmptyHealthIndependent()
	{
		int Health = 100;
		int EmptyHealth = 0;
		return EmptyHealth != Health ? EmptyHealth : -1;
	}
}

/**
 * The sibling that keeps Health 0.
 *
 * @Covers UProperty.ReplicatedUProperty
 * @Inputs none
 * @Return an actor with Health 0
 * @Boundary empty sibling
 */
class AUPropRepActorEmpty : AActor
{
	UPROPERTY(Replicated)
	int Health = 0;
}
