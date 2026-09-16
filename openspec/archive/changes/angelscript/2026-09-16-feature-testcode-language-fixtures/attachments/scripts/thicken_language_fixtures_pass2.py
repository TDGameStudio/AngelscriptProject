"""Second pass: thicken remaining thin containers and leftover language rejects.

Run from the repository root:
    python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/thicken_language_fixtures_pass2.py --apply
"""
from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

REPO = next(p for p in Path(__file__).resolve().parents if (p / "AngelscriptTestCode").is_dir())
LANG = REPO / "AngelscriptTestCode" / "Language"
TOOL = REPO / "AngelscriptTestCode" / "CodeGenTool"
sys.path.insert(0, str(TOOL))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.discovery import discover_sources
from angelscript_test_codegen.model import CodegenError


def existing_versions(path: Path) -> set[str]:
    return set(re.findall(r"^\s*\*\s*@version\s+(\S+)", path.read_text(encoding="utf-8"), re.M))


def version_block(tag: str, summary: str, topics: list[str], body: str) -> str:
    lines = ["/**\n", f" * @version {tag}\n", " * @parent root\n", f" * @summary {summary}\n"]
    for topic in topics:
        lines.append(f" * @topic {topic}\n")
    lines.append(" */\n")
    if not body.endswith("\n"):
        body += "\n"
    lines.append(body)
    lines.append("/** @end */\n")
    return "".join(lines)


def authored_path(file_tag: str) -> Path:
    return LANG / f"{file_tag[len('Language/'):]}.as"


# (file_tag, version_tag, summary, topics, body)
CURATED: list[tuple[str, str, str, list[str], str]] = []


def add(file_tag: str, tag: str, summary: str, body: str, *, invalid: bool = False, extra: list[str] | None = None) -> None:
    theme = file_tag.split("/")[1]
    topics = ["Negative"] if invalid else [theme]
    if extra:
        topics.extend(extra)
    CURATED.append((file_tag, tag, summary, topics, body.strip("\n") + "\n"))


