#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/Helper_CommentFormat.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorCommentFormatTests_Private
{
	bool ExpectFormattedComment(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		const FString& Input,
		const FString& Expected)
	{
		return Test.TestEqual(Context, FormatCommentForToolTip(Input), Expected);
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorCommentFormatTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorCommentFormattingTooltipNormalizationTest,
	"Angelscript.TestModule.Preprocessor.CommentFormatting.TooltipNormalization",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorCommentFormattingTooltipNormalizationTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	bPassed &= TestTrue(
		TEXT("IsAllSameChar should accept uniform dash separators"),
		IsAllSameChar(TEXT("----"), TEXT('-')));
	bPassed &= TestFalse(
		TEXT("IsAllSameChar should reject mixed separator characters"),
		IsAllSameChar(TEXT("--=-"), TEXT('-')));
	bPassed &= TestTrue(
		TEXT("IsLineSeparator should accept equals separators"),
		IsLineSeparator(TEXT("====")));
	bPassed &= TestFalse(
		TEXT("IsLineSeparator should reject lines containing non-separator content"),
		IsLineSeparator(TEXT("-- body --")));

	bPassed &= ExpectFormattedComment(
		*this,
		TEXT("JavaDoc comments should strip markers and leading stars"),
		TEXT("/**\n * Summary line\n * Detail line\n */"),
		TEXT("Summary line\nDetail line"));

	bPassed &= ExpectFormattedComment(
		*this,
		TEXT("Cpp comments should drop //~ ignored lines before tooltip normalization"),
		TEXT("// Summary line\n//~ Hidden line\n// Followup line"),
		TEXT("Summary line\nFollowup line"));

	bPassed &= ExpectFormattedComment(
		*this,
		TEXT("Separator-only wrapper lines should be removed from tooltip output"),
		TEXT("/**\n * =====\n * Body text\n * =====\n */"),
		TEXT("Body text"));

	bPassed &= ExpectFormattedComment(
		*this,
		TEXT("Pure CJK tooltip comments should not be treated as empty"),
		TEXT("// 纯中文提示"),
		TEXT("纯中文提示"));

	bPassed &= ExpectFormattedComment(
		*this,
		TEXT("Tabs and carriage returns should normalize into stable plain-text indentation"),
		TEXT("//\tTabbed line\r\n//\tSecond line"),
		TEXT("Tabbed line\nSecond line"));

	bPassed &= ExpectFormattedComment(
		*this,
		TEXT("Comments without alnum or CJK content should normalize to empty text"),
		TEXT("/* ===== */"),
		TEXT(""));

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
