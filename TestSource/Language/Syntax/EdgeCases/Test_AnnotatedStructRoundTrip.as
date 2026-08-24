// Theme: Language.Syntax.EdgeCases. Positive annotated struct round-trip.
// C++: AngelscriptCompilerStructTests.cpp::AnnotatedStructRoundTrip
// sha256=cbaf4d7e4b76a51fc7a94161473244df8da2109d184ff404e1aff9c8449d1e59; lines 27-40.
// Oracle: Entry() returns 7. Extra: default Value is 7; a copy is independent.
// DefaultSafe.

USTRUCT()
struct FAnnotatedCarrier
{
	UPROPERTY()
	int Value = 7;
}

int Entry()
{
	FAnnotatedCarrier Carrier;
	return Carrier.Value;
}

bool Observe_AnnotatedStruct_Nominal()
{
	return Entry() == 7;
}

bool Observe_AnnotatedStruct_DefaultEmpty()
{
	FAnnotatedCarrier Carrier;
	return Carrier.Value == 7;
}

bool Observe_AnnotatedStruct_CopyIndependence()
{
	FAnnotatedCarrier Original;
	FAnnotatedCarrier Copied = Original;
	Copied.Value = 0;
	return Original.Value == 7 && Copied.Value == 0;
}
