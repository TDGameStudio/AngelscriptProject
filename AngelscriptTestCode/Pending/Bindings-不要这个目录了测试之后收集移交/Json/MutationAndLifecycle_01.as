/**
 * @version v1
 * @summary Observe array empty/add and object field set/remove mutations.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe array empty/add and object field set/remove mutations.
 * @topic Baseline
 */
// Each function returns the exact comparison for the C++ runner.
// AS-facing API: FJsonArray.Empty; AddString; AddNumber(int32); AddNumber(float64);
// FJsonObject.RemoveField; RemoveAllFields; SetStringField; SetNumberField;
// SetBoolField; SetObjectField.
// Inputs: Seeded array with two entries, object with Name/Score/Enabled/Child,
// repeated SetStringField of the same key, and removal of a missing field.
// Expected observations: Empty yields Num 0. Add* increases Num. RemoveField
// drops HasField. RemoveAllFields clears remaining keys. Set* is visible to
// matching getters.
// Boundary/ownership: SetObjectField stores a wrapper sharing the object.
// Remove of a missing field is a no-op.

namespace TS_Json_MutationAndLifecycle_01
{
	bool Observe_Empty_Nominal()
	{
		FJsonArray Values;
		Values.AddString("First");
		Values.Empty();
		return Values.Num() == 0;
	}

	bool Observe_AddString_Nominal()
	{
		FJsonArray Values;
		Values.AddString("First");
		Values.AddString("First");
		return Values.Num() == 2 && Values.GetValueAt(0).GetType() == EJsonType::String;
	}

	bool Observe_AddNumber_Nominal()
	{
		FJsonArray Values;
		Values.AddNumber(42);
		Values.AddNumber(1.5);
		float64 First = 0.0;
		float64 Second = 0.0;
		bool bFirst = Values.GetValueAt(0).TryGetNumber(First);
		bool bSecond = Values.GetValueAt(1).TryGetNumber(Second);
		return Values.Num() == 2 && bFirst && First == 42.0 && bSecond && Second == 1.5;
	}

	bool Observe_RemoveField_Nominal()
	{
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		Root.RemoveField("Name");
		Root.RemoveField("Missing");
		return !Root.HasField("Name") && !Root.HasField("Missing");
	}

	bool Observe_RemoveAllFields_Nominal()
	{
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		Root.SetNumberField("Score", 1.0);
		Root.RemoveAllFields();
		return !Root.HasField("Name") && !Root.HasField("Score");
	}

	bool Observe_SetStringField_Nominal()
	{
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		Root.SetStringField("Name", "Bob");
		return Root.GetStringField("Name") == "Bob";
	}

	bool Observe_SetNumberField_Nominal()
	{
		FJsonObject Root;
		Root.SetNumberField("Score", 1337.0);
		return Root.GetNumberField("Score") == 1337.0;
	}

	bool Observe_SetBoolField_Nominal()
	{
		FJsonObject Root;
		Root.SetBoolField("Enabled", true);
		Root.SetBoolField("Enabled", false);
		return !Root.GetBoolField("Enabled");
	}

	bool Observe_SetObjectField_Nominal()
	{
		FJsonObject Root;
		FJsonObject Child;
		Child.SetStringField("Label", "Nested");
		Root.SetObjectField("Child", Child);
		FJsonObject Read = Root.GetObjectField("Child");
		return Read.GetStringField("Label") == "Nested";
	}
}
/** @end */
