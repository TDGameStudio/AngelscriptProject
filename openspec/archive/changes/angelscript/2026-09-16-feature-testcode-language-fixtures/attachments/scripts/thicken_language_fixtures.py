"""Append legacy Function/Reject scenarios into the accepted 47 Language containers.

Run from the repository root:
    python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/thicken_language_fixtures.py
    python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/thicken_language_fixtures.py --apply

Does not write generated C++. Idempotent: existing version tags are left untouched.
"""
from __future__ import annotations

import argparse
import hashlib
import re
import sys
from collections import defaultdict
from pathlib import Path

REPO = next(p for p in Path(__file__).resolve().parents if (p / "AngelscriptTestCode").is_dir())
OLD = REPO / "TestSource-old" / "Language"
LANG = REPO / "AngelscriptTestCode" / "Language"
TOOL = REPO / "AngelscriptTestCode" / "CodeGenTool"

sys.path.insert(0, str(TOOL))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.discovery import discover_sources
from angelscript_test_codegen.model import CodegenError

THEME = {
    "Operators": "Operators",
    "ControlFlow": "ControlFlow",
    "Casting": "Casting",
    "Namespace": "Namespace",
    "Syntax": "Syntax",
    "Preprocessor": "Preprocessor",
}

HOST_STEM_PARTS = (
    "cvar",
    "listener",
    "compileevent",
    "compileis",
    "virtualpath",
    "mappinggetter",
    "touchandgesture",
    "floatcurve",
    "recursiveframe",
    "staticdelta",
    "runtimecompile",
    "successfulcompile",
    "parseevent",
    "modulefunction",
    "memorysource",
    "ustruct",
    "uenum",
    "consolecommand",
    "httpbind",
    "timerlambda",
    "eventlambda",
    "eventadd",
    "playercontroller",
    "ghostbuilder",
    "fbox2d",
    "nestedcontainer",
    "floatnested",
    "globalplus",
    "globalconsole",
    "failedcompile",
    "interface",
    "legacymapping",
    "colorandrandom",
    "fstring",
    "stringname",
    "fplane",
    "fboxoperation",
    "infiniteloop",
    "import",
    "preprocess",
    "topological",
    "wideimport",
    "circular",
    "async",
    "blueprint",
    "include",
    "restrictusage",
    "warningconfig",
    "backslashpath",
    "addsource",
    "hookmoment",
    "summaryreport",
    "summaryavailable",
    "macrodetection",
    "duplicateclassname",
    "editorconditional",
    "explicitcontext",
    "defaultblueprint",
    "rangeforrewrite",
    "postprocess",
    "unregistered",
    "treatasdeleted",
    "unknownsuper",
    "unknownfunctionspecifier",
    "unsupportedconditional",
    "namespacedannotated",
    "namespacescopelife",
)

HOST_TOKENS = (
    "UFUNCTION",
    "UCLASS",
    "UPROPERTY",
    "TArray",
    "TMap",
    "TSet",
    "TMapIterator",
    "AActor",
    "APawn",
    "UObject",
    "FRandomStream",
    "FColor",
    "FLinearColor",
    "FName",
    "FText",
    "FVector",
    "FQuat",
    "FMatrix",
    "FRotator",
    "FTransform",
    "FString",
    "Cast<",
    "UEnum",
    "CVar",
    "Blueprint",
)

# Primary Function files already represented by root. Do not clone as valid-*.
ROOT_FUNCTION_STEMS = {
    "ArithmeticOperators",
    "AssignmentOperators",
    "BitwiseOperators",
    "ComparisonOperators",
    "LogicalOperators",
    "TernaryOperators",
    "ExpressionPrecedenceChains",
    "ExpressionEdgeCases",
    "IfBasic",
    "IfElseForms",
    "IfNested",
    "WhileLoop",
    "DoWhileLoop",
    "EmptyFunctionBodyCompiles",
    "EmptyVoidFunction",
    "IntReturnFunction",
    "NamedArgumentsMixedPartialOrder",
    "BasicScriptStruct",
    "StructConstructors",
    "ForNestedLoops",
    "PrimitiveAndReferenceLocals",
    "ScopeVariables",
    "DeeplyNestedBlocks",
    "IfElifElseEndifBranches",
    "StringLiteralDoesNotTriggerDirectiveLexer",
}

SKIP_HARNESS = {"UClass", "Fault", "Exception", "Other"}


def kebab(stem: str) -> str:
    name = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1-\2", stem)
    name = re.sub(r"([a-z0-9])([A-Z])", r"\1-\2", name)
    return name.replace("_", "-").lower()


def harness_of(rel: Path) -> str:
    parts = rel.parts
    if "Function" in parts:
        return "Function"
    if "Reject" in parts:
        return "Reject"
    if "UClass" in parts:
        return "UClass"
    if "Fault" in parts or "Exception" in parts:
        return "Fault"
    return "Other"


def has_host_stem(stem: str) -> bool:
    folded = stem.replace("_", "").lower()
    return any(part in folded for part in HOST_STEM_PARTS)


