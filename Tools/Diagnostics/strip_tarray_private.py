from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

def strip_namespace(path: Path, ns: str, using: str, preamble: str) -> None:
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    skip = False
    for line in lines:
        if line.startswith(f"namespace {ns}"):
            out.append(preamble)
            skip = True
            continue
        if skip and line.startswith(f"using namespace {ns}"):
            skip = False
            continue
        if skip:
            continue
        out.append(line)
    path.write_text("".join(out), encoding="utf-8")

strip_namespace(
    ROOT / "Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptTArrayBindingsTests.cpp",
    "AngelscriptTest_Bindings_AngelscriptTArrayBindingsTests_Private",
    "AngelscriptTest_Bindings_AngelscriptTArrayBindingsTests_Private",
    'static const FString TArrayBindingsNestedContainerDiagnostic = TEXT("Containers cannot be nested in other containers");\n'
    "static const FArraySyntaxCoverageProfile TArrayProfile = TArrayBindingsCoverageProfile();\n\n",
)

p = ROOT / "Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptTArrayBindingsTests.cpp"
text = p.read_text(encoding="utf-8")
text = text.replace("TArrayNestedContainerDiagnostic", "TArrayBindingsNestedContainerDiagnostic")
p.write_text(text, encoding="utf-8")

syntax = ROOT / "Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptTArraySyntaxCompatBindingsTests.cpp"
strip_namespace(
    syntax,
    "AngelscriptTest_Bindings_AngelscriptTArraySyntaxCompatBindingsTests_Private",
    "AngelscriptTest_Bindings_AngelscriptTArraySyntaxCompatBindingsTests_Private",
    'static const FString TArraySyntaxCompatNestedContainerDiagnostic = TEXT("Containers cannot be nested in other containers");\n'
    "static const FArraySyntaxCoverageProfile TArraySyntaxCompatProfile = TArraySyntaxCompatCoverageProfile();\n\n",
)
text2 = syntax.read_text(encoding="utf-8")
text2 = text2.replace('#include "Shared/AngelscriptGlobalFunctionInvoker.h"', '#include "Shared/AngelscriptTestExecute.h"')
if "AngelscriptTArrayBindingsTestHelpers.h" not in text2:
    text2 = text2.replace(
        '#include "Shared/AngelscriptTestMacros.h"\n',
        '#include "Shared/AngelscriptTestMacros.h"\n#include "Bindings/AngelscriptTArrayBindingsTestHelpers.h"\n',
    )
text2 = text2.replace("NestedContainerDiagnostic", "TArraySyntaxCompatNestedContainerDiagnostic")
text2 = text2.replace("BuildSyntaxModule(", "TArrayBindingsBuildCoverageModule(TArraySyntaxCompatProfile, ")
text2 = text2.replace("MakeModuleName(", "TArrayBindingsMakeModuleName(TArraySyntaxCompatProfile, ")
text2 = text2.replace("MakeArrayFunctionDecl(", "TArrayBindingsMakeArrayFunctionDecl(TArraySyntaxCompatProfile, ")
text2 = text2.replace("TraceSyntaxCase(", "TArrayBindingsTraceCase(TArraySyntaxCompatProfile, ")
text2 = text2.replace("ExpectSyntaxCompatGlobalInt(", "ExpectTArrayBindingsGlobalInt(TArraySyntaxCompatProfile, ")
text2 = text2.replace("ExpectSyntaxCompatGlobalIntAtLeast(", "ExpectTArrayBindingsGlobalIntAtLeast(TArraySyntaxCompatProfile, ")
text2 = text2.replace("ExpectSyntaxCompatGlobalInts(", "ExpectTArrayBindingsGlobalInts(TArraySyntaxCompatProfile, ")
text2 = text2.replace("ExpectSyntaxCompatGlobalIntsAtLeast(", "ExpectTArrayBindingsGlobalIntsAtLeast(TArraySyntaxCompatProfile, ")
text2 = text2.replace(
    "ExecuteFunctionExpectingScriptException(",
    "TArrayBindingsExecuteFunctionExpectingScriptException(TArraySyntaxCompatProfile, ",
)
text2 = text2.replace(
    "ExecuteFunctionReturningScriptArray(",
    "TArrayBindingsExecuteFunctionReturningScriptArray(TArraySyntaxCompatProfile, ",
)
text2 = text2.replace("SyntaxCompileSummaryContainsDiagnosticMessage(", "TArrayBindingsCompileSummaryContainsDiagnosticMessage(")
text2 = text2.replace("SyntaxReportCompileSummaryDiagnostics(", "TArrayBindingsReportCompileSummaryDiagnostics(")
text2 = text2.replace("ExpectCompileFailure(", "TArraySyntaxCompatExpectCompileFailure(TArraySyntaxCompatProfile, ")
syntax.write_text(text2, encoding="utf-8")
print("done")
