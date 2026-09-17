/**
 * @version v1
 * @summary AHUD DrawHUD plus UUserWidget lifecycle override surface. ReceiveDrawHUD exposes SizeX/SizeY; OnInitialized/Construct/Destruct/Tick UFunctions exist.
 * @topic Definitions
 */
/**
 * @version root
 * @summary AHUD DrawHUD plus UUserWidget lifecycle override surface. ReceiveDrawHUD exposes SizeX/SizeY; OnInitialized/Construct/Destruct/Tick UFunctions exist.
 * @topic Baseline
 */
UCLASS()
class ACoverageUClassSurfaceHUD : AHUD
{
	/**
	 * WorldStory: DrawHUD is the HUD override surface.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Lifecycle
	 * @Param SizeX Canvas width
	 * @Param SizeY Canvas height
	 * @Inputs SizeX, SizeY
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void DrawHUD(int SizeX, int SizeY)
	{
	}

	/**
	 * Observe that an unset HUD handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Lifecycle
	 * @Inputs an unset ACoverageUClassSurfaceHUD handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassSurfaceHUD HUD;
		return HUD == nullptr;
	}

	/**
	 * Observe that an empty DrawHUD(0, 0) completes.
	 *
	 * @Kind Observe
	 * @Covers UClass.Lifecycle
	 * @Inputs DrawHUD(0, 0)
	 * @Return 0
	 * @Boundary empty sizes
	 */
	UFUNCTION()
	int DrawHUDEmptyCompletes()
	{
		DrawHUD(0, 0);
		return 0;
	}
}

UCLASS()
class UCoverageUClassSurfaceWidget : UUserWidget
{
	/**
	 * WorldStory: OnInitialized is the widget initialize override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Lifecycle
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OnInitialized()
	{
	}

	/**
	 * WorldStory: Construct is the widget construct override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Lifecycle
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Construct()
	{
	}

	/**
	 * WorldStory: Destruct is the widget destruct override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Lifecycle
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Destruct()
	{
	}

	/**
	 * WorldStory: Tick is the widget tick override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Lifecycle
	 * @Param MyGeometry Widget geometry
	 * @Param InDeltaTime Frame delta
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float InDeltaTime)
	{
	}

	/**
	 * Observe that an unset widget handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Lifecycle
	 * @Inputs an unset UCoverageUClassSurfaceWidget handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassSurfaceWidget Widget;
		return Widget == nullptr;
	}

	/**
	 * Observe that empty OnInitialized/Construct/Destruct complete.
	 *
	 * @Kind Observe
	 * @Covers UClass.Lifecycle
	 * @Inputs OnInitialized(); Construct(); Destruct()
	 * @Return 0
	 * @Boundary empty lifecycle
	 */
	UFUNCTION()
	int OnInitializedEmptyCompletes()
	{
		OnInitialized();
		Construct();
		Destruct();
		return 0;
	}
}
/** @end */
