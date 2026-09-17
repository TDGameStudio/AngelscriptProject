/**
 * @version v1
 * @summary Typed Create, Get and GetOrCreate accessors, where the latter two must return the same object the first one made. C++ runs the entrypoint and expects 1. The observers cover the local-construct default and copy.
 * @topic World
 */
/**
 * @version root
 * @summary Typed Create, Get and GetOrCreate accessors, where the latter two must return the same object the first one made. C++ runs the entrypoint and expects 1. The observers cover the local-construct default and copy.
 * @topic Baseline
 */
UCLASS()
class UTestActorComponentManagementTypedScene : USceneComponent
{
}

UCLASS()
class ATestActorComponentManagementTypedAccessors : AActor
{
	UPROPERTY()
	UTestActorComponentManagementTypedScene Created;

	UPROPERTY()
	UTestActorComponentManagementTypedScene Found;

	UPROPERTY()
	UTestActorComponentManagementTypedScene Reused;

	/**
	 * Create a typed component, then resolve it twice more and confirm all three
	 * handles are the same object.
	 *
	 * @Kind Observe
	 * @Covers Component.StaticTypedAccessorsCreateGetAndReuse
	 * @Inputs none
	 * @Return 1 on success; 10, 20 or 30 naming the step that failed
	 */
	UFUNCTION()
	int RunTypedAccessorTest()
	{
		Created = UTestActorComponentManagementTypedScene::Create(this, n"TypedScene");
		if (Created == nullptr)
		{
			return 10;
		}

		Found = UTestActorComponentManagementTypedScene::Get(this, n"TypedScene");
		if (Found == nullptr || Found != Created)
		{
			return 20;
		}

		Reused = UTestActorComponentManagementTypedScene::GetOrCreate(this, n"TypedScene");
		if (Reused == nullptr || Reused != Created)
		{
			return 30;
		}

		return 1;
	}

	/**
	 * Observe that a locally constructed actor holds none of the three handles.
	 *
	 * @Kind Observe
	 * @Covers Component.StaticTypedAccessorsCreateGetAndReuse
	 * @Inputs an actor that has not run the entrypoint
	 * @Return true when all three handles are null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (Created != nullptr)
		{
			return false;
		}
		if (Found != nullptr)
		{
			return false;
		}
		return Reused == nullptr;
	}

	/**
	 * Observe that a second instance keeps its own independent null handles.
	 *
	 * @Kind Observe
	 * @Covers Component.StaticTypedAccessorsCreateGetAndReuse
	 * @Inputs this actor plus a second actor
	 * @Return true when all six handles are null
	 * @Param Second the other actor, also expected to hold null handles
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestActorComponentManagementTypedAccessors Second)
	{
		if (Second is null)
		{
			throw("StaticTypedAccessorsCreateGetAndReuse setup: required Second is null");
		}
		Created = Found;

		if (Created != nullptr)
		{
			return false;
		}
		if (Second.Created != nullptr)
		{
			return false;
		}
		if (Second.Found != nullptr)
		{
			return false;
		}
		return Second.Reused == nullptr;
	}
}
/** @end */
