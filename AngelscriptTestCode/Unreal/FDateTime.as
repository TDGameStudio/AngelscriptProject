/**
 * @version v1
 * @summary FDateTime host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FDateTime
 *
 * date-time
 * ordering
 * add-assign
 * subtract-assign
 * to-unix-timestamp
 * to-http-date
 * to-iso-8601
 * to-string
 * from-unix-timestamp
 * today
 * parse
 * parse-http-date
 * parse-iso-8601
 * append
 * days-in-month
 * days-in-year
 * now
 * utc-now
 * equality
 * addition
 * subtraction
 * get-date
 * get-day
 * get-day-of-year
 * get-hour
 * get-hour-12
 * get-millisecond
 * get-minute
 * get-month
 * get-second
 * get-year
 * is-afternoon
 * is-morning
 * get-ticks
 * is-leap-year
 * min-value
 * max-value
 */
/**
 * @begin date-time
 * @summary chronological.
 * @topic Unreal
 */
/**
 * @function ObserveDateTimeNominal
 * @summary chronological.
 * @covers FDateTime.date-time
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDateTimeNominal()
{
	FDateTime DateOnly(2020, 1, 2);
	FDateTime Explicit(2020, 1, 2, 3, 4, 5, 6);
	return DateOnly.GetHour() == 0 && DateOnly.GetMinute() == 0 && DateOnly.GetSecond() == 0 && DateOnly.GetMillisecond() == 0 && Explicit.GetHour() == 3 && Explicit.GetMillisecond() == 6;
}
/** @end */
/**
 * @begin ordering
 * @summary chronological.
 * @topic Unreal
 */
