from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
path = ROOT / "Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptTArraySyntaxCompatBindingsTests.cpp"

text = path.read_text(encoding="utf-8")

# Strip private namespace
start = text.find("namespace AngelscriptTest_Bindings_AngelscriptTArraySyntaxCompatBindingsTests_Private")
end = text.find("using namespace AngelscriptTest_Bindings_AngelscriptTArraySyntaxCompatBindingsTests_Private;")
if start != -1 and end != -1:
    end = text.find("\n", end) + 1
    preamble = (
        '#include "Shared/AngelscriptTestExecute.h"\n'
        '#include "Bindings/AngelscriptTArrayBindingsTestHelpers.h"\n\n'
        'static const FString TArraySyntaxCompatNestedContainerDiagnostic = TEXT("Containers cannot be nested in other containers");\n'
        "static const FArraySyntaxCoverageProfile TArraySyntaxCompatProfile = TArraySyntaxCompatCoverageProfile();\n\n"
    )
    text = text[:start] + preamble + text[end:]
    text = text.replace('#include "Shared/AngelscriptGlobalFunctionInvoker.h"\n', "")

lines = text.splitlines()
out = []
for line in lines:
    stripped = line.lstrip()
    if 'TEXT("void TraceSyntaxCase' in line or stripped.startswith("void TraceSyntaxCase(const FString"):
        out.append(line)
        continue
    if "MakeArrayFunctionDecl(TEXT(" in line:
        line = line.replace("MakeArrayFunctionDecl(", "TArrayBindingsMakeArrayFunctionDecl(TArraySyntaxCompatProfile, ")
    if "BuildSyntaxModule(" in line:
        line = line.replace(
            "BuildSyntaxModule(",
            "TArrayBindingsBuildCoverageModule(Test, Engine, TArraySyntaxCompatProfile, ",
        )
    if "MakeModuleName(" in line and "TEXT(" not in line.split("MakeModuleName(")[0][-10:]:
        line = line.replace("MakeModuleName(", "TArrayBindingsMakeModuleName(TArraySyntaxCompatProfile, ")
    if "TraceSyntaxCase(Test" in line:
        line = line.replace(
            "TraceSyntaxCase(Test, Engine, Module,",
            "TArrayBindingsTraceCase(Test, Engine, Module, TArraySyntaxCompatProfile,",
        )
    if "ExpectSyntaxCompatGlobalIntAtLeast(" in line:
        line = line.replace(
            "ExpectSyntaxCompatGlobalIntAtLeast(Test, Engine, Module,",
            "ExpectTArrayBindingsGlobalIntAtLeast(Test, Engine, Module, TArraySyntaxCompatProfile,",
        )
    if "ExpectSyntaxCompatGlobalInt(" in line:
        line = line.replace(
            "ExpectSyntaxCompatGlobalInt(Test, Engine, Module,",
            "ExpectTArrayBindingsGlobalInt(Test, Engine, Module, TArraySyntaxCompatProfile,",
        )
    if "ExpectSyntaxCompatGlobalIntsAtLeast(" in line:
        line = line.replace(
            "ExpectSyntaxCompatGlobalIntsAtLeast(Test, Engine, Module,",
            "ExpectTArrayBindingsGlobalIntsAtLeast(Test, Engine, Module, TArraySyntaxCompatProfile,",
        )
    if "ExpectSyntaxCompatGlobalInts(" in line:
        line = line.replace(
            "ExpectSyntaxCompatGlobalInts(Test, Engine, Module,",
            "ExpectTArrayBindingsGlobalInts(Test, Engine, Module, TArraySyntaxCompatProfile,",
        )
    if "ExecuteFunctionExpectingScriptException(Test" in line:
        line = line.replace(
            "ExecuteFunctionExpectingScriptException(Test, Engine, Module,",
            "TArrayBindingsExecuteFunctionExpectingScriptException(Test, Engine, Module, TArraySyntaxCompatProfile,",
        )
    if "ExecuteFunctionReturningScriptArray(Test" in line:
        line = line.replace(
            "ExecuteFunctionReturningScriptArray(Test, Engine, Module,",
            "TArrayBindingsExecuteFunctionReturningScriptArray(Test, Engine, Module, TArraySyntaxCompatProfile,",
        )
    if "SyntaxCompileSummaryContainsDiagnosticMessage(" in line:
        line = line.replace(
            "SyntaxCompileSummaryContainsDiagnosticMessage(",
            "TArrayBindingsCompileSummaryContainsDiagnosticMessage(",
        )
    if "SyntaxReportCompileSummaryDiagnostics(" in line:
        line = line.replace(
            "SyntaxReportCompileSummaryDiagnostics(",
            "TArrayBindingsReportCompileSummaryDiagnostics(",
        )
    if "ExpectCompileFailure(Test" in line:
        line = line.replace(
            "ExpectCompileFailure(Test, Engine,",
            "TArraySyntaxCompatExpectCompileFailure(Test, Engine, TArraySyntaxCompatProfile,",
        )
    if "FASGlobalFunctionInvoker" in line:
        line = line.replace("FASGlobalFunctionInvoker", "FAngelscriptTestExecutor")
        line = line.replace(".Call()", ".Execute()")
        line = line.replace(".CallAndReturn", ".ExecuteAndGet")
    if "NestedContainerDiagnostic" in line and "TArraySyntaxCompat" not in line:
        line = line.replace("NestedContainerDiagnostic", "TArraySyntaxCompatNestedContainerDiagnostic")
    if "FSyntaxExpectedGlobalIntAtLeast" in line:
        line = line.replace("FSyntaxExpectedGlobalIntAtLeast", "FTArrayExpectedGlobalIntAtLeast")
    if "FSyntaxExpectedGlobalInt" in line:
        line = line.replace("FSyntaxExpectedGlobalInt", "FTArrayExpectedGlobalInt")
    out.append(line)

path.write_text("\n".join(out) + "\n", encoding="utf-8")
print("migrated syntax compat")
