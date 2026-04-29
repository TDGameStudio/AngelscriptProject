#include "StateInspector/SAngelscriptStateDumpBrowserWidget.h"

#include "AngelscriptEngine.h"
#include "Dump/AngelscriptStateDump.h"
#include "StateInspector/AngelscriptStateDumpBrowserData.h"

#include "Styling/AppStyle.h"
#include "Widgets/Input/SButton.h"
#include "Widgets/Layout/SBorder.h"
#include "Widgets/SBoxPanel.h"
#include "Widgets/Text/STextBlock.h"
#include "Widgets/Views/STableRow.h"

#define LOCTEXT_NAMESPACE "SAngelscriptStateDumpBrowserWidget"

void SAngelscriptStateDumpBrowserWidget::Construct(const FArguments& InArgs)
{
	LoadDirectoryRows();

	ChildSlot
	[
		SNew(SVerticalBox)
		+ SVerticalBox::Slot()
		.AutoHeight()
		.Padding(8.0f)
		[
			SNew(SHorizontalBox)
			+ SHorizontalBox::Slot()
			.AutoWidth()
			.Padding(0.0f, 0.0f, 8.0f, 0.0f)
			[
				SNew(SButton)
				.Text(LOCTEXT("RefreshButton", "Refresh"))
				.OnClicked(this, &SAngelscriptStateDumpBrowserWidget::Refresh)
			]
			+ SHorizontalBox::Slot()
			.AutoWidth()
			.Padding(0.0f, 0.0f, 8.0f, 0.0f)
			[
				SNew(SButton)
				.Text(LOCTEXT("GenerateDumpButton", "Generate Dump"))
				.OnClicked(this, &SAngelscriptStateDumpBrowserWidget::GenerateDump)
			]
			+ SHorizontalBox::Slot()
			.AutoWidth()
			.Padding(0.0f, 0.0f, 12.0f, 0.0f)
			[
				SNew(SButton)
				.Text(LOCTEXT("DiffLatestTwoButton", "Diff Latest Two"))
				.OnClicked(this, &SAngelscriptStateDumpBrowserWidget::DiffLatestTwo)
			]
			+ SHorizontalBox::Slot()
			.FillWidth(1.0f)
			.VAlign(VAlign_Center)
			[
				SAssignNew(SummaryText, STextBlock)
				.Text(LOCTEXT("InitialSummary", "Saved Angelscript state dumps."))
				.AutoWrapText(true)
			]
		]
		+ SVerticalBox::Slot()
		.FillHeight(1.0f)
		.Padding(8.0f, 0.0f, 8.0f, 8.0f)
		[
			SNew(SBorder)
			.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
			.Padding(6.0f)
			[
				SAssignNew(RowsListView, SListView<TSharedPtr<FString>>)
				.ListItemsSource(&Rows)
				.OnGenerateRow(this, &SAngelscriptStateDumpBrowserWidget::GenerateRow)
			]
		]
	];
}

FReply SAngelscriptStateDumpBrowserWidget::Refresh()
{
	LoadDirectoryRows();
	if (RowsListView.IsValid())
	{
		RowsListView->RequestListRefresh();
	}
	return FReply::Handled();
}

FReply SAngelscriptStateDumpBrowserWidget::GenerateDump()
{
	FAngelscriptEngine* Engine = FAngelscriptEngine::TryGetCurrentEngine();
	if (Engine == nullptr)
	{
		SetRows({ TEXT("No active Angelscript engine.") }, TEXT("State dump skipped: no active Angelscript engine."));
		return FReply::Handled();
	}

	const FString OutputDir = FAngelscriptStateDump::DumpAll(*Engine);
	LoadDirectoryRows();
	if (SummaryText.IsValid())
	{
		SummaryText->SetText(FText::FromString(FString::Printf(TEXT("Generated dump: %s"), *OutputDir)));
	}
	return FReply::Handled();
}