/**
 * @function ObserveOrderingNominal
 * @summary chronological.
 * @covers FDateTime.ordering
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOrderingNominal()
{
	FDateTime Earlier(2020, 1, 2);
	FDateTime Later(2020, 1, 3);
	return Earlier < Later && Earlier <= Later && Later > Earlier && Later >= Earlier && !(Later < Earlier);
}
/** @end */
/**
 * @begin add-assign
 * @summary not consumed.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary not consumed.
 * @covers FDateTime.add-assign
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FDateTime Original = DateTime;
	FTimespan OneDay = FTimespan::FromDays(1.0);
	DateTime += OneDay;
	DateTime += FTimespan::Zero();
	return DateTime.GetDay() == 3 && Original.GetDay() == 2;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary not consumed.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary not consumed.
 * @covers FDateTime.subtract-assign
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractAssignNominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FTimespan OneDay = FTimespan::FromDays(1.0);
	DateTime += OneDay;
	DateTime -= OneDay;
	FString Text = "when:";
	Text += DateTime;
	FString Empty = "";
	Empty += DateTime;
	return DateTime.GetDay() == 2 && DateTime.GetHour() == 3 && Text.Len() > 5 && Empty.Len() > 0;
}
/** @end */
/**
 * @begin to-unix-timestamp
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveToUnixTimestampNominal
 * @summary Expected
 * @covers FDateTime.to-unix-timestamp
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: FromUnixTimestamp(0) is a valid date. Parse of the
// engine string succeeds. Parse of empty text fails. Today has zero time-of-day.
// Boundary/ownership: Parse writes OutDateTime only on success. Format strings
// are engine date-time specifiers, not printf.
bool ObserveToUnixTimestampNominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	int64 Unix = DateTime.ToUnixTimestamp();
	FDateTime RoundTrip = FDateTime::FromUnixTimestamp(Unix);
	return Unix > 0 && RoundTrip.GetYear() == 2020 && RoundTrip.GetDay() == 2;
}
/** @end */
/**
 * @begin to-http-date
 * @summary are engine date-time specifiers, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveToHttpDateNominal
 * @summary are engine date-time specifiers, not printf.
 * @covers FDateTime.to-http-date
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveToHttpDateNominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FString Http = DateTime.ToHttpDate();
	return Http.Len() > 0;
}
/** @end */
/**
 * @begin to-iso-8601
 * @summary are engine date-time specifiers, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveToIso8601Nominal
 * @summary are engine date-time specifiers, not printf.
 * @covers FDateTime.to-iso-8601
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveToIso8601Nominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FString Iso = DateTime.ToIso8601();
	return Iso.Len() > 0 && Iso.Contains("2020");
}
/** @end */
/**
 * @begin to-string
 * @summary are engine date-time specifiers, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary are engine date-time specifiers, not printf.
 * @covers FDateTime.to-string
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveToStringNominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FString DefaultText = DateTime.ToString();
	FString YearText = DateTime.ToString("%Y");
	return DefaultText.Len() > 0 && YearText == "2020";
}
/** @end */
/**
 * @begin from-unix-timestamp
 * @summary are engine date-time specifiers, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveFromUnixTimestampNominal
 * @summary are engine date-time specifiers, not printf.
 * @covers FDateTime.from-unix-timestamp
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFromUnixTimestampNominal()
{
	FDateTime Epoch = FDateTime::FromUnixTimestamp(0);
	FDateTime Later = FDateTime::FromUnixTimestamp(86400);
	return Epoch < Later && Epoch.GetYear() == 1970;
}
/** @end */
/**
 * @begin today
 * @summary are engine date-time specifiers, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveTodayNominal
 * @summary are engine date-time specifiers, not printf.
 * @covers FDateTime.today
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveTodayNominal()
{
	FDateTime Today = FDateTime::Today();
	return Today.GetHour() == 0 && Today.GetMinute() == 0 && Today.GetSecond() == 0;
}
/** @end */
/**
 * @begin parse
 * @summary are engine date-time specifiers, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveParseNominal
 * @summary are engine date-time specifiers, not printf.
 * @covers FDateTime.parse
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveParseNominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FString EngineText = DateTime.ToString();
	FDateTime Parsed;
	bool bParsed = FDateTime::Parse(EngineText, Parsed);
	FDateTime Failed;
	bool bEmptyFailed = FDateTime::Parse("", Failed);
	return bParsed && Parsed == DateTime && !bEmptyFailed;
}
/** @end */
/**
 * @begin parse-http-date
 * @summary are engine date-time specifiers, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveParseHttpDateNominal
 * @summary are engine date-time specifiers, not printf.
 * @covers FDateTime.parse-http-date
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveParseHttpDateNominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FString Http = DateTime.ToHttpDate();
	FDateTime Parsed;
	bool bParsed = FDateTime::ParseHttpDate(Http, Parsed);
	FDateTime Failed;
	bool bInvalidFailed = FDateTime::ParseHttpDate("not-a-date", Failed);
	return bParsed && !bInvalidFailed;
}
/** @end */
/**
 * @begin parse-iso-8601
 * @summary are engine date-time specifiers, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveParseIso8601Nominal
 * @summary are engine date-time specifiers, not printf.
 * @covers FDateTime.parse-iso-8601
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveParseIso8601Nominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FString Iso = DateTime.ToIso8601();
	FDateTime Parsed;
	bool bParsed = FDateTime::ParseIso8601(Iso, Parsed);
	FDateTime Failed;
	bool bInvalidFailed = FDateTime::ParseIso8601("not-iso", Failed);
	return bParsed && !bInvalidFailed;
}
/** @end */
/**
 * @begin append
 * @summary value,
 * @topic Unreal
 */
/**
 * @function ObserveAppendNominal
 * @summary value,
 * @covers FDateTime.append
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
// value,

 and Empty() as cleanup.
// Expected observations: First append increases length. Second append grows
// further. Empty restores length 0.
// Boundary/ownership: Append copies formatted date-time text into the string.
// The FDateTime value is not mutated.
bool ObserveAppendNominal()
{
	FString Text = "when:";
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	int Before = Text.Len();
	Text.Append(DateTime);
	int AfterFirst = Text.Len();
	Text.Append(DateTime);
	int AfterSecond = Text.Len();
	Text.Empty();
	return AfterFirst > Before && AfterSecond > AfterFirst && Text.Len() == 0;
}
/** @end */
/**
 * @begin days-in-month
 * @summary objects beyond the returned value type.
 * @topic Unreal
 */
/**
 * @function ObserveDaysInMonthNominal
 * @summary objects beyond the returned value type.
 * @covers FDateTime.days-in-month
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDaysInMonthNominal()
{
	int LeapFebruary = FDateTime::DaysInMonth(2020, 2);
	int CommonFebruary = FDateTime::DaysInMonth(2019, 2);
	int January = FDateTime::DaysInMonth(2020, 1);
	return LeapFebruary == 29 && CommonFebruary == 28 && January == 31;
}
/** @end */
/**
 * @begin days-in-year
 * @summary objects beyond the returned value type.
 * @topic Unreal
 */