# --- thin ControlFlow ---
add(
    "Language/ControlFlow/IfElse",
    "valid-if-else-false-condition",
    "Else arm runs when the if condition is false.",
    """int IfElseFalse()
{
	if (false)
	{
		return 1;
	}
	else
	{
		return 2;
	}
}
""",
)
add(
    "Language/ControlFlow/IfElse",
    "valid-else-if-chain",
    "Else-if chain selects the middle test.",
    """int ElseIfChain(int Value)
{
	if (Value > 10)
	{
		return 1;
	}
	else if (Value > 3)
	{
		return 2;
	}
	else
	{
		return 3;
	}
}
""",
)
add(
    "Language/ControlFlow/IfElse",
    "valid-unbraced-if-else",
    "Unbraced if-else binds a single statement per arm.",
    """int UnbracedIfElse(bool Flag)
{
	int Value = 0;
	if (Flag)
		Value = 1;
	else
		Value = 2;
	return Value;
}
""",
)
add(
    "Language/ControlFlow/IfElse",
    "valid-compound-condition-if-else",
    "If-else with a conjunctive condition.",
    """int CompoundIfElse(int Left, int Right)
{
	if (Left > 0 && Right > 0)
	{
		return Left + Right;
	}
	else
	{
		return 0;
	}
}
""",
)
add(
    "Language/ControlFlow/IfElse",
    "invalid-else-if-without-if",
    "Else-if cannot start a statement.",
    """void Test()
{
	else if (true)
	{
		return;
	}
}
""",
    invalid=True,
)
add(
    "Language/ControlFlow/IfNested",
    "valid-if-nested-three-deep",
    "Three nested ifs all taking the true arm.",
    """int NestedThree(bool A, bool B, bool C)
{
	int Value = 0;
	if (A)
	{
		if (B)
		{
			if (C)
			{
				Value = 1;
			}
			else
			{
				Value = 2;
			}
		}
		else
		{
			Value = 3;
		}
	}
	return Value;
}
""",
)
add(
    "Language/ControlFlow/IfNested",
    "valid-if-nested-in-else",
    "Inner if lives only in the outer else arm.",
    """int NestedInElse(bool Outer, bool Inner)
{
	int Value = 0;
	if (Outer)
	{
		Value = 1;
	}
	else
	{
		if (Inner)
		{
			Value = 2;
		}
		else
		{
			Value = 3;
		}
	}
	return Value;
}
""",
)
add(
    "Language/ControlFlow/IfNested",
    "valid-if-nested-unbraced-inner",
    "Outer if contains an unbraced inner if.",
    """int NestedUnbraced(bool Outer, bool Inner)
{
	int Value = 0;
	if (Outer)
		if (Inner)
			Value = 1;
		else
			Value = 2;
	return Value;
}
""",
)
add(
    "Language/ControlFlow/IfNested",
    "invalid-if-missing-inner-condition",
    "A nested if still requires a condition.",
    """void Test(bool Outer)
{
	if (Outer)
	{
		if
		{
			return;
		}
	}
}
""",
    invalid=True,
)
add(
    "Language/ControlFlow/DoWhile",
    "valid-do-while-once",
    "Do-while body runs once when the condition is already false.",
    """int DoWhileOnce()
{
	int Value = 0;
	do
	{
		Value = 1;
	}
	while (false);
	return Value;
}
""",
)
add(
    "Language/ControlFlow/DoWhile",
    "valid-do-while-nested",
    "Inner do-while nested in an outer do-while.",
    """int DoWhileNested()
{
	int Total = 0;
	int Outer = 0;
	do
	{
		int Inner = 0;
		do
		{
			Total += 1;
			++Inner;
		}
		while (Inner < 2);
		++Outer;
	}
	while (Outer < 2);
	return Total;
}
""",
)
add(
    "Language/ControlFlow/DoWhile",
    "invalid-do-while-empty-condition",
    "Do-while condition cannot be empty.",
    """void Test()
{
	do
	{
	}
	while ();
}
""",
    invalid=True,
)
add(
    "Language/ControlFlow/DoWhile",
    "invalid-do-while-missing-parens",
    "Do-while condition must be parenthesized.",
    """void Test()
{
	do
	{
	}
	while true;
}
""",
    invalid=True,
)
add(
    "Language/ControlFlow/While",
    "valid-while-zero-iterations",
    "While body is skipped when the condition starts false.",
    """int WhileZero()
{
	int Value = 1;
	while (false)
	{
		Value = 0;
	}
	return Value;
}
""",
)
add(
    "Language/ControlFlow/While",
    "valid-while-nested",
    "Nested while loops accumulate a product of iterations.",
    """int WhileNested()
{
	int Total = 0;
	int Outer = 0;
	while (Outer < 2)
	{
		int Inner = 0;
		while (Inner < 3)
		{
			Total += 1;
			++Inner;
		}
		++Outer;
	}
	return Total;
}
""",
)
add(
    "Language/ControlFlow/If",
    "valid-bare-if-true",
    "Bare if with a true condition executes its body.",
    """int BareIf()
{
	if (true)
	{
		return 1;
	}
	return 0;
}
""",
)
add(
    "Language/ControlFlow/If",
    "valid-if-unbraced-body",
    "Unbraced if owns only the following statement.",
    """int UnbracedIf(bool Flag)
{
	int Value = 0;
	if (Flag)
		Value = 1;
	return Value;
}
""",
)

