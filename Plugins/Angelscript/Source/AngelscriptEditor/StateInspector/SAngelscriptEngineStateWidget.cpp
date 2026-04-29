#include "StateInspector/SAngelscriptEngineStateWidget.h"

#include "Framework/Application/SlateApplication.h"
#include "Styling/AppStyle.h"
#include "Widgets/Images/SImage.h"
#include "Widgets/Input/SButton.h"
#include "Widgets/Input/SCheckBox.h"
#include "Widgets/Input/SSearchBox.h"
#include "Widgets/Layout/SBorder.h"
#include "Widgets/Layout/SBox.h"
#include "Widgets/Layout/SScrollBox.h"
#include "Widgets/Layout/SSplitter.h"
#include "Widgets/Layout/SUniformGridPanel.h"
#include "Widgets/SBoxPanel.h"
#include "Widgets/Text/STextBlock.h"
#include "Widgets/Views/STableRow.h"

#define LOCTEXT_NAMESPACE "SAngelscriptEngineStateWidget"

namespace AngelscriptStateInspectorColumns
{
	static const FName Name(TEXT("Name"));
	static const FName Context(TEXT("Context"));
	static const FName Type(TEXT("Type"));
	static const FName CountA(TEXT("CountA"));
	static const FName CountB(TEXT("CountB"));
	static const FName Status(TEXT("Status"));
}

namespace
{
	FString BoolToDisplayString(const bool bValue)
	{
		return bValue ? TEXT("true") : TEXT("false");
	}

	FString CountLabel(const FString& Label, const int32 Count)
	{
		return FString::Printf(TEXT("%s: %d"), *Label, Count);
	}

	FString DisplayOrNone(const FString& Value)
	{
		return Value.IsEmpty() ? TEXT("<none>") : Value;
	}

	FString JoinSearchText(const TArray<FString>& Values)
	{
		return FString::Join(Values, TEXT("\n"));
	}

	FString JoinMemberSearchText(const TArray<FAngelscriptStateMemberSnapshot>& Members)
	{
		TArray<FString> Parts;
		Parts.Reserve(Members.Num() * 2);
		for (const FAngelscriptStateMemberSnapshot& Member : Members)
		{
			Parts.Add(Member.Name);
			Parts.Add(Member.Declaration);
			Parts.Add(Member.Details);
		}
		return JoinSearchText(Parts);
	}

	FString JoinStringArraySearchText(const TArray<FString>& Values)
	{
		return FString::Join(Values, TEXT("\n"));
	}

	FString BuildBindPropertySearchText(const FAngelscriptStateBindPropertySnapshot& Property)
	{
		if (!Property.SearchText.IsEmpty())
		{
			return Property.SearchText;
		}

		return JoinSearchText({
			Property.Declaration,
			Property.UnrealPath,
			Property.GeneratedName,
			Property.DisplayName,
			Property.Category,
			Property.OwnerName,
			Property.ToolTip,
			Property.Flags
		});
	}

	FString BuildBindMethodSearchText(const FAngelscriptStateBindMethodSnapshot& Method)
	{
		if (!Method.SearchText.IsEmpty())
		{
			return Method.SearchText;
		}

		return JoinSearchText({
			Method.Declaration,
			Method.UnrealPath,
			Method.ClassName,
			Method.ScriptName,
			Method.ResolvedFunctionPath,
			Method.OwningCppClassPath,
			Method.BindingPath,
			Method.DisplayName,
			Method.Category,
			Method.OwnerName,
			Method.ToolTip,
			Method.Flags
		});
	}

	FString JoinBindPropertySearchText(const TArray<FAngelscriptStateBindPropertySnapshot>& Properties)
	{
		TArray<FString> Parts;
		Parts.Reserve(Properties.Num());
		for (const FAngelscriptStateBindPropertySnapshot& Property : Properties)
		{
			Parts.Add(BuildBindPropertySearchText(Property));
		}
		return JoinSearchText(Parts);
	}

	FString JoinBindMethodSearchText(const TArray<FAngelscriptStateBindMethodSnapshot>& Methods)
	{
		TArray<FString> Parts;
		Parts.Reserve(Methods.Num());
		for (const FAngelscriptStateBindMethodSnapshot& Method : Methods)
		{
			Parts.Add(BuildBindMethodSearchText(Method));
		}
		return JoinSearchText(Parts);
	}

	bool ContainsAllTerms(const FString& CandidateText, const TArray<FString>& Terms)
	{
		for (const FString& Term : Terms)
		{
			if (!CandidateText.Contains(Term, ESearchCase::IgnoreCase))
			{
				return false;
			}
		}

		return true;
	}

	FString GetBindingPathDisplayText(const FString& BindingPath)
	{
		if (BindingPath == TEXT("DirectNativePointer"))
		{
			return TEXT("Direct function pointer");
		}
		if (BindingPath == TEXT("ReflectiveFallback"))
		{
			return TEXT("Reflective fallback");
		}
		if (BindingPath == TEXT("UnresolvedFunction"))
		{
			return TEXT("Unresolved UFunction");
		}
		return TEXT("No function pointer");
	}

	FSlateColor GetBindingPathColor(const FString& BindingPath)
	{
		if (BindingPath == TEXT("DirectNativePointer"))
		{
			return FSlateColor(FLinearColor(0.22f, 0.72f, 0.38f));
		}
		if (BindingPath == TEXT("ReflectiveFallback"))
		{
			return FSlateColor(FLinearColor(0.20f, 0.55f, 0.90f));
		}
		if (BindingPath == TEXT("UnresolvedFunction"))
		{
			return FSlateColor(FLinearColor(0.95f, 0.36f, 0.26f));
		}
		return FSlateColor(FLinearColor(0.90f, 0.62f, 0.20f));
	}

	bool IsIssueBindingPath(const FString& BindingPath)
	{
		return BindingPath == TEXT("NoFunctionPointer") || BindingPath == TEXT("UnresolvedFunction");
	}

	void AddTextRow(const TSharedRef<SVerticalBox>& Box, const FString& Text)
	{
		Box->AddSlot()
			.AutoHeight()
			.Padding(0.0f, 2.0f)
			[
				SNew(STextBlock)
				.Text(FText::FromString(Text))
				.AutoWrapText(true)
			];
	}

	void AddDetailLine(const TSharedRef<SVerticalBox>& Box, const FString& Text)
	{
		if (Text.IsEmpty())
		{
			return;
		}

		Box->AddSlot()
			.AutoHeight()
			.Padding(0.0f, 2.0f)
			[
				SNew(STextBlock)
				.Text(FText::FromString(Text))
				.AutoWrapText(true)
		];
	}

	void AddNameValueLine(const TSharedRef<SVerticalBox>& Box, const FString& Name, const FString& Value)
	{
		if (Value.IsEmpty())
		{
			return;
		}

		Box->AddSlot()
			.AutoHeight()
			.Padding(0.0f, 2.0f)
			[
				SNew(SHorizontalBox)
				+ SHorizontalBox::Slot()
				.AutoWidth()
				.VAlign(VAlign_Top)
				[
					SNew(SBox)
					.WidthOverride(72.0f)
					[
						SNew(STextBlock)
						.Text(FText::FromString(Name))
						.ColorAndOpacity(FSlateColor(FLinearColor(0.62f, 0.62f, 0.62f)))
					]
				]
				+ SHorizontalBox::Slot()
				.FillWidth(1.0f)
				.VAlign(VAlign_Top)
				[
					SNew(STextBlock)
					.Text(FText::FromString(Value))
					.AutoWrapText(true)
				]
			];
	}

	TSharedRef<SWidget> BuildBindTag(const FString& Text, const FSlateColor& Color)
	{
		return SNew(SBorder)
			.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
			.Padding(FMargin(6.0f, 2.0f))
			[
				SNew(STextBlock)
				.Text(FText::FromString(Text))
				.ColorAndOpacity(Color)
			];
	}

	int32 CountVisibleBindProperties(const TArray<FAngelscriptStateBindPropertySnapshot>& Properties, const FAngelscriptStateInspectorBindDetailsFilter& Filter)
	{
		int32 VisibleCount = 0;
		for (const FAngelscriptStateBindPropertySnapshot& Property : Properties)
		{
			if (Filter.MatchesProperty(Property))
			{
				++VisibleCount;
			}
		}
		return VisibleCount;
	}

	int32 CountVisibleBindMethods(const TArray<FAngelscriptStateBindMethodSnapshot>& Methods, const FAngelscriptStateInspectorBindDetailsFilter& Filter)
	{
		int32 VisibleCount = 0;
		for (const FAngelscriptStateBindMethodSnapshot& Method : Methods)
		{
			if (Filter.MatchesMethod(Method))
			{
				++VisibleCount;
			}
		}
		return VisibleCount;
	}

	FString FormatVisibleCount(const int32 VisibleCount, const int32 TotalCount)
	{
		return VisibleCount == TotalCount
			? FString::Printf(TEXT("%d"), TotalCount)
			: FString::Printf(TEXT("%d / %d"), VisibleCount, TotalCount);
	}

