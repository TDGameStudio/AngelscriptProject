#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Blueprint/UserWidget.h"
#include "Blueprint/WidgetTree.h"
#include "Components/TextBlock.h"
#include "Components/Widget.h"
#include "Containers/Array.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptUserWidgetTreeCompatBindingsTest,
	"Angelscript.TestModule.Bindings.UserWidgetTreeCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptUserWidgetTreeErrorPathsBindingsTest,
	"Angelscript.TestModule.Bindings.UserWidgetTreeErrorPaths",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptUserWidgetBindingsTests_Private
{
	static constexpr ANSICHAR UserWidgetBindingsModuleName[] = "ASUserWidgetTreeCompat";
	static constexpr ANSICHAR UserWidgetErrorPathsModuleName[] = "ASUserWidgetTreeErrorPaths";
	static constexpr TCHAR UserWidgetFixtureModuleName[] = TEXT("ASUserWidgetTreeCompatFixture");
	static constexpr TCHAR UserWidgetFixtureName[] = TEXT("BindingUserWidget");
	static constexpr TCHAR MissingTreeWidgetFixtureName[] = TEXT("BindingUserWidgetMissingTree");
	static constexpr TCHAR UserWidgetTreeFixtureName[] = TEXT("WidgetTree");
	static constexpr TCHAR RuntimeRootWidgetName[] = TEXT("RuntimeText");
	static constexpr TCHAR RuntimeWidgetClassName[] = TEXT("UBindingUserWidgetCompat");
	static constexpr TCHAR DetachedTextBlockFixtureName[] = TEXT("DetachedTextBlock");

	struct FUserWidgetBindingFixture
	{
		UUserWidget* Widget = nullptr;
		UWidgetTree* WidgetTree = nullptr;
		FString WidgetPath;
	};

	struct FNativeUserWidgetTreeState
	{
		UWidget* RootWidget = nullptr;
		int32 WidgetCount = 0;
		bool bContainsNamedWidget = false;
	};

	void ReplaceToken(FString& Source, const TCHAR* Token, const FString& Replacement)
	{
		Source.ReplaceInline(Token, *Replacement, ESearchCase::CaseSensitive);
	}

	FString EscapeScriptString(const FString& Value)
	{
		return Value.ReplaceCharWithEscapedChar();
	}

	UClass* CreateFixtureWidgetClass(FAutomationTestBase& Test, FAngelscriptEngine& Engine)
	{
		const bool bCompiled = CompileAnnotatedModuleFromMemory(
			&Engine,
			FName(UserWidgetFixtureModuleName),
			FString(UserWidgetFixtureModuleName) + TEXT(".as"),
			FString::Printf(
				TEXT(R"AS(
UCLASS()
class %s : UUserWidget
{
}
)AS"),
				RuntimeWidgetClassName));
		if (!Test.TestTrue(TEXT("UserWidgetTreeCompat should compile a concrete scripted UUserWidget fixture class"), bCompiled))
		{
			return nullptr;
		}

		UClass* WidgetClass = FindGeneratedClass(&Engine, FName(RuntimeWidgetClassName));
		Test.TestNotNull(TEXT("UserWidgetTreeCompat should publish the generated concrete widget class"), WidgetClass);
		return WidgetClass;
	}

	FUserWidgetBindingFixture CreateUserWidgetFixture(
		FAutomationTestBase& Test,
		UClass* WidgetClass,
		const TCHAR* FixtureWidgetName = UserWidgetFixtureName,
		bool bCreateWidgetTree = true)
	{
		FUserWidgetBindingFixture Fixture;
		Fixture.Widget = NewObject<UUserWidget>(
			GetTransientPackage(),
			WidgetClass,
			FixtureWidgetName,
			RF_Transient);
		if (!Test.TestNotNull(TEXT("UserWidgetTreeCompat should create the transient user widget fixture"), Fixture.Widget))
		{
			return Fixture;
		}

		Fixture.WidgetPath = Fixture.Widget->GetPathName();
		if (!bCreateWidgetTree)
		{
			return Fixture;
		}

		Fixture.WidgetTree = NewObject<UWidgetTree>(
			Fixture.Widget,
			UWidgetTree::StaticClass(),
			UserWidgetTreeFixtureName,
			RF_Transient);
		if (!Test.TestNotNull(TEXT("UserWidgetTreeCompat should create the transient widget tree fixture"), Fixture.WidgetTree))
		{
			Fixture.Widget->MarkAsGarbage();
			Fixture.Widget = nullptr;
			return Fixture;
		}

		Fixture.Widget->WidgetTree = Fixture.WidgetTree;
		return Fixture;
	}

	UTextBlock* CreateDetachedTextBlockFixture(FAutomationTestBase& Test)
	{
		UTextBlock* TextBlock = NewObject<UTextBlock>(
			GetTransientPackage(),
			UTextBlock::StaticClass(),
			DetachedTextBlockFixtureName,
			RF_Transient);
		Test.TestNotNull(TEXT("UserWidgetTreeErrorPaths should create the detached transient text block fixture"), TextBlock);
		return TextBlock;
	}

	FNativeUserWidgetTreeState CaptureNativeTreeState(const FUserWidgetBindingFixture& Fixture)
	{
		FNativeUserWidgetTreeState State;
		if (Fixture.Widget == nullptr || Fixture.WidgetTree == nullptr)
		{
			return State;
		}

		State.RootWidget = Fixture.Widget->GetRootWidget();

		TArray<UWidget*> Widgets;
		Fixture.WidgetTree->GetAllWidgets(Widgets);
		State.WidgetCount = Widgets.Num();
		for (UWidget* Widget : Widgets)
		{
			if (Widget != nullptr && Widget->GetFName() == FName(RuntimeRootWidgetName))
			{
				State.bContainsNamedWidget = true;
				break;
			}
		}

		return State;
	}

	bool VerifyNativeFixtureBaseline(
		FAutomationTestBase& Test,
		const FUserWidgetBindingFixture& Fixture)
	{
		bool bPassed = true;
		bPassed &= Test.TestNotNull(
			TEXT("UserWidgetTreeCompat fixture should expose a widget tree on the user widget"),
			Fixture.WidgetTree);
		bPassed &= Test.TestTrue(
			TEXT("UserWidgetTreeCompat fixture should have a non-empty object path for FindObject lookup"),
			!Fixture.WidgetPath.IsEmpty());

		const FNativeUserWidgetTreeState State = CaptureNativeTreeState(Fixture);
		bPassed &= Test.TestNull(
			TEXT("UserWidgetTreeCompat native baseline should start without a root widget"),
			State.RootWidget);
		bPassed &= Test.TestEqual(
			TEXT("UserWidgetTreeCompat native baseline should start with an empty widget tree"),
			State.WidgetCount,
			0);
		bPassed &= Test.TestFalse(
			TEXT("UserWidgetTreeCompat native baseline should not already contain the runtime root widget name"),
			State.bContainsNamedWidget);
		return bPassed;
	}

	bool VerifyNativePostconditions(
		FAutomationTestBase& Test,
		const FUserWidgetBindingFixture& Fixture)
	{
		bool bPassed = true;
		const FNativeUserWidgetTreeState State = CaptureNativeTreeState(Fixture);

		bPassed &= Test.TestNull(
			TEXT("UserWidgetTreeCompat should leave the native user widget without a root widget after RemoveWidget"),
			State.RootWidget);
		bPassed &= Test.TestNull(
			TEXT("UserWidgetTreeCompat should clear WidgetTree->RootWidget after the scripted remove path"),
			Fixture.WidgetTree != nullptr ? Fixture.WidgetTree->RootWidget : nullptr);
		bPassed &= Test.TestEqual(
			TEXT("UserWidgetTreeCompat should leave the native widget tree with no remaining widgets after removal"),
			State.WidgetCount,
			0);
		bPassed &= Test.TestFalse(
			TEXT("UserWidgetTreeCompat should not leave the removed runtime widget discoverable by name in the tree"),
			State.bContainsNamedWidget);
		return bPassed;
	}

	FString BuildUserWidgetTreeScript(const FUserWidgetBindingFixture& Fixture)
	{
		FString Script = TEXT(R"AS(
int Entry()
{
	UObject FoundObject = FindObject("__WIDGET_PATH__");
	UUserWidget Widget = Cast<UUserWidget>(FoundObject);
	if (Widget == null)
		return 2;

	if (Widget.GetRootWidget() != null)
		return 4;

	UWidget Root = Widget.ConstructWidget(UTextBlock::StaticClass(), n"__ROOT_NAME__");
	if (Root == null)
		return 8;

	UTextBlock TypedRoot = Cast<UTextBlock>(Root);
	if (TypedRoot == null)
		return 16;

	if (!(Root.GetName() == n"__ROOT_NAME__"))
		return 32;

	Widget.SetRootWidget(Root);
	if (Widget.GetRootWidget() != Root)
		return 64;

	TArray<UWidget> Widgets;
	Widget.GetAllWidgets(Widgets);
	if (Widgets.Num() != 1)
		return 128;
	if (Widgets[0] != Root)
		return 256;

	if (!Widget.RemoveWidget(Root))
		return 512;

	if (Widget.GetRootWidget() != null)
		return 1024;

	Widgets.Reset();
	Widget.GetAllWidgets(Widgets);
	if (Widgets.Num() != 0)
		return 2048;

	return 1;
}
)AS");

		ReplaceToken(Script, TEXT("__WIDGET_PATH__"), EscapeScriptString(Fixture.WidgetPath));
		ReplaceToken(Script, TEXT("__ROOT_NAME__"), FString(RuntimeRootWidgetName));
		return Script;
	}

	FString BuildUserWidgetTreeErrorPathScript(
		const FUserWidgetBindingFixture& FixtureWithTree,
		const FUserWidgetBindingFixture& FixtureWithoutTree,
		const UTextBlock& DetachedTextBlock)
	{
		FString Script = TEXT(R"AS(
int Entry()
{
	UObject WithTreeObject = FindObject("__WITH_TREE_PATH__");
	UObject WithoutTreeObject = FindObject("__WITHOUT_TREE_PATH__");
	UObject TextBlockObject = FindObject("__TEXT_BLOCK_PATH__");

	UUserWidget WithTreeWidget = Cast<UUserWidget>(WithTreeObject);
	UUserWidget WithoutTreeWidget = Cast<UUserWidget>(WithoutTreeObject);
	UTextBlock TextBlock = Cast<UTextBlock>(TextBlockObject);
	if (WithTreeWidget == null || WithoutTreeWidget == null || TextBlock == null)
		return 2;

	if (WithTreeWidget.GetRootWidget() != null)
		return 4;

	UWidget InvalidWidget = WithTreeWidget.ConstructWidget(AActor::StaticClass(), n"BadWidget");
	if (InvalidWidget != null)
		return 8;

	if (WithTreeWidget.GetRootWidget() != null)
		return 16;

	WithoutTreeWidget.SetRootWidget(TextBlock);
	if (WithoutTreeWidget.GetRootWidget() != null)
		return 32;

	if (WithoutTreeWidget.RemoveWidget(TextBlock))
		return 64;

	return 1;
}
)AS");

		ReplaceToken(Script, TEXT("__WITH_TREE_PATH__"), EscapeScriptString(FixtureWithTree.WidgetPath));
		ReplaceToken(Script, TEXT("__WITHOUT_TREE_PATH__"), EscapeScriptString(FixtureWithoutTree.WidgetPath));
		ReplaceToken(Script, TEXT("__TEXT_BLOCK_PATH__"), EscapeScriptString(DetachedTextBlock.GetPathName()));
		return Script;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptUserWidgetBindingsTests_Private;

bool FAngelscriptUserWidgetTreeCompatBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	UClass* FixtureWidgetClass = CreateFixtureWidgetClass(*this, Engine);
	if (FixtureWidgetClass == nullptr)
	{
		return false;
	}

	FUserWidgetBindingFixture Fixture = CreateUserWidgetFixture(*this, FixtureWidgetClass);
	if (Fixture.Widget == nullptr || Fixture.WidgetTree == nullptr)
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		if (Fixture.Widget != nullptr)
		{
			Fixture.Widget->MarkAsGarbage();
		}
	};

	if (!VerifyNativeFixtureBaseline(*this, Fixture))
	{
		return false;
	}

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		UserWidgetBindingsModuleName,
		BuildUserWidgetTreeScript(Fixture));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 ScriptResult = INDEX_NONE;
	if (!ExecuteIntFunction(*this, Engine, *Function, ScriptResult))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("UserWidgetTreeCompat scripted root/create/remove path should report the success sentinel"),
		ScriptResult,
		1);
	bPassed &= VerifyNativePostconditions(*this, Fixture);

	ASTEST_END_FULL
	return bPassed;
}

