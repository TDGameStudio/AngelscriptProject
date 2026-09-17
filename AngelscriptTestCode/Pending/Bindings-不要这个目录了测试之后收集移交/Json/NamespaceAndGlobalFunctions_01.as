/**
 * @version v1
 * @summary Observe EJsonType enumerators and Json::ValueTypeToString. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe EJsonType enumerators and Json::ValueTypeToString. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// FString Json::ValueTypeToString(EJsonType T);
// Inputs: Each enumerator, including None as the empty/invalid kind.
// Expected observations: Enumerators are distinct. ValueTypeToString of
// String is "String" and differs from None.
// Boundary/ownership: ValueTypeToString returns a stable display name and
// does not allocate a JSON value.

namespace TS_Json_NamespaceAndGlobalFunctions_01
{
	// EJsonType::None is distinct from Null.
	bool Observe_Surface002_Nominal()
	{
		return EJsonType::None != EJsonType::Null;
	}

	// EJsonType::Null is distinct from String.
	bool Observe_Surface003_Nominal()
	{
		return EJsonType::Null != EJsonType::String;
	}

	// EJsonType::String is distinct from Number.
	bool Observe_Surface004_Nominal()
	{
		return EJsonType::String != EJsonType::Number;
	}

	// EJsonType::Number is distinct from Boolean.
	bool Observe_Surface005_Nominal()
	{
		return EJsonType::Number != EJsonType::Boolean;
	}

	// EJsonType::Boolean is distinct from Array.
	bool Observe_Surface006_Nominal()
	{
		return EJsonType::Boolean != EJsonType::Array;
	}

	// EJsonType::Array is distinct from Object.
	bool Observe_Surface007_Nominal()
	{
		return EJsonType::Array != EJsonType::Object;
	}

	// EJsonType::Object is distinct from None.
	bool Observe_Surface008_Nominal()
	{
		return EJsonType::Object != EJsonType::None;
	}

	// ValueTypeToString maps None and String to their stable display names.
	bool Observe_ValueTypeToString_Nominal()
	{
		FString NoneText = Json::ValueTypeToString(EJsonType::None);
		FString StringText = Json::ValueTypeToString(EJsonType::String);
		return NoneText == "None" && StringText == "String" && StringText != NoneText;
	}

	void ExerciseExpectedFailure()
	{
		FJsonObject Parsed = Json::ParseString("{");
		FString Name = Parsed.GetStringField("Name");
	}
}
/** @end */