/**
 * @function ObserveDaysInYearNominal
 * @summary objects beyond the returned value type.
 * @covers FDateTime.days-in-year
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDaysInYearNominal()
{
	int LeapYear = FDateTime::DaysInYear(2020);
	int CommonYear = FDateTime::DaysInYear(2019);
	return LeapYear == 366 && CommonYear == 365;
}
/** @end */
/**
 * @begin now
 * @summary objects beyond the returned value type.
 * @topic Unreal
 */
/**
 * @function ObserveNowNominal
 * @summary objects beyond the returned value type.
 * @covers FDateTime.now
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveNowNominal()
{
	FDateTime Now = FDateTime::Now();
	return Now > FDateTime::MinValue();
}
/** @end */
/**
 * @begin utc-now
 * @summary objects beyond the returned value type.
 * @topic Unreal
 */
/**
 * @function ObserveUtcNowNominal
 * @summary objects beyond the returned value type.
 * @covers FDateTime.utc-now
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUtcNowNominal()
{
	FDateTime UtcNow = FDateTime::UtcNow();
	return UtcNow > FDateTime::MinValue();
}
/** @end */
/**
 * @begin equality
 * @summary counterpart and is not used here.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary counterpart and is not used here.
 * @covers FDateTime.equality
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FDateTime Left(2020, 1, 2, 3, 4, 5);
	FDateTime Right(2020, 1, 2, 3, 4, 5);
	FDateTime Later(2020, 1, 3);
	return Left == Right && !(Left == Later);
}
/** @end */
/**
 * @begin addition
 * @summary counterpart and is not used here.
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary counterpart and is not used here.
 * @covers FDateTime.addition
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAdditionNominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FTimespan OneDay = FTimespan::FromDays(1.0);
	FDateTime Offset = DateTime + OneDay;
	FString Prefix = "when:";
	FString Combined = Prefix + DateTime;
	return Offset.GetDay() == 3 && DateTime.GetDay() == 2 && Combined.Len() > Prefix.Len() && Prefix == "when:";
}
/** @end */
/**
 * @begin subtraction
 * @summary counterpart and is not used here.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractionNominal
 * @summary counterpart and is not used here.
 * @covers FDateTime.subtraction
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractionNominal()
{
	FDateTime Start(2020, 1, 2);
	FDateTime End(2020, 1, 3);
	FTimespan Delta = End - Start;
	FTimespan OneHour = FTimespan::FromHours(1.0);
	FDateTime Back = End - OneHour;
	return Delta.GetDays() == 1 && Back < End;
}
/** @end */
/**
 * @begin get-date
 * @summary by the void overload and do not own the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetDateNominal
 * @summary by the void overload and do not own the receiver.
 * @covers FDateTime.get-date
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDateNominal()
{
	FDateTime DateTime(2020, 2, 1, 13, 4, 5, 6);
	FDateTime DateOnly = DateTime.GetDate();
	int OutYear = -1;
	int OutMonth = -1;
	int OutDay = -1;
	DateTime.GetDate(OutYear, OutMonth, OutDay);
	return DateOnly.GetHour() == 0 && DateOnly.GetMinute() == 0 && DateOnly.GetDay() == 1 && OutYear == 2020 && OutMonth == 2 && OutDay == 1;
}
/** @end */
/**
 * @begin get-day
 * @summary by the void overload and do not own the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetDayNominal
 * @summary by the void overload and do not own the receiver.
 * @covers FDateTime.get-day
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDayNominal()
{
	FDateTime DateTime(2020, 2, 1);
	return DateTime.GetDay() == 1;
}
/** @end */
/**
 * @begin get-day-of-year
 * @summary by the void overload and do not own the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetDayOfYearNominal
 * @summary by the void overload and do not own the receiver.
 * @covers FDateTime.get-day-of-year
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDayOfYearNominal()
{
	FDateTime DateTime(2020, 2, 1);
	return DateTime.GetDayOfYear() == 32;
}
/** @end */
/**
 * @begin get-hour
 * @summary by the void overload and do not own the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetHourNominal
 * @summary by the void overload and do not own the receiver.
 * @covers FDateTime.get-hour
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetHourNominal()
{
	FDateTime Afternoon(2020, 2, 1, 13);
	FDateTime Midnight(2020, 2, 1);
	return Afternoon.GetHour() == 13 && Midnight.GetHour() == 0;
}
/** @end */
/**
 * @begin get-hour-12
 * @summary by the void overload and do not own the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetHour12Nominal
 * @summary by the void overload and do not own the receiver.
 * @covers FDateTime.get-hour-12
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetHour12Nominal()
{
	FDateTime Afternoon(2020, 2, 1, 13);
	return Afternoon.GetHour12() == 1;
}
/** @end */
/**
 * @begin get-millisecond
 * @summary by the void overload and do not own the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetMillisecondNominal
 * @summary by the void overload and do not own the receiver.
 * @covers FDateTime.get-millisecond
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMillisecondNominal()
{
	FDateTime DateTime(2020, 2, 1, 13, 4, 5, 6);
	return DateTime.GetMillisecond() == 6;
}
/** @end */
/**
 * @begin get-minute
 * @summary by the void overload and do not own the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetMinuteNominal
 * @summary by the void overload and do not own the receiver.
 * @covers FDateTime.get-minute
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMinuteNominal()
{
	FDateTime DateTime(2020, 2, 1, 13, 4, 5);
	return DateTime.GetMinute() == 4;
}
/** @end */
/**
 * @begin get-month
 * @summary by the void overload and do not own the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetMonthNominal
 * @summary by the void overload and do not own the receiver.
 * @covers FDateTime.get-month
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMonthNominal()
{
	FDateTime DateTime(2020, 2, 1);
	return DateTime.GetMonth() == 2;
}
/** @end */
/**
 * @begin get-second
 * @summary by the void overload and do not own the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetSecondNominal
 * @summary by the void overload and do not own the receiver.
 * @covers FDateTime.get-second
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetSecondNominal()
{
	FDateTime DateTime(2020, 2, 1, 13, 4, 5);
	return DateTime.GetSecond() == 5;
}
/** @end */
/**
 * @begin get-year
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @topic Unreal
 */
