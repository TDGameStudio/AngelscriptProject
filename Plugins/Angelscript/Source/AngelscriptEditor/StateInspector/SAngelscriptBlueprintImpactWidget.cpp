#include "StateInspector/SAngelscriptBlueprintImpactWidget.h"

#include "AngelscriptEngine.h"
#include "AssetRegistry/AssetRegistryModule.h"
#include "BlueprintImpact/AngelscriptBlueprintImpactScanner.h"
#include "Modules/ModuleManager.h"
#include "Styling/AppStyle.h"
#include "Widgets/Input/SButton.h"
#include "Widgets/Input/SCheckBox.h"
#include "Widgets/Input/SEditableTextBox.h"
#include "Widgets/Layout/SBorder.h"
#include "Widgets/Layout/SBox.h"
#include "Widgets/SBoxPanel.h"
#include "Widgets/Text/STextBlock.h"
#include "Widgets/Views/STableRow.h"

#define LOCTEXT_NAMESPACE "SAngelscriptBlueprintImpactWidget"

namespace
{
	FString JoinImpactReasons(const TArray<AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason>& Reasons)
	{
		TArray<FString> ReasonStrings;
		ReasonStrings.Reserve(Reasons.Num());
		for (const AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason Reason : Reasons)
		{
			ReasonStrings.Add(AngelscriptEditor::BlueprintImpact::LexToString(Reason));
		}
		return FString::Join(ReasonStrings, TEXT(", "));
	}
}

void SAngelscriptBlueprintImpactWidget::Construct(const FArguments& InArgs)
{
	Rows.Add(MakeShared<FString>(TEXT("Run a scan to inspect Blueprint assets affected by Angelscript symbols.")));

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
				SNew(SVerticalBox)
				+ SVerticalBox::Slot()
				.AutoHeight()
				[
					SNew(STextBlock)
					.Text(LOCTEXT("ChangedScriptsLabel", "Changed scripts (; separated, empty = full scan)"))
				]
				+ SVerticalBox::Slot()
				.AutoHeight()
				.Padding(0.0f, 4.0f, 0.0f, 8.0f)
				[
					SAssignNew(ChangedScriptsTextBox, SEditableTextBox)
					.HintText(LOCTEXT("ChangedScriptsHint", "Script/Example.as; Plugins/MyPlugin/Script/Feature.as"))
				]
				+ SVerticalBox::Slot()
				.AutoHeight()
				[
					SNew(SHorizontalBox)
					+ SHorizontalBox::Slot()
					.AutoWidth()
					.VAlign(VAlign_Center)
					.Padding(0.0f, 0.0f, 12.0f, 0.0f)
					[
						SNew(SButton)
						.Text(LOCTEXT("RunScanButton", "Run Scan"))
						.OnClicked(this, &SAngelscriptBlueprintImpactWidget::RunScan)
					]
					+ SHorizontalBox::Slot()
					.AutoWidth()
					.VAlign(VAlign_Center)
					.Padding(0.0f, 0.0f, 6.0f, 0.0f)
					[
						SAssignNew(IncludeOnlyOnDiskCheckBox, SCheckBox)
						.IsChecked(ECheckBoxState::Checked)
					]
					+ SHorizontalBox::Slot()
					.AutoWidth()
					.VAlign(VAlign_Center)
					[
						SNew(STextBlock)
						.Text(LOCTEXT("OnDiskOnlyLabel", "Include only on-disk Blueprint assets"))
					]
				]
			]
		]
		+ SVerticalBox::Slot()
		.AutoHeight()
		.Padding(8.0f, 0.0f, 8.0f, 8.0f)
		[
			SAssignNew(SummaryText, STextBlock)
			.Text(LOCTEXT("InitialSummary", "No Blueprint impact scan has run."))
			.AutoWrapText(true)
		]
		+ SVerticalBox::Slot()
		.FillHeight(1.0f)
		.Padding(8.0f, 0.0f, 8.0f, 8.0f)
		[
			SNew(SBorder)
			.BorderImage(FAppStyle::GetBrush("ToolPanel.GroupBorder"))
			.Padding(6.0f)
			[
				SAssignNew(ResultsListView, SListView<TSharedPtr<FString>>)
				.ListItemsSource(&Rows)
				.OnGenerateRow(this, &SAngelscriptBlueprintImpactWidget::GenerateRow)
			]
		]
	];
}

