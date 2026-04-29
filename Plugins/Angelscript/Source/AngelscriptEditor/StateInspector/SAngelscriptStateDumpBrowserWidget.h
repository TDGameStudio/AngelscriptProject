#pragma once

#include "CoreMinimal.h"
#include "Widgets/SCompoundWidget.h"
#include "Widgets/Views/SListView.h"

class STextBlock;

class SAngelscriptStateDumpBrowserWidget : public SCompoundWidget
{
public:
	SLATE_BEGIN_ARGS(SAngelscriptStateDumpBrowserWidget) {}
	SLATE_END_ARGS()

	void Construct(const FArguments& InArgs);

private:
	FReply Refresh();
	FReply GenerateDump();
	FReply DiffLatestTwo();
	TSharedRef<ITableRow> GenerateRow(TSharedPtr<FString> Row, const TSharedRef<STableViewBase>& OwnerTable);
	void SetRows(TArray<FString> InRows, const FString& Summary);
	void LoadDirectoryRows();

	TSharedPtr<STextBlock> SummaryText;
	TSharedPtr<SListView<TSharedPtr<FString>>> RowsListView;
	TArray<TSharedPtr<FString>> Rows;
};
