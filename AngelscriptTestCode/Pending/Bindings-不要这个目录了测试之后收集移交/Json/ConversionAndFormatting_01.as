/**
 * @version v1
 * @summary Observe Json::ParseString success and failure. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Json::ParseString success and failure. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
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
/** @end */
