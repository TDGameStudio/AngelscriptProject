/**
 * @version v1
 * @summary Observe Unix/HTTP/ISO formatting, format-string ToString, parse success and failure, and Today/FromUnixTimestamp.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Unix/HTTP/ISO formatting, format-string ToString, parse success and failure, and Today/FromUnixTimestamp.
 * @topic Baseline
 */
// FString FDateTime.ToHttpDate() const; FString FDateTime.ToIso8601() const;
// FString FDateTime.ToString(const FString& Format) const;
// FDateTime FDateTime::FromUnixTimestamp(int64 UnixTime);
// FDateTime FDateTime::Today(); bool FDateTime::Parse(const FString& DateTimeString, FDateTime& OutDateTime);
// bool FDateTime::ParseHttpDate(const FString& HttpDate, FDateTime& OutDateTime);
// bool FDateTime::ParseIso8601(const FString& DateTimeString, FDateTime& OutDateTime);
// FString FDateTime.ToString() const;
// Inputs: 2020-01-02 03:04:05, unix 0, empty/invalid parse text, ISO text
// produced by ToIso8601, and format "%Y".
// Expected observations: FromUnixTimestamp(0) is a valid date. Parse of the
// engine string succeeds. Parse of empty text fails. Today has zero time-of-day.
// Boundary/ownership: Parse writes OutDateTime only on success. Format strings
// are engine date-time specifiers, not printf.

namespace TS_FDateTime_ConversionAndFormatting_01
{
	bool Observe_ToUnixTimestamp_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		int64 Unix = DateTime.ToUnixTimestamp();
		FDateTime RoundTrip = FDateTime::FromUnixTimestamp(Unix);
		return Unix > 0 && RoundTrip.GetYear() == 2020 && RoundTrip.GetDay() == 2;
	}

	bool Observe_ToHttpDate_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FString Http = DateTime.ToHttpDate();
		return Http.Len() > 0;
	}

	bool Observe_ToIso8601_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FString Iso = DateTime.ToIso8601();
		return Iso.Len() > 0 && Iso.Contains("2020");
	}

	bool Observe_ToString_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FString DefaultText = DateTime.ToString();
		FString YearText = DateTime.ToString("%Y");
		return DefaultText.Len() > 0 && YearText == "2020";
	}

	bool Observe_FromUnixTimestamp_Nominal()
	{
		FDateTime Epoch = FDateTime::FromUnixTimestamp(0);
		FDateTime Later = FDateTime::FromUnixTimestamp(86400);
		return Epoch < Later && Epoch.GetYear() == 1970;
	}

	bool Observe_Today_Nominal()
	{
		FDateTime Today = FDateTime::Today();
		return Today.GetHour() == 0 && Today.GetMinute() == 0 && Today.GetSecond() == 0;
	}

	bool Observe_Parse_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FString EngineText = DateTime.ToString();
		FDateTime Parsed;
		bool bParsed = FDateTime::Parse(EngineText, Parsed);
		FDateTime Failed;
		bool bEmptyFailed = FDateTime::Parse("", Failed);
		return bParsed && Parsed == DateTime && !bEmptyFailed;
	}

	bool Observe_ParseHttpDate_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FString Http = DateTime.ToHttpDate();
		FDateTime Parsed;
		bool bParsed = FDateTime::ParseHttpDate(Http, Parsed);
		FDateTime Failed;
		bool bInvalidFailed = FDateTime::ParseHttpDate("not-a-date", Failed);
		return bParsed && !bInvalidFailed;
	}

	bool Observe_ParseIso8601_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FString Iso = DateTime.ToIso8601();
		FDateTime Parsed;
		bool bParsed = FDateTime::ParseIso8601(Iso, Parsed);
		FDateTime Failed;
		bool bInvalidFailed = FDateTime::ParseIso8601("not-iso", Failed);
		return bParsed && !bInvalidFailed;
	}
}
/** @end */
