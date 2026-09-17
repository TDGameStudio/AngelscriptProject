/**
 * @version v1
 * @summary Subsystems host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic Subsystems
 *
 * get-engine-subsystem
 * get-game-instance-subsystem
 * get-local-player-subsystem
 * get-world-subsystem
 * get-local-player-subsystem-from-local-player
 * get-local-player-subsystem-from-player-controller
 * get
 */
/**
 * @begin get-engine-subsystem
 * @summary destroy them.
 * @topic Unreal
 */
/**
 * @function ObserveGetEngineSubsystemNominal
 * @summary destroy them.
 * @covers Subsystems.get-engine-subsystem
 * @inputs Subsystems values exercised by this observe
 * @return true when the observe comparison holds
 */
// destroy them. Editor-

only Get() forms exist only for editor scripts.
bool ObserveGetEngineSubsystemNominal()
{
	UClass NullClass = nullptr;
	UObject FromNullClass = USubsystemLibrary::GetEngineSubsystem(NullClass);
	UObject FromActorClass = USubsystemLibrary::GetEngineSubsystem(AActor::StaticClass());
	UObject FromLibrary = USubsystemLibrary::GetEngineSubsystem(UAngelscriptSubsystem::StaticClass());
	UAngelscriptSubsystem FromGet = UAngelscriptSubsystem::Get();
	return FromNullClass is null && FromActorClass is null && FromLibrary == FromGet && FromLibrary != nullptr;
}
/** @end */
/**
 * @begin get-game-instance-subsystem
 * @summary destroy them.
 * @topic Unreal
 */
/**
 * @function ObserveGetGameInstanceSubsystemNominal
 * @summary destroy them.
 * @covers Subsystems.get-game-instance-subsystem
 * @inputs Subsystems values exercised by this observe
 * @return true when the observe comparison holds
 */
// destroy them. Editor-

bool ObserveGetGameInstanceSubsystemNominal()
{
	UClass NullClass = nullptr;
	UObject FromNullClass = USubsystemLibrary::GetGameInstanceSubsystem(NullClass);
	UObject FromEngineClass = USubsystemLibrary::GetGameInstanceSubsystem(UAngelscriptSubsystem::StaticClass());
	UObject FromBaseClass = USubsystemLibrary::GetGameInstanceSubsystem(UGameInstanceSubsystem::StaticClass());
	return FromNullClass is null && FromEngineClass is null && FromBaseClass is null;
}
/** @end */
/**
 * @begin get-local-player-subsystem
 * @summary destroy them.
 * @topic Unreal
 */
/**
 * @function ObserveGetLocalPlayerSubsystemNominal
 * @summary destroy them.
 * @covers Subsystems.get-local-player-subsystem
 * @inputs Subsystems values exercised by this observe
 * @return true when the observe comparison holds
 */
// destroy them. Editor-

bool ObserveGetLocalPlayerSubsystemNominal()
{
	UClass NullClass = nullptr;
	UObject FromNullClass = USubsystemLibrary::GetLocalPlayerSubsystem(NullClass);
	UObject FromEngineClass = USubsystemLibrary::GetLocalPlayerSubsystem(UAngelscriptSubsystem::StaticClass());
	UObject Ambient = USubsystemLibrary::GetLocalPlayerSubsystem(UEnhancedInputLocalPlayerSubsystem::StaticClass());
	UEnhancedInputLocalPlayerSubsystem TypedAmbient = Cast<UEnhancedInputLocalPlayerSubsystem>(Ambient);
	UObject TypedAsObject = TypedAmbient;
	return FromNullClass is null && FromEngineClass is null && TypedAsObject == Ambient;
}
/** @end */
/**
 * @begin get-world-subsystem
 * @summary destroy them.
 * @topic Unreal
 */
/**
 * @function ObserveGetWorldSubsystemNominal
 * @summary destroy them.
 * @covers Subsystems.get-world-subsystem
 * @inputs Subsystems values exercised by this observe
 * @return true when the observe comparison holds
 */
// destroy them. Editor-

