/**
 * @version v1
 * @summary Observe FName default/copy/string constructors, NAME_None, and the compiler interned __STATIC_NAME helper.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FName default/copy/string constructors, NAME_None, and the compiler interned __STATIC_NAME helper.
 * @topic Baseline
 */
// FName Name(const FString& Other); const FName NAME_None;
// const FName& Name = __STATIC_NAME(int Id);
// Inputs: Default construction, copy of n"Alpha", string "Alpha_1", and
// NAME_None as the empty interned name.
// Expected observations: Default Name() is NAME_None. Copy preserves
// identity. String constructor interns the text. NAME_None.IsNone is true.
// Boundary/ownership: FName construction interns text in the name table.
// __STATIC_NAME returns a reference to a compiler-assigned interned name.

namespace TS_FName_Behavior_01
{
	// FName(); FName(const FName&); FName(const FString&); default is NAME_None,
	// copy keeps identity, "Alpha_1" interns with plain Alpha and number 1.
	bool Observe_Name_Nominal()
	{
		FName DefaultName;
		FName Source = n"Alpha";
		FName Copied(Source);
		FName FromString("Alpha_1");
		return DefaultName.IsNone() && Copied == Source && FromString.GetPlainNameString() == "Alpha" && FromString.GetNumber() == 1;
	}

	// const FName NAME_None is the canonical empty interned name.
	bool Observe_Surface016_Nominal()
	{
		FName None = NAME_None;
		return None.IsNone() && None == NAME_None;
	}

	// __STATIC_NAME is the compiler interned-name helper; n"" and NAME_None
	// are interned identities the runner can compare.
	bool Observe___STATIC_NAME_Nominal()
	{
		FName Literal = n"Alpha";
		const FName NoneRef = NAME_None;
		return NoneRef.IsNone() && Literal != NAME_None && Literal == n"Alpha";
	}
}
/** @end */
