/**
 * @version v1
 * @summary UCLASS default inheritance CDO versus spawned surface. C++ verifies leaf CDO Health==100, Label==n"Base", ActorClass CDO null, spawned leaf GetIsReplicated true and tags accumulate BaseTag/MidTag/LeafTag. Health 0 on a.
 * @topic Feature
 */
/**
 * @version root
 * @summary UCLASS default inheritance CDO versus spawned surface. C++ verifies leaf CDO Health==100, Label==n"Base", ActorClass CDO null, spawned leaf GetIsReplicated true and tags accumulate BaseTag/MidTag/LeafTag. Health 0 on a.
 * @topic Baseline
 */
UCLASS()
class ACoverageUClassDefaultBaseActor : AActor
{
	default Tags.Add(n"BaseTag");
	default SetReplicates(false);

	UPROPERTY()
	int Health = 100;

	UPROPERTY()
	FName Label = n"Base";
}

UCLASS()
class ACoverageUClassDefaultMidActor : ACoverageUClassDefaultBaseActor
{
	default Health = 200;
	default Label = n"Mid";
	default Tags.Add(n"MidTag");
}

UCLASS()
class ACoverageUClassDefaultLeafActor : ACoverageUClassDefaultMidActor
{
	default Health = 300;
	default Tags.Add(n"LeafTag");
	default SetReplicates(true);

	UPROPERTY()
	TSubclassOf<AActor> ActorClass = ACoverageUClassDefaultBaseActor::StaticClass();

	UPROPERTY()
	ACoverageUClassDefaultBaseActor ActorRef;

	/**
	 * Observe that a locally constructed leaf has a null ActorRef.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassDefaultInheritancePropertySurface
	 * @Inputs a freshly constructed leaf
	 * @Return true when ActorRef is null
	 * @Boundary empty ActorRef
	 */
	UFUNCTION()
	bool EmptyActorRef()
	{
		return ActorRef == nullptr;
	}

	/**
	 * Observe the documented CDO boundary: Health 100 and Label n"Base".
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassDefaultInheritancePropertySurface
	 * @Inputs a freshly constructed leaf
	 * @Return true when Health is 100 and Label is n"Base"
	 * @Boundary CDO surface
	 */
	UFUNCTION()
	bool CDOBoundary()
	{
		if (Health != 100)
		{
			return false;
		}
		return Label == n"Base";
	}

	/**
	 * Observe that writing Health and Label on this leaf leaves another leaf untouched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassDefaultInheritancePropertySurface
	 * @Inputs this leaf plus a second leaf
	 * @Return true when this Health is 0 and the other stays 100 / n"Base"
	 * @Param Second the other leaf, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassDefaultLeafActor Second)
	{
		if (Second == nullptr)
		{
			throw("UClassDefaultInheritancePropertySurface setup: required Second is null");
		}
		Health = 0;
		Label = n"";
		if (Second.Health != 100)
		{
			return false;
		}
		if (Second.Label != n"Base")
		{
			return false;
		}
		return Health == 0;
	}
}
/** @end */
