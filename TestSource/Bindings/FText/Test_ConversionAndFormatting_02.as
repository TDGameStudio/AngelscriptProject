// Purpose: Observe integer AsNumber overloads, AsMemory, and single-argument
// FText::Format.
// AS-facing API: FText FText::AsNumber(int8/int16/int32/int64/uint8/uint16/uint32/uint64);
// FText FText::AsMemory(uint64 NumBytes);
// FText FText::Format(const FText& Format, const ?& Arg0);
// Inputs: 0 and 7 for integer widths, 0 and 1024 bytes, pattern "{0}".
// Expected observations: AsNumber text is non-empty for 0 and 7. AsMemory of
// 1024 is non-empty. Format substitutes Arg0.
// Boundary/ownership: Options are copied into the formatter. Format returns
// new FText and does not mutate the pattern.

namespace TS_FText_ConversionAndFormatting_02
{
	bool Observe_AsNumber_Nominal()
	{
		FNumberFormattingOptions Options;
		FText FromInt8 = FText::AsNumber(int8(7), Options);
		FText FromInt16 = FText::AsNumber(int16(7), Options);
		FText FromInt32 = FText::AsNumber(int32(7), Options);
		FText FromInt64 = FText::AsNumber(int64(7), Options);
		FText FromUint8 = FText::AsNumber(uint8(7), Options);
		FText FromUint16 = FText::AsNumber(uint16(7), Options);
		FText FromUint32 = FText::AsNumber(uint32(7), Options);
		FText FromUint64 = FText::AsNumber(uint64(0), Options);
		return FromInt8.ToString().Len() > 0 && FromInt16.ToString().Len() > 0 && FromInt32.ToString().Contains("7") && FromInt64.ToString().Len() > 0 && FromUint8.ToString().Len() > 0 && FromUint16.ToString().Len() > 0 && FromUint32.ToString().Len() > 0 && FromUint64.ToString().Len() > 0;
	}

	bool Observe_AsMemory_Nominal()
	{
		FText Zero = FText::AsMemory(0);
		FText Kilo = FText::AsMemory(1024);
		return Zero.ToString().Len() > 0 && Kilo.ToString().Len() > 0;
	}

	bool Observe_Format_Nominal()
	{
		FText Pattern = FText::FromString("{0}");
		FText Formatted = FText::Format(Pattern, 7);
		FText EmptyArg = FText::Format(Pattern, "");
		return Formatted.ToString().Contains("7") && !EmptyArg.ToString().Contains("7");
	}
}
