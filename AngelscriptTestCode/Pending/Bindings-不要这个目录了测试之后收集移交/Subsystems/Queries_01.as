/**
 * @version v1
 * @summary Observe USubsystemLibrary lookups and generated native Get() factories for engine, game-instance, local-player, and world subsystems.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe USubsystemLibrary lookups and generated native Get() factories for engine, game-instance, local-player, and world subsystems.
 * @topic Baseline
 */
// Each function returns the exact comparison for the C++ runner.
// AS-facing API: UObject USubsystemLibrary::GetEngineSubsystem(UClass Class);
// UObject USubsystemLibrary::GetGameInstanceSubsystem(UClass Class);
// UObject USubsystemLibrary::GetLocalPlayerSubsystem(UClass Class);
// UObject USubsystemLibrary::GetWorldSubsystem(UClass Class);
// UObject USubsystemLibrary::GetLocalPlayerSubsystemFromLocalPlayer(ULocalPlayer LocalPlayer, UClass Class);
// UObject USubsystemLibrary::GetLocalPlayerSubsystemFromPlayerController(APlayerController PlayerController, UClass Class);
// <NativeSubsystemType> <NativeSubsystemType>::Get();
// <NativeLocalPlayerSubsystemType> <NativeLocalPlayerSubsystemType>::Get(ULocalPlayer LocalPlayer);
// <NativeLocalPlayerSubsystemType> <NativeLocalPlayerSubsystemType>::Get(APlayerController LocalPlayer);
// Inputs: UAngelscriptSubsystem, UNetworkSubsystem, UEnhancedInputLocalPlayerSubsystem,
// UGameInstanceSubsystem as a mismatched class, null UClass, null ULocalPlayer,
// and null APlayerController.
// Expected observations: Engine GetEngineSubsystem and UAngelscriptSubsystem::Get
// return the same non-null identity. Null or mismatched classes return null.
// Null local player/controller lookups return null. World and local-player
// ambient lookups may be null without a world fixture.
// Boundary/ownership: Returned subsystems are engine-owned. Callers must not
// destroy them. Editor-only Get() forms exist only for editor scripts.

namespace TS_Subsystems_Queries_01
{
	bool Observe_GetEngineSubsystem_Nominal()
	{
		UClass NullClass = nullptr;
		UObject FromNullClass = USubsystemLibrary::GetEngineSubsystem(NullClass);
		UObject FromActorClass = USubsystemLibrary::GetEngineSubsystem(AActor::StaticClass());
		UObject FromLibrary = USubsystemLibrary::GetEngineSubsystem(UAngelscriptSubsystem::StaticClass());
		UAngelscriptSubsystem FromGet = UAngelscriptSubsystem::Get();
		return FromNullClass is null && FromActorClass is null && FromLibrary == FromGet && FromLibrary != nullptr;
	}

	bool Observe_GetGameInstanceSubsystem_Nominal()
	{
		UClass NullClass = nullptr;
		UObject FromNullClass = USubsystemLibrary::GetGameInstanceSubsystem(NullClass);
		UObject FromEngineClass = USubsystemLibrary::GetGameInstanceSubsystem(UAngelscriptSubsystem::StaticClass());
		UObject FromBaseClass = USubsystemLibrary::GetGameInstanceSubsystem(UGameInstanceSubsystem::StaticClass());
		return FromNullClass is null && FromEngineClass is null && FromBaseClass is null;
	}

	bool Observe_GetLocalPlayerSubsystem_Nominal()
	{
		UClass NullClass = nullptr;
		UObject FromNullClass = USubsystemLibrary::GetLocalPlayerSubsystem(NullClass);
		UObject FromEngineClass = USubsystemLibrary::GetLocalPlayerSubsystem(UAngelscriptSubsystem::StaticClass());
		UObject Ambient = USubsystemLibrary::GetLocalPlayerSubsystem(UEnhancedInputLocalPlayerSubsystem::StaticClass());
		UEnhancedInputLocalPlayerSubsystem TypedAmbient = Cast<UEnhancedInputLocalPlayerSubsystem>(Ambient);
		UObject TypedAsObject = TypedAmbient;
		return FromNullClass is null && FromEngineClass is null && TypedAsObject == Ambient;
	}

	bool Observe_GetWorldSubsystem_Nominal()
	{
		UClass NullClass = nullptr;
		UObject FromNullClass = USubsystemLibrary::GetWorldSubsystem(NullClass);
		UObject FromEngineClass = USubsystemLibrary::GetWorldSubsystem(UAngelscriptSubsystem::StaticClass());
		UObject FromLibrary = USubsystemLibrary::GetWorldSubsystem(UNetworkSubsystem::StaticClass());
		UNetworkSubsystem FromGet = UNetworkSubsystem::Get();
		return FromNullClass is null && FromEngineClass is null && FromLibrary == FromGet;
	}

	bool Observe_GetLocalPlayerSubsystemFromLocalPlayer_Nominal()
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

	bool Observe_GetLocalPlayerSubsystemFromPlayerController_Nominal()
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

	bool Observe_Get_Nominal()
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
}
/** @end */
