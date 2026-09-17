/**
 * @version v1
 * @summary FMessageDialog host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FMessageDialog
 *
 * open
 */
/**
 * @begin open
 * @summary The returned enumerator is a value.
 * @topic Unreal
 */
/**
 * @function ObserveOpenNominal
 * @summary The returned enumerator is a value.
 * @covers FMessageDialog.open
 * @inputs FMessageDialog values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOpenNominal()
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
/** @end */
