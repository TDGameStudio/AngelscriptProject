// Purpose: Observe UObject.ToString for live and null handles.
// Runner owns the live UObject fixture.
// AS-facing API: FString UObject.ToString() const;
// Inputs: Runner-supplied UObject whose name contains ExpectedName, plus a
// null UObject.
// Expected observations: Live ToString is non-empty and contains ExpectedName.
// Repeating ToString returns equivalent text.
// Boundary/ownership: ToString returns a new FString. It does not mutate the
// UObject. SetupOwner=Runner.

namespace TS_UObject_ConversionAndFormatting_01
{
	bool Observe_ToString_Nominal(UObject Object, const FString& ExpectedName)
	{
		if (Object is null)
		{
			throw("TS_UObject_ConversionAndFormatting_01 setup: required Object is null");
		}
		FString Text = Object.ToString();
		FString Repeated = Object.ToString();
		return Text.Len() > 0 && Text.Contains(ExpectedName) && Repeated == Text;
	}
}
