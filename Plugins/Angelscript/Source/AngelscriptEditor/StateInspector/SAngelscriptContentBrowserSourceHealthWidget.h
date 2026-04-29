#pragma once

#include "CoreMinimal.h"
#include "Widgets/SCompoundWidget.h"
#include "Widgets/Views/SListView.h"

class STextBlock;

class SAngelscriptContentBrowserSourceHealthWidget : public SCompoundWidget
{
public:
	SLATE_BEGIN_ARGS(SAngelscriptContentBrowserSourceHealthWidget) {}
	SLATE_END_ARGS()

	void Construct(const FArguments& InArgs);

private:
	FReply Refresh();
	TSharedRef<ITableRow> GenerateRow(TSharedPtr<FString> Row, const TSharedRef<STableViewBase>& OwnerTable);
	void RebuildRows();

	TSharedPtr<STextBlock> SummaryText;
	TSharedPtr<SListView<TSharedPtr<FString>>> RowsListView;
	TArray<TSharedPtr<FString>> Rows;
};