/**
 * @function ObserveGetYearNominal
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @covers FDateTime.get-year
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetYearNominal()
{
	FDateTime DateTime(2020, 2, 1);
	return DateTime.GetYear() == 2020;
}
/** @end */
/**
 * @begin is-afternoon
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @topic Unreal
 */
/**
 * @function ObserveIsAfternoonNominal
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @covers FDateTime.is-afternoon
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsAfternoonNominal()
{
	FDateTime Afternoon(2020, 2, 1, 13);
	FDateTime Morning(2020, 2, 1, 9);
	return Afternoon.IsAfternoon() && !Morning.IsAfternoon();
}
/** @end */
/**
 * @begin is-morning
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @topic Unreal
 */
/**
 * @function ObserveIsMorningNominal
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @covers FDateTime.is-morning
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsMorningNominal()
{
	FDateTime Afternoon(2020, 2, 1, 13);
	FDateTime Morning(2020, 2, 1, 9);
	return Morning.IsMorning() && !Afternoon.IsMorning();
}
/** @end */
/**
 * @begin get-ticks
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @topic Unreal
 */
/**
 * @function ObserveGetTicksNominal
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @covers FDateTime.get-ticks
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTicksNominal()
{
	FDateTime Earlier(2020, 2, 1);
	FDateTime Later(2020, 2, 2);
	return Later.GetTicks() > Earlier.GetTicks();
}
/** @end */
/**
 * @begin is-leap-year
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeapYearNominal
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @covers FDateTime.is-leap-year
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeapYearNominal()
{
	return FDateTime::IsLeapYear(2020) && !FDateTime::IsLeapYear(2019);
}
/** @end */
/**
 * @begin min-value
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @topic Unreal
 */
/**
 * @function ObserveMinValueNominal
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @covers FDateTime.min-value
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMinValueNominal()
{
	FDateTime MinValue = FDateTime::MinValue();
	FDateTime Sample(2020, 1, 1);
	return MinValue < Sample;
}
/** @end */
/**
 * @begin max-value
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @topic Unreal
 */
/**
 * @function ObserveMaxValueNominal
 * @summary IsLeapYear does not require a constructed FDateTime instance.
 * @covers FDateTime.max-value
 * @inputs FDateTime values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMaxValueNominal()
{
	FDateTime MaxValue = FDateTime::MaxValue();
	FDateTime MinValue = FDateTime::MinValue();
	return MaxValue > MinValue;
}
/** @end */
