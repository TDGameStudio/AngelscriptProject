/**
 * @version v1
 * @summary Observe pawn-side player-controller, locality, player/AI control, and pawn player-state queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe pawn-side player-controller, locality, player/AI control, and pawn player-state queries.
 * @topic Baseline
 */
// Runner owns the Pawn fixture and teardown. A null Pawn is setup failure.
// AS-facing API: APlayerController Pawn.GetPlayerController() const;
// bool Pawn.IsLocallyControlled() const; bool Pawn.IsPlayerControlled() const;
// bool Pawn.IsBotControlled() const; APlayerState Pawn.GetPlayerState() const;
// Inputs: Runner-supplied APawn plus APawn CDO as the negative possession state.
// Expected observations: CDO GetPlayerController is null. Live queries match
// the runner-supplied expected handle or flag.
// Boundary/ownership: SetupOwner=Runner. CleanupOwner=Runner. Handles are
// borrowed. Do not mutate CDOs.

namespace TS_APlayerController_Queries_02
{
	bool Observe_GetPlayerController_Nominal(APawn Pawn, APlayerController Expected)
	{
		if (Pawn is null)
		{
			throw("TS_APlayerController_Queries_02 setup: required Pawn is null");
		}
		TSubclassOf<APawn> PawnClass = APawn::StaticClass();
		APawn Cdo = PawnClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_02 setup: required Pawn CDO is null");
		}
		return Cdo.GetPlayerController() is null && Pawn.GetPlayerController() == Expected;
	}

	bool Observe_IsLocallyControlled_Nominal(APawn Pawn, bool bExpectLocal)
	{
		if (Pawn is null)
		{
			throw("TS_APlayerController_Queries_02 setup: required Pawn is null");
		}
		TSubclassOf<APawn> PawnClass = APawn::StaticClass();
		APawn Cdo = PawnClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_02 setup: required Pawn CDO is null");
		}
		return !Cdo.IsLocallyControlled() && Pawn.IsLocallyControlled() == bExpectLocal;
	}

	bool Observe_IsPlayerControlled_Nominal(APawn Pawn, bool bExpectPlayerControlled)
	{
		if (Pawn is null)
		{
			throw("TS_APlayerController_Queries_02 setup: required Pawn is null");
		}
		TSubclassOf<APawn> PawnClass = APawn::StaticClass();
		APawn Cdo = PawnClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_02 setup: required Pawn CDO is null");
		}
		return !Cdo.IsPlayerControlled() && Pawn.IsPlayerControlled() == bExpectPlayerControlled;
	}

	bool Observe_IsBotControlled_Nominal(APawn Pawn, bool bExpectBotControlled)
	{
		if (Pawn is null)
		{
			throw("TS_APlayerController_Queries_02 setup: required Pawn is null");
		}
		TSubclassOf<APawn> PawnClass = APawn::StaticClass();
		APawn Cdo = PawnClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_02 setup: required Pawn CDO is null");
		}
		return !Cdo.IsBotControlled() && Pawn.IsBotControlled() == bExpectBotControlled;
	}

	bool Observe_GetPlayerState_Nominal(APawn Pawn, APlayerState Expected)
	{
		if (Pawn is null)
		{
			throw("TS_APlayerController_Queries_02 setup: required Pawn is null");
		}
		TSubclassOf<APawn> PawnClass = APawn::StaticClass();
		APawn Cdo = PawnClass.GetDefaultObject();
		if (Cdo is null)
		{
			throw("TS_APlayerController_Queries_02 setup: required Pawn CDO is null");
		}
		return Cdo.GetPlayerState() is null && Pawn.GetPlayerState() == Expected;
	}
}
/** @end */