def map_file_tag(rel: Path) -> str | None:
    parts = rel.parts
    stem = rel.stem
    theme = parts[0]
    kind = harness_of(rel)
    if kind in SKIP_HARNESS:
        return None
    if theme == "Literals":
        return None
    if has_host_stem(stem) and kind == "Function":
        return None

    if theme == "Operators":
        if "Arithmetic" in parts:
            if stem in {"ExpressionEdgeCases", "UnmatchedParenthesis"}:
                return "Language/Operators/ExpressionEdges"
            if stem == "ColorAndRandomStreamExpressions":
                return None
            return "Language/Operators/Arithmetic"
        if "Assignment" in parts:
            if "Definite" in stem:
                return "Language/Operators/DefiniteAssignment"
            return "Language/Operators/Assignment"
        if "Bitwise" in parts:
            return "Language/Operators/Bitwise"
        if "Comparison" in parts:
            return "Language/Operators/Comparison"
        if "Logical" in parts:
            return "Language/Operators/Logical"
        if "Ternary" in parts:
            return "Language/Operators/Ternary"
        if "Advance" in parts:
            if stem == "ExpressionPrecedenceChains":
                return "Language/Operators/Precedence"
            return None
        if "Overload" in parts:
            return "Language/Operators/Overload"
        return None

    if theme == "ControlFlow":
        name = stem.lower()
        if "foreach" in name:
            return "Language/ControlFlow/Foreach"
        if "ternary" in name:
            return "Language/Operators/Ternary"
        if "return" in name or name.startswith("fmatrix") or "geometric" in name:
            return "Language/ControlFlow/Return"
        if "switch" in name or name.startswith("case"):
            return "Language/ControlFlow/Switch"
        if "break" in name or "continue" in name:
            return "Language/ControlFlow/LoopJump"
        if "dowhile" in name:
            return "Language/ControlFlow/DoWhile"
        if "while" in name:
            return "Language/ControlFlow/While"
        if "else" in name:
            return "Language/ControlFlow/IfElse"
        if "nested" in name:
            return "Language/ControlFlow/IfNested"
        if name.startswith("if") or "if" in name:
            return "Language/ControlFlow/If"
        return None

    if theme == "Casting":
        name = stem.lower()
        if "fstring" in name or "stringname" in name:
            return None
        if "nullptr" in name or name.startswith("castnull"):
            return "Language/Casting/Nullptr"
        if name.startswith("explicit"):
            return "Language/Casting/NumericExplicit"
        if name.startswith("implicit") and "derived" in name:
            return "Language/Casting/ClassCast"
        if name.startswith("cast") or "derived" in name:
            return "Language/Casting/ClassCast"
        if name.startswith("implicit") or "numeric" in name or "unaryindex" in name:
            return "Language/Casting/NumericImplicit"
        if name.startswith("cast"):
            return "Language/Casting/ClassCast"
        return "Language/Casting/ClassCast"

    if theme == "Namespace":
        if "enum" in stem.lower():
            return "Language/Namespace/Enum"
        if "shadow" in stem.lower():
            return "Language/Namespace/Shadowing"
        if "global" in stem.lower() or "scoped" in stem.lower():
            return "Language/Namespace/GlobalVersusScoped"
        if "nested" in stem.lower():
            return "Language/Namespace/Nested"
        return "Language/Namespace/QualifiedName"

    if theme == "Const":
        return "Language/Syntax/Const"

    if theme == "Preprocessor":
        if kind == "Function":
            if stem in {
                "EditorConfigurationFlagBranch",
                "IfElifElseEndifBranches",
                "StringLiteralDoesNotTriggerDirectiveLexer",
                "PlainSourcePreprocessorRoundTrip",
            }:
                if "string" in stem.lower():
                    return "Language/Preprocessor/DirectiveInString"
                return "Language/Preprocessor/IfElifElse"
            return None
        name = stem.lower()
        if any(part in name for part in HOST_STEM_PARTS):
            return None
        if "string" in name:
            return "Language/Preprocessor/DirectiveInString"
        if name in {
            "namespacemissingopeningbrace",
            "includirectiveunsupported",
            "includirectiveunsupported",
        } or "include" in name:
            return "Language/Preprocessor/IfElifElse"
        if "endif" in name or "elif" in name or "ifdef" in name or "if" in name:
            return "Language/Preprocessor/IfElifElse"
        return None

    if theme == "Syntax":
        return map_syntax(stem, parts, kind)
    return None


def map_syntax(stem: str, parts: tuple[str, ...], kind: str) -> str | None:
    if has_host_stem(stem):
        return None
    if "Comments" in parts:
        return "Language/Syntax/Comments"
    if "Variable" in parts:
        return "Language/Syntax/Variables"
    if "Keywords" in parts:
        if "Mutate" in stem:
            return "Language/Syntax/StructConst"
        if "Const" in stem:
            return "Language/Syntax/Const"
        return None
    if "Reference" in parts:
        if "const" in stem.lower() and "parameter" not in stem.lower():
            return "Language/Syntax/Const"
        return "Language/Syntax/References"

    s = stem.lower()
    if "comment" in s:
        return "Language/Syntax/Comments"
    if s in {"emptyfunctionbodycompiles", "emptyvoidfunction", "functionwithoutbody"}:
        return "Language/Syntax/EmptyFunction"
    if s in {"intreturnfunction", "functionwithoutreturntype", "functionunknownreturntype"}:
        return "Language/Syntax/FunctionReturn"
    if "defaultparameter" in s or s in {
        "nondefaultparameterafterdefault",
        "defaulttypemismatch",
        "defaultoutsideclassscope",
    }:
        return "Language/Syntax/DefaultParameters"
    if "overload" in s or s in {"duplicatefunctionsignature", "voidoverloadset"}:
        return "Language/Syntax/Overload"
    if "namedargument" in s:
        return "Language/Syntax/NamedArguments"
    if "parameter" in s or s in {"referencewriteparameter", "functionunknownparametertype", "voidparametertype"}:
        return "Language/Syntax/Parameters"
    if s in {
        "basicscriptstruct",
        "structmemberdefaults",
        "anonymousstructcompiles",
        "structvoidmember",
        "structinvalidmembertype",
        "duplicatestructname",
        "structinheritance",
    }:
        return "Language/Syntax/StructFields"
    if "structconstructor" in s:
        return "Language/Syntax/StructConstructors"
    if "structconst" in s or s == "constmethodonstruct":
        return "Language/Syntax/StructConst"
    if "enum" in s or s in {"nonintegerenumerator", "methodinsideenum"}:
        return "Language/Syntax/Enum"
    if s.startswith("for") and "foreach" not in s:
        if "nested" in s or s == "forloopvariableescapesscope":
            return "Language/Syntax/ForNested"
        return "Language/Syntax/ForClauses"
    if s in {"primitiveandreferenceslocals", "scopevariables"}:
        return "Language/Syntax/Variables"
    if "const" in s:
        return "Language/Syntax/Const"
    if "reference" in s:
        return "Language/Syntax/References"
    if s in {
        "deeplynestedblocks",
        "deeplyparenthesizedaddition",
        "longchainedaddition",
        "multiplestatementsinonefunction",
        "shortcircuitskipsrighthandside",
        "unmatchedopeningbrace",
        "extraclosingbrace",
        "unmatchedparenthesis",
        "garbagetokens",
        "syntaxerrormissingsemicolon",
        "missingsemicolonbetweendeclarations",
        "toplevelassignment",
        "outofscopeuse",
    }:
        return "Language/Syntax/Blocks"
    return None


