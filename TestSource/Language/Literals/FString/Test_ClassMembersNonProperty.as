// Theme: Language.Literals.FString. C++ compiles this module then ExecuteAndExpectException
// on TestClassMember* with "Null pointer access". CSV marks NegativeDiagnostic; the method
// is a lifecycle oracle, not a compile-fail.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::ClassMembersNonProperty
// sha256=667036feb83c3973e54dc05fcf04024083b78ac2ab550aa1e3ee6d497e05b991; lines 797-856.
// Oracle: module compiles; TestClassMemberAccess/Modify/Name/Text throw Null pointer access.
// Extra: default-constructed script class members remain the execution boundary.
// DiagnosticOnly for the expected null-pointer messages; declarations remain runner-readable.

class StringHolder
{
	FString Value;
	FName NameValue;
	FText TextValue;

	StringHolder()
	{
		Value = "Initial";
		NameValue = n"Tag";
		TextValue = FText::FromString("TextMember");
	}

	FString GetValue() const
	{
		return Value;
	}

	void SetValue(FString v)
	{
		Value = v;
	}

	FName GetNameValue() const
	{
		return NameValue;
	}

	FString GetTextValue() const
	{
		return TextValue.ToString();
	}
}

FString TestClassMemberAccess()
{
	StringHolder holder;
	return holder.Value;
}

FString TestClassMemberModify()
{
	StringHolder holder;
	holder.Value = "Modified";
	return holder.GetValue();
}

FName TestClassMemberName()
{
	StringHolder holder;
	return holder.NameValue;
}

FString TestClassMemberText()
{
	StringHolder holder;
	return holder.GetTextValue();
}
