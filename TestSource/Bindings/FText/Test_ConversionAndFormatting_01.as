// Purpose: Observe FText factories from tables/names/strings and localized
// date/time/number formatting.
// AS-facing API: FText::FromStringTable; FromName; FromString; AsCultureInvariant;
// AsDate; AsDateTime; AsTime; AsTimespan; AsNumber(float32/float64).
// Inputs: Missing table/key with Find policy, n"Alpha", "Hello", empty string,
// DateTime 2020-01-02, Timespan one hour, 0.0 and 1.5 with default options.
// Expected observations: FromString("Hello") is not empty. FromName text
// contains Alpha. Date/time/timespan formatters return non-empty display
// strings. AsNumber of 0 still produces text.
// Boundary/ownership: FromStringTable with Find does not create a table.
// Formatters return new FText values.

namespace TS_FText_ConversionAndFormatting_01
{
	bool Observe_FromStringTable_Nominal()
	{
		FText Missing = FText::FromStringTable(n"TestSource.MissingTable", "MissingKey");
		FText WithPolicy = FText::FromStringTable(n"TestSource.MissingTable", "MissingKey", EStringTableLoadingPolicy::Find);
		return (Missing.IsEmpty() || !Missing.IsFromStringTable()) && (WithPolicy.IsEmpty() || !WithPolicy.IsFromStringTable());
	}

	bool Observe_FromName_Nominal()
	{
		FText Text = FText::FromName(n"Alpha");
		FText NoneText = FText::FromName(NAME_None);
		return Text.ToString().Contains("Alpha") && NoneText.ToString() != Text.ToString();
	}

	bool Observe_FromString_Nominal()
	{
		FText Text = FText::FromString("Hello");
		FText Empty = FText::FromString("");
		return !Text.IsEmpty() && Empty.IsEmpty();
	}

	bool Observe_AsCultureInvariant_Nominal()
	{
		FText Text = FText::AsCultureInvariant("Hello");
		return Text.IsCultureInvariant() && Text.ToString().Contains("Hello");
	}

	bool Observe_AsDate_Nominal()
	{
		FDateTime DateTime(2020, 1, 2);
		FText DefaultText = FText::AsDate(DateTime);
		FText ShortText = FText::AsDate(DateTime, EDateTimeStyle::Short);
		return DefaultText.ToString().Len() > 0 && ShortText.ToString().Len() > 0;
	}

	bool Observe_AsDateTime_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FText Text = FText::AsDateTime(DateTime);
		FText Styled = FText::AsDateTime(DateTime, EDateTimeStyle::Short, EDateTimeStyle::Short);
		return Text.ToString().Len() > 0 && Styled.ToString().Len() > 0;
	}

	bool Observe_AsTime_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FText Text = FText::AsTime(DateTime);
		return Text.ToString().Len() > 0;
	}

	bool Observe_AsTimespan_Nominal()
	{
		FTimespan Span = FTimespan::FromHours(1.0);
		FText Text = FText::AsTimespan(Span);
		FText Zero = FText::AsTimespan(FTimespan::Zero());
		return Text.ToString().Len() > 0 && Zero.ToString().Len() > 0;
	}

	bool Observe_AsNumber_Nominal()
	{
		FNumberFormattingOptions Options;
		FText FromFloat32 = FText::AsNumber(float32(1.5), Options);
		FText FromFloat64 = FText::AsNumber(float64(0.0), Options);
		return FromFloat32.ToString().Len() > 0 && FromFloat64.ToString().Len() > 0;
	}
}
