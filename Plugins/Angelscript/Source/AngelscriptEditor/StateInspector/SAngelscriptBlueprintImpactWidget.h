#pragma once

#include "CoreMinimal.h"
#include "Widgets/SCompoundWidget.h"
#include "Widgets/Views/SListView.h"

class SCheckBox;
class SEditableTextBox;
class STextBlock;

class SAngelscriptBlueprintImpactWidget : public SCompoundWidget
{
public:
	SLATE_BEGIN_ARGS(SAngelscriptBlueprintImpactWidget) {}
	SLATE_END_ARGS()

	void Construct(const FArguments& InArgs);

private:
	FReply RunScan();
	TSharedRef<ITableRow> GenerateRow(TSharedPtr<FString> Row, const TSharedRef<STableViewBase>& OwnerTable);
	TArray<FString> ParseChangedScripts() const;
	void SetRows(TArray<FString> InRows, const FString& Summary);

	TSharedPtr<SEditableTextBox> ChangedScriptsTextBox;
	TSharedPtr<SCheckBox> IncludeOnlyOnDiskCheckBox;
	TSharedPtr<STextBlock> SummaryText;
	TSharedPtr<SListView<TSharedPtr<FString>>> ResultsListView;
	TArray<TSharedPtr<FString>> Rows;
};
