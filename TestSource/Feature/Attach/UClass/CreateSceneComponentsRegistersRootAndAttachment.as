/**
 * CreateComponent registers a runtime root then a second scene component. C++ executes
 * CreateRuntimeComponents and checks FirstCreated/SecondCreated, so those names are part
 * of the contract and are kept verbatim.
 *
 * @Theme Feature.Attach
 * @Subject Attach.CreateSceneComponentsRegistersRootAndAttachment
 * @Harness UClass
 * @Tag Feature.Attach.CreateSceneComponentsRegistersRootAndAttachment
 * @Provenance Theme: Feature.Attach. WorldStory: CreateComponent registers root then attaches the second scene component.
 * @Provenance C++: AngelscriptActorComponentManagementTests.cpp::CreateSceneComponentsRegistersRootAndAttachment.
 * @Provenance Oracle: CreateRuntimeComponents()==1; FirstCreated becomes root; SecondCreated attaches to FirstCreated.
 * @Provenance Failure codes: FirstCreated nullptr returns 10; SecondCreated nullptr returns 20.
 * @Provenance Extra: CDO FirstCreated/SecondCreated null; copy independence of null defaults.
 * @Provenance FixtureIsolated. Keep FirstCreated, SecondCreated.
 */

UCLASS()
class ATestActorComponentManagementCreateScene : AActor
{
	UPROPERTY()
	USceneComponent FirstCreated;

	UPROPERTY()
	USceneComponent SecondCreated;

	/**
	 * Create two runtime scene components and return a status code.
	 *
	 * @Kind Observe
	 * @Covers Attach.CreateSceneComponentsRegistersRootAndAttachment
	 * @Inputs none
	 * @Return 1 on success, 10 if FirstCreated is null, 20 if SecondCreated is null
	 */
	UFUNCTION()
	int CreateRuntimeComponents()
	{
		FirstCreated = Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"RuntimeRoot"));
		if (FirstCreated == nullptr)
		{
			return 10;
		}

		SecondCreated = Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"RuntimeChild"));
		if (SecondCreated == nullptr)
		{
			return 20;
		}

		return 1;
	}

	/**
	 * Observe that CDO component pointers are null.
	 *
	 * @Kind Observe
	 * @Covers Attach.CreateSceneComponentsRegistersRootAndAttachment
	 * @Inputs none
	 * @Return true when FirstCreated and SecondCreated are null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefault()
	{
		if (FirstCreated != nullptr)
		{
			return false;
		}
		return SecondCreated == nullptr;
	}

	/**
	 * Observe that a second instance also starts with null runtime components.
	 *
	 * @Kind Observe
	 * @Covers Attach.CreateSceneComponentsRegistersRootAndAttachment
	 * @Inputs a second actor
	 * @Return true when both instances hold null components and are distinct objects
	 * @Param Copy the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestActorComponentManagementCreateScene Copy)
	{
		if (Copy is null)
		{
			throw("CreateSceneComponentsRegistersRootAndAttachment setup: required Copy is null");
		}

		if (FirstCreated != nullptr)
		{
			return false;
		}
		if (SecondCreated != nullptr)
		{
			return false;
		}
		if (Copy.FirstCreated != nullptr)
		{
			return false;
		}
		if (Copy.SecondCreated != nullptr)
		{
			return false;
		}
		return this != Copy;
	}
}