# --- thin Namespace / Operators / Syntax ---
add(
    "Language/Namespace/Shadowing",
    "valid-parameter-shadows-namespace",
    "A parameter name shadows a namespace function.",
    """namespace Game
{
	int Score()
	{
		return 10;
	}
}

int UseShadow(int Score)
{
	return Score + Game::Score();
}
""",
)
add(
    "Language/Namespace/Shadowing",
    "valid-inner-block-shadows-local",
    "An inner block local shadows an outer local.",
    """int InnerShadow()
{
	int Score = 1;
	{
		int Score = 2;
		return Score;
	}
}
""",
)
add(
    "Language/Namespace/Shadowing",
    "invalid-duplicate-in-same-namespace",
    "Two functions cannot share a name in one namespace.",
    """namespace Game
{
	int Score()
	{
		return 1;
	}

	int Score()
	{
		return 2;
	}
}
""",
    invalid=True,
)
add(
    "Language/Namespace/Enum",
    "valid-enum-qualified-from-nested-namespace",
    "Enum enumerator accessed through a nested qualifier.",
    """namespace Game
{
	namespace Mode
	{
		enum ELane
		{
			Low,
			High
		}
	}
}

int UseLane()
{
	Game::Mode::ELane Lane = Game::Mode::ELane::High;
	return int(Lane);
}
""",
)
add(
    "Language/Namespace/Enum",
    "invalid-enum-missing-qualifier",
    "A namespaced enumerator is not visible without its qualifier.",
    """namespace Game
{
	enum ELane
	{
		Low
	}
}

void Test()
{
	ELane Lane = Low;
}
""",
    invalid=True,
)
add(
    "Language/Operators/Precedence",
    "valid-arithmetic-before-comparison",
    "Addition binds before equality comparison.",
    """bool ArithmeticBeforeComparison()
{
	return (1 + 2 == 3);
}
""",
)
add(
    "Language/Operators/Precedence",
    "valid-comparison-before-logical",
    "Comparisons bind before logical and.",
    """bool ComparisonBeforeLogical()
{
	return (1 < 2 && 3 < 4);
}
""",
)
add(
    "Language/Operators/Precedence",
    "valid-bitwise-before-comparison",
    "Bitwise and binds before equality.",
    """bool BitwiseBeforeComparison()
{
	return ((0xFF & 0x0F) == 0x0F);
}
""",
)
add(
    "Language/Operators/Precedence",
    "valid-ternary-inside-arithmetic",
    "A parenthesized ternary resolves before surrounding addition.",
    """int TernaryInsideAdd()
{
	return 1 + (true ? 2 : 3);
}
""",
)
add(
    "Language/Operators/Precedence",
    "valid-and-versus-or",
    "Logical and binds tighter than logical or.",
    """bool AndBeforeOr()
{
	return (false || true && false);
}
""",
)
add(
    "Language/Operators/ExpressionEdges",
    "valid-unary-minus-versus-subtract",
    "Unary minus on the right operand of subtraction.",
    """int UnaryMinusRight()
{
	int Value = 5;
	return 3 - -Value;
}
""",
)
add(
    "Language/Operators/ExpressionEdges",
    "valid-deeply-nested-parens",
    "Eight nested parenthesis pairs around an addition.",
    """int DeepParens()
{
	return ((((((((1 + 2))))))));
}
""",
)
add(
    "Language/Operators/ExpressionEdges",
    "invalid-extra-closing-paren",
    "An extra closing parenthesis is invalid.",
    """int Test()
{
	return (1 + 2));
}
""",
    invalid=True,
)
add(
    "Language/Operators/ExpressionEdges",
    "invalid-empty-call-on-int",
    "An integer cannot be called.",
    """void Test()
{
	int Value = 1;
	Value();
}
""",
    invalid=True,
)
add(
    "Language/Syntax/EmptyFunction",
    "valid-empty-void-no-statements",
    "A void function whose body contains no statements.",
    """void Empty()
{
}
""",
)
add(
    "Language/Syntax/EmptyFunction",
    "valid-empty-inner-block",
    "A function whose only statement is an empty block.",
    """void EmptyBlock()
{
	{
	}
}
""",
)
add(
    "Language/Syntax/EmptyFunction",
    "invalid-function-missing-braces",
    "A function body cannot be a bare semicolon.",
    """void MissingBraces();
int Test()
{
	return 0
}
""",
    invalid=True,
)
add(
    "Language/Syntax/StructConstructors",
    "valid-default-constructor-only",
    "A struct with only a default constructor.",
    """struct FOrigin
{
	int X;
	int Y;

	FOrigin()
	{
		X = 0;
		Y = 0;
	}
}

int UseDefault()
{
	FOrigin Value;
	return Value.X + Value.Y;
}
""",
)
add(
    "Language/Syntax/StructConstructors",
    "valid-constructor-overload-set",
    "Default and one-argument constructors on one struct.",
    """struct FScale
{
	int Amount;

	FScale()
	{
		Amount = 1;
	}

	FScale(int InAmount)
	{
		Amount = InAmount;
	}
}

int UseBoth()
{
	FScale Defaulted;
	FScale Explicit(4);
	return Defaulted.Amount + Explicit.Amount;
}
""",
)
add(
    "Language/Syntax/StructConstructors",
    "invalid-constructor-unknown-arg-type",
    "Constructor parameter type must exist.",
    """struct FPoint
{
	int X;

	FPoint(MissingType Value)
	{
		X = 0;
	}
}
""",
    invalid=True,
)
add(
    "Language/Syntax/StructConstructors",
    "invalid-constructor-on-primitive",
    "A primitive cannot be constructed with a user constructor call shape.",
    """void Test()
{
	int Value(1, 2);
}
""",
    invalid=True,
)
add(
    "Language/Syntax/ForNested",
    "valid-for-nested-three-deep",
    "Three nested for loops accumulate a product of trip counts.",
    """int NestedThree()
{
	int Total = 0;
	for (int A = 0; A < 2; ++A)
	{
		for (int B = 0; B < 2; ++B)
		{
			for (int C = 0; C < 2; ++C)
			{
				Total += 1;
			}
		}
	}
	return Total;
}
""",
)
add(
    "Language/Syntax/ForNested",
    "valid-for-nested-with-break",
    "Inner for break leaves the outer loop running.",
    """int NestedBreak()
{
	int Total = 0;
	for (int Outer = 0; Outer < 3; ++Outer)
	{
		for (int Inner = 0; Inner < 5; ++Inner)
		{
			if (Inner == 1)
			{
				break;
			}
			Total += 1;
		}
	}
	return Total;
}
""",
)
add(
    "Language/Syntax/References",
    "valid-ref-to-local",
    "A reference parameter writes through a local.",
    """void Write(int& Amount)
{
	Amount = 9;
}

int UseRef()
{
	int Value = 0;
	Write(Value);
	return Value;
}
""",
)
add(
    "Language/Syntax/References",
    "valid-ref-inout-chain",
    "Two inout references update the same local in sequence.",
    """void AddOne(int& InOut Amount)
{
	Amount += 1;
}

void AddTwo(int& InOut Amount)
{
	Amount += 2;
}

int UseChain()
{
	int Value = 0;
	AddOne(Value);
	AddTwo(Value);
	return Value;
}
""",
)
add(
    "Language/Syntax/References",
    "invalid-ref-to-const-then-write",
    "A const reference cannot be written.",
    """void Test()
{
	const int Value = 1;
	int& Written = Value;
	Written = 2;
}
""",
    invalid=True,
)
add(
    "Language/Syntax/FunctionReturn",
    "valid-int-return-function",
    "A function whose only job is to return an integer literal.",
    """int Answer()
{
	return 42;
}
""",
)
add(
    "Language/Syntax/FunctionReturn",
    "invalid-return-missing-semicolon",
    "A return expression must end with a semicolon.",
    """int Test()
{
	return 1
}
""",
    invalid=True,
)