bool FAngelscriptUserWidgetTreeErrorPathsBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASUserWidgetTreeErrorPaths"));
	};

	UClass* FixtureWidgetClass = CreateFixtureWidgetClass(*this, Engine);
	if (FixtureWidgetClass == nullptr)
	{
		return false;
	}

	FUserWidgetBindingFixture FixtureWithTree = CreateUserWidgetFixture(*this, FixtureWidgetClass);
	FUserWidgetBindingFixture FixtureWithoutTree = CreateUserWidgetFixture(*this, FixtureWidgetClass, MissingTreeWidgetFixtureName, false);
	UTextBlock* DetachedTextBlock = CreateDetachedTextBlockFixture(*this);
	if (FixtureWithTree.Widget == nullptr || FixtureWithTree.WidgetTree == nullptr || FixtureWithoutTree.Widget == nullptr || DetachedTextBlock == nullptr)
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		if (DetachedTextBlock != nullptr)
		{
			DetachedTextBlock->MarkAsGarbage();
		}

		if (FixtureWithoutTree.Widget != nullptr)
		{
			FixtureWithoutTree.Widget->MarkAsGarbage();
		}

		if (FixtureWithTree.Widget != nullptr)
		{
			FixtureWithTree.Widget->MarkAsGarbage();
		}
	};

	bPassed &= TestTrue(
		TEXT("UserWidgetTreeErrorPaths should create a widget-with-tree fixture path"),
		!FixtureWithTree.WidgetPath.IsEmpty());
	bPassed &= TestTrue(
		TEXT("UserWidgetTreeErrorPaths should create a widget-without-tree fixture path"),
		!FixtureWithoutTree.WidgetPath.IsEmpty());
	bPassed &= TestNull(
		TEXT("UserWidgetTreeErrorPaths should keep the missing-tree fixture without a WidgetTree before the script runs"),
		FixtureWithoutTree.Widget->WidgetTree);
	bPassed &= TestNull(
		TEXT("UserWidgetTreeErrorPaths native baseline should start without a root widget on the missing-tree fixture"),
		FixtureWithoutTree.Widget->GetRootWidget());
	bPassed &= TestNull(
		TEXT("UserWidgetTreeErrorPaths detached text block should start without a parent"),
		DetachedTextBlock->GetParent());
	if (!bPassed)
	{
		return false;
	}

	AddExpectedErrorPlain(
		TEXT("Ensure condition failed: WidgetClass && WidgetClass->IsChildOf(UWidget::StaticClass())"),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedErrorPlain(TEXT("LogOutputDevice:"), EAutomationExpectedErrorFlags::Contains, 0);

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		UserWidgetErrorPathsModuleName,
		BuildUserWidgetTreeErrorPathScript(FixtureWithTree, FixtureWithoutTree, *DetachedTextBlock));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 ScriptResult = INDEX_NONE;
	if (!ExecuteIntFunction(*this, Engine, *Function, ScriptResult))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("UserWidgetTreeErrorPaths should return the success sentinel after invalid-class and missing-tree coverage"),
		ScriptResult,
		1);

	const FNativeUserWidgetTreeState WithTreeState = CaptureNativeTreeState(FixtureWithTree);
	bPassed &= TestNull(
		TEXT("UserWidgetTreeErrorPaths should not create a root widget when ConstructWidget receives an unrelated class"),
		WithTreeState.RootWidget);
	bPassed &= TestEqual(
		TEXT("UserWidgetTreeErrorPaths should leave the tree-backed widget without any constructed widgets after the invalid-class path"),
		WithTreeState.WidgetCount,
		0);
	bPassed &= TestFalse(
		TEXT("UserWidgetTreeErrorPaths should not leak the compatibility root widget name after the invalid-class path"),
		WithTreeState.bContainsNamedWidget);
	bPassed &= TestNull(
		TEXT("UserWidgetTreeErrorPaths should keep the missing-tree fixture without a WidgetTree after SetRootWidget"),
		FixtureWithoutTree.Widget->WidgetTree);
	bPassed &= TestNull(
		TEXT("UserWidgetTreeErrorPaths should keep GetRootWidget() null when SetRootWidget runs without a WidgetTree"),
		FixtureWithoutTree.Widget->GetRootWidget());
	bPassed &= TestNull(
		TEXT("UserWidgetTreeErrorPaths should keep the detached text block parentless after RemoveWidget on a widget without tree"),
		DetachedTextBlock->GetParent());

	ASTEST_END_FULL
	return bPassed;
}

#endif