def strip_leading_comment(text: str) -> str:
    text = text.lstrip("\ufeff")
    if not text.startswith("/**"):
        return text
    end = text.find("*/")
    if end < 0:
        return text
    return text[end + 2 :].lstrip("\n")


def find_matching_brace(text: str, open_index: int) -> int:
    depth = 0
    i = open_index
    in_string = None
    while i < len(text):
        ch = text[i]
        if in_string:
            if ch == "\\":
                i += 2
                continue
            if ch == in_string:
                in_string = None
            i += 1
            continue
        if text.startswith("//", i):
            newline = text.find("\n", i)
            i = len(text) if newline < 0 else newline + 1
            continue
        if text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = len(text) if end < 0 else end + 2
            continue
        if ch in "\"'":
            in_string = ch
            i += 1
            continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def unwrap_namespace(text: str) -> str:
    match = re.match(r"namespace\s+\w+\s*\{", text)
    if not match:
        return text
    close = find_matching_brace(text, match.end() - 1)
    if close < 0:
        return text
    inner = text[match.end() : close]
    return unwrap_namespace(inner.strip("\n") + "\n")


def drop_doxygen(text: str) -> str:
    return re.sub(r"/\*\*.*?\*/\s*", "", text, flags=re.S)


def drop_ufunctions(text: str) -> str:
    out: list[str] = []
    i = 0
    while i < len(text):
        match = re.search(r"\bUFUNCTION\s*\(\s*\)", text[i:])
        if not match:
            out.append(text[i:])
            break
        start = i + match.start()
        out.append(text[i:start])
        after = i + match.end()
        brace = text.find("{", after)
        if brace < 0:
            break
        close = find_matching_brace(text, brace)
        if close < 0:
            break
        i = close + 1
        if i < len(text) and text[i] == "\n":
            i += 1
    return "".join(out)


def adapt_host_tokens(text: str) -> str:
    text = text.replace("FString", "string")
    text = re.sub(r"TArray\s*<", "array<", text)
    text = re.sub(r"\.Add\s*\(", ".insertLast(", text)
    return text


def leftover_host(text: str) -> str | None:
    for token in HOST_TOKENS:
        if token in text:
            return token
    return None


def normalize_body(text: str) -> str:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = text.replace("    ", "\t")
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = text.strip("\n") + "\n"
    return text


def extract_body(path: Path, kind: str) -> str | None:
    raw = path.read_text(encoding="utf-8")
    text = strip_leading_comment(raw)
    text = unwrap_namespace(text)
    text = drop_doxygen(text)
    text = drop_ufunctions(text)
    text = adapt_host_tokens(text)
    text = text.strip()
    if not text:
        return None
    host = leftover_host(text)
    if host:
        return None
    if kind == "Function" and not re.search(r"\b(void|int|int8|int16|int64|uint|uint8|uint16|uint64|bool|float|double|string|struct|class|enum)\b", text):
        return None
    return normalize_body(text)


def existing_versions(path: Path) -> set[str]:
    text = path.read_text(encoding="utf-8")
    return set(re.findall(r"^\s*\*\s*@version\s+(\S+)", text, re.M))


def version_block(tag: str, summary: str, topics: list[str], body: str) -> str:
    lines = [
        "/**\n",
        f" * @version {tag}\n",
        " * @parent root\n",
        f" * @summary {summary}\n",
    ]
    for topic in topics:
        lines.append(f" * @topic {topic}\n")
    lines.append(" */\n")
    if not body.endswith("\n"):
        body += "\n"
    lines.append(body)
    lines.append("/** @end */\n")
    return "".join(lines)


def summary_for(stem: str, kind: str) -> str:
    words = kebab(stem).replace("-", " ")
    if kind == "Reject":
        return f"Compile-rejection form retained from legacy {words}."
    return f"Positive language form retained from legacy {words}."


def authored_path(file_tag: str) -> Path:
    return LANG / f"{file_tag[len('Language/'):]}.as"