# --- Preprocessor ---
add(
    "Language/Preprocessor/IfElifElse",
    "valid-if-elif-endif-no-else",
    "If/elif/endif chain without an else arm.",
    """int Entry()
{
#if FIRST
	return 1;
#elif SECOND
	return 2;
#endif
	return 0;
}
""",
    extra=["SourceOnly"],
)
add(
    "Language/Preprocessor/IfElifElse",
    "valid-nested-if-directives",
    "An inner #if nested inside an outer #if/#endif.",
    """int Entry()
{
#if OUTER
#if INNER
	return 1;
#endif
	return 2;
#else
	return 0;
#endif
}
""",
    extra=["SourceOnly"],
)
add(
    "Language/Preprocessor/IfElifElse",
    "valid-if-zero-dead-branch",
    "A #if 0 branch is source text that is not selected.",
    """int Entry()
{
#if 0
	return 1;
#else
	return 0;
#endif
}
""",
    extra=["SourceOnly"],
)
add(
    "Language/Preprocessor/IfElifElse",
    "invalid-elif-without-if",
    "Elif cannot appear without an open if.",
    """int Test()
{
#elif FLAG
	return 1;
#endif
	return 0;
}
""",
    invalid=True,
    extra=["SourceOnly"],
)
add(
    "Language/Preprocessor/IfElifElse",
    "invalid-endif-without-if",
    "Endif cannot appear without an open if.",
    """int Test()
{
#endif
	return 0;
}
""",
    invalid=True,
    extra=["SourceOnly"],
)
add(
    "Language/Preprocessor/DirectiveInString",
    "valid-endif-in-string",
    "Endif text inside quotes is not a directive.",
    """int Count()
{
	string Text = "#endif";
	return Text.length();
}
""",
    extra=["SourceOnly"],
)
add(
    "Language/Preprocessor/DirectiveInString",
    "valid-if-in-line-comment",
    "A line comment may contain #if text.",
    """int Count()
{
	// #if 0 this is a comment
	return 1;
}
""",
    extra=["SourceOnly"],
)
add(
    "Language/Preprocessor/DirectiveInString",
    "valid-if-in-block-comment",
    "A block comment may contain #endif text.",
    """int Count()
{
	/* #endif */
	return 1;
}
""",
    extra=["SourceOnly"],
)
add(
    "Language/Preprocessor/DirectiveInString",
    "invalid-include-directive",
    "Include is not a supported source directive in this corpus.",
    """#include "Missing.as"
int Test()
{
	return 1;
}
""",
    invalid=True,
    extra=["SourceOnly"],
)

