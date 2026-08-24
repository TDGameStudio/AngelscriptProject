// Purpose: Observe FormatAngelscriptCallstack as formatted callstack text.
// AS-facing API: FString FormatAngelscriptCallstack();
// Inputs: The current executing function as a representative non-empty stack,
// compared against an empty FString default. No precision specifier applies.
// Expected observations: The formatted text is non-empty and differs from "".
// Boundary/ownership: The returned FString is an independent copy. Formatting
// does not mutate the live script callstack.

namespace TS_Debugging_ConversionAndFormatting_01
{
	bool Observe_FormatAngelscriptCallstack_Nominal()
	{
		FString Formatted = FormatAngelscriptCallstack();
		FString Empty = "";
		return Formatted.Len() > 0 && Formatted != Empty;
	}
}