	TSharedRef<SWidget> BuildBindPropertyList(const TArray<FAngelscriptStateBindPropertySnapshot>& Properties, const FAngelscriptStateInspectorBindDetailsFilter& Filter, const FString& EmptyText)
	{
		TSharedRef<SVerticalBox> Box = SNew(SVerticalBox);
		int32 VisibleCount = 0;

		for (const FAngelscriptStateBindPropertySnapshot& Property : Properties)
		{
			if (!Filter.MatchesProperty(Property))
			{
				continue;
			}

			TSharedRef<SVerticalBox> Entry = SNew(SVerticalBox);
			Entry->AddSlot()
				.AutoHeight()
				[
					SNew(SHorizontalBox)
					+ SHorizontalBox::Slot()
					.FillWidth(1.0f)
					.VAlign(VAlign_Center)
					[
						SNew(STextBlock)
						.Text(FText::FromString(DisplayOrNone(Property.DisplayName)))
						.Font(FAppStyle::GetFontStyle("BoldFont"))
						.AutoWrapText(true)
					]
					+ SHorizontalBox::Slot()
					.AutoWidth()
					.VAlign(VAlign_Center)
					.Padding(8.0f, 0.0f, 0.0f, 0.0f)
					[
						BuildBindTag(TEXT("Property"), FSlateColor(FLinearColor(0.24f, 0.62f, 0.86f)))
					]
				];
			AddNameValueLine(Entry, TEXT("Owner"), DisplayOrNone(Property.OwnerName));
			AddNameValueLine(Entry, TEXT("Category"), DisplayOrNone(Property.Category));
			AddNameValueLine(Entry, TEXT("AS"), DisplayOrNone(Property.Declaration));
			AddNameValueLine(Entry, TEXT("Unreal"), DisplayOrNone(Property.UnrealPath));
			AddNameValueLine(Entry, TEXT("Generated"), DisplayOrNone(Property.GeneratedName));
			AddNameValueLine(Entry, TEXT("Flags"), DisplayOrNone(Property.Flags));
			AddNameValueLine(Entry, TEXT("Tooltip"), DisplayOrNone(Property.ToolTip));

			Box->AddSlot()
				.AutoHeight()
				.Padding(0.0f, 0.0f, 0.0f, 6.0f)
				[
					SNew(SBorder)
					.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
					.Padding(6.0f)
					[
						Entry
					]
				];
			++VisibleCount;
		}

		if (VisibleCount == 0)
		{
			AddTextRow(Box, Properties.IsEmpty() ? EmptyText : TEXT("No properties match the details filter."));
		}

		return Box;
	}

	TSharedRef<SWidget> BuildBindMethodList(const TArray<FAngelscriptStateBindMethodSnapshot>& Methods, const FAngelscriptStateInspectorBindDetailsFilter& Filter, const FString& EmptyText)
	{
		TSharedRef<SVerticalBox> Box = SNew(SVerticalBox);
		int32 VisibleCount = 0;

		for (const FAngelscriptStateBindMethodSnapshot& Method : Methods)
		{
			if (!Filter.MatchesMethod(Method))
			{
				continue;
			}

			TSharedRef<SVerticalBox> Entry = SNew(SVerticalBox);
			Entry->AddSlot()
				.AutoHeight()
				[
					SNew(SHorizontalBox)
					+ SHorizontalBox::Slot()
					.FillWidth(1.0f)
					.VAlign(VAlign_Center)
					[
						SNew(STextBlock)
						.Text(FText::FromString(DisplayOrNone(Method.DisplayName)))
						.Font(FAppStyle::GetFontStyle("BoldFont"))
						.AutoWrapText(true)
					]
					+ SHorizontalBox::Slot()
					.AutoWidth()
					.VAlign(VAlign_Center)
					.Padding(8.0f, 0.0f, 0.0f, 0.0f)
					[
						BuildBindTag(GetBindingPathDisplayText(Method.BindingPath), GetBindingPathColor(Method.BindingPath))
					]
				];
			AddNameValueLine(Entry, TEXT("Owner"), DisplayOrNone(Method.OwnerName));
			AddNameValueLine(Entry, TEXT("Category"), DisplayOrNone(Method.Category));
			AddNameValueLine(Entry, TEXT("AS"), DisplayOrNone(Method.Declaration));
			AddNameValueLine(Entry, TEXT("UFunction"), DisplayOrNone(Method.ResolvedFunctionPath));
			AddNameValueLine(Entry, TEXT("Unreal"), DisplayOrNone(Method.UnrealPath));
			AddNameValueLine(Entry, TEXT("Script"), DisplayOrNone(Method.ScriptName));
			AddNameValueLine(Entry, TEXT("Class"), DisplayOrNone(Method.ClassName));
			AddNameValueLine(Entry, TEXT("Flags"), DisplayOrNone(Method.Flags));
			AddNameValueLine(Entry, TEXT("Callable"), FString::Printf(
				TEXT("Native entry %s / direct pointer %s / reflective fallback %s"),
				*BoolToDisplayString(Method.bHasNativeFunctionEntry),
				*BoolToDisplayString(Method.bHasDirectNativePointer),
				*BoolToDisplayString(Method.bReflectiveFallbackBound)));
			AddNameValueLine(Entry, TEXT("Tooltip"), DisplayOrNone(Method.ToolTip));

			Box->AddSlot()
				.AutoHeight()
				.Padding(0.0f, 0.0f, 0.0f, 6.0f)
				[
					SNew(SBorder)
					.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
					.Padding(6.0f)
					[
						Entry
					]
				];
			++VisibleCount;
		}

		if (VisibleCount == 0)
		{
			AddTextRow(Box, Methods.IsEmpty() ? EmptyText : TEXT("No methods match the details filter."));
		}

		return Box;
	}

	TSharedRef<SWidget> BuildStringList(const TArray<FString>& Values, const FString& EmptyText)
	{
		TSharedRef<SVerticalBox> Box = SNew(SVerticalBox);
		if (Values.IsEmpty())
		{
			AddTextRow(Box, EmptyText);
			return Box;
		}

		for (const FString& Value : Values)
		{
			AddTextRow(Box, FString::Printf(TEXT("- %s"), *Value));
		}

		return Box;
	}

	TSharedRef<SWidget> BuildMemberList(const TArray<FAngelscriptStateMemberSnapshot>& Members, const FString& EmptyText)
	{
		TSharedRef<SVerticalBox> Box = SNew(SVerticalBox);
		if (Members.IsEmpty())
		{
			AddTextRow(Box, EmptyText);
			return Box;
		}

		for (const FAngelscriptStateMemberSnapshot& Member : Members)
		{
			FString Line = FString::Printf(TEXT("- %s"), *Member.Declaration);
			if (!Member.Details.IsEmpty())
			{
				Line += FString::Printf(TEXT(" [%s]"), *Member.Details);
			}
			if (Member.LineNumber > 0)
			{
				Line += FString::Printf(TEXT(" (line %d)"), Member.LineNumber);
			}
			AddTextRow(Box, Line);
		}

		return Box;
	}

	TSharedRef<SWidget> BuildMetricCard(const FText& Label, const FString& Value, const FString& Detail = FString())
	{
		return SNew(SBorder)
			.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
			.Padding(10.0f)
			[
				SNew(SVerticalBox)
				+ SVerticalBox::Slot()
				.AutoHeight()
				[
					SNew(STextBlock)
					.Text(Label)
				]
				+ SVerticalBox::Slot()
				.AutoHeight()
				.Padding(0.0f, 4.0f, 0.0f, 0.0f)
				[
					SNew(STextBlock)
					.Text(FText::FromString(Value))
					.Font(FAppStyle::GetFontStyle("HeadingMedium"))
				]
				+ SVerticalBox::Slot()
				.AutoHeight()
				.Padding(0.0f, 2.0f, 0.0f, 0.0f)
				[
					SNew(STextBlock)
					.Text(FText::FromString(Detail))
					.AutoWrapText(true)
				]
			];
	}

	FString GetSectionRowCountText(const int32 FilteredCount, const int32 TotalCount)
	{
		return FilteredCount == TotalCount
			? FString::Printf(TEXT("%d entries"), TotalCount)
			: FString::Printf(TEXT("%d of %d entries"), FilteredCount, TotalCount);
	}

