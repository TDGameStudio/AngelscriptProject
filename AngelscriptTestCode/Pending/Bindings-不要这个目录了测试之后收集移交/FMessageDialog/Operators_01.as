/**
 * @version v1
 * @summary Observe FMessageDialog::Open return values for the plain and categorized overloads, including default title omission.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FMessageDialog::Open return values for the plain and categorized overloads, including default title omission.
 * @topic Baseline
 */
// const FText& Message, FText OptionalTitle = FText());
// EAppReturnType FMessageDialog::Open(EAppMsgCategory MessageCategory,
// EAppMsgType MessageType, const FText& Message, FText OptionalTitle = FText());
// Inputs: EAppMsgType::Ok, message "TestSource.FMessageDialog", empty default
// title, an explicit title, and EAppMsgCategory::Info.
// Expected observations: Each Open returns an EAppReturnType. Empty title uses
// the platform default. The categorized overload also returns a consumed
// result.
// Boundary/ownership: Open is modal. Message and OptionalTitle are borrowed.
// The returned enumerator is a value.

namespace TS_FMessageDialog_Operators_01
{
	bool Observe_Open_Nominal()
	{
		FText Message = FText::FromString("TestSource.FMessageDialog");
		FText EmptyTitle;
		EAppReturnType DefaultTitle = FMessageDialog::Open(EAppMsgType::Ok, Message);
		EAppReturnType WithTitle = FMessageDialog::Open(EAppMsgType::Ok, Message, EmptyTitle);
		FText Title = FText::FromString("TestSource");
		EAppReturnType NamedTitle = FMessageDialog::Open(EAppMsgType::Ok, Message, Title);
		EAppReturnType Categorized = FMessageDialog::Open(EAppMsgCategory::Info, EAppMsgType::Ok, Message);
		EAppReturnType CategorizedTitled = FMessageDialog::Open(EAppMsgCategory::Info, EAppMsgType::Ok, Message, Title);
		return DefaultTitle == EAppReturnType::Ok && WithTitle == EAppReturnType::Ok && NamedTitle == EAppReturnType::Ok && Categorized == EAppReturnType::Ok && CategorizedTitled == EAppReturnType::Ok;
	}
}
/** @end */
