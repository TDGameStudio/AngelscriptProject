#include "SAngelscriptDebuggerWindow.h"

#include "AngelscriptDebuggerClient.h"
#include "AngelscriptDebuggerPresentation.h"
#include "AngelscriptDebuggerSourcePresentation.h"
#include "AngelscriptDebuggerSourceViewState.h"
#include "AngelscriptDebuggerViewModels.h"
#include "Debugging/AngelscriptDebugClientModel.h"
#include "Debugging/AngelscriptDebugProtocol.h"
#include "Framework/Application/SlateApplication.h"
#include "HAL/FileManager.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Styling/CoreStyle.h"
#include "Syntax/AngelscriptSyntaxTokenizer.h"
#include "Syntax/SAngelscriptHighlightedLine.h"
#include "Widgets/Input/SButton.h"
#include "Widgets/Input/SCheckBox.h"
#include "Widgets/Input/SEditableTextBox.h"
#include "Widgets/Input/SSearchBox.h"
#include "Widgets/Images/SImage.h"
#include "Widgets/Layout/SBorder.h"
#include "Widgets/Layout/SBox.h"
#include "Widgets/Layout/SSplitter.h"
#include "Widgets/Text/STextBlock.h"
#include "Widgets/Views/SListView.h"
#include "Widgets/Views/STreeView.h"

namespace
{
	using namespace AngelscriptDebugger;

	class SAngelscriptDebuggerWindow final : public SCompoundWidget
	{
	public:
		SLATE_BEGIN_ARGS(SAngelscriptDebuggerWindow) {}
			SLATE_ARGUMENT(FString, InitialHost)
			SLATE_ARGUMENT(int32, InitialPort)
			SLATE_ARGUMENT(FString, ProjectPath)
			SLATE_ARGUMENT(FString, ScriptRoot)
			SLATE_ARGUMENT(bool, AutoConnect)
		SLATE_END_ARGS()

		void Construct(const FArguments& InArgs)
		{
			HostText = FText::FromString(InArgs._InitialHost.IsEmpty() ? TEXT("127.0.0.1") : InArgs._InitialHost);
			PortText = FText::AsNumber(InArgs._InitialPort > 0 ? InArgs._InitialPort : 27099);
			ProjectPath = InArgs._ProjectPath;
			ScriptRoot = AngelscriptDebugClient::NormalizeDebuggerFilename(InArgs._ScriptRoot);
			if (ScriptRoot.IsEmpty() && !ProjectPath.IsEmpty())
			{
				ScriptRoot = AngelscriptDebugClient::NormalizeDebuggerFilename(FPaths::GetPath(ProjectPath) / TEXT("Script"));
			}
			ScriptRoots.Add(ScriptRoot);

			RefreshSectionsFromDisk();
			AddLogLine(TEXT("Ready."));

			ChildSlot
			[
				SNew(SBorder)
				.Padding(8.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 6.0f)
					[
						BuildConnectionBar()
					]
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 6.0f)
					[
						BuildControlBar()
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						BuildWorkspace()
					]
				]
			];