	FText GetColumnLabel(const SAngelscriptEngineStateWidget::ESection Section, const FName& ColumnName)
	{
		using namespace AngelscriptStateInspectorColumns;

		if (ColumnName == Name)
		{
			switch (Section)
			{
			case SAngelscriptEngineStateWidget::ESection::Modules:
				return LOCTEXT("ModuleNameColumn", "Module");
			case SAngelscriptEngineStateWidget::ESection::ScriptClasses:
				return LOCTEXT("ClassNameColumn", "Class");
			case SAngelscriptEngineStateWidget::ESection::RegisteredTypes:
				return LOCTEXT("RegisteredTypeNameColumn", "Declaration");
			case SAngelscriptEngineStateWidget::ESection::BindDatabase:
				return LOCTEXT("BindTypeNameColumn", "AS Type");
			case SAngelscriptEngineStateWidget::ESection::BindRegistrations:
				return LOCTEXT("BindNameColumn", "Bind");
			case SAngelscriptEngineStateWidget::ESection::Diagnostics:
				return LOCTEXT("DiagnosticFileColumn", "File");
			default:
				return LOCTEXT("NameColumn", "Name");
			}
		}

		if (ColumnName == Context)
		{
			switch (Section)
			{
			case SAngelscriptEngineStateWidget::ESection::Modules:
				return LOCTEXT("ModuleFilesColumn", "Files");
			case SAngelscriptEngineStateWidget::ESection::ScriptClasses:
				return LOCTEXT("ClassModuleColumn", "Module");
			case SAngelscriptEngineStateWidget::ESection::RegisteredTypes:
				return LOCTEXT("TypeNamespaceColumn", "Namespace");
			case SAngelscriptEngineStateWidget::ESection::BindDatabase:
				return LOCTEXT("BindCppTypeColumn", "C++ Type");
			case SAngelscriptEngineStateWidget::ESection::BindRegistrations:
				return LOCTEXT("BindOrderColumn", "Order");
			case SAngelscriptEngineStateWidget::ESection::Diagnostics:
				return LOCTEXT("DiagnosticLocationColumn", "Location");
			default:
				return LOCTEXT("ContextColumn", "Context");
			}
		}

		if (ColumnName == Type)
		{
			switch (Section)
			{
			case SAngelscriptEngineStateWidget::ESection::Modules:
				return LOCTEXT("ModuleImportsColumn", "Imports");
			case SAngelscriptEngineStateWidget::ESection::ScriptClasses:
				return LOCTEXT("ClassSuperColumn", "Super");
			case SAngelscriptEngineStateWidget::ESection::RegisteredTypes:
				return LOCTEXT("TypeBaseColumn", "Base");
			case SAngelscriptEngineStateWidget::ESection::BindDatabase:
				return LOCTEXT("BindCppPathColumn", "C++ Path");
			case SAngelscriptEngineStateWidget::ESection::BindRegistrations:
				return LOCTEXT("BindEnabledColumn", "Enabled");
			case SAngelscriptEngineStateWidget::ESection::Diagnostics:
				return LOCTEXT("DiagnosticSeverityColumn", "Severity");
			default:
				return LOCTEXT("TypeColumn", "Type");
			}
		}

		if (ColumnName == CountA)
		{
			switch (Section)
			{
			case SAngelscriptEngineStateWidget::ESection::Modules:
				return LOCTEXT("ModuleClassesColumn", "Classes");
			case SAngelscriptEngineStateWidget::ESection::ScriptClasses:
			case SAngelscriptEngineStateWidget::ESection::RegisteredTypes:
			case SAngelscriptEngineStateWidget::ESection::BindDatabase:
				return Section == SAngelscriptEngineStateWidget::ESection::BindDatabase ? LOCTEXT("BindPropertiesColumn", "Props") : LOCTEXT("PropertiesColumn", "Properties");
			default:
				return FText::GetEmpty();
			}
		}

		if (ColumnName == CountB)
		{
			switch (Section)
			{
			case SAngelscriptEngineStateWidget::ESection::Modules:
				return LOCTEXT("ModuleMethodsColumn", "Methods");
			case SAngelscriptEngineStateWidget::ESection::ScriptClasses:
			case SAngelscriptEngineStateWidget::ESection::RegisteredTypes:
			case SAngelscriptEngineStateWidget::ESection::BindDatabase:
				return LOCTEXT("MethodsColumn", "Methods");
			default:
				return FText::GetEmpty();
			}
		}

		return Section == SAngelscriptEngineStateWidget::ESection::BindDatabase ? LOCTEXT("BindCallPathColumn", "Call Path") : LOCTEXT("StatusColumn", "Status");
	}

	class SAngelscriptStateInspectorTableRow : public SMultiColumnTableRow<TSharedPtr<FAngelscriptStateInspectorRow>>
	{
	public:
		SLATE_BEGIN_ARGS(SAngelscriptStateInspectorTableRow) {}
			SLATE_ARGUMENT(TSharedPtr<FAngelscriptStateInspectorRow>, Item)
		SLATE_END_ARGS()

		void Construct(const FArguments& InArgs, const TSharedRef<STableViewBase>& OwnerTableView)
		{
			Item = InArgs._Item;
			SMultiColumnTableRow<TSharedPtr<FAngelscriptStateInspectorRow>>::Construct(
				FSuperRowType::FArguments()
				.Padding(FMargin(4.0f, 2.0f)),
				OwnerTableView);
		}

		virtual TSharedRef<SWidget> GenerateWidgetForColumn(const FName& ColumnName) override
		{
			const FString Text = Item.IsValid() ? Item->GetColumnText(ColumnName) : FString();
			const bool bWarningColumn = Item.IsValid() && Item->bWarning && ColumnName == AngelscriptStateInspectorColumns::Status;

			return SNew(STextBlock)
				.Text(FText::FromString(Text))
				.ColorAndOpacity(bWarningColumn ? FSlateColor(FLinearColor(1.0f, 0.58f, 0.18f)) : FSlateColor::UseForeground())
				.AutoWrapText(false);
		}

	private:
		TSharedPtr<FAngelscriptStateInspectorRow> Item;
	};
}

FString FAngelscriptStateInspectorRow::GetColumnText(const FName& ColumnName) const
{
	if (ColumnName == AngelscriptStateInspectorColumns::Name)
	{
		return this->Name;
	}
	if (ColumnName == AngelscriptStateInspectorColumns::Context)
	{
		return this->Context;
	}
	if (ColumnName == AngelscriptStateInspectorColumns::Type)
	{
		return this->Type;
	}
	if (ColumnName == AngelscriptStateInspectorColumns::CountA)
	{
		return this->CountA;
	}
	if (ColumnName == AngelscriptStateInspectorColumns::CountB)
	{
		return this->CountB;
	}
	if (ColumnName == AngelscriptStateInspectorColumns::Status)
	{
		return this->Status;
	}

	return FString();
}

FAngelscriptStateInspectorBindDetailsFilter FAngelscriptStateInspectorBindDetailsFilter::Parse(const FString& InText)
{
	FAngelscriptStateInspectorBindDetailsFilter Filter;
	Filter.RawText = InText;

	TArray<FString> Tokens;
	InText.ParseIntoArrayWS(Tokens, nullptr, true);
	for (const FString& Token : Tokens)
	{
		FString Prefix;
		FString Value;
		if (Token.Split(TEXT(":"), &Prefix, &Value, ESearchCase::IgnoreCase, ESearchDir::FromStart) && !Value.IsEmpty())
		{
			if (Prefix.Equals(TEXT("kind"), ESearchCase::IgnoreCase))
			{
				Filter.KindTerms.Add(Value);
				continue;
			}
			if (Prefix.Equals(TEXT("owner"), ESearchCase::IgnoreCase))
			{
				Filter.OwnerTerms.Add(Value);
				continue;
			}
			if (Prefix.Equals(TEXT("category"), ESearchCase::IgnoreCase))
			{
				Filter.CategoryTerms.Add(Value);
				continue;
			}
			if (Prefix.Equals(TEXT("path"), ESearchCase::IgnoreCase))
			{
				Filter.PathTerms.Add(Value);
				continue;
			}
			if (Prefix.Equals(TEXT("flag"), ESearchCase::IgnoreCase))
			{
				Filter.FlagTerms.Add(Value);
				continue;
			}
		}

		Filter.PlainTerms.Add(Token);
	}

	return Filter;
}

bool FAngelscriptStateInspectorBindDetailsFilter::MatchesProperty(const FAngelscriptStateBindPropertySnapshot& Property) const
{
	if (!bShowProperties)
	{
		return false;
	}
	if (bOnlyIssues)
	{
		return false;
	}

	if (!ContainsAllTerms(TEXT("property"), KindTerms))
	{
		return false;
	}

	if (!ContainsAllTerms(Property.OwnerName, OwnerTerms))
	{
		return false;
	}

	if (!ContainsAllTerms(Property.Category, CategoryTerms))
	{
		return false;
	}

	if (!ContainsAllTerms(Property.Flags, FlagTerms))
	{
		return false;
	}

	if (!ContainsAllTerms(JoinSearchText({ Property.UnrealPath, Property.GeneratedName }), PathTerms))
	{
		return false;
	}

	return ContainsAllTerms(BuildBindPropertySearchText(Property), PlainTerms);
}

