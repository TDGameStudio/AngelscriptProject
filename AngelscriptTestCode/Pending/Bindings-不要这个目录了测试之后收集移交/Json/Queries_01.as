/**
 * @version v1
 * @summary Observe JSON value type/null, array count/index, and object field getters. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe JSON value type/null, array count/index, and object field getters. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// int32 FJsonArray.Num() const; FJsonValue FJsonArray.GetValueAt(int32 Index) const;
// bool FJsonObject.IsValid() const; bool FJsonObject.HasField(const FString& FieldName) const;
// GetStringField/GetNumberField/GetBoolField/GetObjectField.
// Inputs: Empty value/array/object, object with Name/Score/Enabled/Child,
// array of two strings, missing field name, index 0.
// Expected observations: Empty value type is None and IsNull is false unless
// explicitly null. Num matches appended elements. GetValueAt(0) is a string.
// HasField is true/false accordingly.
// Boundary/ownership: Get*Field on a missing name is the diagnostic path.

namespace TS_Json_Queries_01
{
	bool Observe_GetType_Nominal()
	{
		FJsonValue Empty;
		FJsonArray Values;
		Values.AddString("First");
		FJsonValue First = Values.GetValueAt(0);
		return Empty.GetType() == EJsonType::None && First.GetType() == EJsonType::String;
	}

	bool Observe_IsNull_Nominal()
	{
		FJsonValue Empty;
		FJsonObject Root = Json::ParseString("{\"X\":null}");
		FJsonObjectFieldIterator It = Root.Iterator();
		It.Proceed();
		FJsonValue NullValue = It.GetValue();
		return !Empty.IsNull() && NullValue.IsNull();
	}

	bool Observe_Num_Nominal()
	{
		FJsonArray Empty;
		FJsonArray Values;
		Values.AddString("First");
		Values.AddString("Second");
		return Empty.Num() == 0 && Values.Num() == 2;
	}

	bool Observe_GetValueAt_Nominal()
	{
		FJsonArray Values;
		Values.AddString("First");
		FJsonValue First = Values.GetValueAt(0);
		FString Text;
		bool bGot = First.TryGetString(Text);
		return First.GetType() == EJsonType::String && bGot && Text == "First";
	}

	bool Observe_IsValid_Nominal()
	{
		FJsonObject Root;
		FJsonObject Parsed = Json::ParseString("{");
		return Root.IsValid() && !Parsed.IsValid();
	}

	bool Observe_HasField_Nominal()
	{
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		return Root.HasField("Name") && !Root.HasField("Missing");
	}

	bool Observe_GetStringField_Nominal()
	{
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		return Root.GetStringField("Name") == "Alice";
	}

	bool Observe_GetNumberField_Nominal()
	{
		FJsonObject Root;
		Root.SetNumberField("Score", 1337.0);
		return Root.GetNumberField("Score") == 1337.0;
	}

	bool Observe_GetBoolField_Nominal()
	{
		FJsonObject Root;
		Root.SetBoolField("Enabled", true);
		Root.SetBoolField("Disabled", false);
		return Root.GetBoolField("Enabled") && !Root.GetBoolField("Disabled");
	}

	bool Observe_GetObjectField_Nominal()
	{
		FJsonObject Root;
		FJsonObject Child = Root.CreateObjectField("Child");
		Child.SetStringField("Label", "Nested");
		FJsonObject Read = Root.GetObjectField("Child");
		return Read.IsValid() && Read.GetStringField("Label") == "Nested";
	}

	void ExerciseExpectedFailure()
	{
		FJsonObject Root;
		FString Missing = Root.GetStringField("Missing");
	}
}
/** @end */