			RegisterActiveTimer(0.0f, FWidgetActiveTimerDelegate::CreateSP(this, &SAngelscriptDebuggerWindow::HandleActiveTimer));
			if (InArgs._AutoConnect)
			{
				Client.Connect(HostText.ToString(), InArgs._InitialPort > 0 ? InArgs._InitialPort : 27099);
			}
		}

		void ShutdownSession()
		{
			if (Client.IsConnected())
			{
				Client.SendEmpty(EDebugMessageType::StopDebugging);
				Client.SendEmpty(EDebugMessageType::Disconnect);
				Client.Tick();
			}
			Client.Disconnect();
			ResetRuntimeSessionState(false);
		}

		virtual bool SupportsKeyboardFocus() const override
		{
			return true;
		}

		virtual FReply OnKeyDown(const FGeometry& MyGeometry, const FKeyEvent& InKeyEvent) override
		{
			if (InKeyEvent.GetKey() == EKeys::F5)
			{
				SendDebuggerCommand(EDebugMessageType::Continue);
				return FReply::Handled();
			}
			if (InKeyEvent.GetKey() == EKeys::F9)
			{
				ToggleBreakpointAtCurrentLine();
				return FReply::Handled();
			}
			if (InKeyEvent.GetKey() == EKeys::F10)
			{
				SendDebuggerCommand(EDebugMessageType::StepOver);
				return FReply::Handled();
			}
			if (InKeyEvent.GetKey() == EKeys::F11)
			{
				SendDebuggerCommand(InKeyEvent.IsShiftDown() ? EDebugMessageType::StepOut : EDebugMessageType::StepIn);
				return FReply::Handled();
			}
			return SCompoundWidget::OnKeyDown(MyGeometry, InKeyEvent);
		}

	private:
		TSharedRef<SWidget> BuildConnectionBar()
		{
			return SNew(SHorizontalBox)
				+ SHorizontalBox::Slot().AutoWidth().VAlign(VAlign_Center).Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					SNew(STextBlock).Text(FText::FromString(TEXT("Host")))
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 10.0f, 0.0f)
				[
					SNew(SBox).WidthOverride(150.0f)
					[
						SAssignNew(HostTextBox, SEditableTextBox).Text(HostText)
					]
				]
				+ SHorizontalBox::Slot().AutoWidth().VAlign(VAlign_Center).Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					SNew(STextBlock).Text(FText::FromString(TEXT("Port")))
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 10.0f, 0.0f)
				[
					SNew(SBox).WidthOverride(90.0f)
					[
						SAssignNew(PortTextBox, SEditableTextBox).Text(PortText)
					]
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					SNew(SButton).Text(FText::FromString(TEXT("Connect"))).OnClicked(this, &SAngelscriptDebuggerWindow::OnConnectClicked)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 10.0f, 0.0f)
				[
					SNew(SButton).Text(FText::FromString(TEXT("Disconnect"))).OnClicked(this, &SAngelscriptDebuggerWindow::OnDisconnectClicked)
				]
				+ SHorizontalBox::Slot().FillWidth(1.0f).VAlign(VAlign_Center)
				[
					SNew(STextBlock).Text(this, &SAngelscriptDebuggerWindow::GetStatusText)
				];
		}

		TSharedRef<SWidget> BuildControlBar()
		{
			return SNew(SHorizontalBox)
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					BuildCommandButton(TEXT("Pause"), EDebugMessageType::Pause)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					BuildCommandButton(TEXT("Continue"), EDebugMessageType::Continue)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					BuildCommandButton(TEXT("Step In"), EDebugMessageType::StepIn)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					BuildCommandButton(TEXT("Step Over"), EDebugMessageType::StepOver)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					BuildCommandButton(TEXT("Step Out"), EDebugMessageType::StepOut)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 12.0f, 0.0f)
				[
					BuildCommandButton(TEXT("Stop Debugging"), EDebugMessageType::StopDebugging)
				]
				+ SHorizontalBox::Slot().AutoWidth().VAlign(VAlign_Center).Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					SNew(STextBlock).Text(FText::FromString(TEXT("Breakpoint condition")))
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 8.0f, 0.0f)
				[
					SNew(SBox).WidthOverride(240.0f)
					[
						SAssignNew(BreakpointConditionTextBox, SEditableTextBox)
						.HintText(FText::FromString(TEXT("Optional expression for selected line")))
					]
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					SNew(SButton)
					.Text(FText::FromString(TEXT("Toggle")))
					.ToolTipText(FText::FromString(TEXT("Toggle a breakpoint on the selected source line. Shortcut: F9.")))
					.OnClicked(this, &SAngelscriptDebuggerWindow::OnToggleBreakpointClicked)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					SNew(SButton)
					.Text(FText::FromString(TEXT("Apply Condition")))
					.ToolTipText(FText::FromString(TEXT("Apply the condition to the selected breakpoint or current line breakpoint.")))
					.OnClicked(this, &SAngelscriptDebuggerWindow::OnApplyBreakpointConditionClicked)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					SNew(SButton)
					.Text(FText::FromString(TEXT("Clear Condition")))
					.ToolTipText(FText::FromString(TEXT("Remove the condition from the selected breakpoint or current line breakpoint.")))
					.OnClicked(this, &SAngelscriptDebuggerWindow::OnClearBreakpointConditionClicked)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					SNew(SButton)
					.Text(FText::FromString(TEXT("Remove")))
					.ToolTipText(FText::FromString(TEXT("Remove the selected breakpoint.")))
					.OnClicked(this, &SAngelscriptDebuggerWindow::OnRemoveBreakpointClicked)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					SNew(SButton)
					.Text(FText::FromString(TEXT("Clear All")))
					.ToolTipText(FText::FromString(TEXT("Remove all breakpoints in this debugger window.")))
					.OnClicked(this, &SAngelscriptDebuggerWindow::OnClearAllBreakpointsClicked)
				]
				+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
				[
					SNew(SButton)
					.Text(FText::FromString(TEXT("Refresh Source")))
					.OnClicked(this, &SAngelscriptDebuggerWindow::OnRefreshSourceClicked)
				];
		}

		TSharedRef<SWidget> BuildCommandButton(const TCHAR* Label, const EDebugMessageType MessageType)
		{
			return SNew(SButton)
				.Text(FText::FromString(Label))
				.ToolTipText(GetDebuggerCommandTooltip(MessageType))
				.IsEnabled_Lambda([this, MessageType]()
				{
					return IsDebuggerCommandEnabled(MessageType);
				})
				.OnClicked_Lambda([this, MessageType]()
				{
					SendDebuggerCommand(MessageType);
					return FReply::Handled();
				});
		}

		bool IsDebuggerCommandEnabled(const EDebugMessageType MessageType) const
		{
			if (!Client.IsConnected())
			{
				return false;
			}

			switch (MessageType)
			{
			case EDebugMessageType::Pause:
				return !bTargetPaused && !bPauseRequested;
			case EDebugMessageType::Continue:
			case EDebugMessageType::StepIn:
			case EDebugMessageType::StepOver:
			case EDebugMessageType::StepOut:
				return bTargetPaused;
			case EDebugMessageType::StopDebugging:
				return true;
			default:
				return true;
			}
		}

		void SendDebuggerCommand(const EDebugMessageType MessageType)
		{
			if (!IsDebuggerCommandEnabled(MessageType))
			{
				return;
			}

			Client.SendEmpty(MessageType);
			switch (MessageType)
			{
			case EDebugMessageType::Pause:
				bPauseRequested = true;
				LastStopReason = TEXT("pause requested");
				LastStopText.Empty();
				break;
			case EDebugMessageType::Continue:
			case EDebugMessageType::StepIn:
			case EDebugMessageType::StepOver:
			case EDebugMessageType::StepOut:
				bTargetPaused = false;
				bPauseRequested = false;
				ExecutionSourcePath.Empty();
				ExecutionSourceLine = 0;
				RefreshSourceDecorations();
				break;
			case EDebugMessageType::StopDebugging:
				ResetRuntimeSessionState(false);
				break;
			default:
				break;
			}
		}

		TSharedRef<SWidget> BuildWorkspace()
		{
			return SNew(SSplitter)
				+ SSplitter::Slot().Value(0.20f)
				[
					SNew(SSplitter).Orientation(Orient_Vertical)
					+ SSplitter::Slot().Value(0.38f)
					[
						BuildSectionsPanel()
					]
					+ SSplitter::Slot().Value(0.34f)
					[
						BuildBreakpointsPanel()
					]
					+ SSplitter::Slot().Value(0.28f)
					[
						BuildBreakFiltersPanel()
					]
				]
				+ SSplitter::Slot().Value(0.52f)
				[
					SNew(SSplitter).Orientation(Orient_Vertical)
					+ SSplitter::Slot().Value(0.62f)
					[
						BuildSourcePanel()
					]
					+ SSplitter::Slot().Value(0.16f)
					[
						BuildDiagnosticsPanel()
					]
					+ SSplitter::Slot().Value(0.10f)
					[
						BuildExceptionPanel()
					]
					+ SSplitter::Slot().Value(0.12f)
					[
						BuildTextListPanel(TEXT("Session Log"), LogLines, LogView)
					]
				]
				+ SSplitter::Slot().Value(0.28f)
				[
					SNew(SSplitter).Orientation(Orient_Vertical)
					+ SSplitter::Slot().Value(0.22f)
					[
						BuildListPanel(TEXT("Call Stack"), CallStackItems, CallStackView)
					]
					+ SSplitter::Slot().Value(0.48f)
					[
						BuildVariablesPanel()
					]
					+ SSplitter::Slot().Value(0.18f)
					[
						BuildWatchPanel()
					]
					+ SSplitter::Slot().Value(0.12f)
					[
						BuildDataBreakpointsPanel()
					]
				];
		}

		TSharedRef<SWidget> BuildSectionsPanel()
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(STextBlock).Text(FText::FromString(TEXT("Sections")))
					]
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(SSearchBox)
						.HintText(FText::FromString(TEXT("Filter scripts")))
						.OnTextChanged(this, &SAngelscriptDebuggerWindow::OnSectionFilterTextChanged)
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SAssignNew(SectionView, SListView<TSharedPtr<FSectionView>>)
						.ListItemsSource(&SectionItems)
						.OnGenerateRow(this, &SAngelscriptDebuggerWindow::GenerateGenericRow<FSectionView>)
						.OnSelectionChanged(this, &SAngelscriptDebuggerWindow::OnGenericSelectionChanged<FSectionView>)
					]
				];
		}

		TSharedRef<SWidget> BuildSourcePanel()
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(STextBlock).Text(this, &SAngelscriptDebuggerWindow::GetSourceTitleText)
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SAssignNew(SourceView, SListView<TSharedPtr<FSourceLineView>>)
						.ListItemsSource(&SourceLineItems)
						.OnGenerateRow(this, &SAngelscriptDebuggerWindow::GenerateSourceRow)
						.OnSelectionChanged(this, &SAngelscriptDebuggerWindow::OnSourceSelectionChanged)
					]
				];
		}

		TSharedRef<SWidget> BuildDiagnosticsPanel()
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(STextBlock).Text(FText::FromString(TEXT("Diagnostics")))
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SAssignNew(DiagnosticView, SListView<TSharedPtr<FDiagnosticView>>)
						.ListItemsSource(&DiagnosticItems)
						.OnGenerateRow(this, &SAngelscriptDebuggerWindow::GenerateDiagnosticRow)
						.OnSelectionChanged(this, &SAngelscriptDebuggerWindow::OnGenericSelectionChanged<FDiagnosticView>)
					]
				];
		}

		TSharedRef<SWidget> BuildBreakpointsPanel()
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(SHorizontalBox)
						+ SHorizontalBox::Slot().FillWidth(1.0f).VAlign(VAlign_Center)
						[
							SNew(STextBlock).Text(FText::FromString(TEXT("Breakpoints")))
						]
						+ SHorizontalBox::Slot().AutoWidth()
						[
							SNew(SButton).Text(FText::FromString(TEXT("Remove"))).OnClicked(this, &SAngelscriptDebuggerWindow::OnRemoveBreakpointClicked)
						]
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SAssignNew(BreakpointView, SListView<TSharedPtr<FBreakpointView>>)
						.ListItemsSource(&BreakpointItems)
						.OnGenerateRow(this, &SAngelscriptDebuggerWindow::GenerateGenericRow<FBreakpointView>)
						.OnSelectionChanged(this, &SAngelscriptDebuggerWindow::OnGenericSelectionChanged<FBreakpointView>)
					]
				];
		}

		TSharedRef<SWidget> BuildVariablesPanel()
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(SHorizontalBox)
						+ SHorizontalBox::Slot().FillWidth(1.0f).VAlign(VAlign_Center)
						[
							SNew(STextBlock).Text(FText::FromString(TEXT("Variables")))
						]
						+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
						[
							SNew(SButton).Text(FText::FromString(TEXT("Refresh"))).OnClicked(this, &SAngelscriptDebuggerWindow::OnRefreshVariablesClicked)
						]
						+ SHorizontalBox::Slot().AutoWidth()
						[
							SNew(SButton).Text(FText::FromString(TEXT("Data BP"))).OnClicked(this, &SAngelscriptDebuggerWindow::OnAddDataBreakpointClicked)
						]
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SAssignNew(VariableTree, STreeView<TSharedPtr<FVariableNode>>)
						.TreeItemsSource(&VariableRootNodes)
						.OnGenerateRow(this, &SAngelscriptDebuggerWindow::GenerateVariableRow)
						.OnGetChildren(this, &SAngelscriptDebuggerWindow::GetVariableChildren)
						.OnExpansionChanged(this, &SAngelscriptDebuggerWindow::OnVariableExpansionChanged)
						.OnSelectionChanged(this, &SAngelscriptDebuggerWindow::OnVariableSelectionChanged)
					]
				];
		}

		TSharedRef<SWidget> BuildWatchPanel()
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(SHorizontalBox)
						+ SHorizontalBox::Slot().FillWidth(1.0f).Padding(0.0f, 0.0f, 6.0f, 0.0f)
						[
							SAssignNew(WatchTextBox, SEditableTextBox).HintText(FText::FromString(TEXT("Expression")))
						]
						+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
						[
							SNew(SButton).Text(FText::FromString(TEXT("Add"))).OnClicked(this, &SAngelscriptDebuggerWindow::OnAddWatchClicked)
						]
						+ SHorizontalBox::Slot().AutoWidth()
						[
							SNew(SButton).Text(FText::FromString(TEXT("Refresh"))).OnClicked(this, &SAngelscriptDebuggerWindow::OnRefreshWatchClicked)
						]
						+ SHorizontalBox::Slot().AutoWidth().Padding(6.0f, 0.0f, 0.0f, 0.0f)
						[
							SNew(SButton).Text(FText::FromString(TEXT("Remove"))).OnClicked(this, &SAngelscriptDebuggerWindow::OnRemoveWatchClicked)
						]
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SAssignNew(WatchView, SListView<TSharedPtr<FWatchView>>)
						.ListItemsSource(&WatchItems)
						.OnGenerateRow(this, &SAngelscriptDebuggerWindow::GenerateWatchRow)
						.OnSelectionChanged(this, &SAngelscriptDebuggerWindow::OnWatchSelectionChanged)
					]
				];
		}

		TSharedRef<SWidget> BuildDataBreakpointsPanel()
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(SHorizontalBox)
						+ SHorizontalBox::Slot().FillWidth(1.0f).VAlign(VAlign_Center)
						[
							SNew(STextBlock).Text(FText::FromString(TEXT("Data Breakpoints")))
						]
						+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 6.0f, 0.0f)
						[
							SNew(SButton).Text(FText::FromString(TEXT("Remove"))).OnClicked(this, &SAngelscriptDebuggerWindow::OnRemoveDataBreakpointClicked)
						]
						+ SHorizontalBox::Slot().AutoWidth()
						[
							SNew(SButton).Text(FText::FromString(TEXT("Clear"))).OnClicked(this, &SAngelscriptDebuggerWindow::OnClearDataBreakpointsClicked)
						]
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SAssignNew(DataBreakpointView, SListView<TSharedPtr<FDataBreakpointView>>)
						.ListItemsSource(&DataBreakpointItems)
						.OnGenerateRow(this, &SAngelscriptDebuggerWindow::GenerateGenericRow<FDataBreakpointView>)
						.OnSelectionChanged(this, &SAngelscriptDebuggerWindow::OnGenericSelectionChanged<FDataBreakpointView>)
					]
				];
		}

		TSharedRef<SWidget> BuildExceptionPanel()
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight()
					[
						SNew(STextBlock).Text(FText::FromString(TEXT("Exception / Stop Reason")))
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SNew(STextBlock).Text(this, &SAngelscriptDebuggerWindow::GetExceptionText).AutoWrapText(true)
					]
				];
		}

		TSharedRef<SWidget> BuildBreakFiltersPanel()
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(STextBlock).Text(FText::FromString(TEXT("Break Filters")))
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SAssignNew(BreakFilterView, SListView<TSharedPtr<FBreakFilterView>>)
						.ListItemsSource(&BreakFilterItems)
						.OnGenerateRow(this, &SAngelscriptDebuggerWindow::GenerateBreakFilterRow)
					]
				];
		}

		TSharedRef<SWidget> BuildTextListPanel(const TCHAR* Title, TArray<TSharedPtr<FString>>& Items, TSharedPtr<SListView<TSharedPtr<FString>>>& OutListView)
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(STextBlock).Text(FText::FromString(Title))
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SAssignNew(OutListView, SListView<TSharedPtr<FString>>)
						.ListItemsSource(&Items)
						.OnGenerateRow(this, &SAngelscriptDebuggerWindow::GenerateTextRow)
					]
				];
		}

		template <typename ItemType>
		TSharedRef<SWidget> BuildListPanel(const TCHAR* Title, TArray<TSharedPtr<ItemType>>& Items, TSharedPtr<SListView<TSharedPtr<ItemType>>>& OutListView)
		{
			return SNew(SBorder).Padding(6.0f)
				[
					SNew(SVerticalBox)
					+ SVerticalBox::Slot().AutoHeight().Padding(0.0f, 0.0f, 0.0f, 4.0f)
					[
						SNew(STextBlock).Text(FText::FromString(Title))
					]
					+ SVerticalBox::Slot().FillHeight(1.0f)
					[
						SAssignNew(OutListView, SListView<TSharedPtr<ItemType>>)
						.ListItemsSource(&Items)
						.OnGenerateRow(this, &SAngelscriptDebuggerWindow::GenerateGenericRow<ItemType>)
						.OnSelectionChanged(this, &SAngelscriptDebuggerWindow::OnGenericSelectionChanged<ItemType>)
					]
				];
		}

		template <typename ItemType>
		TSharedRef<ITableRow> GenerateGenericRow(TSharedPtr<ItemType> Item, const TSharedRef<STableViewBase>& OwnerTable) const
		{
			return SNew(STableRow<TSharedPtr<ItemType>>, OwnerTable)
				[
					SNew(STextBlock).Text(FText::FromString(DescribeItem(Item)))
				];
		}

		template <typename ItemType>
		void OnGenericSelectionChanged(TSharedPtr<ItemType> Item, ESelectInfo::Type SelectInfo)
		{
			HandleSelectedItem(Item);
		}

		TSharedRef<ITableRow> GenerateTextRow(TSharedPtr<FString> Item, const TSharedRef<STableViewBase>& OwnerTable) const
		{
			return SNew(STableRow<TSharedPtr<FString>>, OwnerTable)
				[
					SNew(STextBlock).Text(FText::FromString(Item.IsValid() ? *Item : FString()))
				];
		}

		TSharedRef<ITableRow> GenerateDiagnosticRow(TSharedPtr<FDiagnosticView> Item, const TSharedRef<STableViewBase>& OwnerTable) const
		{
			const FSlateColor TextColor = Item.IsValid() && Item->bIsError
				? FSlateColor(FLinearColor(0.95f, 0.28f, 0.22f, 1.0f))
				: (Item.IsValid() && Item->bIsInfo
					? FSlateColor(FLinearColor(0.45f, 0.65f, 1.0f, 1.0f))
					: FSlateColor(FLinearColor(0.95f, 0.70f, 0.20f, 1.0f)));
			return SNew(STableRow<TSharedPtr<FDiagnosticView>>, OwnerTable)
				[
					SNew(STextBlock)
					.Text(FText::FromString(Item.IsValid() ? DescribeDiagnostic(*Item) : FString()))
					.ColorAndOpacity(TextColor)
				];
		}

		bool TryGetSourceLineBreakpoint(TSharedPtr<FSourceLineView> Item, FBreakpointView& OutBreakpoint) const
		{
			return AngelscriptDebugger::TryGetSourceLineBreakpoint(Item, CurrentSourcePath, BreakpointStore, OutBreakpoint);
		}

		bool HasSourceLineBreakpoint(TSharedPtr<FSourceLineView> Item) const
		{
			FBreakpointView Breakpoint;
			return TryGetSourceLineBreakpoint(Item, Breakpoint);
		}

		const FSlateBrush* GetSourceBreakpointGlyphBrush(TSharedPtr<FSourceLineView> Item) const
		{
			FBreakpointView Breakpoint;
			return TryGetSourceLineBreakpoint(Item, Breakpoint)
				? AngelscriptDebugger::GetSourceBreakpointGlyphBrush(&Breakpoint)
				: AngelscriptDebugger::GetSourceBreakpointGlyphBrush(nullptr);
		}

		FText GetSourceBreakpointTooltip(TSharedPtr<FSourceLineView> Item) const
		{
			FBreakpointView Breakpoint;
			return TryGetSourceLineBreakpoint(Item, Breakpoint)
				? AngelscriptDebugger::GetSourceBreakpointTooltip(&Breakpoint)
				: AngelscriptDebugger::GetSourceBreakpointTooltip(nullptr);
		}

		FSlateColor GetSourceLineNumberColor(TSharedPtr<FSourceLineView> Item) const
		{
			return AngelscriptDebugger::GetSourceLineNumberColor(HasSourceLineBreakpoint(Item));
		}

		FSlateColor GetSourceLineBackgroundColor(TSharedPtr<FSourceLineView> Item) const
		{
			const bool bIsExecutionLine = AngelscriptDebugger::IsSourceExecutionLine(Item, CurrentSourcePath, ExecutionSourcePath, ExecutionSourceLine);
			const bool bIsSelectedLine = Item.IsValid() && Item->LineNumber == SelectedSourceLine;
			return AngelscriptDebugger::GetSourceLineBackgroundColor(bIsExecutionLine, bIsSelectedLine);
		}

		TSharedRef<ITableRow> GenerateSourceRow(TSharedPtr<FSourceLineView> Item, const TSharedRef<STableViewBase>& OwnerTable)
		{
			const FString SourceText = Item.IsValid() ? Item->Text : FString();
			const TArray<FAngelscriptSyntaxToken> SourceTokens = Item.IsValid() ? Item->Tokens : TArray<FAngelscriptSyntaxToken>();
			const FSlateFontInfo SourceFont = FCoreStyle::GetDefaultFontStyle("Mono", 9);

			return SNew(STableRow<TSharedPtr<FSourceLineView>>, OwnerTable)
				[
					SNew(SBorder)
					.BorderBackgroundColor_Lambda([this, Item]()
					{
						return GetSourceLineBackgroundColor(Item);
					})
					.Padding(1.0f)
					[
						SNew(SHorizontalBox)
						+ SHorizontalBox::Slot().AutoWidth().Padding(0.0f, 0.0f, 8.0f, 0.0f)
						[
							SNew(SButton)
							.ButtonStyle(FCoreStyle::Get(), "NoBorder")
							.ContentPadding(FMargin(2.0f, 0.0f))
							.ToolTipText_Lambda([this, Item]()
							{
								return GetSourceBreakpointTooltip(Item);
							})
							.OnClicked_Lambda([this, Item]()
							{
								if (Item.IsValid())
								{
									SelectedSourceLine = Item->LineNumber;
									ToggleBreakpointAtLine(Item->LineNumber);
								}
								return FReply::Handled();
							})
							[
								SNew(SHorizontalBox)
								+ SHorizontalBox::Slot().AutoWidth().VAlign(VAlign_Center)
								[
									SNew(SBox).WidthOverride(36.0f)
									[
										SNew(STextBlock)
										.Text(FText::AsNumber(Item.IsValid() ? Item->LineNumber : 0))
										.Justification(ETextJustify::Right)
										.ColorAndOpacity_Lambda([this, Item]()
										{
											return GetSourceLineNumberColor(Item);
										})
									]
								]
								+ SHorizontalBox::Slot().AutoWidth().VAlign(VAlign_Center).Padding(4.0f, 0.0f, 0.0f, 0.0f)
								[
									SNew(SBox)
									.WidthOverride(14.0f)
									.HeightOverride(14.0f)
									.HAlign(HAlign_Center)
									.VAlign(VAlign_Center)
									[
										SNew(SImage)
										.Visibility_Lambda([this, Item]()
										{
											return AngelscriptDebugger::GetSourceBreakpointGlyphVisibility(HasSourceLineBreakpoint(Item));
										})
										.Image_Lambda([this, Item]()
										{
											return GetSourceBreakpointGlyphBrush(Item);
										})
									]
								]
							]
						]
						+ SHorizontalBox::Slot().FillWidth(1.0f)
						[
							SNew(SAngelscriptHighlightedLine)
							.Text(SourceText)
							.Tokens(SourceTokens)
							.Font(SourceFont)
						]
					]
				];
		}

		TSharedRef<ITableRow> GenerateVariableRow(TSharedPtr<FVariableNode> Item, const TSharedRef<STableViewBase>& OwnerTable) const
		{
			return SNew(STableRow<TSharedPtr<FVariableNode>>, OwnerTable)
				[
					SNew(STextBlock).Text(FText::FromString(Item.IsValid() ? DescribeVariable(*Item) : FString()))
				];
		}

		void GetVariableChildren(TSharedPtr<FVariableNode> Item, TArray<TSharedPtr<FVariableNode>>& OutChildren) const
		{
			if (Item.IsValid())
			{
				OutChildren.Append(Item->Children);
			}
		}

		void OnVariableExpansionChanged(TSharedPtr<FVariableNode> Item, bool bExpanded)
		{
			if (!bExpanded || !Item.IsValid() || !Item->Value.bHasMembers || Item->bChildrenRequested)
			{
				return;
			}
			Item->bChildrenRequested = true;
			Client.SendRequestVariables(Item->Value.Path);
		}

		void OnVariableSelectionChanged(TSharedPtr<FVariableNode> Item, ESelectInfo::Type SelectInfo)
		{
			SelectedVariable = Item;
		}

		void OnSourceSelectionChanged(TSharedPtr<FSourceLineView> Item, ESelectInfo::Type SelectInfo)
		{
			if (Item.IsValid())
			{
				SelectedSourceLine = Item->LineNumber;
				SyncSelectedBreakpointFromCurrentLine();
				RefreshSourceDecorations();
			}
		}

		void OnSectionFilterTextChanged(const FText& NewText)
		{
			SectionFilterText = NewText.ToString().TrimStartAndEnd();
			ApplySectionFilter();
		}

		void OnWatchSelectionChanged(TSharedPtr<FWatchView> Item, ESelectInfo::Type SelectInfo)
		{
			SelectedWatch = Item;
		}

		TSharedRef<ITableRow> GenerateWatchRow(TSharedPtr<FWatchView> Item, const TSharedRef<STableViewBase>& OwnerTable) const
		{
			return SNew(STableRow<TSharedPtr<FWatchView>>, OwnerTable)
				[
					SNew(STextBlock).Text(FText::FromString(Item.IsValid() ? DescribeWatch(*Item) : FString()))
				];
		}

		TSharedRef<ITableRow> GenerateBreakFilterRow(TSharedPtr<FBreakFilterView> Item, const TSharedRef<STableViewBase>& OwnerTable)
		{
			return SNew(STableRow<TSharedPtr<FBreakFilterView>>, OwnerTable)
				[
					SNew(SCheckBox)
					.IsChecked(Item.IsValid() && Item->bEnabled ? ECheckBoxState::Checked : ECheckBoxState::Unchecked)
					.OnCheckStateChanged_Lambda([this, Item](ECheckBoxState NewState)
					{
						if (Item.IsValid())
						{
							Item->bEnabled = NewState == ECheckBoxState::Checked;
							SendBreakFilterSelection();
						}
					})
					[
						SNew(STextBlock).Text(FText::FromString(Item.IsValid() ? Item->Title : FString()))
					]
				];
		}

		FString DescribeItem(TSharedPtr<FSectionView> Item) const
		{
			return Item.IsValid() ? DescribeSection(*Item) : FString();
		}

		FString DescribeItem(TSharedPtr<FDebuggerFrameView> Item) const
		{
			return Item.IsValid() ? DescribeFrame(*Item) : FString();
		}

		FString DescribeItem(TSharedPtr<FBreakpointView> Item) const
		{
			return Item.IsValid() ? DescribeBreakpoint(*Item) : FString();
		}

		FString DescribeItem(TSharedPtr<FDataBreakpointView> Item) const
		{
			return Item.IsValid() ? DescribeDataBreakpoint(*Item) : FString();
		}

		FString DescribeItem(TSharedPtr<FDiagnosticView> Item) const
		{
			return Item.IsValid() ? DescribeDiagnostic(*Item) : FString();
		}

		void HandleSelectedItem(TSharedPtr<FSectionView> Item)
		{
			if (Item.IsValid())
			{
				OpenSourceFile(Item->Filename, 1);
			}
		}

		void HandleSelectedItem(TSharedPtr<FDebuggerFrameView> Item)
		{
			if (Item.IsValid())
			{
				SelectedFrameIndex = FMath::Max(0, CallStackItems.IndexOfByPredicate([Item](const TSharedPtr<FDebuggerFrameView>& Candidate) { return Candidate == Item; }));
				const FString SourcePath = AngelscriptDebugClient::ResolveSourcePath(Item->Source, Item->ModuleName, ScriptRoots);
				OpenSourceFile(SourcePath, Item->LineNumber);
				RequestRootScopes();
				RefreshAllWatches();
			}
		}

		void HandleSelectedItem(TSharedPtr<FBreakpointView> Item)
		{
			SelectedBreakpoint = Item;
			if (Item.IsValid())
			{
				SetBreakpointConditionText(Item->Condition);
				OpenSourceFile(Item->Filename, Item->LineNumber);
			}
		}

		void HandleSelectedItem(TSharedPtr<FDataBreakpointView> Item)
		{
			SelectedDataBreakpoint = Item;
		}

		void HandleSelectedItem(TSharedPtr<FDiagnosticView> Item)
		{
			if (Item.IsValid())
			{
				OpenSourceFile(Item->Filename, FMath::Max(1, Item->Line));
			}
		}

		EActiveTimerReturnType HandleActiveTimer(double InCurrentTime, float InDeltaTime)
		{
			Client.Tick();
			for (const FDebuggerClientEvent& Event : Client.DrainEvents())
			{
				HandleClientEvent(Event);
			}
			return EActiveTimerReturnType::Continue;
		}

		void HandleClientEvent(const FDebuggerClientEvent& Event)
		{
			if (!Event.Summary.IsEmpty())
			{
				AddLogLine(Event.Summary);
			}

			switch (Event.Type)
			{
			case EDebuggerEventType::Connected:
				ResetRuntimeSessionState(false);
				ReapplyAllBreakpoints();
				break;
			case EDebuggerEventType::Closed:
				ResetRuntimeSessionState(false);
				LastStopReason = TEXT("disconnected");
				LastStopText.Empty();
				break;
			case EDebuggerEventType::Stopped:
				bTargetPaused = true;
				bPauseRequested = false;
				LastStopReason = Event.StopReason;
				LastStopText = Event.StopText;
				break;
			case EDebuggerEventType::Continued:
				bTargetPaused = false;
				bPauseRequested = false;
				LastStopReason = TEXT("running");
				LastStopText.Empty();
				ExecutionSourcePath.Empty();
				ExecutionSourceLine = 0;
				RefreshSourceDecorations();
				break;
			case EDebuggerEventType::DebugServerVersion:
				LastDebugServerVersion = Event.DebugServerVersion;
				break;
			case EDebuggerEventType::CallStack:
				ApplyCallStack(Event.Frames);
				break;
			case EDebuggerEventType::Variables:
				ApplyVariables(Event.Path, Event.Variables);
				break;
			case EDebuggerEventType::Evaluate:
				ApplyEvaluate(Event.Expression, Event.Variables);
				break;
			case EDebuggerEventType::BreakFilters:
				ApplyBreakFilters(Event.Lines);
				break;
			case EDebuggerEventType::BreakpointAck:
			{
				const int32 PreviouslySelectedBreakpointId = SelectedBreakpoint.IsValid() ? SelectedBreakpoint->Id : INDEX_NONE;
				BreakpointStore.ApplyServerAck(Event.BreakpointAck);
				RefreshBreakpoints();
				if (PreviouslySelectedBreakpointId == Event.BreakpointAck.Id)
				{
					SelectedBreakpoint = FindBreakpointItemById(Event.BreakpointAck.Id);
					if (SelectedBreakpoint.IsValid())
					{
						SetBreakpointConditionText(SelectedBreakpoint->Condition);
					}
				}
				else
				{
					SyncSelectedBreakpointFromCurrentLine();
				}
				RefreshSourceDecorations();
				break;
			}
			case EDebuggerEventType::ClearDataBreakpoints:
				ApplyClearDataBreakpoints(Event.ClearDataBreakpoints);
				break;
			case EDebuggerEventType::DebugDatabase:
			case EDebuggerEventType::AssetDatabase:
				break;
			case EDebuggerEventType::Diagnostics:
				ApplyDiagnostics(Event.Path, Event.Diagnostics);
				break;
			default:
				break;
			}
		}

		FReply OnConnectClicked()
		{
			const FString Host = HostTextBox.IsValid() ? HostTextBox->GetText().ToString() : TEXT("127.0.0.1");
			const FString PortString = PortTextBox.IsValid() ? PortTextBox->GetText().ToString() : TEXT("27099");
			int32 Port = 27099;
			LexTryParseString(Port, *PortString);
			Client.Connect(Host, Port);
			return FReply::Handled();
		}

		FReply OnDisconnectClicked()
		{
			ShutdownSession();
			ResetRuntimeSessionState(false);
			LastStopReason = TEXT("disconnected");
			LastStopText.Empty();
			AddLogLine(TEXT("Disconnected."));
			return FReply::Handled();
		}

		FReply OnToggleBreakpointClicked()
		{
			ToggleBreakpointAtCurrentLine();
			return FReply::Handled();
		}

		FReply OnRemoveBreakpointClicked()
		{
			if (SelectedBreakpoint.IsValid())
			{
				RemoveBreakpointById(SelectedBreakpoint->Id);
			}
			else
			{
				AddLogLine(TEXT("Select a breakpoint before removing it."));
			}
			return FReply::Handled();
		}

		FReply OnApplyBreakpointConditionClicked()
		{
			ApplyBreakpointConditionToSelectedTarget(GetBreakpointConditionText());
			return FReply::Handled();
		}

		FReply OnClearBreakpointConditionClicked()
		{
			SetBreakpointConditionText(FString());
			ApplyBreakpointConditionToSelectedTarget(FString());
			return FReply::Handled();
		}

		FReply OnClearAllBreakpointsClicked()
		{
			ClearAllBreakpoints();
			return FReply::Handled();
		}

		FReply OnRefreshSourceClicked()
		{
			RefreshSectionsFromDisk();
			LoadSourceLines();
			return FReply::Handled();
		}

		FReply OnRefreshVariablesClicked()
		{
			RequestRootScopes();
			return FReply::Handled();
		}

		FReply OnAddWatchClicked()
		{
			if (WatchTextBox.IsValid())
			{
				const FString Expression = WatchTextBox->GetText().ToString();
				if (!Expression.IsEmpty())
				{
					TSharedPtr<FWatchView> Watch = MakeShared<FWatchView>();
					Watch->Expression = Expression.TrimStartAndEnd();
					WatchItems.Add(Watch);
					WatchTextBox->SetText(FText::GetEmpty());
					RefreshWatch(Watch);
					if (WatchView.IsValid())
					{
						WatchView->RequestListRefresh();
					}
				}
			}
			return FReply::Handled();
		}

		FReply OnRefreshWatchClicked()
		{
			for (const TSharedPtr<FWatchView>& Watch : WatchItems)
			{
				RefreshWatch(Watch);
			}
			return FReply::Handled();
		}

		FReply OnRemoveWatchClicked()
		{
			if (SelectedWatch.IsValid())
			{
				WatchItems.Remove(SelectedWatch);
				SelectedWatch.Reset();
				RefreshList(WatchView);
			}
			return FReply::Handled();
		}

		FReply OnAddDataBreakpointClicked()
		{
			if (!SelectedVariable.IsValid())
			{
				AddLogLine(TEXT("Select a variable before adding a data breakpoint."));
				return FReply::Handled();
			}
			const FDebuggerVariableView& Variable = SelectedVariable->Value;
			if (Variable.ValueAddress == 0 || (Variable.ValueSize != 1 && Variable.ValueSize != 2 && Variable.ValueSize != 4 && Variable.ValueSize != 8))
			{
				AddLogLine(TEXT("Selected variable does not expose a supported data breakpoint address."));
				return FReply::Handled();
			}
			if (DataBreakpointItems.Num() >= MaxDataBreakpoints)
			{
				AddLogLine(TEXT("Only four hardware data breakpoints are supported."));
				return FReply::Handled();
			}
			for (const TSharedPtr<FDataBreakpointView>& Item : DataBreakpointItems)
			{
				if (Item.IsValid() && Item->Address == Variable.ValueAddress && Item->ValueSize == Variable.ValueSize)
				{
					AddLogLine(TEXT("A data breakpoint already watches the selected address."));
					return FReply::Handled();
				}
			}

			TSharedPtr<FDataBreakpointView> Entry = MakeShared<FDataBreakpointView>();
			Entry->Id = NextDataBreakpointId++;
			Entry->Name = Variable.Path;
			Entry->Address = Variable.ValueAddress;
			Entry->ValueSize = Variable.ValueSize;
			DataBreakpointItems.Add(Entry);
			SyncDataBreakpoints();
			RefreshList(DataBreakpointView);
			return FReply::Handled();
		}

		FReply OnRemoveDataBreakpointClicked()
		{
			if (SelectedDataBreakpoint.IsValid())
			{
				DataBreakpointItems.Remove(SelectedDataBreakpoint);
				SelectedDataBreakpoint.Reset();
				SyncDataBreakpoints();
				RefreshList(DataBreakpointView);
			}
			return FReply::Handled();
		}

		FReply OnClearDataBreakpointsClicked()
		{
			DataBreakpointItems.Reset();
			SelectedDataBreakpoint.Reset();
			SyncDataBreakpoints();
			RefreshList(DataBreakpointView);
			return FReply::Handled();
		}

		FText GetStatusText() const
		{
			FString Status = Client.GetStatusText().ToString();
			if (Client.IsConnected())
			{
				if (LastDebugServerVersion > 0)
				{
					Status += FString::Printf(TEXT(" | server v%d"), LastDebugServerVersion);
				}
				if (bTargetPaused)
				{
					Status += TEXT(" | paused");
				}
				else if (bPauseRequested)
				{
					Status += TEXT(" | pause requested");
				}
				else
				{
					Status += TEXT(" | running");
				}
			}
			return FText::FromString(Status);
		}

		FText GetSourceTitleText() const
		{
			if (CurrentSourcePath.IsEmpty())
			{
				return FText::FromString(TEXT("Source"));
			}
			return FText::FromString(FString::Printf(TEXT("Source: %s"), *CurrentSourcePath));
		}

		FText GetExceptionText() const
		{
			if (LastStopReason.IsEmpty())
			{
				return FText::FromString(TEXT("No stop event."));
			}
			return FText::FromString(LastStopText.IsEmpty() ? LastStopReason : LastStopReason + TEXT(": ") + LastStopText);
		}

		void ApplyCallStack(const TArray<FDebuggerFrameView>& Frames)
		{
			CallStackItems.Reset();
			for (const FDebuggerFrameView& Frame : Frames)
			{
				CallStackItems.Add(MakeShared<FDebuggerFrameView>(Frame));
			}
			RefreshList(CallStackView);

			if (CallStackItems.Num() > 0)
			{
				SelectedFrameIndex = 0;
				const TSharedPtr<FDebuggerFrameView> TopFrame = CallStackItems[0];
				ExecutionSourcePath = AngelscriptDebugClient::ResolveSourcePath(TopFrame->Source, TopFrame->ModuleName, ScriptRoots);
				ExecutionSourcePath = AngelscriptDebugClient::NormalizeDebuggerFilename(ExecutionSourcePath);
				ExecutionSourceLine = TopFrame->LineNumber;
				OpenSourceFile(ExecutionSourcePath, ExecutionSourceLine);
				RequestRootScopes();
				RefreshAllWatches();
			}
		}

		void ApplyVariables(const FString& Path, const TArray<FDebuggerVariableView>& Variables)
		{
			TSharedPtr<FVariableNode> Parent = FindVariableNodeByPath(Path);
			if (!Parent.IsValid())
			{
				Parent = FindOrCreateScopeRoot(Path);
			}

			Parent->Children.Reset();
			for (const FDebuggerVariableView& Variable : Variables)
			{
				TSharedPtr<FVariableNode> Node = MakeShared<FVariableNode>();
				Node->Value = Variable;
				Parent->Children.Add(Node);
			}
			Parent->bChildrenRequested = true;
			RefreshVariableTree();
		}

		void ApplyEvaluate(const FString& Expression, const TArray<FDebuggerVariableView>& Variables)
		{
			for (const TSharedPtr<FWatchView>& Watch : WatchItems)
			{
				if (Watch.IsValid() && (Watch->RequestExpression == Expression || Watch->Expression == Expression))
				{
					if (Variables.Num() == 0)
					{
						Watch->Value = TEXT("<unavailable>");
						Watch->Type.Empty();
						Watch->Path.Empty();
						Watch->bHasMembers = false;
					}
					else
					{
						Watch->Value = Variables[0].Value;
						Watch->Type = Variables[0].Type;
						Watch->Path = Variables[0].Path;
						Watch->bHasMembers = Variables[0].bHasMembers;
					}
				}
			}
			RefreshList(WatchView);
		}

		void ApplyBreakFilters(const TArray<FString>& Lines)
		{
			BreakFilterItems.Reset();
			for (const FString& Line : Lines)
			{
				FString Filter;
				FString Title;
				Line.Split(TEXT("|"), &Filter, &Title);
				TSharedPtr<FBreakFilterView> Item = MakeShared<FBreakFilterView>();
				Item->Filter = Filter;
				Item->Title = Title.IsEmpty() ? Filter : Title;
				Item->bEnabled = true;
				BreakFilterItems.Add(Item);
			}
			RefreshList(BreakFilterView);
			SendBreakFilterSelection();
		}

		void ApplyClearDataBreakpoints(const FAngelscriptClearDataBreakpoints& ClearDataBreakpoints)
		{
			if (ClearDataBreakpoints.Ids.Num() == 0)
			{
				DataBreakpointItems.Reset();
			}
			else
			{
				DataBreakpointItems.RemoveAll([&ClearDataBreakpoints](const TSharedPtr<FDataBreakpointView>& Item)
				{
					return Item.IsValid() && ClearDataBreakpoints.Ids.Contains(Item->Id);
				});
			}
			RefreshList(DataBreakpointView);
		}

		void ApplyDiagnostics(const FString& Filename, const TArray<FDiagnosticView>& Diagnostics)
		{
			const FString ResolvedFilename = AngelscriptDebugClient::NormalizeDebuggerFilename(
				AngelscriptDebugClient::ResolveSourcePath(Filename, FString(), ScriptRoots));
			DiagnosticItems.RemoveAll([&ResolvedFilename](const TSharedPtr<FDiagnosticView>& Item)
			{
				return Item.IsValid()
					&& AngelscriptDebugClient::NormalizeDebuggerFilename(Item->Filename).Equals(ResolvedFilename, ESearchCase::IgnoreCase);
			});

			for (const FDiagnosticView& Diagnostic : Diagnostics)
			{
				TSharedPtr<FDiagnosticView> Item = MakeShared<FDiagnosticView>(Diagnostic);
				Item->Filename = ResolvedFilename;
				DiagnosticItems.Add(Item);
			}
			RefreshList(DiagnosticView);
		}

		void ResetRuntimeSessionState(const bool bClearUserState)
		{
			bTargetPaused = false;
			bPauseRequested = false;
			ExecutionSourcePath.Empty();
			ExecutionSourceLine = 0;
			SelectedFrameIndex = 0;
			LastDebugServerVersion = 0;
			CallStackItems.Reset();
			VariableRootNodes.Reset();
			DiagnosticItems.Reset();
			SelectedVariable.Reset();
			DataBreakpointItems.Reset();
			SelectedDataBreakpoint.Reset();
			if (bClearUserState)
			{
				WatchItems.Reset();
				SelectedWatch.Reset();
			}
			RefreshList(CallStackView);
			RefreshList(DataBreakpointView);
			RefreshList(DiagnosticView);
			RefreshList(WatchView);
			RefreshVariableTree();
			RefreshSourceDecorations();
		}

		void ReapplyAllBreakpoints()
		{
			for (const AngelscriptDebugClient::FBreakpointEntry& Entry : BreakpointStore.GetBreakpoints())
			{
				Client.SendSetBreakpoint(Entry.Id, Entry.Filename, Entry.ModuleName, Entry.RequestedLineNumber, Entry.Condition);
			}
		}

		void RequestRootScopes()
		{
			VariableRootNodes.Reset();
			AddScopeRoot(TEXT("Parameters / Locals"), AngelscriptDebugClient::MakeScopePath(SelectedFrameIndex, AngelscriptDebugClient::EScopeKind::Local));
			AddScopeRoot(TEXT("this"), AngelscriptDebugClient::MakeScopePath(SelectedFrameIndex, AngelscriptDebugClient::EScopeKind::This));
			AddScopeRoot(TEXT("Globals"), AngelscriptDebugClient::MakeScopePath(SelectedFrameIndex, AngelscriptDebugClient::EScopeKind::Module));
			RefreshVariableTree();

			for (const TSharedPtr<FVariableNode>& Root : VariableRootNodes)
			{
				if (Root.IsValid())
				{
					Client.SendRequestVariables(Root->Value.Path);
				}
			}
		}

		void AddScopeRoot(const FString& Name, const FString& Path)
		{
			TSharedPtr<FVariableNode> Root = MakeShared<FVariableNode>();
			Root->Value.Name = Name;
			Root->Value.Type = TEXT("scope");
			Root->Value.Path = Path;
			Root->Value.bHasMembers = true;
			Root->bIsScopeRoot = true;
			VariableRootNodes.Add(Root);
		}

		TSharedPtr<FVariableNode> FindOrCreateScopeRoot(const FString& Path)
		{
			TSharedPtr<FVariableNode> Existing = FindVariableNodeByPath(Path);
			if (Existing.IsValid())
			{
				return Existing;
			}

			TSharedPtr<FVariableNode> Root = MakeShared<FVariableNode>();
			Root->Value.Name = Path;
			Root->Value.Path = Path;
			Root->Value.Type = TEXT("scope");
			Root->Value.bHasMembers = true;
			Root->bIsScopeRoot = true;
			VariableRootNodes.Add(Root);
			return Root;
		}

		TSharedPtr<FVariableNode> FindVariableNodeByPath(const FString& Path) const
		{
			for (const TSharedPtr<FVariableNode>& Root : VariableRootNodes)
			{
				TSharedPtr<FVariableNode> Found = FindVariableNodeByPathRecursive(Root, Path);
				if (Found.IsValid())
				{
					return Found;
				}
			}
			return nullptr;
		}

		TSharedPtr<FVariableNode> FindVariableNodeByPathRecursive(TSharedPtr<FVariableNode> Node, const FString& Path) const
		{
			if (!Node.IsValid())
			{
				return nullptr;
			}
			if (Node->Value.Path == Path)
			{
				return Node;
			}
			for (const TSharedPtr<FVariableNode>& Child : Node->Children)
			{
				TSharedPtr<FVariableNode> Found = FindVariableNodeByPathRecursive(Child, Path);
				if (Found.IsValid())
				{
					return Found;
				}
			}
			return nullptr;
		}

		FString GetBreakpointConditionText() const
		{
			return BreakpointConditionTextBox.IsValid()
				? BreakpointConditionTextBox->GetText().ToString().TrimStartAndEnd()
				: FString();
		}

		void SetBreakpointConditionText(const FString& Condition)
		{
			if (BreakpointConditionTextBox.IsValid())
			{
				BreakpointConditionTextBox->SetText(FText::FromString(Condition));
			}
		}

		TSharedPtr<FBreakpointView> FindBreakpointItemById(const int32 BreakpointId) const
		{
			return AngelscriptDebugger::FindBreakpointItemById(BreakpointItems, BreakpointId);
		}

		bool TryGetBreakpointById(const int32 BreakpointId, AngelscriptDebugClient::FBreakpointEntry& OutBreakpoint) const
		{
			return AngelscriptDebugger::TryGetBreakpointById(BreakpointStore, BreakpointId, OutBreakpoint);
		}

		bool TryGetBreakpointForCurrentLine(AngelscriptDebugClient::FBreakpointEntry& OutBreakpoint) const
		{
			return AngelscriptDebugger::TryGetBreakpointForSourceLine(BreakpointStore, CurrentSourcePath, SelectedSourceLine, OutBreakpoint);
		}

		bool TryGetBreakpointEditTarget(AngelscriptDebugClient::FBreakpointEntry& OutBreakpoint) const
		{
			if (SelectedBreakpoint.IsValid() && TryGetBreakpointById(SelectedBreakpoint->Id, OutBreakpoint))
			{
				return true;
			}
			return TryGetBreakpointForCurrentLine(OutBreakpoint);
		}

		void SyncSelectedBreakpointFromCurrentLine()
		{
			AngelscriptDebugClient::FBreakpointEntry CurrentLineBreakpoint;
			if (TryGetBreakpointForCurrentLine(CurrentLineBreakpoint))
			{
				SelectedBreakpoint = FindBreakpointItemById(CurrentLineBreakpoint.Id);
				SetBreakpointConditionText(CurrentLineBreakpoint.Condition);
			}
			else
			{
				SelectedBreakpoint.Reset();
				SetBreakpointConditionText(FString());
			}
		}

		void ApplyBreakpointConditionToSelectedTarget(const FString& Condition)
		{
			AngelscriptDebugClient::FBreakpointEntry Target;
			if (!TryGetBreakpointEditTarget(Target))
			{
				AddLogLine(TEXT("Select a breakpoint or source line with a breakpoint first."));
				return;
			}

			AngelscriptDebugClient::FBreakpointEntry Updated;
			if (!BreakpointStore.UpdateBreakpointCondition(Target.Id, Condition, &Updated))
			{
				AddLogLine(TEXT("Selected breakpoint no longer exists."));
				return;
			}

			SendBreakpointSetForFile(Updated.Filename, Updated.ModuleName, GetBreakpointsForFileAndModule(Updated.Filename, Updated.ModuleName));
			RefreshBreakpoints();
			RefreshSourceDecorations();
			SelectedBreakpoint = FindBreakpointItemById(Updated.Id);
			SetBreakpointConditionText(Updated.Condition);
			AddLogLine(Updated.Condition.IsEmpty()
				? TEXT("Breakpoint condition cleared.")
				: FString::Printf(TEXT("Breakpoint condition updated: %s"), *Updated.Condition));
		}

		bool IsSameBreakpointFileAndModule(const AngelscriptDebugClient::FBreakpointEntry& Entry, const FString& Filename, const FString& ModuleName) const
		{
			return AngelscriptDebugClient::NormalizeDebuggerFilename(Entry.Filename).Equals(
					AngelscriptDebugClient::NormalizeDebuggerFilename(Filename),
					ESearchCase::IgnoreCase)
				&& Entry.ModuleName.Equals(ModuleName, ESearchCase::IgnoreCase);
		}

		TArray<AngelscriptDebugClient::FBreakpointEntry> GetBreakpointsForFileAndModule(const FString& Filename, const FString& ModuleName) const
		{
			TArray<AngelscriptDebugClient::FBreakpointEntry> Result;
			for (const AngelscriptDebugClient::FBreakpointEntry& Entry : BreakpointStore.GetBreakpoints())
			{
				if (IsSameBreakpointFileAndModule(Entry, Filename, ModuleName))
				{
					Result.Add(Entry);
				}
			}
			return Result;
		}

		void SendBreakpointSetForFile(const FString& Filename, const FString& ModuleName, const TArray<AngelscriptDebugClient::FBreakpointEntry>& Breakpoints)
		{
			Client.SendClearBreakpoints(Filename, ModuleName);

			for (const AngelscriptDebugClient::FBreakpointEntry& Entry : Breakpoints)
			{
				Client.SendSetBreakpoint(Entry.Id, Entry.Filename, Entry.ModuleName, Entry.RequestedLineNumber, Entry.Condition);
			}
		}

		void RemoveBreakpointById(const int32 BreakpointId)
		{
			AngelscriptDebugClient::FBreakpointEntry Removed;
			if (!BreakpointStore.RemoveBreakpointById(BreakpointId, &Removed))
			{
				AddLogLine(TEXT("Selected breakpoint no longer exists."));
				return;
			}

			SendBreakpointSetForFile(Removed.Filename, Removed.ModuleName, GetBreakpointsForFileAndModule(Removed.Filename, Removed.ModuleName));
			SelectedBreakpoint.Reset();
			RefreshBreakpoints();
			RefreshSourceDecorations();
			SyncSelectedBreakpointFromCurrentLine();
			AddLogLine(FString::Printf(TEXT("Breakpoint removed: %s:%d"),
				*FPaths::GetCleanFilename(Removed.Filename),
				Removed.RequestedLineNumber));
		}

		void ClearAllBreakpoints()
		{
			const TArray<AngelscriptDebugClient::FBreakpointEntry> ExistingBreakpoints = BreakpointStore.GetBreakpoints();
			if (ExistingBreakpoints.Num() == 0)
			{
				AddLogLine(TEXT("No breakpoints to clear."));
				return;
			}

			TSet<FString> ClearedFiles;
			for (const AngelscriptDebugClient::FBreakpointEntry& Entry : ExistingBreakpoints)
			{
				const FString Key = AngelscriptDebugClient::NormalizeDebuggerFilename(Entry.Filename) + TEXT("|") + Entry.ModuleName;
				if (ClearedFiles.Contains(Key))
				{
					continue;
				}

				ClearedFiles.Add(Key);
				Client.SendClearBreakpoints(Entry.Filename, Entry.ModuleName);
				BreakpointStore.ClearBreakpoints(Entry.Filename, Entry.ModuleName);
			}

			SelectedBreakpoint.Reset();
			SetBreakpointConditionText(FString());
			RefreshBreakpoints();
			RefreshSourceDecorations();
			AddLogLine(TEXT("All breakpoints cleared."));
		}

		void ToggleBreakpointAtCurrentLine()
		{
			if (SelectedSourceLine > 0)
			{
				ToggleBreakpointAtLine(SelectedSourceLine);
			}
		}

		void ToggleBreakpointAtLine(const int32 LineNumber)
		{
			if (CurrentSourcePath.IsEmpty())
			{
				AddLogLine(TEXT("Open a source file before toggling a breakpoint."));
				return;
			}

			const FString ModuleName = AngelscriptDebugClient::MakeModuleNameFromScriptPath(CurrentSourcePath, ScriptRoots);
			AngelscriptDebugClient::FBreakpointEntry ExistingBreakpoint;
			if (BreakpointStore.TryGetBreakpointAtLine(CurrentSourcePath, LineNumber, ExistingBreakpoint))
			{
				RemoveBreakpointById(ExistingBreakpoint.Id);
				return;
			}

			const FString Condition = GetBreakpointConditionText();
			const int32 Id = BreakpointStore.SetBreakpoint(CurrentSourcePath, ModuleName, LineNumber, Condition);
			SendBreakpointSetForFile(CurrentSourcePath, ModuleName, GetBreakpointsForFileAndModule(CurrentSourcePath, ModuleName));
			RefreshBreakpoints();
			RefreshSourceDecorations();
			SelectedBreakpoint = FindBreakpointItemById(Id);
			SetBreakpointConditionText(Condition);
			AddLogLine(FString::Printf(TEXT("Breakpoint set: %s:%d"),
				*FPaths::GetCleanFilename(CurrentSourcePath),
				LineNumber));
		}

		void RefreshBreakpoints()
		{
			BreakpointItems.Reset();
			for (const AngelscriptDebugClient::FBreakpointEntry& Entry : BreakpointStore.GetBreakpoints())
			{
				BreakpointItems.Add(MakeShared<FBreakpointView>(AngelscriptDebugger::MakeBreakpointView(Entry)));
			}
			RefreshList(BreakpointView);
		}

		void RefreshSourceDecorations()
		{
			ApplySourceBreakpointDecorations();
			if (SourceView.IsValid())
			{
				SourceView->RequestListRefresh();
				SourceView->Invalidate(EInvalidateWidgetReason::Paint);
			}
		}

		void ApplySourceBreakpointDecorations()
		{
			AngelscriptDebugger::ApplySourceBreakpointDecorations(SourceLineItems, CurrentSourcePath, BreakpointStore);
		}

		void OpenSourceFile(const FString& Filename, const int32 LineNumber)
		{
			CurrentSourcePath = AngelscriptDebugClient::NormalizeDebuggerFilename(Filename);
			SelectedSourceLine = LineNumber;
			LoadSourceLines();
		}

		void LoadSourceLines()
		{
			TArray<FString> FileLines;
			if (CurrentSourcePath.IsEmpty() || !FFileHelper::LoadFileToStringArray(FileLines, *CurrentSourcePath))
			{
				const FString Message = CurrentSourcePath.IsEmpty()
					? TEXT("No source selected.")
					: FString::Printf(TEXT("Unable to load source file: %s (ScriptRoot: %s)"), *CurrentSourcePath, *ScriptRoot);
				SourceLineItems = AngelscriptDebugger::MakeSourceLineItemsForMessage(Message);
			}
			else
			{
				SourceLineItems = AngelscriptDebugger::MakeSourceLineItems(FileLines);
			}

			ApplySourceBreakpointDecorations();
			RefreshList(SourceView);
			if (SourceView.IsValid() && SourceLineItems.IsValidIndex(SelectedSourceLine - 1))
			{
				SourceView->SetSelection(SourceLineItems[SelectedSourceLine - 1], ESelectInfo::Direct);
				SourceView->RequestScrollIntoView(SourceLineItems[SelectedSourceLine - 1]);
			}
		}

		void RefreshSectionsFromDisk()
		{
			AllSectionItems.Reset();
			if (!ScriptRoot.IsEmpty())
			{
				TArray<FString> Files;
				IFileManager::Get().FindFilesRecursive(Files, *ScriptRoot, TEXT("*.as"), true, false);
				Files.Sort();
				for (const FString& File : Files)
				{
					const FString Normalized = AngelscriptDebugClient::NormalizeDebuggerFilename(File);
					TSharedPtr<FSectionView> Item = MakeShared<FSectionView>();
					Item->Filename = Normalized;
					Item->Label = AngelscriptDebugClient::MakeModuleNameFromScriptPath(Normalized, ScriptRoots);
					AllSectionItems.Add(Item);
				}
			}
			ApplySectionFilter();
		}

		void ApplySectionFilter()
		{
			SectionItems.Reset();
			if (SectionFilterText.IsEmpty())
			{
				SectionItems.Append(AllSectionItems);
			}
			else
			{
				for (const TSharedPtr<FSectionView>& Item : AllSectionItems)
				{
					if (!Item.IsValid())
					{
						continue;
					}

					if (Item->Label.Contains(SectionFilterText, ESearchCase::IgnoreCase)
						|| Item->Filename.Contains(SectionFilterText, ESearchCase::IgnoreCase))
					{
						SectionItems.Add(Item);
					}
				}
			}
			RefreshList(SectionView);
		}

		FString NormalizeWatchExpression(const FString& Expression) const
		{
			if (Expression.Contains(TEXT(":")))
			{
				return Expression;
			}
			return FString::Printf(TEXT("%d:%s"), SelectedFrameIndex, *Expression);
		}

		void RefreshWatch(const TSharedPtr<FWatchView>& Watch)
		{
			if (Watch.IsValid())
			{
				Watch->RequestExpression = NormalizeWatchExpression(Watch->Expression);
				Watch->Value = TEXT("<pending>");
				Watch->Type.Empty();
				Client.SendRequestEvaluate(Watch->RequestExpression, SelectedFrameIndex);
				RefreshList(WatchView);
			}
		}

		void RefreshAllWatches()
		{
			for (const TSharedPtr<FWatchView>& Watch : WatchItems)
			{
				RefreshWatch(Watch);
			}
		}

		void SendBreakFilterSelection()
		{
			TArray<FString> Filters;
			for (const TSharedPtr<FBreakFilterView>& Item : BreakFilterItems)
			{
				if (Item.IsValid() && Item->bEnabled)
				{
					Filters.Add(Item->Filter);
				}
			}
			Client.SendBreakOptions(Filters);
		}

		void SyncDataBreakpoints()
		{
			TArray<FDataBreakpointView> Breakpoints;
			for (const TSharedPtr<FDataBreakpointView>& Item : DataBreakpointItems)
			{
				if (Item.IsValid())
				{
					Breakpoints.Add(*Item);
				}
			}
			Client.SendSetDataBreakpoints(Breakpoints);
		}

		void AddLogLine(const FString& Line)
		{
			LogLines.Add(MakeShared<FString>(Line));
			if (LogLines.Num() > MaxSessionLogLines)
			{
				LogLines.RemoveAt(0, LogLines.Num() - MaxSessionLogLines, EAllowShrinking::No);
			}
			RefreshList(LogView);
			if (LogView.IsValid())
			{
				LogView->ScrollToBottom();
			}
		}

		template <typename ItemType>
		void RefreshList(const TSharedPtr<SListView<TSharedPtr<ItemType>>>& ListView)
		{
			if (ListView.IsValid())
			{
				ListView->RequestListRefresh();
			}
		}

		void RefreshVariableTree()
		{
			if (VariableTree.IsValid())
			{
				VariableTree->RequestTreeRefresh();
			}
		}

		FClient Client;
		AngelscriptDebugClient::FBreakpointStore BreakpointStore;
		FText HostText;
		FText PortText;
		FString ProjectPath;
		FString ScriptRoot;
		TArray<FString> ScriptRoots;
		FString SectionFilterText;
		FString CurrentSourcePath;
		int32 SelectedSourceLine = 0;
		FString ExecutionSourcePath;
		int32 ExecutionSourceLine = 0;
		int32 SelectedFrameIndex = 0;
		FString LastStopReason;
		FString LastStopText;
		int32 LastDebugServerVersion = 0;
		bool bTargetPaused = false;
		bool bPauseRequested = false;
		int32 NextDataBreakpointId = 1;

		TSharedPtr<SEditableTextBox> HostTextBox;
		TSharedPtr<SEditableTextBox> PortTextBox;
		TSharedPtr<SEditableTextBox> BreakpointConditionTextBox;
		TSharedPtr<SEditableTextBox> WatchTextBox;
		TSharedPtr<SListView<TSharedPtr<FSourceLineView>>> SourceView;
		TSharedPtr<SListView<TSharedPtr<FSectionView>>> SectionView;
		TSharedPtr<SListView<TSharedPtr<FDebuggerFrameView>>> CallStackView;
		TSharedPtr<SListView<TSharedPtr<FBreakpointView>>> BreakpointView;
		TSharedPtr<SListView<TSharedPtr<FDataBreakpointView>>> DataBreakpointView;
		TSharedPtr<SListView<TSharedPtr<FDiagnosticView>>> DiagnosticView;
		TSharedPtr<SListView<TSharedPtr<FString>>> LogView;
		TSharedPtr<SListView<TSharedPtr<FWatchView>>> WatchView;
		TSharedPtr<SListView<TSharedPtr<FBreakFilterView>>> BreakFilterView;
		TSharedPtr<STreeView<TSharedPtr<FVariableNode>>> VariableTree;
		TSharedPtr<FVariableNode> SelectedVariable;
		TSharedPtr<FBreakpointView> SelectedBreakpoint;
		TSharedPtr<FDataBreakpointView> SelectedDataBreakpoint;
		TSharedPtr<FWatchView> SelectedWatch;

		TArray<TSharedPtr<FSourceLineView>> SourceLineItems;
		TArray<TSharedPtr<FSectionView>> AllSectionItems;
		TArray<TSharedPtr<FSectionView>> SectionItems;
		TArray<TSharedPtr<FDebuggerFrameView>> CallStackItems;
		TArray<TSharedPtr<FBreakpointView>> BreakpointItems;
		TArray<TSharedPtr<FDataBreakpointView>> DataBreakpointItems;
		TArray<TSharedPtr<FDiagnosticView>> DiagnosticItems;
		TArray<TSharedPtr<FString>> LogLines;
		TArray<TSharedPtr<FWatchView>> WatchItems;
		TArray<TSharedPtr<FBreakFilterView>> BreakFilterItems;
		TArray<TSharedPtr<FVariableNode>> VariableRootNodes;
	};
}
namespace AngelscriptDebugger
{
	class FWindowController final : public IWindowController
	{
	public:
		explicit FWindowController(const TSharedRef<SAngelscriptDebuggerWindow>& InWidget)
			: Widget(InWidget)
		{
		}

		virtual TSharedRef<SWidget> GetWidget() const override
		{
			return StaticCastSharedRef<SWidget>(Widget);
		}

		virtual void ShutdownSession() override
		{
			Widget->ShutdownSession();
		}

	private:
		TSharedRef<SAngelscriptDebuggerWindow> Widget;
	};

	TSharedRef<IWindowController> CreateWindowController(const FWindowArgs& Args)
	{
		TSharedPtr<SAngelscriptDebuggerWindow> Widget;
		SAssignNew(Widget, SAngelscriptDebuggerWindow)
			.InitialHost(Args.InitialHost)
			.InitialPort(Args.InitialPort)
			.ProjectPath(Args.ProjectPath)
			.ScriptRoot(Args.ScriptRoot)
			.AutoConnect(Args.bAutoConnect);

		return MakeShared<FWindowController>(Widget.ToSharedRef());
	}
}