bool FAngelscriptStateInspectorBindDetailsFilter::MatchesMethod(const FAngelscriptStateBindMethodSnapshot& Method) const
{
	if (!bShowMethods)
	{
		return false;
	}

	if (Method.BindingPath == TEXT("DirectNativePointer") && !bShowDirectMethods)
	{
		return false;
	}
	if (Method.BindingPath == TEXT("ReflectiveFallback") && !bShowReflectiveFallbackMethods)
	{
		return false;
	}
	if (Method.BindingPath == TEXT("UnresolvedFunction") && !bShowUnresolvedMethods)
	{
		return false;
	}
	if (Method.BindingPath != TEXT("DirectNativePointer")
		&& Method.BindingPath != TEXT("ReflectiveFallback")
		&& Method.BindingPath != TEXT("UnresolvedFunction")
		&& !bShowNoFunctionPointerMethods)
	{
		return false;
	}
	if (bOnlyIssues && !IsIssueBindingPath(Method.BindingPath))
	{
		return false;
	}

	if (!ContainsAllTerms(TEXT("method"), KindTerms))
	{
		return false;
	}

	if (!ContainsAllTerms(Method.OwnerName, OwnerTerms))
	{
		return false;
	}

	if (!ContainsAllTerms(Method.Category, CategoryTerms))
	{
		return false;
	}

	if (!ContainsAllTerms(JoinSearchText({ Method.BindingPath, Method.UnrealPath, Method.ResolvedFunctionPath, Method.OwningCppClassPath }), PathTerms))
	{
		return false;
	}

	if (!ContainsAllTerms(Method.Flags, FlagTerms))
	{
		return false;
	}

	return ContainsAllTerms(BuildBindMethodSearchText(Method), PlainTerms);
}

void SAngelscriptEngineStateWidget::Construct(const FArguments& InArgs)
{
	ActiveSection = InArgs._InitialSection;
	bShowSectionNavigation = InArgs._bShowSectionNavigation;
	SortColumn = AngelscriptStateInspectorColumns::Name;
	RefreshSnapshotData();

	ChildSlot
	[
		SNew(SVerticalBox)
		+ SVerticalBox::Slot()
		.AutoHeight()
		.Padding(8.0f)
		[
			SNew(SBorder)
			.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
			.Padding(8.0f)
			[
				SNew(SHorizontalBox)
				+ SHorizontalBox::Slot()
				.AutoWidth()
				.VAlign(VAlign_Center)
				.Padding(0.0f, 0.0f, 8.0f, 0.0f)
				[
					SNew(SButton)
					.ButtonStyle(FAppStyle::Get(), "FlatButton")
					.ToolTipText(LOCTEXT("RefreshTooltip", "Capture the current Angelscript engine state again."))
					.OnClicked(this, &SAngelscriptEngineStateWidget::RefreshSnapshot)
					[
						SNew(SHorizontalBox)
						+ SHorizontalBox::Slot()
						.AutoWidth()
						.VAlign(VAlign_Center)
						.Padding(0.0f, 0.0f, 4.0f, 0.0f)
						[
							SNew(SImage)
							.Image(FAppStyle::GetBrush("Icons.Refresh"))
						]
						+ SHorizontalBox::Slot()
						.AutoWidth()
						.VAlign(VAlign_Center)
						[
							SNew(STextBlock)
							.Text(LOCTEXT("RefreshButton", "Refresh"))
						]
					]
				]
				+ SHorizontalBox::Slot()
				.FillWidth(1.0f)
				.VAlign(VAlign_Center)
				.Padding(0.0f, 0.0f, 12.0f, 0.0f)
				[
					SAssignNew(SummaryText, STextBlock)
					.Text(GetSummaryText())
					.AutoWrapText(true)
				]
				+ SHorizontalBox::Slot()
				.AutoWidth()
				.VAlign(VAlign_Center)
				[
					SNew(SBox)
					.WidthOverride(340.0f)
					[
						SAssignNew(SearchBox, SSearchBox)
						.HintText(LOCTEXT("SearchHint", "Search current section"))
						.OnTextChanged(this, &SAngelscriptEngineStateWidget::OnSearchTextChanged)
					]
				]
			]
		]
		+ SVerticalBox::Slot()
		.FillHeight(1.0f)
		.Padding(8.0f, 0.0f, 8.0f, 8.0f)
		[
			bShowSectionNavigation
				? StaticCastSharedRef<SWidget>(
					SNew(SSplitter)
					+ SSplitter::Slot()
					.Value(0.18f)
					[
						SNew(SBorder)
						.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
						.Padding(6.0f)
						[
							SNew(SVerticalBox)
							+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)[BuildSectionButton(ESection::Overview, GetSectionTitle(ESection::Overview))]
							+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)[BuildSectionButton(ESection::Modules, GetSectionTitle(ESection::Modules))]
							+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)[BuildSectionButton(ESection::ScriptClasses, GetSectionTitle(ESection::ScriptClasses))]
							+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)[BuildSectionButton(ESection::RegisteredTypes, GetSectionTitle(ESection::RegisteredTypes))]
							+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)[BuildSectionButton(ESection::BindDatabase, GetSectionTitle(ESection::BindDatabase))]
							+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)[BuildSectionButton(ESection::BindRegistrations, GetSectionTitle(ESection::BindRegistrations))]
							+ SVerticalBox::Slot().AutoHeight()[BuildSectionButton(ESection::Diagnostics, GetSectionTitle(ESection::Diagnostics))]
						]
					]
					+ SSplitter::Slot()
					.Value(0.82f)
					[
						SAssignNew(MainContent, SBorder)
						.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
						.Padding(8.0f)
					])
				: StaticCastSharedRef<SWidget>(
					SAssignNew(MainContent, SBorder)
					.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
					.Padding(8.0f))
		]
	];

	RebuildContent();
}

FReply SAngelscriptEngineStateWidget::RefreshSnapshot()
{
	RefreshSnapshotData();
	UpdateSummaryText();
	RebuildContent();
	return FReply::Handled();
}

FReply SAngelscriptEngineStateWidget::SelectSection(const ESection Section)
{
	if (ActiveSection != Section)
	{
		ActiveSection = Section;
		SelectedRow.Reset();
		BindDetailsSearchText.Reset();
		SortColumn = AngelscriptStateInspectorColumns::Name;
		SortMode = EColumnSortMode::Ascending;
		RebuildContent();
	}

	return FReply::Handled();
}

void SAngelscriptEngineStateWidget::OnSearchTextChanged(const FText& NewText)
{
	SearchText = NewText.ToString();
	SelectedRow.Reset();
	RebuildContent();
}

void SAngelscriptEngineStateWidget::OnBindDetailsSearchTextChanged(const FText& NewText)
{
	BindDetailsSearchText = NewText.ToString();
	RebuildDetailsPanel();

	if (BindDetailsSearchBox.IsValid())
	{
		FSlateApplication::Get().SetKeyboardFocus(BindDetailsSearchBox, EFocusCause::SetDirectly);
	}
}

void SAngelscriptEngineStateWidget::RefreshSnapshotData()
{
	Snapshot = FAngelscriptEngineStateSnapshot::CaptureCurrent();
}

void SAngelscriptEngineStateWidget::RebuildContent()
{
	if (!MainContent.IsValid())
	{
		return;
	}

	RowListView.Reset();
	DetailsBox.Reset();

	if (ActiveSection == ESection::Overview)
	{
		FilteredRows.Reset();
		SelectedRow.Reset();
		MainContent->SetContent(BuildOverviewContent());
		return;
	}

	RebuildRows();
	MainContent->SetContent(BuildTableContent());
	SelectDefaultRow();
	RebuildDetailsPanel();
}

