// Purpose: Observe FString::Format with three to five ordered arguments and
// ApplyFormat for integer widths.
// AS-facing API: FString FString::Format(..., Arg0..Arg2/3/4);
// FString FString::ApplyFormat(int32/uint32/int64/uint64/int16/uint16/int8 Value, const FString& Specifier);
// Inputs: Format "{0},{1},{2}" and longer, values 0 and 7, specifier "x" as
// used by the existing ApplyFormat binding coverage, and empty specifier as
// a boundary.
// Expected observations: Ordered Format includes every argument. ApplyFormat
// of 255 with "x" is non-empty. Zero values still format.
// Boundary/ownership: Format/ApplyFormat return new strings. Specifier is
// copied and not retained.

namespace TS_FString_ConversionAndFormatting_02
{
	bool Observe_Format_Nominal()
	{
		FString Three = FString::Format("{0},{1},{2}", 1, 2, 3);
		FString Four = FString::Format("{0},{1},{2},{3}", 1, 2, 3, 4);
		FString Five = FString::Format("{0},{1},{2},{3},{4}", 1, 2, 3, 4, 5);
		return Three.Contains("1") && Three.Contains("3") && Four.Contains("4") && Five.Contains("5");
	}

	bool Observe_ApplyFormat_Nominal()
	{
		FString FromInt32 = FString::ApplyFormat(int32(255), "x");
		FString FromUint32 = FString::ApplyFormat(uint32(255), "x");
		FString FromInt64 = FString::ApplyFormat(int64(255), "x");
		FString FromUint64 = FString::ApplyFormat(uint64(255), "x");
		FString FromInt16 = FString::ApplyFormat(int16(255), "x");
		FString FromUint16 = FString::ApplyFormat(uint16(255), "x");
		FString FromInt8 = FString::ApplyFormat(int8(7), "x");
		FString FromZero = FString::ApplyFormat(int32(0), "x");
		return FromInt32.Len() > 0 && FromUint32.Len() > 0 && FromInt64.Len() > 0 && FromUint64.Len() > 0 && FromInt16.Len() > 0 && FromUint16.Len() > 0 && FromInt8.Len() > 0 && FromZero.Len() > 0;
	}
}