FOREACH_FILE = """/**
 * @version v1
 * @summary Foreach over a script iterable using the opFor protocol.
 * @topic Language
 * @topic ControlFlow
 */
/**
 * @version root
 * @summary Complete opForBegin/opForEnd/opForNext/opForValue range and a summing foreach.
 * @topic Baseline
 */
struct FIntRange
{
	int First;
	int Last;

	int opForBegin() const
	{
		return First;
	}

	bool opForEnd(int Iterator) const
	{
		return Iterator >= Last;
	}

	void opForNext(int& InOut Iterator) const
	{
		++Iterator;
	}

	int opForValue(int Iterator) const
	{
		return Iterator;
	}
}

int ForeachSum()
{
	FIntRange Values;
	Values.First = 1;
	Values.Last = 4;
	int Total = 0;
	for (int Value : Values)
	{
		Total += Value;
	}
	return Total;
}
/** @end */
/**
 * @version valid-foreach-break-continue
 * @parent root
 * @summary Foreach that skips the first value and breaks on a negative sentinel.
 * @topic ControlFlow
 */
struct FIntRange
{
	int First;
	int Last;

	int opForBegin() const
	{
		return First;
	}

	bool opForEnd(int Iterator) const
	{
		return Iterator >= Last;
	}

	void opForNext(int& InOut Iterator) const
	{
		++Iterator;
	}

	int opForValue(int Iterator) const
	{
		return Iterator;
	}
}

int ForeachBreakContinue()
{
	FIntRange Values;
	Values.First = 1;
	Values.Last = 6;
	int Total = 0;
	int Index = 0;
	for (int Value : Values)
	{
		++Index;
		if (Index == 1)
		{
			continue;
		}
		if (Value == 5)
		{
			break;
		}
		Total += Value;
	}
	return Total;
}
/** @end */
/**
 * @version valid-foreach-container-mutation
 * @parent root
 * @summary Foreach that writes through opForValue references into stored elements.
 * @topic ControlFlow
 */
struct FMutableRange
{
	int First = 1;
	int Second = 2;
	int Third = 3;

	int opForBegin() const
	{
		return 0;
	}

	bool opForEnd(int Iterator) const
	{
		return Iterator >= 3;
	}

	void opForNext(int& InOut Iterator) const
	{
		++Iterator;
	}

	int& opForValue(int Iterator)
	{
		if (Iterator == 0)
		{
			return First;
		}
		if (Iterator == 1)
		{
			return Second;
		}
		return Third;
	}
}

int ForeachMutate()
{
	FMutableRange Values;
	for (int& Value : Values)
	{
		Value *= 2;
	}
	int Total = 0;
	for (int Value : Values)
	{
		Total += Value;
	}
	return Total;
}
/** @end */
/**
 * @version valid-foreach-value-reference
 * @parent root
 * @summary Value, reference, and const-reference foreach variables over one range.
 * @topic ControlFlow
 */
struct FMutableRange
{
	int First = 10;
	int Second = 20;
	int Third = 30;

	int opForBegin() const
	{
		return 0;
	}

	bool opForEnd(int Iterator) const
	{
		return Iterator >= 3;
	}

	void opForNext(int& InOut Iterator) const
	{
		++Iterator;
	}

	int& opForValue(int Iterator)
	{
		if (Iterator == 0)
		{
			return First;
		}
		if (Iterator == 1)
		{
			return Second;
		}
		return Third;
	}
}

int ForeachByValue(FMutableRange Values)
{
	int Total = 0;
	for (int Value : Values)
	{
		Total += Value;
		Value = 0;
	}
	return Total;
}

int ForeachByReference(FMutableRange Values)
{
	for (int& Value : Values)
	{
		Value += 1;
	}
	int Total = 0;
	for (int Value : Values)
	{
		Total += Value;
	}
	return Total;
}

int ForeachByConstReference(FMutableRange Values)
{
	int Total = 0;
	for (const int& Value : Values)
	{
		Total += Value;
	}
	return Total;
}
/** @end */
/**
 * @version invalid-foreach-on-int
 * @parent root
 * @summary Foreach requires an iterable collection.
 * @topic Negative
 */
void Test()
{
	int Value = 1;
	for (int Item : Value)
	{
		Item = Item;
	}
}
/** @end */
/**
 * @version invalid-foreach-over-integer-literal
 * @parent root
 * @summary An integer literal is not a foreach range.
 * @topic Negative
 */
void Test()
{
	for (int Item : 3)
	{
		Item = Item;
	}
}
/** @end */
/**
 * @version invalid-foreach-missing-colon
 * @parent root
 * @summary Foreach header requires a colon before the range.
 * @topic Negative
 */
void Test()
{
	int Values = 0;
	for (int Item Values)
	{
		Item = Item;
	}
}
/** @end */
/**
 * @version invalid-foreach-element-type-mismatch
 * @parent root
 * @summary Foreach variable type must accept the range value.
 * @topic Negative
 */
struct FIntRange
{
	int First;
	int Last;

	int opForBegin() const
	{
		return First;
	}

	bool opForEnd(int Iterator) const
	{
		return Iterator >= Last;
	}

	void opForNext(int& InOut Iterator) const
	{
		++Iterator;
	}

	int opForValue(int Iterator) const
	{
		return Iterator;
	}
}

void Test()
{
	FIntRange Values;
	Values.First = 0;
	Values.Last = 2;
	for (bool Item : Values)
	{
		Item = Item;
	}
}
/** @end */
/**
 * @version invalid-foreach-over-string-literal
 * @parent root
 * @summary A string literal is not a foreach range.
 * @topic Negative
 */
void Test()
{
	for (int Item : "abc")
	{
		Item = Item;
	}
}
/** @end */
/**
 * @version invalid-foreach-missing-next
 * @parent root
 * @summary An iterable must declare opForNext.
 * @topic Negative
 */
struct FBrokenRange
{
	int opForBegin() const
	{
		return 0;
	}

	bool opForEnd(int Iterator) const
	{
		return Iterator >= 1;
	}

	int opForValue(int Iterator) const
	{
		return Iterator;
	}
}

void Test()
{
	FBrokenRange Values;
	for (int Item : Values)
	{
		Item = Item;
	}
}
/** @end */
"""