void SAngelscriptEngineStateWidget::RebuildRows()
{
	FilteredRows.Reset();

	auto AddRowIfMatched = [this](const TSharedRef<FAngelscriptStateInspectorRow>& Row)
	{
		if (MatchesFilter(Row->SearchText))
		{
			FilteredRows.Add(Row);
		}
	};

	switch (ActiveSection)
	{
	case ESection::Modules:
		for (int32 Index = 0; Index < Snapshot.Modules.Num(); ++Index)
		{
			const FAngelscriptStateModuleSnapshot& Module = Snapshot.Modules[Index];
			TSharedRef<FAngelscriptStateInspectorRow> Row = MakeShared<FAngelscriptStateInspectorRow>();
			Row->SourceIndex = Index;
			Row->Name = Module.ModuleName;
			Row->Context = FString::Printf(TEXT("%d"), Module.CodeFileCount);
			Row->Type = FString::Printf(TEXT("%d"), Module.ImportedModuleCount);
			Row->CountA = FString::Printf(TEXT("%d"), Module.ClassCount);
			Row->CountB = FString::Printf(TEXT("%d"), Module.MethodCount);
			Row->Status = Module.bCompileError ? TEXT("Compile error") : (Module.bLoadedPrecompiledCode ? TEXT("Precompiled") : TEXT("Ready"));
			Row->SearchText = JoinSearchText({ Module.ModuleName, Module.CodeFiles, Row->Status });
			Row->bWarning = Module.bCompileError;
			AddRowIfMatched(Row);
		}
		break;
	case ESection::ScriptClasses:
		for (int32 Index = 0; Index < Snapshot.ScriptClasses.Num(); ++Index)
		{
			const FAngelscriptStateScriptClassSnapshot& ClassSnapshot = Snapshot.ScriptClasses[Index];
			TSharedRef<FAngelscriptStateInspectorRow> Row = MakeShared<FAngelscriptStateInspectorRow>();
			Row->SourceIndex = Index;
			Row->Name = ClassSnapshot.ClassName;
			Row->Context = ClassSnapshot.ModuleName;
			Row->Type = ClassSnapshot.SuperClass;
			Row->CountA = FString::Printf(TEXT("%d"), ClassSnapshot.Properties.Num());
			Row->CountB = FString::Printf(TEXT("%d"), ClassSnapshot.Methods.Num());
			Row->Status = ClassSnapshot.Flags;
			Row->SearchText = JoinSearchText({
				ClassSnapshot.ModuleName,
				ClassSnapshot.ClassName,
				ClassSnapshot.SuperClass,
				ClassSnapshot.Namespace,
				ClassSnapshot.UnrealTypePath,
				ClassSnapshot.Flags,
				JoinMemberSearchText(ClassSnapshot.Properties),
				JoinMemberSearchText(ClassSnapshot.Methods)
			});
			AddRowIfMatched(Row);
		}
		break;
	case ESection::RegisteredTypes:
		for (int32 Index = 0; Index < Snapshot.RegisteredTypes.Num(); ++Index)
		{
			const FAngelscriptStateRegisteredTypeSnapshot& TypeSnapshot = Snapshot.RegisteredTypes[Index];
			TSharedRef<FAngelscriptStateInspectorRow> Row = MakeShared<FAngelscriptStateInspectorRow>();
			Row->SourceIndex = Index;
			Row->Name = TypeSnapshot.Declaration;
			Row->Context = TypeSnapshot.Namespace;
			Row->Type = TypeSnapshot.BaseType;
			Row->CountA = FString::Printf(TEXT("%d"), TypeSnapshot.Properties.Num());
			Row->CountB = FString::Printf(TEXT("%d"), TypeSnapshot.Methods.Num());
			Row->Status = TypeSnapshot.Flags;
			Row->SearchText = JoinSearchText({
				TypeSnapshot.TypeName,
				TypeSnapshot.Namespace,
				TypeSnapshot.Declaration,
				TypeSnapshot.BaseType,
				TypeSnapshot.Flags,
				JoinStringArraySearchText(TypeSnapshot.Properties),
				JoinStringArraySearchText(TypeSnapshot.Methods)
			});
			AddRowIfMatched(Row);
		}
		break;
	case ESection::BindDatabase:
		for (int32 Index = 0; Index < Snapshot.BindTypes.Num(); ++Index)
		{
			const FAngelscriptStateBindTypeSnapshot& BindSnapshot = Snapshot.BindTypes[Index];
			TSharedRef<FAngelscriptStateInspectorRow> Row = MakeShared<FAngelscriptStateInspectorRow>();
			Row->SourceIndex = Index;
			Row->Name = BindSnapshot.TypeName;
			Row->Context = DisplayOrNone(BindSnapshot.CppTypeName);
			Row->Type = DisplayOrNone(BindSnapshot.CppTypePath);
			Row->CountA = FString::Printf(TEXT("%d"), BindSnapshot.Properties.Num());
			Row->CountB = FString::Printf(TEXT("%d"), BindSnapshot.Methods.Num());
			Row->Status = FString::Printf(
				TEXT("Direct %d / Fallback %d / NoPtr %d / Unresolved %d"),
				BindSnapshot.DirectNativeMethodCount,
				BindSnapshot.ReflectiveFallbackMethodCount,
				BindSnapshot.NoFunctionPointerMethodCount,
				BindSnapshot.UnresolvedMethodCount);
			Row->SearchText = JoinSearchText({
				BindSnapshot.Kind,
				BindSnapshot.TypeName,
				BindSnapshot.UnrealPath,
				BindSnapshot.ResolvedTypePath,
				BindSnapshot.CppTypeName,
				BindSnapshot.CppTypePath,
				BindSnapshot.SourceHeader,
				Row->Status,
				JoinBindPropertySearchText(BindSnapshot.Properties),
				JoinBindMethodSearchText(BindSnapshot.Methods)
			});
			Row->bWarning = BindSnapshot.ResolvedTypePath.IsEmpty();
			AddRowIfMatched(Row);
		}
		break;
	case ESection::BindRegistrations:
		for (int32 Index = 0; Index < Snapshot.BindRegistrations.Num(); ++Index)
		{
			const FAngelscriptStateBindRegistrationSnapshot& Registration = Snapshot.BindRegistrations[Index];
			TSharedRef<FAngelscriptStateInspectorRow> Row = MakeShared<FAngelscriptStateInspectorRow>();
			Row->SourceIndex = Index;
			Row->Name = Registration.BindName;
			Row->Context = FString::Printf(TEXT("%d"), Registration.BindOrder);
			Row->Type = BoolToDisplayString(Registration.bEnabled);
			Row->Status = Registration.SkipReason;
			Row->SearchText = JoinSearchText({ Registration.BindName, Row->Context, Row->Type, Registration.SkipReason });
			Row->bWarning = !Registration.bEnabled;
			AddRowIfMatched(Row);
		}
		break;
	case ESection::Diagnostics:
		for (int32 Index = 0; Index < Snapshot.Diagnostics.Num(); ++Index)
		{
			const FAngelscriptStateDiagnosticSnapshot& Diagnostic = Snapshot.Diagnostics[Index];
			TSharedRef<FAngelscriptStateInspectorRow> Row = MakeShared<FAngelscriptStateInspectorRow>();
			Row->SourceIndex = Index;
			Row->Name = Diagnostic.Filename;
			Row->Context = FString::Printf(TEXT("%d:%d"), Diagnostic.Row, Diagnostic.Column);
			Row->Type = Diagnostic.Severity;
			Row->Status = Diagnostic.Message;
			Row->SearchText = JoinSearchText({ Diagnostic.Filename, Row->Context, Diagnostic.Severity, Diagnostic.Message });
			Row->bWarning = Diagnostic.Severity != TEXT("Info");
			AddRowIfMatched(Row);
		}
		break;
	default:
		break;
	}

	ApplySort();
}

void SAngelscriptEngineStateWidget::ApplySort()
{
	if (SortColumn.IsNone())
	{
		SortColumn = AngelscriptStateInspectorColumns::Name;
	}

	FilteredRows.Sort([this](const TSharedPtr<FAngelscriptStateInspectorRow>& A, const TSharedPtr<FAngelscriptStateInspectorRow>& B)
	{
		if (!A.IsValid() || !B.IsValid())
		{
			return A.IsValid();
		}

		int32 CompareResult = A->GetColumnText(SortColumn).Compare(B->GetColumnText(SortColumn), ESearchCase::IgnoreCase);
		if (CompareResult == 0)
		{
			CompareResult = A->Name.Compare(B->Name, ESearchCase::IgnoreCase);
		}

		return SortMode == EColumnSortMode::Descending
			? CompareResult > 0
			: CompareResult < 0;
	});
}

void SAngelscriptEngineStateWidget::SelectDefaultRow()
{
	if (!RowListView.IsValid())
	{
		return;
	}

	SelectedRow = FilteredRows.Num() > 0 ? FilteredRows[0] : nullptr;
	if (SelectedRow.IsValid())
	{
		RowListView->SetSelection(SelectedRow);
		RowListView->RequestScrollIntoView(SelectedRow);
	}
}

