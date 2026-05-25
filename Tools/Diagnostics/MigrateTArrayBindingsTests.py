#!/usr/bin/env python3
"""Migrate TArray binding tests to AngelscriptTArrayBindingsTestHelpers.h."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BINDINGS = ROOT / "Plugins/Angelscript/Source/AngelscriptTest/Bindings"

TARRAY_CPP = BINDINGS / "AngelscriptTArrayBindingsTests.cpp"
SYNTAX_CPP = BINDINGS / "AngelscriptTArraySyntaxCompatBindingsTests.cpp"

HELPER_INCLUDE = '#include "Bindings/AngelscriptTArrayBindingsTestHelpers.h"\n'
EXECUTE_INCLUDE = '#include "Shared/AngelscriptTestExecute.h"\n'

REPLACEMENTS = [
    ("#include \"Shared/AngelscriptGlobalFunctionInvoker.h\"\n", EXECUTE_INCLUDE),
    ("#include \"Shared/AngelscriptBindingsAssertions.h\"\n", ""),
    ("FASGlobalFunctionInvoker", "FAngelscriptTestExecutor"),
    ("Invoker.Call()", "Invoker.Execute()"),
    ("Invoker.CallAndReturn", "Invoker.ExecuteAndGet"),
]

def strip_tarray_private_namespace(text: str) -> str:
    start = text.find("namespace AngelscriptTest_Bindings_AngelscriptTArrayBindingsTests_Private")
    if start == -1:
        return text
    end = text.find("\n}\n\nusing namespace AngelscriptTest_Bindings_AngelscriptTArrayBindingsTests_Private;", start)
    if end == -1:
        return text
    end += len("\n}\n\nusing namespace AngelscriptTest_Bindings_AngelscriptTArrayBindingsTests_Private;")
    return text[:start] + HELPER_INCLUDE + "\n" + text[end:]

def strip_syntax_private_namespace(text: str) -> str:
    start = text.find("namespace AngelscriptTest_Bindings_AngelscriptTArraySyntaxCompatBindingsTests_Private")
    if start == -1:
        return text
    end = text.find("\n}\n\nusing namespace AngelscriptTest_Bindings_AngelscriptTArraySyntaxCompatBindingsTests_Private;", start)
    if end == -1:
        return text
    end += len("\n}\n\nusing namespace AngelscriptTest_Bindings_AngelscriptTArraySyntaxCompatBindingsTests_Private;")
    return text[:start] + HELPER_INCLUDE + "\n" + text[end:]

def migrate_tarray(text: str) -> str:
    text = strip_tarray_private_namespace(text)
    text = text.replace(
        "using namespace AngelscriptTest_Bindings_AngelscriptTArrayBindingsTests_Private;\n\n",
        "",
    )
    text = text.replace(
        "static const FArraySyntaxCoverageProfile TArrayProfile{",
        "static const FArraySyntaxCoverageProfile TArrayProfile = TArrayBindingsCoverageProfile();\n\n#if 0 // legacy profile initializer removed\nstatic const FArraySyntaxCoverageProfile TArrayProfileLegacy{",
        1,
    )
    # Simpler: replace profile usage
    text = text.replace(
        "static const FArraySyntaxCoverageProfile TArrayProfile{\n\t\tTEXT(\"TArray\"),\n\t\tTEXT(\"ASTArray\"),\n\t\tTEXT(\"TArrayBindings\"),\n\t};",
        "static const FArraySyntaxCoverageProfile TArrayProfile = TArrayBindingsCoverageProfile();",
    )
    text = text.replace("TArrayNestedContainerDiagnostic", "TArrayBindingsNestedContainerDiagnostic")
    text = text.replace(
        "static const FString TArrayNestedContainerDiagnostic = TEXT(",
        "static const FString TArrayBindingsNestedContainerDiagnostic = TEXT(",
    )
    for old, new in REPLACEMENTS:
        text = text.replace(old, new)
    if "TArrayBindingsNestedContainerDiagnostic" not in text and "TArrayNestedContainerDiagnostic" in text:
        pass
    return text

def migrate_syntax(text: str) -> str:
    text = strip_syntax_private_namespace(text)
    text = text.replace(
        "using namespace AngelscriptTest_Bindings_AngelscriptTArraySyntaxCompatBindingsTests_Private;\n\n",
        "",
    )
    text = text.replace("BuildSyntaxModule(", "TArrayBindingsBuildCoverageModule(TArraySyntaxCompatCoverageProfile(), ")
    text = text.replace("MakeModuleName(", "TArrayBindingsMakeModuleName(TArraySyntaxCompatCoverageProfile(), ")
    text = text.replace("MakeArrayFunctionDecl(", "TArrayBindingsMakeArrayFunctionDecl(TArraySyntaxCompatCoverageProfile(), ")
    text = text.replace("TraceSyntaxCase(", "TArrayBindingsTraceCase(TArraySyntaxCompatCoverageProfile(), ")
    text = text.replace("ExpectSyntaxCompatGlobalInt(", "ExpectTArrayBindingsGlobalInt(TArraySyntaxCompatCoverageProfile(), ")
    text = text.replace("ExpectSyntaxCompatGlobalIntAtLeast(", "ExpectTArrayBindingsGlobalIntAtLeast(TArraySyntaxCompatCoverageProfile(), ")
    text = text.replace("ExpectSyntaxCompatGlobalInts(", "ExpectTArrayBindingsGlobalInts(TArraySyntaxCompatCoverageProfile(), ")
    text = text.replace("ExpectSyntaxCompatGlobalIntsAtLeast(", "ExpectTArrayBindingsGlobalIntsAtLeast(TArraySyntaxCompatCoverageProfile(), ")
    text = text.replace(
        "ExecuteFunctionExpectingScriptException(",
        "TArrayBindingsExecuteFunctionExpectingScriptException(TArraySyntaxCompatCoverageProfile(), ",
    )
    text = text.replace(
        "ExecuteFunctionReturningScriptArray(",
        "TArrayBindingsExecuteFunctionReturningScriptArray(TArraySyntaxCompatCoverageProfile(), ",
    )
    text = text.replace("SyntaxCompileSummaryContainsDiagnosticMessage(", "TArrayBindingsCompileSummaryContainsDiagnosticMessage(")
    text = text.replace("SyntaxReportCompileSummaryDiagnostics(", "TArrayBindingsReportCompileSummaryDiagnostics(")
    text = text.replace("ExpectCompileFailure(", "TArraySyntaxCompatExpectCompileFailure(TArraySyntaxCompatCoverageProfile(), ")
    text = text.replace("NestedContainerDiagnostic", "TArraySyntaxCompatNestedContainerDiagnostic")
    text = text.replace("static const FString NestedContainerDiagnostic", "static const FString TArraySyntaxCompatNestedContainerDiagnostic")
    text = text.replace("static const TCHAR* ModulePrefix = TEXT(\"ASTArraySyntaxCompat\");", "")
    text = text.replace("static const TCHAR* LogCategory = TEXT(\"TArraySyntaxCompatBindings\");", "")
    for old, new in REPLACEMENTS:
        text = text.replace(old, new)
    return text

def main() -> None:
    tarray = TARRAY_CPP.read_text(encoding="utf-8")
    syntax = SYNTAX_CPP.read_text(encoding="utf-8")
    TARRAY_CPP.write_text(migrate_tarray(tarray), encoding="utf-8")
    SYNTAX_CPP.write_text(migrate_syntax(syntax), encoding="utf-8")
    print("Migrated TArray binding tests")

if __name__ == "__main__":
    main()
