/**
 * @version v1
 * @summary AHUD DrawHUD BlueprintOverride dispatch. After ReceiveDrawHUD(640, 360), DrawHUDCount is 1, DrawHUDMarker is 77, LastDrawHUDSizeX is 640, and LastDrawHUDSizeY is 360. Keep those UPROPERTY names.
 * @topic Definitions
 */
/**
 * @version root
 * @summary AHUD DrawHUD BlueprintOverride dispatch. After ReceiveDrawHUD(640, 360), DrawHUDCount is 1, DrawHUDMarker is 77, LastDrawHUDSizeX is 640, and LastDrawHUDSizeY is 360. Keep those UPROPERTY names.
 * @topic Baseline
 */
UCLASS()
class ACoverageUClassDispatchHUD : AHUD
{
	UPROPERTY()
	int DrawHUDCount = 0;

	UPROPERTY()
	int DrawHUDMarker = 0;

	UPROPERTY()
	int LastDrawHUDSizeX = 0;

	UPROPERTY()
	int LastDrawHUDSizeY = 0;

	/**
	 * WorldStory: DrawHUD records count, marker, and last sizes.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.HUD
	 * @Param SizeX Canvas width
	 * @Param SizeY Canvas height
	 * @Inputs SizeX, SizeY
	 * @Return DrawHUDCount increased; DrawHUDMarker=77; last sizes stored
	 */
	UFUNCTION(BlueprintOverride)
	void DrawHUD(int SizeX, int SizeY)
	{
		DrawHUDCount++;
		DrawHUDMarker = 77;
		LastDrawHUDSizeX = SizeX;
		LastDrawHUDSizeY = SizeY;
	}

	/**
	 * Observe that an unset HUD handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.HUD
	 * @Inputs an unset ACoverageUClassDispatchHUD handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassDispatchHUD HUD;
		return HUD == nullptr;
	}

	/**
	 * Observe DrawHUD counters at defaults.
	 *
	 * @Kind Observe
	 * @Covers UClass.HUD
	 * @Inputs a freshly constructed HUD
	 * @Return DrawHUDCount + DrawHUDMarker + LastDrawHUDSizeX + LastDrawHUDSizeY
	 * @Boundary default counters
	 */
	UFUNCTION()
	int CountersDefault()
	{
		return DrawHUDCount + DrawHUDMarker + LastDrawHUDSizeX + LastDrawHUDSizeY;
	}

	/**
	 * Observe DrawHUD(0, 0) as the zero-size boundary.
	 *
	 * @Kind Observe
	 * @Covers UClass.HUD
	 * @Inputs DrawHUD(0, 0)
	 * @Return LastDrawHUDSizeX + LastDrawHUDSizeY
	 * @Boundary zero size
	 */
	UFUNCTION()
	int ZeroSizeBoundary()
	{
		DrawHUD(0, 0);
		return LastDrawHUDSizeX + LastDrawHUDSizeY;
	}

	/**
	 * Observe DrawHUD(640, 360) writing DrawHUDMarker 77.
	 *
	 * @Kind Observe
	 * @Covers UClass.HUD
	 * @Inputs DrawHUD(640, 360)
	 * @Return DrawHUDMarker
	 */
	UFUNCTION()
	int DrawHUDNominal()
	{
		DrawHUD(640, 360);
		return DrawHUDMarker;
	}
}
/** @end */