void SAngelscriptEngineStateWidget::RebuildDetailsPanel()
{
	if (!DetailsBox.IsValid())
	{
		return;
	}

	DetailsBox->ClearChildren();

	if (!SelectedRow.IsValid())
	{
		AddDetailsEmptyState(FilteredRows.IsEmpty()
			? FString::Printf(TEXT("No %s match the current filter."), *GetSectionTitle(ActiveSection).ToString())
			: TEXT("Select an entry to inspect its details."));
		return;
	}

	const int32 Index = SelectedRow->SourceIndex;
	switch (ActiveSection)
	{
	case ESection::Modules:
		if (Snapshot.Modules.IsValidIndex(Index))
		{
			const FAngelscriptStateModuleSnapshot& Module = Snapshot.Modules[Index];
			AddDetailsHeader(Module.ModuleName);
			AddDetailsRow(TEXT("Code files"), FString::FromInt(Module.CodeFileCount));
			AddDetailsRow(TEXT("Imported modules"), FString::FromInt(Module.ImportedModuleCount));
			AddDetailsRow(TEXT("Classes"), FString::FromInt(Module.ClassCount));
			AddDetailsRow(TEXT("Properties"), FString::FromInt(Module.PropertyCount));
			AddDetailsRow(TEXT("Methods"), FString::FromInt(Module.MethodCount));
			AddDetailsRow(TEXT("Enums"), FString::FromInt(Module.EnumCount));
			AddDetailsRow(TEXT("Delegates"), FString::FromInt(Module.DelegateCount));
			AddDetailsRow(TEXT("Compile error"), BoolToDisplayString(Module.bCompileError));
			AddDetailsRow(TEXT("Precompiled"), BoolToDisplayString(Module.bLoadedPrecompiledCode));
			AddDetailsRow(TEXT("Files"), DisplayOrNone(Module.CodeFiles));
		}
		break;
	case ESection::ScriptClasses:
		if (Snapshot.ScriptClasses.IsValidIndex(Index))
		{
			const FAngelscriptStateScriptClassSnapshot& ClassSnapshot = Snapshot.ScriptClasses[Index];
			AddDetailsHeader(ClassSnapshot.ClassName);
			AddDetailsRow(TEXT("Module"), ClassSnapshot.ModuleName);
			AddDetailsRow(TEXT("SuperClass"), DisplayOrNone(ClassSnapshot.SuperClass));
			AddDetailsRow(TEXT("Namespace"), DisplayOrNone(ClassSnapshot.Namespace));
			AddDetailsRow(TEXT("UnrealType"), DisplayOrNone(ClassSnapshot.UnrealTypePath));
			AddDetailsRow(TEXT("CodeSuperClass"), DisplayOrNone(ClassSnapshot.CodeSuperClass));
			AddDetailsRow(TEXT("ConfigName"), DisplayOrNone(ClassSnapshot.ConfigName));
			AddDetailsRow(TEXT("Flags"), DisplayOrNone(ClassSnapshot.Flags));
			AddDetailsRow(TEXT("Line"), FString::FromInt(ClassSnapshot.LineNumber));
			AddDetailsWidget(FString::Printf(TEXT("Properties (%d)"), ClassSnapshot.Properties.Num()), BuildMemberList(ClassSnapshot.Properties, TEXT("No properties.")));
			AddDetailsWidget(FString::Printf(TEXT("Methods (%d)"), ClassSnapshot.Methods.Num()), BuildMemberList(ClassSnapshot.Methods, TEXT("No methods.")));
		}
		break;
	case ESection::RegisteredTypes:
		if (Snapshot.RegisteredTypes.IsValidIndex(Index))
		{
			const FAngelscriptStateRegisteredTypeSnapshot& TypeSnapshot = Snapshot.RegisteredTypes[Index];
			AddDetailsHeader(TypeSnapshot.Declaration);
			AddDetailsRow(TEXT("TypeName"), TypeSnapshot.TypeName);
			AddDetailsRow(TEXT("Namespace"), DisplayOrNone(TypeSnapshot.Namespace));
			AddDetailsRow(TEXT("BaseType"), DisplayOrNone(TypeSnapshot.BaseType));
			AddDetailsRow(TEXT("TypeId"), FString::FromInt(TypeSnapshot.TypeId));
			AddDetailsRow(TEXT("Size"), FString::FromInt(TypeSnapshot.Size));
			AddDetailsRow(TEXT("Flags"), DisplayOrNone(TypeSnapshot.Flags));
			AddDetailsWidget(FString::Printf(TEXT("Properties (%d)"), TypeSnapshot.Properties.Num()), BuildStringList(TypeSnapshot.Properties, TEXT("No properties.")));
			AddDetailsWidget(FString::Printf(TEXT("Methods (%d)"), TypeSnapshot.Methods.Num()), BuildStringList(TypeSnapshot.Methods, TEXT("No methods.")));
		}
		break;
	case ESection::BindDatabase:
		if (Snapshot.BindTypes.IsValidIndex(Index))
		{
			const FAngelscriptStateBindTypeSnapshot& BindSnapshot = Snapshot.BindTypes[Index];
			AddDetailsHeader(BindSnapshot.TypeName);
			AddDetailsRow(TEXT("Kind"), BindSnapshot.Kind);
			AddDetailsRow(TEXT("C++ Type"), DisplayOrNone(BindSnapshot.CppTypeName));
			AddDetailsRow(TEXT("C++ Path"), DisplayOrNone(BindSnapshot.CppTypePath));
			AddDetailsRow(TEXT("UnrealPath"), DisplayOrNone(BindSnapshot.UnrealPath));
			AddDetailsRow(TEXT("ResolvedType"), DisplayOrNone(BindSnapshot.ResolvedTypePath));
			AddDetailsRow(TEXT("SourceHeader"), DisplayOrNone(BindSnapshot.SourceHeader));
			AddDetailsRow(
				TEXT("Call paths"),
				FString::Printf(
					TEXT("Direct %d / Reflective fallback %d / No function pointer %d / Unresolved %d"),
					BindSnapshot.DirectNativeMethodCount,
					BindSnapshot.ReflectiveFallbackMethodCount,
					BindSnapshot.NoFunctionPointerMethodCount,
					BindSnapshot.UnresolvedMethodCount));
			FAngelscriptStateInspectorBindDetailsFilter DetailsFilter = FAngelscriptStateInspectorBindDetailsFilter::Parse(BindDetailsSearchText);
			DetailsFilter.bShowProperties = bBindShowProperties;
			DetailsFilter.bShowMethods = bBindShowMethods;
			DetailsFilter.bShowDirectMethods = bBindShowDirectMethods;
			DetailsFilter.bShowReflectiveFallbackMethods = bBindShowReflectiveFallbackMethods;
			DetailsFilter.bShowNoFunctionPointerMethods = bBindShowNoFunctionPointerMethods;
			DetailsFilter.bShowUnresolvedMethods = bBindShowUnresolvedMethods;
			DetailsFilter.bOnlyIssues = bBindOnlyShowIssues;

			const int32 VisiblePropertyCount = CountVisibleBindProperties(BindSnapshot.Properties, DetailsFilter);
			const int32 VisibleMethodCount = CountVisibleBindMethods(BindSnapshot.Methods, DetailsFilter);

			auto MakeFilterToggle = [this](const FText& Label, bool SAngelscriptEngineStateWidget::* ToggleMember) -> TSharedRef<SWidget>
			{
				return SNew(SCheckBox)
					.IsChecked_Lambda([this, ToggleMember]()
					{
						return (this->*ToggleMember) ? ECheckBoxState::Checked : ECheckBoxState::Unchecked;
					})
					.OnCheckStateChanged_Lambda([this, ToggleMember](const ECheckBoxState NewState)
					{
						(this->*ToggleMember) = NewState == ECheckBoxState::Checked;
						RebuildDetailsPanel();
					})
					[
						SNew(STextBlock)
						.Text(Label)
					];
			};

			TSharedRef<SUniformGridPanel> ToggleGrid = SNew(SUniformGridPanel)
				.SlotPadding(FMargin(6.0f, 2.0f));
			ToggleGrid->AddSlot(0, 0)[MakeFilterToggle(LOCTEXT("BindFilterProperties", "Properties"), &SAngelscriptEngineStateWidget::bBindShowProperties)];
			ToggleGrid->AddSlot(1, 0)[MakeFilterToggle(LOCTEXT("BindFilterMethods", "Methods"), &SAngelscriptEngineStateWidget::bBindShowMethods)];
			ToggleGrid->AddSlot(0, 1)[MakeFilterToggle(LOCTEXT("BindFilterDirect", "Direct"), &SAngelscriptEngineStateWidget::bBindShowDirectMethods)];
			ToggleGrid->AddSlot(1, 1)[MakeFilterToggle(LOCTEXT("BindFilterFallback", "Fallback"), &SAngelscriptEngineStateWidget::bBindShowReflectiveFallbackMethods)];
			ToggleGrid->AddSlot(0, 2)[MakeFilterToggle(LOCTEXT("BindFilterNoPtr", "NoPtr"), &SAngelscriptEngineStateWidget::bBindShowNoFunctionPointerMethods)];
			ToggleGrid->AddSlot(1, 2)[MakeFilterToggle(LOCTEXT("BindFilterUnresolved", "Unresolved"), &SAngelscriptEngineStateWidget::bBindShowUnresolvedMethods)];
			ToggleGrid->AddSlot(0, 3)[MakeFilterToggle(LOCTEXT("BindFilterIssuesOnly", "Issues only"), &SAngelscriptEngineStateWidget::bBindOnlyShowIssues)];

			DetailsBox->AddSlot()
				.Padding(0.0f, 10.0f, 0.0f, 2.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot()
					.AutoHeight()
					[
						SNew(SBox)
						.WidthOverride(340.0f)
						[
							SAssignNew(BindDetailsSearchBox, SSearchBox)
							.InitialText(FText::FromString(BindDetailsSearchText))
							.HintText(LOCTEXT("BindDetailsSearchHint", "Search, kind:, owner:, category:, path:, flag:"))
							.OnTextChanged(this, &SAngelscriptEngineStateWidget::OnBindDetailsSearchTextChanged)
						]
					]
					+ SVerticalBox::Slot()
					.AutoHeight()
					.Padding(0.0f, 6.0f, 0.0f, 0.0f)
					[
						ToggleGrid
					]
				];
			AddDetailsWidget(
				FString::Printf(TEXT("Properties (%s)"), *FormatVisibleCount(VisiblePropertyCount, BindSnapshot.Properties.Num())),
				BuildBindPropertyList(BindSnapshot.Properties, DetailsFilter, TEXT("No properties.")));
			AddDetailsWidget(
				FString::Printf(TEXT("Methods (%s)"), *FormatVisibleCount(VisibleMethodCount, BindSnapshot.Methods.Num())),
				BuildBindMethodList(BindSnapshot.Methods, DetailsFilter, TEXT("No methods.")));
		}
		break;
	case ESection::BindRegistrations:
		if (Snapshot.BindRegistrations.IsValidIndex(Index))
		{
			const FAngelscriptStateBindRegistrationSnapshot& Registration = Snapshot.BindRegistrations[Index];
			AddDetailsHeader(Registration.BindName);
			AddDetailsRow(TEXT("BindOrder"), FString::FromInt(Registration.BindOrder));
			AddDetailsRow(TEXT("Enabled"), BoolToDisplayString(Registration.bEnabled));
			AddDetailsRow(TEXT("SkipReason"), DisplayOrNone(Registration.SkipReason));
		}
		break;
	case ESection::Diagnostics:
		if (Snapshot.Diagnostics.IsValidIndex(Index))
		{
			const FAngelscriptStateDiagnosticSnapshot& Diagnostic = Snapshot.Diagnostics[Index];
			AddDetailsHeader(Diagnostic.Filename);
			AddDetailsRow(TEXT("Location"), FString::Printf(TEXT("%d:%d"), Diagnostic.Row, Diagnostic.Column));
			AddDetailsRow(TEXT("Severity"), Diagnostic.Severity);
			AddDetailsRow(TEXT("Message"), Diagnostic.Message);
		}
		break;
	default:
		break;
	}
}

