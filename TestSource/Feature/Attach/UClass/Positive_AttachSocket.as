/**
 * DefaultComponent Attach + AttachSocket compiles. C++ AssertCompiles
 * ADefCompSocketActor. The observers cover the local-construct default, the
 * named-socket attachment when components materialize, and copy independence.
 *
 * @Theme Feature.Attach
 * @Subject Attach.Positive_AttachSocket
 * @Harness UClass
 * @Tag Feature.Attach.Positive_AttachSocket
 * @Provenance Theme: Feature.Attach. WorldStory: DefaultComponent Attach + AttachSocket compiles.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Positive_AttachSocket AssertCompiles.
 * @Provenance Oracle: Child attaches to Root at "Socket1" when components materialize.
 * @Provenance Extra: empty Root/Child may be null before spawn; copy independence.
 * @Provenance FixtureIsolated. Keep Root and Child.
 */

UCLASS()
class ADefCompSocketActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root, AttachSocket = "Socket1")
	USceneComponent Child;

	/**
	 * Observe that a locally constructed actor has not materialized Root or Child.
	 *
	 * @Kind Observe
	 * @Covers Attach.Positive_AttachSocket
	 * @Inputs an actor that has not been spawned
	 * @Return true when Root and Child are both null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (Root != nullptr)
		{
			return false;
		}
		return Child == nullptr;
	}

	/**
	 * Observe the Socket1 attachment when both components have materialized,
	 * and the joint-null case when they have not.
	 *
	 * @Kind Observe
	 * @Covers Attach.Positive_AttachSocket
	 * @Inputs this actor after spawn, or a local construct whose handles are still null
	 * @Return true when Child is attached to Root at n"Socket1", or both handles are null
	 * @Boundary components may be null before spawn
	 */
	UFUNCTION()
	bool RuntimeIfMaterialized()
	{
		if (Root == nullptr)
		{
			return Child == nullptr;
		}
		if (Child == nullptr)
		{
			return false;
		}
		if (Child.GetAttachParent() != Root)
		{
			return false;
		}
		return Child.GetAttachSocketName() == n"Socket1";
	}

	/**
	 * Observe that a second instance is a different object.
	 *
	 * @Kind Observe
	 * @Covers Attach.Positive_AttachSocket
	 * @Inputs this actor plus a second actor
	 * @Return true when the two actors are not the same object
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ADefCompSocketActor Second)
	{
		if (Second is null)
		{
			throw("Positive_AttachSocket setup: required Second is null");
		}
		return this != Second;
	}
}
