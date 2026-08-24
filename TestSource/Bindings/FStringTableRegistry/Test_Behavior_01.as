// Purpose: Observe runtime string-table creation, optional file loads, key
// mutation, metadata, and LOCTABLE lookup.
// AS-facing API: void LOCTABLE_NEW(const FName TableId, const FString& Namespace);
// void LOCTABLE_FROMFILE_ENGINE(...); void LOCTABLE_FROMFILE_GAME(...);
// void LOCTABLE_SETSTRING(...); void LOCTABLE_SETMETA(...);
// FText LOCTABLE(const FName TableId, const FString& Key);
// Inputs: TableId n"TestSource.LocTable", namespace "TestSource", key "Greeting",
// source "Hello", empty key as the empty-state lookup, and a non-existent
// file path as the load boundary.
// Expected observations: After NEW+SETSTRING, LOCTABLE returns text whose
// string contains Hello. Missing keys return empty or non-matching text.
// File-load helpers are invoked with a documented missing path.
// Boundary/ownership: The registry owns table storage. LOCTABLE returns FText
// by value and does not transfer table ownership.

namespace TS_FStringTableRegistry_Behavior_01
{
	bool Observe_LOCTABLE_NEW_Nominal()
	{
		LOCTABLE_NEW(n"TestSource.LocTable", "TestSource");
		LOCTABLE_SETSTRING(n"TestSource.LocTable", "Greeting", "Hello");
		FText Found = LOCTABLE(n"TestSource.LocTable", "Greeting");
		return Found.ToString().Contains("Hello");
	}

	bool Observe_LOCTABLE_FROMFILE_ENGINE_Nominal()
	{
		LOCTABLE_FROMFILE_ENGINE(n"TestSource.EngineLocTable", "TestSource", "Missing/EngineTable.csv");
		FText Missing = LOCTABLE(n"TestSource.EngineLocTable", "MissingKey");
		return Missing.IsEmpty() || !Missing.IsFromStringTable();
	}

	bool Observe_LOCTABLE_FROMFILE_GAME_Nominal()
	{
		LOCTABLE_FROMFILE_GAME(n"TestSource.GameLocTable", "TestSource", "Missing/GameTable.csv");
		FText Missing = LOCTABLE(n"TestSource.GameLocTable", "MissingKey");
		return Missing.IsEmpty() || !Missing.IsFromStringTable();
	}

	bool Observe_LOCTABLE_SETSTRING_Nominal()
	{
		LOCTABLE_NEW(n"TestSource.LocTable.SetString", "TestSource");
		LOCTABLE_SETSTRING(n"TestSource.LocTable.SetString", "Greeting", "Hello");
		LOCTABLE_SETSTRING(n"TestSource.LocTable.SetString", "Greeting", "Hello");
		FText Found = LOCTABLE(n"TestSource.LocTable.SetString", "Greeting");
		return Found.ToString().Contains("Hello");
	}

	bool Observe_LOCTABLE_SETMETA_Nominal()
	{
		LOCTABLE_NEW(n"TestSource.LocTable.SetMeta", "TestSource");
		LOCTABLE_SETSTRING(n"TestSource.LocTable.SetMeta", "Greeting", "Hello");
		LOCTABLE_SETMETA(n"TestSource.LocTable.SetMeta", "Greeting", n"Comment", "nominal");
		FText Found = LOCTABLE(n"TestSource.LocTable.SetMeta", "Greeting");
		return Found.ToString().Contains("Hello");
	}

	bool Observe_LOCTABLE_Nominal()
	{
		LOCTABLE_NEW(n"TestSource.LocTable.Lookup", "TestSource");
		LOCTABLE_SETSTRING(n"TestSource.LocTable.Lookup", "Greeting", "Hello");
		FText Found = LOCTABLE(n"TestSource.LocTable.Lookup", "Greeting");
		FText Missing = LOCTABLE(n"TestSource.LocTable.Lookup", "");
		return Found.ToString().Contains("Hello") && Missing.ToString() != Found.ToString();
	}
}