void SAngelscriptEngineStateWidget::UpdateSummaryText()
{
	if (SummaryText.IsValid())
	{
		SummaryText->SetText(GetSummaryText());
	}
}

FText SAngelscriptEngineStateWidget::GetSummaryText() const
{
	const FAngelscriptEngineStateOverviewSnapshot& Overview = Snapshot.Overview;
	return FText::FromString(FString::Printf(
		TEXT("%s | Instance: %s | Modules: %d | Script classes: %d | Bind DB: %d classes / %d structs | AS object types: %d | Captured: %s"),
		*Overview.Status,
		Overview.InstanceId.IsEmpty() ? TEXT("<none>") : *Overview.InstanceId,
		Overview.ModuleCount,
		Overview.ScriptClassCount,
		Overview.BindDatabaseClassCount,
		Overview.BindDatabaseStructCount,
		Overview.ScriptObjectTypeCount,
		*Overview.Timestamp));
}

TSharedRef<SWidget> SAngelscriptEngineStateWidget::BuildSectionButton(const ESection Section, const FText& Label)
{
	return SNew(SButton)
		.ButtonStyle(FAppStyle::Get(), "FlatButton")
		.ButtonColorAndOpacity_Lambda([this, Section]()
		{
			return ActiveSection == Section ? FLinearColor(0.18f, 0.28f, 0.42f) : FLinearColor::White;
		})
		.ContentPadding(FMargin(8.0f, 6.0f))
		.OnClicked(this, &SAngelscriptEngineStateWidget::SelectSection, Section)
		[
			SNew(SHorizontalBox)
			+ SHorizontalBox::Slot()
			.FillWidth(1.0f)
			.VAlign(VAlign_Center)
			[
				SNew(STextBlock)
				.Text(Label)
			]
			+ SHorizontalBox::Slot()
			.AutoWidth()
			.VAlign(VAlign_Center)
			[
				SNew(STextBlock)
				.Text_Lambda([this, Section]()
				{
					return Section == ESection::Overview ? FText::GetEmpty() : FText::AsNumber(GetSectionTotal(Section));
				})
			]
		];
}

TSharedRef<SWidget> SAngelscriptEngineStateWidget::BuildOverviewContent()
{
	const FAngelscriptEngineStateOverviewSnapshot& Overview = Snapshot.Overview;

	TSharedRef<SScrollBox> ScrollBox = SNew(SScrollBox);
	TSharedRef<SVerticalBox> Root = SNew(SVerticalBox);
	ScrollBox->AddSlot()
	[
		Root
	];

	Root->AddSlot()
	.AutoHeight()
	.Padding(0.0f, 0.0f, 0.0f, 8.0f)
	[
		SNew(STextBlock)
		.Text(LOCTEXT("OverviewTitle", "Engine Overview"))
		.Font(FAppStyle::GetFontStyle("HeadingSmall"))
	];

	TSharedRef<SVerticalBox> EngineBox = SNew(SVerticalBox);
	AddOverviewLine(EngineBox, TEXT("Status"), Overview.Status);
	AddOverviewLine(EngineBox, TEXT("InstanceId"), DisplayOrNone(Overview.InstanceId));
	AddOverviewLine(EngineBox, TEXT("CreationMode"), DisplayOrNone(Overview.CreationMode));
	AddOverviewLine(EngineBox, TEXT("SourceEngineId"), DisplayOrNone(Overview.SourceEngineId));
	AddOverviewLine(EngineBox, TEXT("OwnsEngine"), BoolToDisplayString(Overview.bOwnsEngine));
	AddOverviewLine(EngineBox, TEXT("HasScriptEngine"), BoolToDisplayString(Overview.bHasScriptEngine));
	AddOverviewLine(EngineBox, TEXT("InitialCompileFinished"), BoolToDisplayString(Overview.bInitialCompileFinished));
	AddOverviewLine(EngineBox, TEXT("InitialCompileSucceeded"), BoolToDisplayString(Overview.bInitialCompileSucceeded));
	AddOverviewLine(EngineBox, TEXT("IsHotReloading"), BoolToDisplayString(Overview.bIsHotReloading));
	AddOverviewLine(EngineBox, TEXT("UseEditorScripts"), BoolToDisplayString(Overview.bUseEditorScripts));
	AddOverviewLine(EngineBox, TEXT("ScriptDevelopmentMode"), BoolToDisplayString(Overview.bScriptDevelopmentMode));

	Root->AddSlot()
	.AutoHeight()
	.Padding(0.0f, 0.0f, 0.0f, 12.0f)
	[
		SNew(SBorder)
		.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
		.Padding(10.0f)
		[
			EngineBox
		]
	];

	Root->AddSlot()
	.AutoHeight()
	.Padding(0.0f, 0.0f, 0.0f, 8.0f)
	[
		SNew(STextBlock)
		.Text(LOCTEXT("CountsTitle", "Counts"))
		.Font(FAppStyle::GetFontStyle("HeadingSmall"))
	];

	Root->AddSlot()
	.AutoHeight()
	[
		SNew(SUniformGridPanel)
		.SlotPadding(FMargin(6.0f))
		+ SUniformGridPanel::Slot(0, 0)[BuildMetricCard(LOCTEXT("ModulesMetric", "Modules"), FString::FromInt(Overview.ModuleCount), CountLabel(TEXT("Diagnostics"), Overview.DiagnosticCount))]
		+ SUniformGridPanel::Slot(1, 0)[BuildMetricCard(LOCTEXT("ScriptClassesMetric", "Script Classes"), FString::FromInt(Overview.ScriptClassCount), FString::Printf(TEXT("%d properties / %d methods"), Overview.ScriptPropertyCount, Overview.ScriptMethodCount))]
		+ SUniformGridPanel::Slot(2, 0)[BuildMetricCard(LOCTEXT("BindTypesMetric", "Bind Database"), FString::Printf(TEXT("%d"), Overview.BindDatabaseClassCount + Overview.BindDatabaseStructCount), FString::Printf(TEXT("%d classes / %d structs"), Overview.BindDatabaseClassCount, Overview.BindDatabaseStructCount))]
		+ SUniformGridPanel::Slot(0, 1)[BuildMetricCard(LOCTEXT("BindRegistrationsMetric", "Bind Registrations"), FString::FromInt(Overview.BindRegistrationCount), FString::Printf(TEXT("%d methods / %d properties"), Overview.BindDatabaseMethodCount, Overview.BindDatabasePropertyCount))]
		+ SUniformGridPanel::Slot(1, 1)[BuildMetricCard(LOCTEXT("RegisteredTypesMetric", "FAngelscriptType"), FString::FromInt(Overview.RegisteredTypeCount), CountLabel(TEXT("AS object types"), Overview.ScriptObjectTypeCount))]
		+ SUniformGridPanel::Slot(2, 1)[BuildMetricCard(LOCTEXT("ScriptEnumsMetric", "Script Symbols"), FString::Printf(TEXT("%d"), Overview.ScriptEnumCount + Overview.ScriptDelegateCount), FString::Printf(TEXT("%d enums / %d delegates"), Overview.ScriptEnumCount, Overview.ScriptDelegateCount))]
	];

	return ScrollBox;
}

TSharedRef<SWidget> SAngelscriptEngineStateWidget::BuildTableContent()
{
	const int32 TotalCount = GetSectionTotal(ActiveSection);

	return SNew(SSplitter)
		+ SSplitter::Slot()
		.Value(0.62f)
		[
			SNew(SVerticalBox)
			+ SVerticalBox::Slot()
			.AutoHeight()
			.Padding(0.0f, 0.0f, 0.0f, 6.0f)
			[
				SNew(SHorizontalBox)
				+ SHorizontalBox::Slot()
				.FillWidth(1.0f)
				.VAlign(VAlign_Center)
				[
					SNew(STextBlock)
					.Text(GetSectionTitle(ActiveSection))
					.Font(FAppStyle::GetFontStyle("HeadingSmall"))
				]
				+ SHorizontalBox::Slot()
				.AutoWidth()
				.VAlign(VAlign_Center)
				[
					SNew(STextBlock)
					.Text(FText::FromString(GetSectionRowCountText(FilteredRows.Num(), TotalCount)))
				]
			]
			+ SVerticalBox::Slot()
			.FillHeight(1.0f)
			[
				SNew(SBorder)
				.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
				.Padding(1.0f)
				[
					SAssignNew(RowListView, SListView<TSharedPtr<FAngelscriptStateInspectorRow>>)
					.ListItemsSource(&FilteredRows)
					.SelectionMode(ESelectionMode::Single)
					.OnGenerateRow(this, &SAngelscriptEngineStateWidget::GenerateRow)
					.OnSelectionChanged(this, &SAngelscriptEngineStateWidget::OnRowSelectionChanged)
					.HeaderRow(BuildHeaderRow())
				]
			]
		]
		+ SSplitter::Slot()
		.Value(0.38f)
		[
			SNew(SBorder)
			.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
			.Padding(10.0f)
			[
				SAssignNew(DetailsBox, SScrollBox)
			]
		];
}

