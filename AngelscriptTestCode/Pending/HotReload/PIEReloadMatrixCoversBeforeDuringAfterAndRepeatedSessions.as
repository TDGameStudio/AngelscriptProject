/**
 * @version v1
 * @summary HotReload VersionPair Version_01. PIE reload matrix body V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. PIE reload matrix body V1.
 * @topic Baseline
 */
// Retained across matrix steps: ExistingValue=10, GameMode / LevelScript names, SetReplicates(false).
// Replaced in Version_02: GetValue ExistingValue+1 -> ExistingValue+2. Later matrix versions are later TaskIds.
// FixtureIsolated. Before-PIE InvokeGetValue is 11.

UCLASS(Blueprintable)
class AHotReloadPIEMatrixGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEMatrixLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 10;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + 1;
	}
}
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. PIE reload matrix body V2 (before-PIE reload).
 * @topic HotReload
 */
UCLASS(Blueprintable)
class AHotReloadPIEMatrixGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEMatrixLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 10;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + 2;
	}
}
/** @end */
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. During-PIE body reload.
 * @topic HotReload
 */
UCLASS(Blueprintable)
class AHotReloadPIEMatrixGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEMatrixLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 10;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + 3;
	}
}
/** @end */
/**
 * @version version-04
 * @parent root
 * @summary HotReload VersionPair Version_04. During-PIE required signature change.
 * @topic HotReload
 */
// Retained last-good (Version_03): UClass identity; GetValue() with no Extra; InvokeGetValue == 13.
// Replaced shape (rejected during PIE): GetValue(int Extra) returning ExistingValue + Extra.
// Oracle: SoftReloadOnly false; ErrorNeedFullReload; "Full Reload is required due to UPROPERTY() or UFUNCTION() changes".
// FixtureIsolated. Load Version_01..Version_07 in recorded order.

UCLASS(Blueprintable)
class AHotReloadPIEMatrixGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEMatrixLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 10;

	/** Returns the value. */
	UFUNCTION()
	int GetValue(int Extra)
	{
		return ExistingValue + Extra;
	}
}
/** @end */
/**
 * @version version-05
 * @parent root
 * @summary HotReload VersionPair Version_05. During-PIE suggested property shape.
 * @topic HotReload
 */
// Retained during PIE: live LevelScriptActor; AddedValue not published on the PIE class.
// Replaced body (partially applied): GetValue ExistingValue+3 -> ExistingValue+4 (oracle 14).
// Oracle: SoftReloadOnly PartiallyHandled; "Performing a Soft Reload during PIE"; AddedValue deferred.
// FixtureIsolated. Load Version_01..Version_07 in recorded order.

UCLASS(Blueprintable)
class AHotReloadPIEMatrixGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEMatrixLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 10;

	UPROPERTY()
	int AddedValue = 40;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + 4;
	}
}
/** @end */
/**
 * @version version-06
 * @parent root
 * @summary HotReload VersionPair Version_06. After-PIE shape reload.
 * @topic HotReload
 */
UCLASS(Blueprintable)
class AHotReloadPIEMatrixGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEMatrixLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 10;

	UPROPERTY()
	int AddedValue = 40;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + AddedValue;
	}
}
/** @end */
/**
 * @version version-07
 * @parent root
 * @summary HotReload VersionPair Version_07. After-second-PIE body reload.
 * @topic HotReload
 */
UCLASS(Blueprintable)
class AHotReloadPIEMatrixGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEMatrixLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 10;

	UPROPERTY()
	int AddedValue = 40;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + AddedValue + 1;
	}
}
/** @end */
