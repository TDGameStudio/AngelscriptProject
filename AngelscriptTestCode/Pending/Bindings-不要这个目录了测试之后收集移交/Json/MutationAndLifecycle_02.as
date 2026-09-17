/**
 * @version v1
 * @summary Observe array-field storage, nested object creation, and load/save round-trip including pretty-print omission. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe array-field storage, nested object creation, and load/save round-trip including pretty-print omission. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// malformed "{", and bPrettyPrint false.
// Expected observations: CreateObjectField returns a valid nested object.
// LoadFromString succeeds for object text and fails for malformed text.
// SaveToString contains Name. Compact save is shorter or equal vs pretty.
// Boundary/ownership: LoadFromString replaces this object's fields. Failed
// parse leaves an invalid or empty wrapper depending on the API.

namespace TS_Json_MutationAndLifecycle_02
{
	bool Observe_SetArrayField_Nominal()
	{
		FJsonObject Root;
		FJsonArray Values;
		Values.AddString("First");
		Values.AddNumber(42);
		Root.SetArrayField("Values", Values);
		FJsonArray Read = Root.GetArrayField("Values");
		return Read.Num() == 2 && Read.GetValueAt(0).GetType() == EJsonType::String;
	}

	bool Observe_CreateObjectField_Nominal()
	{
		FJsonObject Root;
		FJsonObject Child = Root.CreateObjectField("Child");
		Child.SetStringField("Label", "Nested");
		return Root.HasField("Child") && Child.GetStringField("Label") == "Nested";
	}

	bool Observe_LoadFromString_Nominal()
	{
		FJsonObject Root;
		bool bLoaded = Root.LoadFromString("{\"Name\":\"Alice\"}");
		FJsonObject Failed;
		bool bMalformed = Failed.LoadFromString("{");
		return bLoaded && Root.GetStringField("Name") == "Alice" && !bMalformed;
	}

	bool Observe_SaveToString_Nominal()
	{
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		FString Pretty = Root.SaveToString();
		FString Compact = Root.SaveToString(false);
		FJsonObject Empty;
		FString EmptyText = Empty.SaveToString(false);
		return Pretty.Contains("Name") && Compact.Contains("Alice") && Compact.Len() <= Pretty.Len() && EmptyText.Contains("{");
	}
}
/** @end */
