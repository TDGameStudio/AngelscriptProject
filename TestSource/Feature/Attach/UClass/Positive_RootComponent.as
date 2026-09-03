/**
 * DefaultComponent + RootComponent compiles. C++ AssertCompiles ADefCompRootActor.
 * The observers cover the local-construct null Root and copy independence.
 *
 * @Theme Feature.Attach
 * @Subject Attach.Positive_RootComponent
 * @Harness UClass
 * @Tag Feature.Attach.Positive_RootComponent
 * @Provenance Theme: Feature.Attach. WorldStory: DefaultComponent + RootComponent compiles.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Positive_RootComponent AssertCompiles.
 * @Provenance Oracle: ADefCompRootActor constructs; Root is the declared scene root.
 * @Provenance Extra: empty Root may be null before spawn; copy independence of two actors.
 * @Provenance FixtureIsolated. Keep Root.
 */

UCLASS()
class ADefCompRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	/**
	 * Observe that a locally constructed actor has not materialized Root.
	 *
	 * @Kind Observe
	 * @Covers Attach.Positive_RootComponent
	 * @Inputs an actor that has not been spawned
	 * @Return true when Root is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		return Root == nullptr;
	}

	/**
	 * Observe that a second instance is a different object.
	 *
	 * @Kind Observe
	 * @Covers Attach.Positive_RootComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when the two actors are not the same object
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ADefCompRootActor Second)
	{
		if (Second is null)
		{
			throw("Positive_RootComponent setup: required Second is null");
		}
		return this != Second;
	}
}
