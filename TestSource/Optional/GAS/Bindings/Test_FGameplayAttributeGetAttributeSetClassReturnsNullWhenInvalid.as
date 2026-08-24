// Theme: Optional.GAS. C++ ExecuteIntFunction InvalidAttributeSetClassIsNull == 1.
// CSV NegativeDiagnostic is a heuristic; default FGameplayAttribute class is null.
// C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::FGameplayAttributeGetAttributeSetClassReturnsNullWhenInvalid
// Extra: second default also null; empty tag.
// FixtureIsolated.

int InvalidAttributeSetClassIsNull()
{
	FGameplayAttribute Attr;
	return Attr.GetAttributeSetClass() == null ? 1 : 0;
}

int Observe_InvalidAttributeSetClassIsNull_Nominal()
{
	return InvalidAttributeSetClassIsNull();
}

int Observe_InvalidAttributeSetClassIsNull_SecondDefault()
{
	FGameplayAttribute First;
	FGameplayAttribute Second;
	if (First.GetAttributeSetClass() != null)
	{
		return 0;
	}
	if (Second.GetAttributeSetClass() != null)
	{
		return 0;
	}
	return 1;
}

int Observe_InvalidAttributeSetClassIsNull_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}