FReply SAngelscriptStateDumpBrowserWidget::DiffLatestTwo()
{
	const FString RootDirectory = AngelscriptEditor::StateInspector::GetDefaultStateDumpRootDirectory();
	const TArray<FAngelscriptStateDumpDirectoryInfo> Dumps = AngelscriptEditor::StateInspector::ListStateDumpDirectories(RootDirectory);
	if (Dumps.Num() < 2)
	{
		SetRows({ FString::Printf(TEXT("Need at least two dump directories under %s."), *RootDirectory) }, TEXT("Diff skipped."));
		return FReply::Handled();
	}

	TArray<FString> DiffRows;
	const TArray<FAngelscriptStateDumpTableDiff> Diffs = AngelscriptEditor::StateInspector::DiffStateDumpDirectories(Dumps[1].DirectoryPath, Dumps[0].DirectoryPath);
	for (const FAngelscriptStateDumpTableDiff& Diff : Diffs)
	{
		if (!Diff.ErrorMessage.IsEmpty())
		{
			DiffRows.Add(FString::Printf(TEXT("%s | error: %s"), *Diff.TableName, *Diff.ErrorMessage));
			continue;
		}

		if (Diff.AddedRows != 0 || Diff.RemovedRows != 0 || Diff.ChangedRows != 0)
		{
			DiffRows.Add(FString::Printf(
				TEXT("%s | added %d / removed %d / changed %d"),
				*Diff.TableName,
				Diff.AddedRows,
				Diff.RemovedRows,
				Diff.ChangedRows));
		}
	}

	if (DiffRows.IsEmpty())
	{
		DiffRows.Add(TEXT("No table row differences found between the latest two dumps."));
	}

	SetRows(
		MoveTemp(DiffRows),
		FString::Printf(TEXT("Diff: %s -> %s"), *Dumps[1].DirectoryName, *Dumps[0].DirectoryName));
	return FReply::Handled();
}

TSharedRef<ITableRow> SAngelscriptStateDumpBrowserWidget::GenerateRow(TSharedPtr<FString> Row, const TSharedRef<STableViewBase>& OwnerTable)
{
	return SNew(STableRow<TSharedPtr<FString>>, OwnerTable)
	[
		SNew(STextBlock)
		.Text(FText::FromString(Row.IsValid() ? *Row : FString()))
		.AutoWrapText(true)
	];
}

void SAngelscriptStateDumpBrowserWidget::SetRows(TArray<FString> InRows, const FString& Summary)
{
	Rows.Reset();
	for (FString& Row : InRows)
	{
		Rows.Add(MakeShared<FString>(MoveTemp(Row)));
	}

	if (SummaryText.IsValid())
	{
		SummaryText->SetText(FText::FromString(Summary));
	}
	if (RowsListView.IsValid())
	{
		RowsListView->RequestListRefresh();
	}
}

void SAngelscriptStateDumpBrowserWidget::LoadDirectoryRows()
{
	const FString RootDirectory = AngelscriptEditor::StateInspector::GetDefaultStateDumpRootDirectory();
	const TArray<FAngelscriptStateDumpDirectoryInfo> Dumps = AngelscriptEditor::StateInspector::ListStateDumpDirectories(RootDirectory);

	TArray<FString> DirectoryRows;
	DirectoryRows.Reserve(FMath::Max(1, Dumps.Num()));
	for (const FAngelscriptStateDumpDirectoryInfo& Dump : Dumps)
	{
		DirectoryRows.Add(FString::Printf(
			TEXT("%s | CSV tables: %d | %s"),
			*Dump.DirectoryName,
			Dump.CsvFileCount,
			*Dump.DirectoryPath));
	}
	if (DirectoryRows.IsEmpty())
	{
		DirectoryRows.Add(FString::Printf(TEXT("No state dumps found under %s."), *RootDirectory));
	}

	SetRows(
		MoveTemp(DirectoryRows),
		FString::Printf(TEXT("State dumps: %d | Root: %s"), Dumps.Num(), *RootDirectory));
}

#undef LOCTEXT_NAMESPACE
