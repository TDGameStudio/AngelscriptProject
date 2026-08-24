// Purpose: Observe Json::ParseString success and failure. The bool return is
// the runner-readable oracle.
// AS-facing API: FJsonObject Json::ParseString(const FString& JsonStr);
// Inputs: "{\"Name\":\"Alice\"}", empty string, and malformed "{".
// Expected observations: Valid object text yields IsValid true and Name
// Alice. Malformed text yields an invalid wrapper.
// Boundary/ownership: ParseString returns a wrapper; failure does not throw
// in the nominal API, it returns invalid.

namespace TS_Json_ConversionAndFormatting_01
{
	bool Observe_ParseString_Nominal()
	{
		FJsonObject Parsed = Json::ParseString("{\"Name\":\"Alice\"}");
		FJsonObject Empty = Json::ParseString("");
		FJsonObject Malformed = Json::ParseString("{");
		return Parsed.IsValid() && Parsed.GetStringField("Name") == "Alice" && !Empty.IsValid() && !Malformed.IsValid();
	}
}
