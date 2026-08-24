// Theme: Optional.GAS. C++ ExpectGlobalInt Attribute_DefaultInvalid == 1.
// CSV NegativeDiagnostic is a heuristic; default FGameplayAttribute is the
// false/invalid vector, not a compile failure.
// C++: AngelscriptGASExtendedBindingsTests.cpp::FGameplayAttributeDefault
// Extra: second default also invalid; empty tag.
// FixtureIsolated.

int Attribute_DefaultInvalid()
{
	FGameplayAttribute Attr;
	return Attr.IsValid() ? 0 : 1;
}

int Observe_Attribute_DefaultInvalid_Nominal()
{
	return Attribute_DefaultInvalid();
}

int Observe_Attribute_DefaultInvalid_SecondDefault()
{
	FGameplayAttribute First;
	FGameplayAttribute Second;
	if (First.IsValid())
	{
		return 0;
	}
	if (Second.IsValid())
	{
		return 0;
	}
	return 1;
}

int Observe_Attribute_DefaultInvalid_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}