TSharedRef<SHeaderRow> SAngelscriptEngineStateWidget::BuildHeaderRow()
{
	using namespace AngelscriptStateInspectorColumns;

	return SNew(SHeaderRow)
		+ SHeaderRow::Column(Name)
		.DefaultLabel(GetColumnLabel(ActiveSection, Name))
		.FillWidth(0.28f)
		.SortMode(this, &SAngelscriptEngineStateWidget::GetColumnSortMode, Name)
		.OnSort(this, &SAngelscriptEngineStateWidget::OnSortColumn)
		+ SHeaderRow::Column(Context)
		.DefaultLabel(GetColumnLabel(ActiveSection, Context))
		.FillWidth(0.20f)
		.SortMode(this, &SAngelscriptEngineStateWidget::GetColumnSortMode, Context)
		.OnSort(this, &SAngelscriptEngineStateWidget::OnSortColumn)
		+ SHeaderRow::Column(Type)
		.DefaultLabel(GetColumnLabel(ActiveSection, Type))
		.FillWidth(0.22f)
		.SortMode(this, &SAngelscriptEngineStateWidget::GetColumnSortMode, Type)
		.OnSort(this, &SAngelscriptEngineStateWidget::OnSortColumn)
		+ SHeaderRow::Column(CountA)
		.DefaultLabel(GetColumnLabel(ActiveSection, CountA))
		.FixedWidth(78.0f)
		.SortMode(this, &SAngelscriptEngineStateWidget::GetColumnSortMode, CountA)
		.OnSort(this, &SAngelscriptEngineStateWidget::OnSortColumn)
		+ SHeaderRow::Column(CountB)
		.DefaultLabel(GetColumnLabel(ActiveSection, CountB))
		.FixedWidth(78.0f)
		.SortMode(this, &SAngelscriptEngineStateWidget::GetColumnSortMode, CountB)
		.OnSort(this, &SAngelscriptEngineStateWidget::OnSortColumn)
		+ SHeaderRow::Column(Status)
		.DefaultLabel(GetColumnLabel(ActiveSection, Status))
		.FillWidth(0.18f)
		.SortMode(this, &SAngelscriptEngineStateWidget::GetColumnSortMode, Status)
		.OnSort(this, &SAngelscriptEngineStateWidget::OnSortColumn);
}

TSharedRef<ITableRow> SAngelscriptEngineStateWidget::GenerateRow(TSharedPtr<FAngelscriptStateInspectorRow> Row, const TSharedRef<STableViewBase>& OwnerTable)
{
	return SNew(SAngelscriptStateInspectorTableRow, OwnerTable)
		.Item(Row);
}

void SAngelscriptEngineStateWidget::OnRowSelectionChanged(TSharedPtr<FAngelscriptStateInspectorRow> Row, ESelectInfo::Type SelectInfo)
{
	if (ActiveSection == ESection::BindDatabase && SelectedRow != Row)
	{
		BindDetailsSearchText.Reset();
	}

	SelectedRow = Row;
	RebuildDetailsPanel();
}

void SAngelscriptEngineStateWidget::OnSortColumn(EColumnSortPriority::Type SortPriority, const FName& ColumnName, EColumnSortMode::Type NewSortMode)
{
	SortColumn = ColumnName;
	SortMode = NewSortMode == EColumnSortMode::None ? EColumnSortMode::Ascending : NewSortMode;
	ApplySort();

	if (RowListView.IsValid())
	{
		RowListView->RequestListRefresh();
	}

	SelectDefaultRow();
	RebuildDetailsPanel();
}

EColumnSortMode::Type SAngelscriptEngineStateWidget::GetColumnSortMode(const FName ColumnName) const
{
	return SortColumn == ColumnName ? SortMode : EColumnSortMode::None;
}

FText SAngelscriptEngineStateWidget::GetSectionTitle(const ESection Section) const
{
	switch (Section)
	{
	case ESection::Overview:
		return LOCTEXT("OverviewSection", "Overview");
	case ESection::Modules:
		return LOCTEXT("ModulesSection", "Modules");
	case ESection::ScriptClasses:
		return LOCTEXT("ScriptClassesSection", "Script Classes");
	case ESection::RegisteredTypes:
		return LOCTEXT("RegisteredTypesSection", "AS Types");
	case ESection::BindDatabase:
		return LOCTEXT("BindDatabaseSection", "Bind Database");
	case ESection::BindRegistrations:
		return LOCTEXT("BindRegistrationsSection", "Bind Registrations");
	case ESection::Diagnostics:
		return LOCTEXT("DiagnosticsSection", "Diagnostics");
	default:
		return LOCTEXT("UnknownSection", "Unknown");
	}
}

int32 SAngelscriptEngineStateWidget::GetSectionTotal(const ESection Section) const
{
	switch (Section)
	{
	case ESection::Modules:
		return Snapshot.Modules.Num();
	case ESection::ScriptClasses:
		return Snapshot.ScriptClasses.Num();
	case ESection::RegisteredTypes:
		return Snapshot.RegisteredTypes.Num();
	case ESection::BindDatabase:
		return Snapshot.BindTypes.Num();
	case ESection::BindRegistrations:
		return Snapshot.BindRegistrations.Num();
	case ESection::Diagnostics:
		return Snapshot.Diagnostics.Num();
	case ESection::Overview:
	default:
		return 0;
	}
}

void SAngelscriptEngineStateWidget::AddOverviewLine(const TSharedRef<SVerticalBox>& Box, const FString& Key, const FString& Value) const
{
	Box->AddSlot()
		.AutoHeight()
		.Padding(0.0f, 2.0f)
		[
			SNew(SHorizontalBox)
			+ SHorizontalBox::Slot()
			.AutoWidth()
			[
				SNew(SBox)
				.WidthOverride(180.0f)
				[
					SNew(STextBlock)
					.Text(FText::FromString(Key))
				]
			]
			+ SHorizontalBox::Slot()
			.FillWidth(1.0f)
			[
				SNew(STextBlock)
				.Text(FText::FromString(Value))
				.AutoWrapText(true)
			]
		];
}

void SAngelscriptEngineStateWidget::AddDetailsHeader(const FString& Text)
{
	DetailsBox->AddSlot()
		.Padding(0.0f, 0.0f, 0.0f, 8.0f)
		[
			SNew(STextBlock)
			.Text(FText::FromString(Text))
			.Font(FAppStyle::GetFontStyle("HeadingSmall"))
			.AutoWrapText(true)
		];
}

void SAngelscriptEngineStateWidget::AddDetailsRow(const FString& Key, const FString& Value)
{
	DetailsBox->AddSlot()
		.Padding(0.0f, 2.0f)
		[
			SNew(SHorizontalBox)
			+ SHorizontalBox::Slot()
			.AutoWidth()
			[
				SNew(SBox)
				.WidthOverride(130.0f)
				[
					SNew(STextBlock)
					.Text(FText::FromString(Key))
				]
			]
			+ SHorizontalBox::Slot()
			.FillWidth(1.0f)
			[
				SNew(STextBlock)
				.Text(FText::FromString(Value))
				.AutoWrapText(true)
			]
		];
}

void SAngelscriptEngineStateWidget::AddDetailsWidget(const FString& Header, const TSharedRef<SWidget>& Widget)
{
	DetailsBox->AddSlot()
		.Padding(0.0f, 10.0f, 0.0f, 4.0f)
		[
			SNew(STextBlock)
			.Text(FText::FromString(Header))
			.Font(FAppStyle::GetFontStyle("HeadingExtraSmall"))
		];

	DetailsBox->AddSlot()
		.Padding(8.0f, 0.0f, 0.0f, 0.0f)
		[
			Widget
		];
}

void SAngelscriptEngineStateWidget::AddDetailsEmptyState(const FString& Message)
{
	DetailsBox->AddSlot()
		.Padding(4.0f)
		[
			SNew(STextBlock)
			.Text(FText::FromString(Message))
			.AutoWrapText(true)
		];
}

bool SAngelscriptEngineStateWidget::MatchesFilter(const FString& Text) const
{
	return SearchText.IsEmpty() || Text.Contains(SearchText, ESearchCase::IgnoreCase);
}

bool SAngelscriptEngineStateWidget::MatchesFilter(const TArray<FString>& Texts) const
{
	if (SearchText.IsEmpty())
	{
		return true;
	}

	for (const FString& Text : Texts)
	{
		if (MatchesFilter(Text))
		{
			return true;
		}
	}

	return false;
}

#undef LOCTEXT_NAMESPACE
