/**
 * @version v1
 * @summary Observe shared string formatter contributions for every registered primitive width, including bool and both float widths. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe shared string formatter contributions for every registered primitive width, including bool and both float widths. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// formatted text assigned into another FString.
// Expected observations: Formatted integers contain 7. Formatting 0 and false
// still produces text. Copied FString equals the source.
// Boundary/ownership: The formatter copies digits into a new FString. The
// primitive values remain independent of the formatted text.

namespace TS_Primitives_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		int8 Signed8 = 7;
		int16 Signed16 = 7;
		int32 Signed32 = 7;
		int64 Signed64 = 7;
		uint8 Unsigned8 = 7;
		uint16 Unsigned16 = 7;
		uint32 Unsigned32 = 7;
		uint64 Unsigned64 = 7;
		float32 Float32Value = 7.5;
		float64 Float64Value = 7.5;
		bool Flag = true;

		FString TextInt8 = f"{Signed8}";
		FString TextInt16 = f"{Signed16}";
		FString TextInt32 = f"{Signed32}";
		FString TextInt64 = f"{Signed64}";
		FString TextUInt8 = f"{Unsigned8}";
		FString TextUInt16 = f"{Unsigned16}";
		FString TextUInt32 = f"{Unsigned32}";
		FString TextUInt64 = f"{Unsigned64}";
		FString TextFloat32 = f"{Float32Value}";
		FString TextFloat64 = f"{Float64Value}";
		FString TextBool = f"{Flag}";

		int8 Zero8 = 0;
		bool FalseFlag = false;
		FString TextZero = f"{Zero8}";
		FString TextFalse = f"{FalseFlag}";
		FString Copied = TextInt32;
		return TextInt8 == "7" && TextInt16 == "7" && TextInt32 == "7" && TextInt64 == "7" && TextUInt8 == "7" && TextUInt16 == "7" && TextUInt32 == "7" && TextUInt64 == "7" && TextFloat32.Contains("7") && TextFloat64.Contains("7") && TextBool.Len() > 0 && TextZero == "0" && TextFalse.Len() > 0 && Copied == TextInt32;
	}
}
/** @end */
