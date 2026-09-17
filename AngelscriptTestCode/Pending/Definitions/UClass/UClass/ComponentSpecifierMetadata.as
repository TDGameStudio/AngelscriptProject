/**
 * @version v1
 * @summary DefaultComponent AttachSocket/ShowOnActor metadata. After BeginPlay, ChildAttachedToRoot is true. Keep ChildAttachedToRoot and ChildAttachSocket.
 * @topic Definitions
 */
/**
 * @version root
 * @summary DefaultComponent AttachSocket/ShowOnActor metadata. After BeginPlay, ChildAttachedToRoot is true. Keep ChildAttachedToRoot and ChildAttachSocket.
 * @topic Baseline
 */
UCLASS()
class AComponentSpecifierMetadataActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, AttachSocket="CoverageSocket", ShowOnActor, EditAnywhere, BlueprintReadOnly)
	USceneComponent Child;

	UPROPERTY()
	bool ChildAttachedToRoot = false;

	UPROPERTY()
	FName ChildAttachSocket;

	/**
	 * WorldStory: BeginPlay records attach parent and socket.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.DefaultComponent
	 * @Inputs Child.GetAttachParent and GetAttachSocketName
	 * @Return ChildAttachedToRoot and ChildAttachSocket updated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ChildAttachedToRoot = Child.GetAttachParent() == Root;
		ChildAttachSocket = Child.GetAttachSocketName();
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs an unset AComponentSpecifierMetadataActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		AComponentSpecifierMetadataActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe ChildAttachedToRoot before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs a freshly constructed actor
	 * @Return true when ChildAttachedToRoot is false
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool ChildAttachedDefaultFalse()
	{
		return ChildAttachedToRoot == false;
	}
}
/** @end */