CURATED: dict[tuple[str, str], str] = {
    (
        "Language/Syntax/Parameters",
        "valid-int-family-value-parameters",
    ): """int8 AcceptInt8(int8 Amount)
{
	return Amount + 1;
}

int16 AcceptInt16(int16 Amount)
{
	return Amount + 100;
}

int AcceptInt(int Amount)
{
	return Amount * 2;
}

int64 AcceptInt64(int64 Amount)
{
	return Amount + 1000000;
}

uint8 AcceptUInt8(uint8 Amount)
{
	return Amount + 1;
}

uint16 AcceptUInt16(uint16 Amount)
{
	return Amount + 1000;
}

uint AcceptUInt(uint Amount)
{
	return Amount + 100;
}

uint64 AcceptUInt64(uint64 Amount)
{
	return Amount + 1000000000000;
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-int-family-out-parameters",
    ): """void WriteInt8(int8& Out Amount)
{
	Amount = 8;
}

void WriteInt(int& Out Amount)
{
	Amount = 42;
}

void WriteInt64(int64& Out Amount)
{
	Amount = 10000000000;
}

void WriteUInt(uint& Out Amount)
{
	Amount = 7;
}

int UseOuts()
{
	int8 Narrow = 0;
	int Wide = 0;
	int64 Big = 0;
	uint Unsigned = 0;
	WriteInt8(Narrow);
	WriteInt(Wide);
	WriteInt64(Big);
	WriteUInt(Unsigned);
	return Wide + int(Narrow);
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-int-family-inout-parameters",
    ): """void AddInt8(int8& InOut Amount)
{
	Amount += 1;
}

void AddInt(int& InOut Amount)
{
	Amount += 2;
}

void AddInt64(int64& InOut Amount)
{
	Amount += 3;
}

int UseInOuts()
{
	int8 Narrow = 1;
	int Wide = 10;
	int64 Big = 100;
	AddInt8(Narrow);
	AddInt(Wide);
	AddInt64(Big);
	return Wide + int(Narrow);
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-int-family-reference-in-parameters",
    ): """int8 ReadInt8(const int8& In Amount)
{
	return Amount;
}

int ReadInt(const int& In Amount)
{
	return Amount;
}

int64 ReadInt64(const int64& In Amount)
{
	return Amount;
}

int UseRefs()
{
	int8 Narrow = 2;
	int Wide = 4;
	int64 Big = 8;
	return ReadInt(Wide) + int(ReadInt8(Narrow));
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-bool-value-parameters",
    ): """bool Flip(bool Flag)
{
	return !Flag;
}

bool Keep(bool Flag)
{
	return Flag;
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-bool-out-parameter",
    ): """void SetTrue(bool& Out Flag)
{
	Flag = true;
}

bool UseOut()
{
	bool Flag = false;
	SetTrue(Flag);
	return Flag;
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-bool-inout-parameter",
    ): """void Toggle(bool& InOut Flag)
{
	Flag = !Flag;
}

bool UseInOut()
{
	bool Flag = false;
	Toggle(Flag);
	return Flag;
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-float-value-parameters",
    ): """float Scale(float Amount)
{
	return Amount * 2.0f;
}

double Widen(double Amount)
{
	return Amount + 1.0;
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-float-out-parameters",
    ): """void WriteFloat(float& Out Amount)
{
	Amount = 1.5f;
}

void WriteDouble(double& Out Amount)
{
	Amount = 2.5;
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-float-inout-parameters",
    ): """void AddFloat(float& InOut Amount)
{
	Amount += 0.5f;
}

void AddDouble(double& InOut Amount)
{
	Amount += 1.0;
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-script-quat-value-parameters",
    ): """struct FScriptQuat
{
	float X;
	float Y;
	float Z;
	float W;
}

FScriptQuat ScaleQuat(FScriptQuat Value)
{
	Value.X *= 2.0f;
	Value.Y *= 2.0f;
	Value.Z *= 2.0f;
	Value.W *= 2.0f;
	return Value;
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-script-quat-out-parameters",
    ): """struct FScriptQuat
{
	float X;
	float Y;
	float Z;
	float W;
}

void Identity(FScriptQuat& Out Value)
{
	Value.X = 0.0f;
	Value.Y = 0.0f;
	Value.Z = 0.0f;
	Value.W = 1.0f;
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-function-parameters-multiple-out",
    ): """void Split(int Amount, int& Out Left, int& Out Right)
{
	Left = Amount / 2;
	Right = Amount - Left;
}

int UseSplit()
{
	int Left = 0;
	int Right = 0;
	Split(9, Left, Right);
	return Left + Right;
}
""",
    (
        "Language/Syntax/Parameters",
        "valid-reference-write-parameter",
    ): """void WriteThrough(int& Amount)
{
	Amount = 11;
}

int UseRef()
{
	int Value = 0;
	WriteThrough(Value);
	return Value;
}
""",
    (
        "Language/ControlFlow/Return",
        "valid-function-return-integer-widths",
    ): """int8 Int8Return()
{
	return -42;
}

int16 Int16Return()
{
	return 30000;
}

int IntReturn()
{
	return 123456;
}

int64 Int64Return()
{
	return 10000000000;
}

uint8 UInt8Return()
{
	return 255;
}

uint16 UInt16Return()
{
	return 60000;
}

uint UIntReturn()
{
	return 3000000000;
}

uint64 UInt64Return()
{
	return 18000000000000000000;
}
""",
    (
        "Language/ControlFlow/Return",
        "valid-function-return-bool-values",
    ): """bool TrueReturn()
{
	return true;
}

bool FalseReturn()
{
	return false;
}
""",
    (
        "Language/ControlFlow/Return",
        "valid-function-return-float-values",
    ): """float FloatReturn()
{
	return 1.5f;
}

double DoubleReturn()
{
	return 2.25;
}
""",
    (
        "Language/ControlFlow/Return",
        "valid-return-float-as-int",
    ): """int ReturnFloatAsInt()
{
	float Amount = 3.9f;
	return int(Amount);
}
""",
    (
        "Language/ControlFlow/Return",
        "valid-script-quat-return",
    ): """struct FScriptQuat
{
	float X;
	float Y;
	float Z;
	float W;
}

FScriptQuat IdentityQuat()
{
	FScriptQuat Value;
	Value.X = 0.0f;
	Value.Y = 0.0f;
	Value.Z = 0.0f;
	Value.W = 1.0f;
	return Value;
}
""",
    (
        "Language/ControlFlow/Return",
        "valid-script-matrix-return",
    ): """struct FScriptMatrix
{
	float M00;
	float M01;
	float M10;
	float M11;
}

FScriptMatrix IdentityMatrix()
{
	FScriptMatrix Value;
	Value.M00 = 1.0f;
	Value.M01 = 0.0f;
	Value.M10 = 0.0f;
	Value.M11 = 1.0f;
	return Value;
}
""",
    (
        "Language/ControlFlow/Return",
        "valid-geometric-struct-parameters-and-returns",
    ): """struct FScriptVec
{
	float X;
	float Y;
}

FScriptVec Offset(FScriptVec Value, float Delta)
{
	Value.X += Delta;
	Value.Y += Delta;
	return Value;
}
""",
    (
        "Language/Casting/NumericImplicit",
        "valid-implicit-bool-to-int",
    ): """int ImplicitBoolToInt()
{
	bool Flag = true;
	int Value = Flag;
	return Value;
}
""",
    (
        "Language/Casting/NumericImplicit",
        "valid-implicit-int-to-float",
    ): """float ImplicitIntToFloat()
{
	int Value = 3;
	float Wide = Value;
	return Wide;
}
""",
    (
        "Language/Casting/NumericImplicit",
        "valid-implicit-float-to-int",
    ): """int ImplicitFloatToInt()
{
	float Value = 3.9f;
	int Narrow = Value;
	return Narrow;
}
""",
    (
        "Language/Casting/NumericImplicit",
        "valid-implicit-int-to-int64",
    ): """int64 ImplicitIntToInt64()
{
	int Value = 7;
	int64 Wide = Value;
	return Wide;
}
""",
    (
        "Language/Casting/NumericImplicit",
        "valid-implicit-int64-to-int",
    ): """int ImplicitInt64ToInt()
{
	int64 Value = 9;
	int Narrow = Value;
	return Narrow;
}
""",
    (
        "Language/Casting/NumericImplicit",
        "valid-implicit-uint8-to-int",
    ): """int ImplicitUint8ToInt()
{
	uint8 Value = 5;
	int Wide = Value;
	return Wide;
}
""",
    (
        "Language/Casting/NumericImplicit",
        "valid-implicit-float-to-uint8",
    ): """uint8 ImplicitFloatToUint8()
{
	float Value = 2.2f;
	uint8 Narrow = Value;
	return Narrow;
}
""",
    (
        "Language/Casting/NumericImplicit",
        "valid-implicit-literal-to-float",
    ): """float ImplicitLiteralToFloat()
{
	float Value = 4;
	return Value;
}
""",
    (
        "Language/Casting/NumericImplicit",
        "valid-numeric-enum-conversions",
    ): """enum ELane
{
	Low = 1,
	High = 4
}

int EnumToInt()
{
	ELane Lane = ELane::High;
	return int(Lane);
}

ELane IntToEnum()
{
	return ELane(1);
}
""",
    (
        "Language/Casting/NumericExplicit",
        "valid-explicit-float-to-int",
    ): """int ExplicitFloatToInt()
{
	return int(3.9f);
}
""",
    (
        "Language/Casting/NumericExplicit",
        "valid-explicit-int-to-float",
    ): """float ExplicitIntToFloat()
{
	return float(3);
}
""",
    (
        "Language/Casting/NumericExplicit",
        "valid-explicit-int-to-uint8",
    ): """uint8 ExplicitIntToUint8()
{
	return uint8(200);
}
""",
    (
        "Language/Casting/ClassCast",
        "valid-cast-downcast",
    ): """class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ADerived@ CastDowncast(ABase@ Parent)
{
	return cast<ADerived>(Parent);
}
""",
    (
        "Language/Casting/ClassCast",
        "valid-cast-to-parent-class",
    ): """class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ABase@ CastToParent(ADerived@ Child)
{
	return cast<ABase>(Child);
}
""",
    (
        "Language/Casting/ClassCast",
        "valid-implicit-derived-to-base",
    ): """class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ABase@ ImplicitDerivedToBase(ADerived@ Child)
{
	ABase@ Parent = Child;
	return Parent;
}
""",
    (
        "Language/Operators/Overload",
        "valid-fvec-add-overload",
    ): """struct FVecAdd
{
	int X = 0;
	int Y = 0;

	FVecAdd opAdd(const FVecAdd& In Other) const
	{
		FVecAdd Result;
		Result.X = X + Other.X;
		Result.Y = Y + Other.Y;
		return Result;
	}
}

int UseAdd()
{
	FVecAdd Left;
	Left.X = 1;
	Left.Y = 2;
	FVecAdd Right;
	Right.X = 3;
	Right.Y = 4;
	FVecAdd Sum = Left + Right;
	return Sum.X + Sum.Y;
}
""",
    (
        "Language/Operators/Overload",
        "valid-fvec-sub-overload",
    ): """struct FVecSub
{
	int X = 0;
	int Y = 0;

	FVecSub opSub(const FVecSub& In Other) const
	{
		FVecSub Result;
		Result.X = X - Other.X;
		Result.Y = Y - Other.Y;
		return Result;
	}
}

int UseSub()
{
	FVecSub Left;
	Left.X = 5;
	Left.Y = 4;
	FVecSub Right;
	Right.X = 1;
	Right.Y = 2;
	FVecSub Diff = Left - Right;
	return Diff.X + Diff.Y;
}
""",
    (
        "Language/Operators/Overload",
        "valid-fvec-mul-overload",
    ): """struct FVecMul
{
	int X = 0;
	int Y = 0;

	FVecMul opMul(int Scale) const
	{
		FVecMul Result;
		Result.X = X * Scale;
		Result.Y = Y * Scale;
		return Result;
	}
}

int UseMul()
{
	FVecMul Value;
	Value.X = 2;
	Value.Y = 3;
	FVecMul Scaled = Value * 4;
	return Scaled.X + Scaled.Y;
}
""",
    (
        "Language/Operators/Overload",
        "valid-fvec-neg-overload",
    ): """struct FVecNeg
{
	int X = 0;
	int Y = 0;

	FVecNeg opNeg() const
	{
		FVecNeg Result;
		Result.X = -X;
		Result.Y = -Y;
		return Result;
	}
}

int UseNeg()
{
	FVecNeg Value;
	Value.X = 2;
	Value.Y = 3;
	FVecNeg Flipped = -Value;
	return Flipped.X + Flipped.Y;
}
""",
    (
        "Language/Operators/Overload",
        "valid-fvec-equals-overload",
    ): """struct FVecEq
{
	int X = 0;
	int Y = 0;

	bool opEquals(const FVecEq& In Other) const
	{
		return X == Other.X && Y == Other.Y;
	}
}

int UseEquals()
{
	FVecEq Left;
	Left.X = 1;
	Left.Y = 2;
	FVecEq Right;
	Right.X = 1;
	Right.Y = 2;
	return Left == Right ? 1 : 0;
}
""",
    (
        "Language/Operators/Overload",
        "valid-fvec-add-assign-overload",
    ): """struct FVecAddAssign
{
	int X = 0;
	int Y = 0;

	FVecAddAssign& opAddAssign(const FVecAddAssign& In Other)
	{
		X += Other.X;
		Y += Other.Y;
		return this;
	}
}

int UseAddAssign()
{
	FVecAddAssign Left;
	Left.X = 1;
	Left.Y = 2;
	FVecAddAssign Right;
	Right.X = 3;
	Right.Y = 4;
	Left += Right;
	return Left.X + Left.Y;
}
""",
    (
        "Language/Syntax/Overload",
        "valid-bool-int-overload-resolution",
    ): """int Combine(bool Flag)
{
	return Flag ? 1 : 0;
}

int Combine(int Value)
{
	return Value;
}

int Pick()
{
	return Combine(true) + Combine(2);
}
""",
    (
        "Language/Syntax/Overload",
        "valid-float-double-overload-resolution",
    ): """int Combine(float Value)
{
	return int(Value);
}

int Combine(double Value)
{
	return int(Value * 10);
}

int Pick()
{
	return Combine(1.5f) + Combine(2.0);
}
""",
    (
        "Language/Syntax/Overload",
        "valid-int-width-overload-resolution",
    ): """int Combine(int8 Value)
{
	return int(Value);
}

int Combine(int64 Value)
{
	return int(Value / 10);
}

int Pick()
{
	int8 Narrow = 3;
	int64 Wide = 40;
	return Combine(Narrow) + Combine(Wide);
}
""",
    (
        "Language/Syntax/Overload",
        "valid-void-overload-set",
    ): """void Store(int Value)
{
	Value = Value;
}

void Store(int Left, int Right)
{
	int Total = Left + Right;
	Total = Total;
}
""",
    (
        "Language/Syntax/DefaultParameters",
        "valid-bool-default-parameters",
    ): """int WithBool(bool Flag = true)
{
	return Flag ? 1 : 0;
}

int CallDefault()
{
	return WithBool();
}
""",
    (
        "Language/Syntax/DefaultParameters",
        "valid-float-default-parameters",
    ): """float WithFloat(float Scale = 2.0f)
{
	return Scale * 3.0f;
}

float CallDefault()
{
	return WithFloat();
}
""",
    (
        "Language/Syntax/DefaultParameters",
        "valid-int-family-default-parameters",
    ): """int8 WithInt8(int8 Amount = 1)
{
	return Amount;
}

int WithInt(int Amount = 4)
{
	return Amount;
}

int64 WithInt64(int64 Amount = 8)
{
	return Amount;
}
""",
    (
        "Language/Syntax/Comments",
        "valid-single-line-comment",
    ): """// leading line comment
int Commented()
{
	return 1; // trailing
}
""",
    (
        "Language/Syntax/Comments",
        "valid-block-comment-before-function",
    ): """/* block before the function */
int Commented()
{
	return 1;
}
""",
    (
        "Language/Syntax/Comments",
        "valid-documentation-comment",
    ): """/** documents the helper */
int Documented()
{
	return 1;
}
""",
    (
        "Language/Syntax/Comments",
        "valid-inline-comment-inside-function",
    ): """int Commented()
{
	int Value = /* mid-expression */ 2;
	return Value;
}
""",
    (
        "Language/Syntax/Comments",
        "valid-multi-line-block-comment",
    ): """/*
 * several
 * lines
 */
int Commented()
{
	return 1;
}
""",
    (
        "Language/Syntax/ForClauses",
        "valid-for-basic-shapes",
    ): """int CountUp()
{
	int Total = 0;
	for (int Index = 0; Index < 3; ++Index)
	{
		Total += Index;
	}
	return Total;
}
""",
    (
        "Language/Syntax/ForClauses",
        "valid-for-comma-clauses",
    ): """int CountPair()
{
	int Total = 0;
	for (int Left = 0, Right = 3; Left < Right; ++Left, --Right)
	{
		Total += Left + Right;
	}
	return Total;
}
""",
    (
        "Language/Syntax/ForClauses",
        "valid-for-omitted-clauses",
    ): """int CountWhileStyle()
{
	int Index = 0;
	int Total = 0;
	for (; Index < 3; )
	{
		Total += Index;
		++Index;
	}
	return Total;
}
""",
    (
        "Language/ControlFlow/If",
        "valid-if-conditions",
    ): """int IfAnd(int Left, int Right)
{
	int Value = 0;
	if (Left > 0 && Right > 0)
	{
		Value = 1;
	}
	if (Left == 0 || Right == 0)
	{
		Value = 2;
	}
	return Value;
}
""",
    (
        "Language/ControlFlow/Switch",
        "valid-switch-basic",
    ): """int SwitchBasic(int Value)
{
	switch (Value)
	{
		case 1:
			return 10;
		case 2:
			return 20;
		default:
			return 0;
	}
}
""",
    (
        "Language/ControlFlow/Switch",
        "valid-switch-break",
    ): """int SwitchBreak(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result = 1;
			break;
		case 2:
			Result = 2;
			break;
		default:
			Result = 3;
			break;
	}
	return Result;
}
""",
    (
        "Language/ControlFlow/Switch",
        "valid-switch-enum",
    ): """enum ELane
{
	Low,
	High
}

int SwitchEnum(ELane Lane)
{
	switch (Lane)
	{
		case ELane::Low:
			return 1;
		case ELane::High:
			return 2;
	}
	return 0;
}
""",
    (
        "Language/ControlFlow/Switch",
        "valid-switch-integer-types",
    ): """int SwitchInt8(int8 Value)
{
	switch (Value)
	{
		case 1:
			return 1;
		default:
			return 0;
	}
}

int SwitchInt64(int64 Value)
{
	switch (Value)
	{
		case 10:
			return 10;
		default:
			return 0;
	}
}
""",
    (
        "Language/ControlFlow/LoopJump",
        "valid-break-in-loop",
    ): """int BreakInLoop()
{
	int Total = 0;
	for (int Index = 0; Index < 8; ++Index)
	{
		if (Index == 3)
		{
			break;
		}
		Total += Index;
	}
	return Total;
}
""",
    (
        "Language/ControlFlow/LoopJump",
        "valid-continue-in-loop",
    ): """int ContinueInLoop()
{
	int Total = 0;
	for (int Index = 0; Index < 5; ++Index)
	{
		if (Index == 2)
		{
			continue;
		}
		Total += Index;
	}
	return Total;
}
""",
}


