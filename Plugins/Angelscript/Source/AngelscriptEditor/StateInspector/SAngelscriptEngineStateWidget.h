#pragma once

#include "CoreMinimal.h"
#include "StateInspector/AngelscriptEngineStateSnapshot.h"
#include "Widgets/SCompoundWidget.h"
#include "Widgets/Views/SHeaderRow.h"
#include "Widgets/Views/SListView.h"

class SBorder;
class SScrollBox;
class SSearchBox;
class STextBlock;

struct FAngelscriptStateInspectorRow
{
	int32 SourceIndex = INDEX_NONE;
	FString Name;
	FString Context;
	FString Type;
	FString CountA;
	FString CountB;
	FString Status;
	FString SearchText;
	bool bWarning = false;

	FString GetColumnText(const FName& ColumnName) const;
};

struct FAngelscriptStateInspectorBindDetailsFilter
{
	FString RawText;
	TArray<FString> PlainTerms;
	TArray<FString> KindTerms;
	TArray<FString> OwnerTerms;
	TArray<FString> CategoryTerms;
	TArray<FString> PathTerms;
	TArray<FString> FlagTerms;
	bool bShowProperties = true;
	bool bShowMethods = true;
	bool bShowDirectMethods = true;
	bool bShowReflectiveFallbackMethods = true;
	bool bShowNoFunctionPointerMethods = true;
	bool bShowUnresolvedMethods = true;
	bool bOnlyIssues = false;

	static FAngelscriptStateInspectorBindDetailsFilter Parse(const FString& InText);
	bool MatchesProperty(const FAngelscriptStateBindPropertySnapshot& Property) const;
	bool MatchesMethod(const FAngelscriptStateBindMethodSnapshot& Method) const;
};

class SAngelscriptEngineStateWidget : public SCompoundWidget
{
public:
	enum class ESection : uint8
	{
		Overview,
		Modules,
		ScriptClasses,
		RegisteredTypes,
		BindDatabase,
		BindRegistrations,
		Diagnostics
	};

	SLATE_BEGIN_ARGS(SAngelscriptEngineStateWidget)
		: _InitialSection(ESection::Overview)
		, _bShowSectionNavigation(true)
	{
	}
		SLATE_ARGUMENT(ESection, InitialSection)
		SLATE_ARGUMENT(bool, bShowSectionNavigation)
	SLATE_END_ARGS()

	void Construct(const FArguments& InArgs);

private:
	FReply RefreshSnapshot();
	FReply SelectSection(ESection Section);
	void OnSearchTextChanged(const FText& NewText);
	void OnBindDetailsSearchTextChanged(const FText& NewText);
	void RefreshSnapshotData();
	void RebuildContent();
	void RebuildRows();
	void ApplySort();
	void SelectDefaultRow();
	void RebuildDetailsPanel();
	void UpdateSummaryText();
	FText GetSummaryText() const;

	TSharedRef<SWidget> BuildSectionButton(ESection Section, const FText& Label);
	TSharedRef<SWidget> BuildOverviewContent();
	TSharedRef<SWidget> BuildTableContent();
	TSharedRef<SHeaderRow> BuildHeaderRow();
	TSharedRef<ITableRow> GenerateRow(TSharedPtr<FAngelscriptStateInspectorRow> Row, const TSharedRef<STableViewBase>& OwnerTable);
	void OnRowSelectionChanged(TSharedPtr<FAngelscriptStateInspectorRow> Row, ESelectInfo::Type SelectInfo);
	void OnSortColumn(EColumnSortPriority::Type SortPriority, const FName& ColumnName, EColumnSortMode::Type NewSortMode);
	EColumnSortMode::Type GetColumnSortMode(const FName ColumnName) const;

	FText GetSectionTitle(ESection Section) const;
	int32 GetSectionTotal(ESection Section) const;
	void AddOverviewLine(const TSharedRef<SVerticalBox>& Box, const FString& Key, const FString& Value) const;
	void AddDetailsHeader(const FString& Text);
	void AddDetailsRow(const FString& Key, const FString& Value);
	void AddDetailsWidget(const FString& Header, const TSharedRef<SWidget>& Widget);
	void AddDetailsEmptyState(const FString& Message);

	bool MatchesFilter(const FString& Text) const;
	bool MatchesFilter(const TArray<FString>& Texts) const;

	FAngelscriptEngineStateSnapshot Snapshot;
	ESection ActiveSection = ESection::Overview;
	bool bShowSectionNavigation = true;
	FString SearchText;
	FString BindDetailsSearchText;
	FName SortColumn;
	EColumnSortMode::Type SortMode = EColumnSortMode::Ascending;
	TArray<TSharedPtr<FAngelscriptStateInspectorRow>> FilteredRows;
	TSharedPtr<FAngelscriptStateInspectorRow> SelectedRow;
	TSharedPtr<SBorder> MainContent;
	TSharedPtr<SListView<TSharedPtr<FAngelscriptStateInspectorRow>>> RowListView;
	TSharedPtr<SScrollBox> DetailsBox;
	TSharedPtr<SSearchBox> SearchBox;
	TSharedPtr<SSearchBox> BindDetailsSearchBox;
	TSharedPtr<STextBlock> SummaryText;
	bool bBindShowProperties = true;
	bool bBindShowMethods = true;
	bool bBindShowDirectMethods = true;
	bool bBindShowReflectiveFallbackMethods = true;
	bool bBindShowNoFunctionPointerMethods = true;
	bool bBindShowUnresolvedMethods = true;
	bool bBindOnlyShowIssues = false;
};