# --- leftover Casting rejects / nullptr positives ---
add(
    "Language/Casting/Nullptr",
    "valid-cast-nullptr-is-null",
    "Casting a null handle yields null.",
    """class ANode
{
	int Value;
}

bool CastNull()
{
	ANode@ Node = null;
	return cast<ANode>(Node) is null;
}
""",
)
add(
    "Language/Casting/Nullptr",
    "valid-nullptr-comparison",
    "is-null and not-is-null on a handle.",
    """class ANode
{
	int Value;
}

bool Compare(ANode@ Node)
{
	return Node is null || Node !is null;
}
""",
)
add(
    "Language/Casting/Nullptr",
    "invalid-nullptr-to-struct",
    "A script struct value cannot be assigned null.",
    """struct FBox
{
	int X;
}

void Test()
{
	FBox Value = null;
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-cast-on-primitive",
    "Handle cast cannot target a primitive value.",
    """void Test()
{
	int Value = 5;
	int Casted = cast<int>(Value);
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-implicit-base-to-derived",
    "A base handle cannot convert implicitly to derived.",
    """class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

void TakeDerived(ADerived@ Child)
{
	Child = Child;
}

void Test(ABase@ Parent)
{
	TakeDerived(Parent);
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-cast-to-undeclared-class",
    "Cast target class must be declared.",
    """class ABase
{
	int Id;
}

void Test(ABase@ Parent)
{
	AMissing@ Child = cast<AMissing>(Parent);
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-cast-to-struct",
    "Handle cast cannot target a struct.",
    """struct FBox
{
	int X;
}

class ANode
{
	int Value;
}

void Test(ANode@ Node)
{
	FBox Value = cast<FBox>(Node);
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-cast-to-enum",
    "Handle cast cannot target an enum.",
    """enum ELane
{
	Low
}

class ANode
{
	int Value;
}

void Test(ANode@ Node)
{
	ELane Lane = cast<ELane>(Node);
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-cast-without-argument",
    "Cast requires a value argument.",
    """class ANode
{
	int Value;
}

void Test()
{
	ANode@ Node = cast<ANode>();
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-cast-with-two-arguments",
    "Cast takes one value argument.",
    """class ANode
{
	int Value;
}

void Test(ANode@ Left, ANode@ Right)
{
	ANode@ Node = cast<ANode>(Left, Right);
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-class-without-name",
    "A class declaration requires a name.",
    """class
{
	int Value;
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-class-without-braces",
    "A class declaration requires a body.",
    """class ANode;
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-class-self-inheritance",
    "A class cannot inherit from itself.",
    """class ANode : ANode
{
	int Value;
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-duplicate-class-name",
    "Two classes cannot share a name.",
    """class ANode
{
	int X;
}

class ANode
{
	int Y;
}
""",
    invalid=True,
)
add(
    "Language/Casting/NumericImplicit",
    "invalid-implicit-int-to-bool",
    "An integer cannot convert implicitly to bool.",
    """void Test()
{
	int Value = 1;
	bool Flag = Value;
}
""",
    invalid=True,
)
add(
    "Language/Casting/NumericImplicit",
    "invalid-implicit-string-to-int",
    "A string cannot convert implicitly to int.",
    """void Test()
{
	string Text = "1";
	int Value = Text;
}
""",
    invalid=True,
)
add(
    "Language/Casting/NumericImplicit",
    "invalid-implicit-array-to-int",
    "An array cannot convert implicitly to int.",
    """void Test()
{
	array<int> Values;
	int Value = Values;
}
""",
    invalid=True,
)

# --- language string forms folded into existing tags ---
add(
    "Language/Syntax/Variables",
    "valid-string-literal-assignment",
    "A string local assigned from a literal.",
    """string Literal()
{
	string Text = "Hello World";
	return Text;
}
""",
)
add(
    "Language/Syntax/Variables",
    "valid-empty-string-literal",
    "An empty string literal assigned to a local.",
    """string Empty()
{
	string Text = "";
	return Text;
}
""",
)
add(
    "Language/Syntax/Variables",
    "valid-string-escape-sequences",
    "Newline, tab, quote, and backslash escapes in a string literal.",
    """string Escapes()
{
	return "Line1\\nLine2\\t\\"\\\\";
}
""",
)
add(
    "Language/Syntax/Variables",
    "invalid-unterminated-string-literal",
    "A string literal must close on the same line.",
    """void Test()
{
	string Text = "unterminated;
}
""",
    invalid=True,
)
add(
    "Language/Operators/Arithmetic",
    "valid-string-concatenation-plus",
    "String concatenation with plus.",
    """string Concat()
{
	return "Hello" + " " + "World";
}
""",
)
add(
    "Language/Operators/Arithmetic",
    "invalid-string-subtraction",
    "Strings cannot use minus.",
    """void Test()
{
	string Text = "ab" - "b";
}
""",
    invalid=True,
)
add(
    "Language/Operators/Arithmetic",
    "invalid-string-multiplication",
    "Strings cannot use times.",
    """void Test()
{
	string Text = "ab" * 2;
}
""",
    invalid=True,
)
add(
    "Language/Operators/Arithmetic",
    "invalid-string-division",
    "Strings cannot use divide.",
    """void Test()
{
	string Text = "ab" / 2;
}
""",
    invalid=True,
)
add(
    "Language/Operators/Assignment",
    "valid-string-concatenation-plus-assign",
    "Plus-assign concatenates onto a string local.",
    """string ConcatAssign()
{
	string Text = "Hello";
	Text += " World";
	return Text;
}
""",
)
add(
    "Language/Operators/Comparison",
    "valid-string-equality-operator",
    "String equality and inequality.",
    """bool Equal()
{
	return "a" == "a";
}

bool Unequal()
{
	return "a" != "b";
}
""",
)
add(
    "Language/Operators/Comparison",
    "invalid-string-compared-to-int",
    "A string cannot be compared to an integer.",
    """void Test()
{
	bool Result = "1" == 1;
}
""",
    invalid=True,
)
add(
    "Language/Syntax/Parameters",
    "valid-string-value-parameters",
    "A string received by value.",
    """string Prefix(string Text)
{
	return "[" + Text + "]";
}
""",
)
add(
    "Language/Syntax/Parameters",
    "valid-string-in-parameter",
    "A const-in string parameter.",
    """int LengthOf(const string& In Text)
{
	return Text.length();
}
""",
)
add(
    "Language/Syntax/Parameters",
    "valid-string-out-parameter",
    "A string written through an out parameter.",
    """void WriteHello(string& Out Text)
{
	Text = "Hello";
}
""",
)
add(
    "Language/Syntax/Parameters",
    "valid-string-inout-parameter",
    "A string updated through an inout parameter.",
    """void AppendMark(string& InOut Text)
{
	Text += "!";
}
""",
)
add(
    "Language/ControlFlow/Return",
    "valid-string-function-return",
    "A function that returns a string literal.",
    """string Message()
{
	return "ok";
}
""",
)
add(
    "Language/Syntax/DefaultParameters",
    "valid-string-default-parameter",
    "A trailing string parameter with a default literal.",
    """string Label(string Text = "none")
{
	return Text;
}
""",
)
add(
    "Language/Syntax/Overload",
    "valid-string-function-overloading",
    "Overloads distinguished by string versus int.",
    """int Describe(string Text)
{
	return Text.length();
}

int Describe(int Value)
{
	return Value;
}
""",
)
add(
    "Language/Syntax/Const",
    "valid-const-string-local",
    "A const string local cannot be rebound.",
    """string Read()
{
	const string Text = "fixed";
	return Text;
}
""",
)
add(
    "Language/Syntax/Const",
    "invalid-this-outside-class",
    "This is invalid outside a class or struct method.",
    """void Test()
{
	int Value = this;
}
""",
    invalid=True,
)
add(
    "Language/Casting/ClassCast",
    "invalid-super-outside-class",
    "Super is invalid outside a derived type.",
    """void Test()
{
	super.Value = 1;
}
""",
    invalid=True,
)
add(
    "Language/Syntax/Blocks",
    "invalid-syntax-error-missing-semicolon",
    "Adjacent declarations require a semicolon.",
    """void Test()
{
	int Left = 1
	int Right = 2;
}
""",
    invalid=True,
)
add(
    "Language/Operators/Logical",
    "valid-short-circuit-and",
    "Logical and skips the right operand when the left is false.",
    """int Probe()
{
	int Value = 0;
	bool Result = (false && (Value = 1) == 1);
	return Result ? Value : 0;
}
""",
)
add(
    "Language/Operators/Logical",
    "valid-short-circuit-or",
    "Logical or skips the right operand when the left is true.",
    """int Probe()
{
	int Value = 0;
	bool Result = (true || (Value = 1) == 1);
	return Result ? 1 : Value;
}
""",
)
add(
    "Language/Operators/Ternary",
    "valid-nested-ternary",
    "A ternary nested in both arms of an outer ternary.",
    """int Nested(int Value)
{
	return Value > 0 ? (Value > 10 ? 2 : 1) : 0;
}
""",
)
add(
    "Language/Operators/Ternary",
    "valid-ternary-as-return",
    "A function whose body is a single ternary return.",
    """int Sign(int Value)
{
	return Value < 0 ? -1 : Value == 0 ? 0 : 1;
}
""",
)
add(
    "Language/Syntax/NamedArguments",
    "valid-named-arguments-all-named",
    "A call that names every argument.",
    """int Combine(int Left, int Right)
{
	return Left + Right;
}

int CallNamed()
{
	return Combine(Left = 2, Right = 3);
}
""",
)
add(
    "Language/Syntax/NamedArguments",
    "valid-named-arguments-trailing-only",
    "A call that names only the trailing argument.",
    """int Combine(int Left, int Right)
{
	return Left + Right;
}

int CallPartial()
{
	return Combine(2, Right = 3);
}
""",
)
add(
    "Language/Syntax/Comments",
    "valid-comment-in-string-is-literal",
    "Comment markers inside a string remain payload.",
    """string Text()
{
	return "/* not a comment */ // still a string";
}
""",
)
add(
    "Language/Namespace/QualifiedName",
    "valid-multi-segment-qualifier",
    "A three-segment qualified function call.",
    """namespace Game
{
	namespace Combat
	{
		int Hit()
		{
			return 4;
		}
	}
}

int Use()
{
	return Game::Combat::Hit();
}
""",
)
add(
    "Language/Namespace/Nested",
    "invalid-namespace-missing-opening-brace",
    "A namespace declaration requires an opening brace.",
    """namespace Game
	int Score()
	{
		return 1;
	}
}
""",
    invalid=True,
)
add(
    "Language/Syntax/Enum",
    "valid-enum-trailing-comma",
    "An enumerator list that ends with a trailing comma.",
    """enum ELane
{
	Low,
	High,
}

int Use()
{
	return int(ELane::High);
}
""",
)
add(
    "Language/Syntax/StructFields",
    "valid-struct-empty-body",
    "A struct with no members.",
    """struct FEmpty
{
}

int Use()
{
	FEmpty Value;
	return 0;
}
""",
)
add(
    "Language/Syntax/StructConst",
    "valid-const-method-on-struct",
    "A const method that only reads members.",
    """struct FPoint
{
	int X;
	int Y;

	int Sum() const
	{
		return X + Y;
	}
}
""",
)
add(
    "Language/ControlFlow/Switch",
    "valid-switch-fallthrough-to-default",
    "A case without break falls into default.",
    """int Fall(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result = 1;
		default:
			Result += 10;
			break;
	}
	return Result;
}
""",
)
add(
    "Language/ControlFlow/LoopJump",
    "valid-break-in-nested-loop",
    "Break leaves only the inner loop.",
    """int NestedBreak()
{
	int Total = 0;
	for (int Outer = 0; Outer < 3; ++Outer)
	{
		for (int Inner = 0; Inner < 3; ++Inner)
		{
			if (Inner == 1)
			{
				break;
			}
			Total += 1;
		}
	}
	return Total;
}
""",
)
add(
    "Language/ControlFlow/LoopJump",
    "valid-continue-in-nested-loop",
    "Continue skips the rest of the inner iteration.",
    """int NestedContinue()
{
	int Total = 0;
	for (int Outer = 0; Outer < 2; ++Outer)
	{
		for (int Inner = 0; Inner < 3; ++Inner)
		{
			if (Inner == 1)
			{
				continue;
			}
			Total += Inner;
		}
	}
	return Total;
}
""",
)
add(
    "Language/ControlFlow/Foreach",
    "valid-foreach-empty-range",
    "Foreach over an empty opFor range visits nothing.",
    """struct FEmptyRange
{
	int opForBegin() const
	{
		return 0;
	}

	bool opForEnd(int Iterator) const
	{
		return true;
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

int ForeachEmpty()
{
	FEmptyRange Values;
	int Total = 0;
	for (int Value : Values)
	{
		Total += Value;
	}
	return Total;
}
""",
)
add(
    "Language/ControlFlow/Foreach",
    "invalid-foreach-missing-begin",
    "An iterable must declare opForBegin.",
    """struct FBrokenRange
{
	bool opForEnd(int Iterator) const
	{
		return Iterator >= 1;
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
	FBrokenRange Values;
	for (int Item : Values)
	{
		Item = Item;
	}
}
""",
    invalid=True,
)
add(
    "Language/ControlFlow/Foreach",
    "invalid-foreach-missing-value",
    "An iterable must declare opForValue.",
    """struct FBrokenRange
{
	int opForBegin() const
	{
		return 0;
	}

	bool opForEnd(int Iterator) const
	{
		return Iterator >= 1;
	}

	void opForNext(int& InOut Iterator) const
	{
		++Iterator;
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
""",
    invalid=True,
)
add(
    "Language/Operators/Overload",
    "valid-op-index-read-write",
    "A value type with opIndex used on both sides of assignment.",
    """struct FCells
{
	int First;
	int Second;

	int& opIndex(int Index)
	{
		if (Index == 0)
		{
			return First;
		}
		return Second;
	}
}

int UseIndex()
{
	FCells Cells;
	Cells[0] = 3;
	Cells[1] = 4;
	return Cells[0] + Cells[1];
}
""",
)
add(
    "Language/Operators/Bitwise",
    "valid-bitmask-protocol",
    "Mask, shift, and complementary bit forms on one integer.",
    """int MaskLowNibble(int Value)
{
	return Value & 0x0F;
}

int ShiftIntoPlace(int Value)
{
	return (Value << 4) | MaskLowNibble(Value);
}

int ClearBit(int Value)
{
	return Value & ~1;
}
""",
)
add(
    "Language/Operators/DefiniteAssignment",
    "valid-assigned-on-all-returns",
    "A local is assigned on every return path before it is read.",
    """int AllPaths(bool Flag)
{
	int Value;
	if (Flag)
	{
		Value = 1;
	}
	else
	{
		Value = 2;
	}
	return Value;
}
""",
)
add(
    "Language/Syntax/ForClauses",
    "valid-for-infinite-with-break",
    "A for with omitted clauses that exits by break.",
    """int UntilThree()
{
	int Index = 0;
	for (;;)
	{
		if (Index == 3)
		{
			break;
		}
		++Index;
	}
	return Index;
}
""",
)


def apply() -> tuple[int, int]:
    grouped: dict[str, list[tuple[str, str, list[str], str]]] = defaultdict(list)
    for file_tag, tag, summary, topics, body in CURATED:
        grouped[file_tag].append((tag, summary, topics, body))
    added = 0
    skipped = 0
    for file_tag, items in grouped.items():
        path = authored_path(file_tag)
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
    return added, skipped


def parse_authored() -> tuple[int, int, int]:
    errors: list[str] = []
    total = valids = invalids = 0
    for source in discover_sources(REPO / "AngelscriptTestCode"):
        if not source.file_tag.startswith("Language/"):
            continue
        try:
            parsed = parse_source_file(source)
        except CodegenError as exc:
            errors.append(source.file_tag + ": " + ", ".join(item.code for item in exc.diagnostics))
            continue
        total += len(parsed.versions)
        for version in parsed.versions:
            if version.tag.startswith("valid-"):
                valids += 1
            elif version.tag.startswith("invalid-"):
                invalids += 1
    if errors:
        raise SystemExit("parse failed:\n" + "\n".join(errors))
    return total, valids, invalids


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    print(f"planned versions={len(CURATED)}")
    if not args.apply:
        print("dry-run only; pass --apply to write AngelscriptTestCode")
        return
    added, skipped = apply()
    total, valids, invalids = parse_authored()
    print(f"wrote added={added} skipped-existing={skipped}")
    print(f"parsed files=47 versions={total} valid_star={valids} invalid={invalids}")


if __name__ == "__main__":
    main()
