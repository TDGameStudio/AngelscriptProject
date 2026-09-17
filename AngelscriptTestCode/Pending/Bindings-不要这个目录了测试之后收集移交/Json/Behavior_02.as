/**
 * @version v1
 * @summary Observe TryGet* conversions, array/object constructors, field TryGet helpers, and iterator CanProceed. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TryGet* conversions, array/object constructors, field TryGet helpers, and iterator CanProceed. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// FJsonObject Value(const FJsonObject& InObject); FJsonObject Value();
// TryGetObjectField; TryGetArrayField; CanProceed.
// Inputs: String/bool/array/object JSON values, empty constructors, shared
// object copy, missing field names.
// Expected observations: Matching TryGet returns true and writes the out
// value. Type mismatch returns false. Empty array Num is 0. Copy constructor
// shares HasField. CanProceed is false on an empty iterator.
// Boundary/ownership: FJsonObject copy shares the underlying JSON object.

namespace TS_Json_Behavior_02
{
	// TryGetString writes Alice from a string value and fails on a number.
	bool Observe_TryGetString_Nominal()
	{
		FJsonArray Values;
		Values.AddString("Alice");
		Values.AddNumber(42);
		FJsonValue Value = Values.GetValueAt(0);
		FString Text = "seed";
		bool bGot = Value.TryGetString(Text);
		FString Failed = "seed";
		bool bNumberAsString = Values.GetValueAt(1).TryGetString(Failed);
		return bGot && Text == "Alice" && !bNumberAsString;
	}

	// TryGetBool writes true from a Boolean field value and fails on a string.
	bool Observe_TryGetBool_Nominal()
	{
		FJsonObject Root;
		Root.SetBoolField("Enabled", true);
		FJsonObjectFieldIterator It = Root.Iterator();
		It.Proceed();
		FJsonValue Enabled = It.GetValue();
		bool OutValue = false;
		bool bGot = Enabled.TryGetBool(OutValue);
		FJsonArray Values;
		Values.AddString("x");
		FJsonValue NotBool = Values.GetValueAt(0);
		bool Mismatch = false;
		bool bMismatch = NotBool.TryGetBool(Mismatch);
		return bGot && OutValue && Root.GetBoolField("Enabled") && !bMismatch;
	}

	// TryGetArray fails on a string element; TryGetArrayField writes Num 1.
	bool Observe_TryGetArray_Nominal()
	{
		FJsonObject Root;
		FJsonArray Values;
		Values.AddString("First");
		Root.SetArrayField("Values", Values);
		FJsonValue AsValue = Root.GetArrayField("Values").GetValueAt(0);
		FJsonArray OutArray;
		bool bFromStringValue = AsValue.TryGetArray(OutArray);
		FJsonArray Read;
		bool bFromField = Root.TryGetArrayField("Values", Read);
		return bFromField && Read.Num() == 1 && !bFromStringValue;
	}

	// TryGetObject fails on a string value; GetObjectField Child is valid.
	bool Observe_TryGetObject_Nominal()
	{
		FJsonObject Root;
		FJsonObject Child = Root.CreateObjectField("Child");
		Child.SetStringField("Label", "Nested");
		FJsonObjectFieldIterator It = Root.Iterator();
		It.Proceed();
		FJsonValue ObjectValue = It.GetValue();
		FJsonObject OutObject;
		bool bGot = ObjectValue.TryGetObject(OutObject);
		FJsonArray Values;
		Values.AddString("x");
		FJsonValue NotObject = Values.GetValueAt(0);
		FJsonObject MismatchObject;
		bool bMismatch = NotObject.TryGetObject(MismatchObject);
		return bGot && OutObject.GetStringField("Label") == "Nested" && !bMismatch && Root.GetObjectField("Child").IsValid();
	}

	// Empty array Num is 0, empty object IsValid, copy shares Name.
	bool Observe_Value_Nominal()
	{
		FJsonArray EmptyArray;
		FJsonObject EmptyObject;
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		FJsonObject Shared(Root);
		return EmptyArray.Num() == 0 && EmptyObject.IsValid() && Shared.HasField("Name") && Shared.GetStringField("Name") == "Alice";
	}

	// TryGetObjectField writes Nested Label and returns false for Missing.
	bool Observe_TryGetObjectField_Nominal()
	{
		FJsonObject Root;
		FJsonObject Child = Root.CreateObjectField("Child");
		Child.SetStringField("Label", "Nested");
		FJsonObject OutObject;
		bool bGot = Root.TryGetObjectField("Child", OutObject);
		FJsonObject Missing;
		bool bMissing = Root.TryGetObjectField("Missing", Missing);
		return bGot && OutObject.GetStringField("Label") == "Nested" && !bMissing;
	}

	// TryGetArrayField writes Num 1 and returns false for Missing.
	bool Observe_TryGetArrayField_Nominal()
	{
		FJsonObject Root;
		FJsonArray Values;
		Values.AddString("First");
		Root.SetArrayField("Values", Values);
		FJsonArray OutArray;
		bool bGot = Root.TryGetArrayField("Values", OutArray);
		FJsonArray Missing;
		bool bMissing = Root.TryGetArrayField("Missing", Missing);
		return bGot && OutArray.Num() == 1 && !bMissing;
	}

	// Empty FJsonObjectFieldIterator.CanProceed is false.
	bool Observe_Surface053_Nominal()
	{
		FJsonObject Empty;
		FJsonObjectFieldIterator It = Empty.Iterator();
		return !It.CanProceed;
	}
}
/** @end */
