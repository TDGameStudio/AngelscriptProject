// Purpose: Observe current-world classification, net mode, game state, and
// the four world clocks.
// Runner owns the World fixture. A null World is setup failure.
// AS-facing API: UWorld GetCurrentWorld();
// bool UWorld.IsGameWorld() const;
// bool UWorld.IsEditorWorld() const;
// bool UWorld.IsPreviewWorld() const;
// ENetMode UWorld.GetNetMode() const;
// AGameStateBase UWorld.GetGameState() const;
// float64 UWorld.GetTimeSeconds() const;
// float64 UWorld.GetUnpausedTimeSeconds() const;
// float64 UWorld.GetRealTimeSeconds() const;
// float64 UWorld.GetAudioTimeSeconds() const;
// Inputs: Runner-owned UWorld, expected kind flags, expected ENetMode, expected
// game-state presence, and clock lower bounds.
// Expected observations: returned bool is the exact comparison.
// Boundary/ownership: GetCurrentWorld uses the AngelScript world context.
// Clock values are copies. Do not call ServerTravel. SetupOwner=Runner.

namespace TS_UWorld_Queries_01
{
	bool Observe_GetCurrentWorld_Nominal(UWorld World)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_01 setup: required World is null");
		}
		return GetCurrentWorld() == World;
	}

	bool Observe_IsGameWorld_Nominal(UWorld World, bool bExpectGameWorld)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_01 setup: required World is null");
		}
		return World.IsGameWorld() == bExpectGameWorld;
	}

	bool Observe_IsEditorWorld_Nominal(UWorld World, bool bExpectEditorWorld)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_01 setup: required World is null");
		}
		return World.IsEditorWorld() == bExpectEditorWorld;
	}

	bool Observe_IsPreviewWorld_Nominal(UWorld World, bool bExpectPreviewWorld)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_01 setup: required World is null");
		}
		return World.IsPreviewWorld() == bExpectPreviewWorld;
	}

	bool Observe_GetNetMode_Nominal(UWorld World, ENetMode Expected)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_01 setup: required World is null");
		}
		return World.GetNetMode() == Expected;
	}

	bool Observe_GetGameState_Nominal(UWorld World, bool bExpectGameState)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_01 setup: required World is null");
		}
		AGameStateBase GameState = World.GetGameState();
		if (bExpectGameState)
		{
			return GameState != nullptr;
		}
		return GameState is null;
	}

	bool Observe_GetTimeSeconds_Nominal(UWorld World, float64 ExpectedMinimum)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_01 setup: required World is null");
		}
		return World.GetTimeSeconds() >= ExpectedMinimum;
	}

	bool Observe_GetUnpausedTimeSeconds_Nominal(UWorld World, float64 ExpectedMinimum)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_01 setup: required World is null");
		}
		return World.GetUnpausedTimeSeconds() >= ExpectedMinimum;
	}

	bool Observe_GetRealTimeSeconds_Nominal(UWorld World, float64 ExpectedMinimum)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_01 setup: required World is null");
		}
		return World.GetRealTimeSeconds() >= ExpectedMinimum;
	}

	bool Observe_GetAudioTimeSeconds_Nominal(UWorld World, float64 ExpectedMinimum)
	{
		if (World is null)
		{
			throw("TS_UWorld_Queries_01 setup: required World is null");
		}
		return World.GetAudioTimeSeconds() >= ExpectedMinimum;
	}
}