FReply SAngelscriptBlueprintImpactWidget::RunScan()
{
	FAngelscriptEngine* Engine = FAngelscriptEngine::TryGetCurrentEngine();
	if (Engine == nullptr)
	{
		SetRows({ TEXT("No active Angelscript engine.") }, TEXT("Blueprint impact scan skipped: no active Angelscript engine."));
		return FReply::Handled();
	}

	FAssetRegistryModule& AssetRegistryModule = FModuleManager::LoadModuleChecked<FAssetRegistryModule>(TEXT("AssetRegistry"));
	AngelscriptEditor::BlueprintImpact::FBlueprintImpactRequest Request;
	Request.ChangedScripts = ParseChangedScripts();
	Request.bIncludeOnlyOnDiskAssets = IncludeOnlyOnDiskCheckBox.IsValid() && IncludeOnlyOnDiskCheckBox->IsChecked();

	const AngelscriptEditor::BlueprintImpact::FBlueprintImpactScanResult Result =
		AngelscriptEditor::BlueprintImpact::ScanBlueprintAssets(*Engine, AssetRegistryModule.Get(), Request);

	TArray<FString> ResultRows;
	ResultRows.Add(FString::Printf(TEXT("Matching modules: %d"), Result.MatchingModules.Num()));
	for (const TSharedRef<FAngelscriptModuleDesc>& Module : Result.MatchingModules)
	{
		ResultRows.Add(FString::Printf(TEXT("Module: %s"), *Module->ModuleName));
	}

	for (const AngelscriptEditor::BlueprintImpact::FBlueprintImpactMatch& Match : Result.Matches)
	{
		ResultRows.Add(FString::Printf(
			TEXT("%s | %s"),
			*Match.AssetData.PackageName.ToString(),
			*JoinImpactReasons(Match.Reasons)));
	}

	if (ResultRows.IsEmpty())
	{
		ResultRows.Add(TEXT("No affected Blueprint assets found."));
	}

	SetRows(
		MoveTemp(ResultRows),
		FString::Printf(
			TEXT("Changed scripts: %d | Candidates: %d | Matches: %d | Failed loads: %d"),
			Result.NormalizedChangedScripts.Num(),
			Result.CandidateAssets.Num(),
			Result.Matches.Num(),
			Result.FailedAssetLoads));
	return FReply::Handled();
}

TSharedRef<ITableRow> SAngelscriptBlueprintImpactWidget::GenerateRow(TSharedPtr<FString> Row, const TSharedRef<STableViewBase>& OwnerTable)
{
	return SNew(STableRow<TSharedPtr<FString>>, OwnerTable)
	[
		SNew(STextBlock)
		.Text(FText::FromString(Row.IsValid() ? *Row : FString()))
		.AutoWrapText(true)
	];
}

TArray<FString> SAngelscriptBlueprintImpactWidget::ParseChangedScripts() const
{
	TArray<FString> Result;
	if (!ChangedScriptsTextBox.IsValid())
	{
		return Result;
	}

	TArray<FString> Parts;
	ChangedScriptsTextBox->GetText().ToString().ParseIntoArray(Parts, TEXT(";"), true);
	for (FString Part : Parts)
	{
		Part.TrimStartAndEndInline();
		if (!Part.IsEmpty())
		{
			Result.Add(MoveTemp(Part));
		}
	}
	return Result;
}

void SAngelscriptBlueprintImpactWidget::SetRows(TArray<FString> InRows, const FString& Summary)
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
	if (ResultsListView.IsValid())
	{
		ResultsListView->RequestListRefresh();
	}
}

#undef LOCTEXT_NAMESPACE
