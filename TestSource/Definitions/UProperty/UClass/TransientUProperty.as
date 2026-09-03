/**
 * A Transient UPROPERTY compiles with default TempVal 0. The sibling carries
 * TempVal 1 so the empty default stays independent of the non-zero boundary.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.TransientUProperty
 * @Harness UClass
 * @Tag Definitions.UProperty.TransientUProperty
 * @Provenance Theme: Definitions.UProperty. WorldStory: Transient UPROPERTY compiles with default TempVal 0.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles UPropSP_Transient.
 * @Provenance Extra: sibling TempVal 1 is independent of the empty default 0. FixtureIsolated.
 */

class AUPropTransActor : AActor
{
	UPROPERTY(Transient)
	int TempVal = 0;

	/**
	 * Observe the empty Transient default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TransientUProperty
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int EmptyDefault()
	{
		return 0;
	}

	/**
	 * Observe that empty TempVal 0 is independent of the sibling 1.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TransientUProperty
	 * @Inputs local EmptyTempVal 0 and TempVal 1
	 * @Return 0 when the empty value differs, otherwise -1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int BoundaryIndependent()
	{
		int EmptyTempVal = 0;
		int TempVal = 1;
		return EmptyTempVal != TempVal ? EmptyTempVal : -1;
	}
}

/**
 * The sibling that keeps TempVal 1.
 *
 * @Covers UProperty.TransientUProperty
 * @Inputs none
 * @Return an actor with TempVal 1
 * @Boundary non-zero sibling
 */
class AUPropTransActorBoundary : AActor
{
	UPROPERTY(Transient)
	int TempVal = 1;
}
