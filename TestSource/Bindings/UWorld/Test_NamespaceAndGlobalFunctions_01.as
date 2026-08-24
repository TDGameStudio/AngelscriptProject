// Purpose: Observe published EWorldType and ENetMode enumerators used as
// namespace values.
// AS-facing API: EWorldType::None; EWorldType::Game; EWorldType::Editor;
// EWorldType::PIE; EWorldType::EditorPreview; EWorldType::GamePreview;
// EWorldType::GameRPC; EWorldType::Inactive; ENetMode::NM_Client;
// ENetMode::NM_DedicatedServer;
// Inputs: Each enumerator, a copy of None, and comparison against Game.
// Expected observations: Each enumerator compares equal to itself and differs
// from a neighboring value. None is distinct from Game. NM_Client is distinct
// from NM_DedicatedServer.
// Boundary/ownership: These values classify worlds; they do not construct one.

namespace TS_UWorld_NamespaceAndGlobalFunctions_01
{
	// EWorldType::None copies equal to None and differs from Game.
	bool Observe_Surface002_Nominal()
	{
		EWorldType Value = EWorldType::None;
		EWorldType Copied = Value;
		return Copied == EWorldType::None && Value != EWorldType::Game;
	}

	// EWorldType::Game equals Game and differs from None.
	bool Observe_Surface003_Nominal()
	{
		EWorldType Value = EWorldType::Game;
		return Value == EWorldType::Game && Value != EWorldType::None;
	}

	// EWorldType::Editor equals Editor and differs from Game.
	bool Observe_Surface004_Nominal()
	{
		EWorldType Value = EWorldType::Editor;
		return Value == EWorldType::Editor && Value != EWorldType::Game;
	}

	// EWorldType::PIE equals PIE and differs from Editor.
	bool Observe_Surface005_Nominal()
	{
		EWorldType Value = EWorldType::PIE;
		return Value == EWorldType::PIE && Value != EWorldType::Editor;
	}

	// EWorldType::EditorPreview equals EditorPreview and differs from PIE.
	bool Observe_Surface006_Nominal()
	{
		EWorldType Value = EWorldType::EditorPreview;
		return Value == EWorldType::EditorPreview && Value != EWorldType::PIE;
	}

	// EWorldType::GamePreview equals GamePreview and differs from EditorPreview.
	bool Observe_Surface007_Nominal()
	{
		EWorldType Value = EWorldType::GamePreview;
		return Value == EWorldType::GamePreview && Value != EWorldType::EditorPreview;
	}

	// EWorldType::GameRPC equals GameRPC and differs from GamePreview.
	bool Observe_Surface008_Nominal()
	{
		EWorldType Value = EWorldType::GameRPC;
		return Value == EWorldType::GameRPC && Value != EWorldType::GamePreview;
	}

	// EWorldType::Inactive equals Inactive and differs from GameRPC.
	bool Observe_Surface009_Nominal()
	{
		EWorldType Value = EWorldType::Inactive;
		return Value == EWorldType::Inactive && Value != EWorldType::GameRPC;
	}

	// ENetMode::NM_Client equals NM_Client and differs from NM_DedicatedServer.
	bool Observe_Surface011_Nominal()
	{
		ENetMode Value = ENetMode::NM_Client;
		return Value == ENetMode::NM_Client && Value != ENetMode::NM_DedicatedServer;
	}

	// ENetMode::NM_DedicatedServer equals NM_DedicatedServer and differs from NM_Client.
	bool Observe_Surface012_Nominal()
	{
		ENetMode Value = ENetMode::NM_DedicatedServer;
		return Value == ENetMode::NM_DedicatedServer && Value != ENetMode::NM_Client;
	}
}