def collect_old_files() -> list[Path]:
    return sorted(path for path in OLD.rglob("*.as") if path.is_file())


def planned_additions() -> list[tuple[str, str, str, list[str], str, Path | None]]:
    planned: list[tuple[str, str, str, list[str], str, Path | None]] = []
    seen: set[tuple[str, str]] = set()

    for path in collect_old_files():
        rel = path.relative_to(OLD)
        kind = harness_of(rel)
        file_tag = map_file_tag(rel)
        if file_tag is None:
            continue
        if kind == "Function" and rel.stem in ROOT_FUNCTION_STEMS:
            continue
        prefix = "invalid" if kind == "Reject" else "valid"
        tag = f"{prefix}-{kebab(rel.stem)}"
        if (file_tag, tag) in seen:
            continue
        body = extract_body(path, kind)
        if body is None:
            continue
        theme = file_tag.split("/")[1]
        topics = ["Negative"] if kind == "Reject" else [theme]
        if file_tag.startswith("Language/Preprocessor/"):
            topics.append("SourceOnly")
        planned.append((file_tag, tag, summary_for(rel.stem, kind), topics, body, path))
        seen.add((file_tag, tag))

    for (file_tag, tag), body in CURATED.items():
        if (file_tag, tag) in seen:
            continue
        theme = file_tag.split("/")[1]
        planned.append(
            (
                file_tag,
                tag,
                f"Authored language form for {tag[6:].replace('-', ' ')}.",
                [theme],
                normalize_body(body),
                None,
            )
        )
        seen.add((file_tag, tag))
    return planned