bool ObserveGetWorldSubsystemNominal()
{
	UClass NullClass = nullptr;
	UObject FromNullClass = USubsystemLibrary::GetWorldSubsystem(NullClass);
	UObject FromEngineClass = USubsystemLibrary::GetWorldSubsystem(UAngelscriptSubsystem::StaticClass());
	UObject FromLibrary = USubsystemLibrary::GetWorldSubsystem(UNetworkSubsystem::StaticClass());
	UNetworkSubsystem FromGet = UNetworkSubsystem::Get();
	return FromNullClass is null && FromEngineClass is null && FromLibrary == FromGet;
}
/** @end */
/**
 * @begin get-local-player-subsystem-from-local-player
 * @summary destroy them.
 * @topic Unreal
 */
/**
 * @function ObserveGetLocalPlayerSubsystemFromLocalPlayerNominal
 * @summary destroy them.
 * @covers Subsystems.get-local-player-subsystem-from-local-player
 * @inputs Subsystems values exercised by this observe
 * @return true when the observe comparison holds
 */
// destroy them. Editor-

bool ObserveGetLocalPlayerSubsystemFromLocalPlayerNominal()
{
	ULocalPlayer NullPlayer = nullptr;
	UObject FromNullPlayer = USubsystemLibrary::GetLocalPlayerSubsystemFromLocalPlayer(
		NullPlayer,
		UEnhancedInputLocalPlayerSubsystem::StaticClass());
	UObject FromNullClass = USubsystemLibrary::GetLocalPlayerSubsystemFromLocalPlayer(
		NullPlayer,
		nullptr);
	return FromNullPlayer is null && FromNullClass is null;
}
/** @end */
/**
 * @begin get-local-player-subsystem-from-player-controller
 * @summary destroy them.
 * @topic Unreal
 */
/**
 * @function ObserveGetLocalPlayerSubsystemFromPlayerControllerNominal
 * @summary destroy them.
 * @covers Subsystems.get-local-player-subsystem-from-player-controller
 * @inputs Subsystems values exercised by this observe
 * @return true when the observe comparison holds
 */
// destroy them. Editor-

bool ObserveGetLocalPlayerSubsystemFromPlayerControllerNominal()
{
	APlayerController NullController = nullptr;
	UObject FromNullController = USubsystemLibrary::GetLocalPlayerSubsystemFromPlayerController(
		NullController,
		UEnhancedInputLocalPlayerSubsystem::StaticClass());
	UObject FromNullClass = USubsystemLibrary::GetLocalPlayerSubsystemFromPlayerController(
		NullController,
		nullptr);
	return FromNullController is null && FromNullClass is null;
}
/** @end */
/**
 * @begin get
 * @summary destroy them.
 * @topic Unreal
 */
/**
 * @function ObserveGetNominal
 * @summary destroy them.
 * @covers Subsystems.get
 * @inputs Subsystems values exercised by this observe
 * @return true when the observe comparison holds
 */
// destroy them. Editor-

bool ObserveGetNominal()
{
	UAngelscriptSubsystem EngineSubsystem = UAngelscriptSubsystem::Get();
	UObject EngineFromLibrary = USubsystemLibrary::GetEngineSubsystem(UAngelscriptSubsystem::StaticClass());
	UNetworkSubsystem WorldSubsystem = UNetworkSubsystem::Get();
	UObject WorldFromLibrary = USubsystemLibrary::GetWorldSubsystem(UNetworkSubsystem::StaticClass());
	UObject EngineAsObject = EngineSubsystem;
	UObject WorldAsObject = WorldSubsystem;
	ULocalPlayer NullPlayer = nullptr;
	UEnhancedInputLocalPlayerSubsystem FromNullPlayer = UEnhancedInputLocalPlayerSubsystem::Get(NullPlayer);
	APlayerController NullController = nullptr;
	UEnhancedInputLocalPlayerSubsystem FromNullController = UEnhancedInputLocalPlayerSubsystem::Get(NullController);
	return EngineSubsystem == EngineFromLibrary && WorldSubsystem == WorldFromLibrary && EngineAsObject != WorldAsObject && FromNullPlayer is null && FromNullController is null;
}
/** @end */
