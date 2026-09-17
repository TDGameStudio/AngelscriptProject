/**
 * @version v1
 * @summary UUserWidget OnInitialized/Construct/Destruct/Tick overrides. NewObject widgets expose those UFunctions; default counters stay 0 until called.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UUserWidget OnInitialized/Construct/Destruct/Tick overrides. NewObject widgets expose those UFunctions; default counters stay 0 until called.
 * @topic Baseline
 */
UCLASS()
class ULifecycleWidget : UUserWidget
{
	UPROPERTY()
	int ConstructCalled = 0;

	UPROPERTY()
	int DestructCalled = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int OnInitializedCalled = 0;

	/**
	 * WorldStory: OnInitialized records that the widget was initialized.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Widget
	 * @Inputs none
	 * @Return OnInitializedCalled = 1
	 */
	UFUNCTION(BlueprintOverride)
	void OnInitialized()
	{
		OnInitializedCalled = 1;
	}

	/**
	 * WorldStory: Construct records that the widget was built.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Widget
	 * @Inputs none
	 * @Return ConstructCalled = 1
	 */
	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		ConstructCalled = 1;
	}

	/**
	 * WorldStory: Destruct records that the widget was torn down.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Widget
	 * @Inputs none
	 * @Return DestructCalled = 1
	 */
	UFUNCTION(BlueprintOverride)
	void Destruct()
	{
		DestructCalled = 1;
	}

	/**
	 * WorldStory: Tick counts frames.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Widget
	 * @Param MyGeometry Widget geometry
	 * @Param InDeltaTime Frame delta
	 * @Inputs TickCount
	 * @Return TickCount increased by 1
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float InDeltaTime)
	{
		TickCount++;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Widget
	 * @Inputs an unset ULifecycleWidget handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ULifecycleWidget Widget;
		return Widget == nullptr;
	}

	/**
	 * Observe lifecycle counters at defaults.
	 *
	 * @Kind Observe
	 * @Covers UClass.Widget
	 * @Inputs a freshly constructed widget
	 * @Return OnInitializedCalled + ConstructCalled + DestructCalled + TickCount
	 * @Boundary default counters
	 */
	UFUNCTION()
	int CountersDefault()
	{
		return OnInitializedCalled + ConstructCalled + DestructCalled + TickCount;
	}

	/**
	 * Observe OnInitialized writing 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Widget
	 * @Inputs OnInitialized()
	 * @Return OnInitializedCalled
	 */
	UFUNCTION()
	int OnInitializedNominal()
	{
		OnInitialized();
		return OnInitializedCalled;
	}

	/**
	 * Observe Construct writing 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Widget
	 * @Inputs Construct()
	 * @Return ConstructCalled
	 */
	UFUNCTION()
	int ConstructNominal()
	{
		Construct();
		return ConstructCalled;
	}
}
/** @end */