def parse_authored() -> None:
    sources = [source for source in discover_sources(REPO / "AngelscriptTestCode") if source.file_tag.startswith("Language/")]
    errors: list[str] = []
    version_total = 0
    for source in sources:
        try:
            parsed = parse_source_file(source)
        except CodegenError as exc:
            codes = ", ".join(item.code for item in exc.diagnostics)
            errors.append(f"{source.file_tag}: {codes}")
            continue
        version_total += len(parsed.versions)
    if errors:
        raise SystemExit("parse failed:\n" + "\n".join(errors))
    print(f"parsed files={len(sources)} versions={version_total}")


def apply(planned: list[tuple[str, str, str, list[str], str, Path | None]]) -> tuple[int, int]:
    authored = LANG / "ControlFlow" / "Foreach.as"
    authored.write_bytes(FOREACH_FILE.encode("utf-8"))

    existing_by_tag: dict[str, set[str]] = {}
    added = 0
    skipped = 0
    grouped: dict[str, list[tuple[str, str, list[str], str]]] = defaultdict(list)
    for file_tag, tag, summary, topics, body, _source in planned:
        grouped[file_tag].append((tag, summary, topics, body))

    for file_tag, items in grouped.items():
        path = authored_path(file_tag)
        if file_tag == "Language/ControlFlow/Foreach":
            existing = existing_versions(path)
            for tag, summary, topics, body in items:
                if tag in existing:
                    skipped += 1
                    continue
                path.write_bytes((path.read_text(encoding="utf-8") + version_block(tag, summary, topics, body)).encode("utf-8"))
                existing.add(tag)
                added += 1
            continue
        text = path.read_text(encoding="utf-8")
        existing = existing_versions(path)
        extra = []
        for tag, summary, topics, body in items:
            if tag in existing:
                skipped += 1
                continue
            extra.append(version_block(tag, summary, topics, body))
            existing.add(tag)
            added += 1
        if extra:
            if not text.endswith("\n"):
                text += "\n"
            path.write_bytes((text + "".join(extra)).encode("utf-8"))
        existing_by_tag[file_tag] = existing
    return added, skipped


def report(planned: list[tuple[str, str, str, list[str], str, Path | None]]) -> None:
    by_tag: dict[str, list[str]] = defaultdict(list)
    for file_tag, tag, _summary, _topics, _body, _source in planned:
        path = authored_path(file_tag)
        existing = existing_versions(path) if path.is_file() else set()
        if tag in existing and file_tag != "Language/ControlFlow/Foreach":
            continue
        by_tag[file_tag].append(tag)
    print(f"planned new-or-foreach versions={sum(len(v) for v in by_tag.values())} files={len(by_tag)}")
    for file_tag in sorted(by_tag):
        print(f"  {file_tag}: {len(by_tag[file_tag])}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    planned = planned_additions()
    report(planned)
    if not args.apply:
        print("dry-run only; pass --apply to write AngelscriptTestCode")
        return
    added, skipped = apply(planned)
    print(f"wrote added={added} skipped-existing={skipped}")
    parse_authored()


if __name__ == "__main__":
    main()
