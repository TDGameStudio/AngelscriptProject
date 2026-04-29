#include "StateInspector/SAngelscriptContentBrowserSourceHealthWidget.h"

#include "AngelscriptEngine.h"
#include "ContentBrowserDataSubsystem.h"
#include "IContentBrowserDataModule.h"
#include "Misc/Paths.h"
#include "SourceNavigation/AngelscriptSourceCodeNavigation.h"
#include "Styling/AppStyle.h"
#include "Widgets/Input/SButton.h"
#include "Widgets/Layout/SBorder.h"
#include "Widgets/SBoxPanel.h"
#include "Widgets/Text/STextBlock.h"
#include "Widgets/Views/STableRow.h"

#define LOCTEXT_NAMESPACE "SAngelscriptContentBrowserSourceHealthWidget"

namespace
{
	FString BoolToString(const bool bValue)
	{
		return bValue ? TEXT("true") : TEXT("false");
	}
}

void SAngelscriptContentBrowserSourceHealthWidget::Construct(const FArguments& InArgs)
{
	RebuildRows();

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
				.OnClicked(this, &SAngelscriptContentBrowserSourceHealthWidget::Refresh)
			]
			+ SHorizontalBox::Slot()
			.FillWidth(1.0f)
			.VAlign(VAlign_Center)
			[
				SAssignNew(SummaryText, STextBlock)
				.Text(LOCTEXT("Summary", "Content Browser and source navigation health snapshot."))
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
				.OnGenerateRow(this, &SAngelscriptContentBrowserSourceHealthWidget::GenerateRow)
			]
		]
	];
}

FReply SAngelscriptContentBrowserSourceHealthWidget::Refresh()
{
	RebuildRows();
	if (RowsListView.IsValid())
	{
		RowsListView->RequestListRefresh();
	}
	return FReply::Handled();
}

TSharedRef<ITableRow> SAngelscriptContentBrowserSourceHealthWidget::GenerateRow(TSharedPtr<FString> Row, const TSharedRef<STableViewBase>& OwnerTable)
{
	return SNew(STableRow<TSharedPtr<FString>>, OwnerTable)
	[
		SNew(STextBlock)
		.Text(FText::FromString(Row.IsValid() ? *Row : FString()))
		.AutoWrapText(true)
	];
}

void SAngelscriptContentBrowserSourceHealthWidget::RebuildRows()
{
	Rows.Reset();

	UContentBrowserDataSubsystem* ContentBrowserDataSubsystem = IContentBrowserDataModule::Get().GetSubsystem();
	const TArray<FName> ActiveDataSources = ContentBrowserDataSubsystem != nullptr
		? ContentBrowserDataSubsystem->GetActiveDataSources()
		: TArray<FName>();
	const bool bAngelscriptDataSourceActive = ActiveDataSources.Contains(FName(TEXT("AngelscriptData")));

	Rows.Add(MakeShared<FString>(FString::Printf(TEXT("ContentBrowserDataSubsystem: %s"), ContentBrowserDataSubsystem != nullptr ? TEXT("available") : TEXT("missing"))));
	Rows.Add(MakeShared<FString>(FString::Printf(TEXT("AngelscriptData active: %s"), *BoolToString(bAngelscriptDataSourceActive))));
	for (const FName ActiveDataSource : ActiveDataSources)
	{
		Rows.Add(MakeShared<FString>(FString::Printf(TEXT("Active data source: %s"), *ActiveDataSource.ToString())));
	}

	if (FAngelscriptEngine* Engine = FAngelscriptEngine::TryGetCurrentEngine())
	{
		Rows.Add(MakeShared<FString>(FString::Printf(TEXT("Script root directory: %s"), *FAngelscriptEngine::GetScriptRootDirectory())));
		for (const FString& RootPath : Engine->AllRootPaths)
		{
			Rows.Add(MakeShared<FString>(FString::Printf(TEXT("Script root: %s"), *RootPath)));
		}

		const FString VSCodeParameters = AngelscriptSourceNavigation::BuildVSCodeOpenParameters(
			TEXT("Example.as:12"),
			FPaths::ProjectDir(),
			true,
			FAngelscriptEngine::GetScriptRootDirectory());
		Rows.Add(MakeShared<FString>(FString::Printf(TEXT("VS Code sample parameters: %s"), *VSCodeParameters)));
	}
	else
	{
		Rows.Add(MakeShared<FString>(TEXT("No active Angelscript engine; script roots and source navigation workspace cannot be resolved.")));
	}

	if (SummaryText.IsValid())
	{
		SummaryText->SetText(FText::FromString(FString::Printf(
			TEXT("AngelscriptData active: %s | Active data sources: %d"),
			*BoolToString(bAngelscriptDataSourceActive),
			ActiveDataSources.Num())));
	}
}

#undef LOCTEXT_NAMESPACE
