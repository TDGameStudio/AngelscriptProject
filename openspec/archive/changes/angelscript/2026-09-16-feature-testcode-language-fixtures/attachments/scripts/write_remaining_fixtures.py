"""Write remaining Language fixture containers. Run from the repository root."""
from __future__ import annotations

from pathlib import Path

ROOT = next(p for p in Path(__file__).resolve().parents if (p / "AngelscriptTestCode").is_dir())
LANG = ROOT / "AngelscriptTestCode" / "Language"


def container(file_summary: str, theme: str, versions: list[tuple[str, str | None, str, list[str], str]]) -> str:
    parts = [
        "/**\n",
        " * @version v1\n",
        f" * @summary {file_summary}\n",
        " * @topic Language\n",
        f" * @topic {theme}\n",
        " */\n",
    ]
    for tag, parent, summary, topics, body in versions:
        parts.append("/**\n")
        parts.append(f" * @version {tag}\n")
        if parent is not None:
            parts.append(f" * @parent {parent}\n")
        parts.append(f" * @summary {summary}\n")
        for topic in topics:
            parts.append(f" * @topic {topic}\n")
        parts.append(" */\n")
        if not body.endswith("\n"):
            body += "\n"
        parts.append(body)
        parts.append("/** @end */\n")
    return "".join(parts)


def write(rel: str, text: str) -> None:
    path = LANG / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    data = text.encode("utf-8")
    if data.startswith(b"\xef\xbb\xbf"):
        raise SystemExit(f"BOM forbidden: {rel}")
    if b"\r" in data:
        raise SystemExit(f"CR forbidden: {rel}")
    path.write_bytes(data)
    print(rel)


FILES: dict[str, str] = {}

FILES["Operators/Assignment.as"] = container(
    "Assignment and compound assignment forms without observation wrappers.",
    "Operators",
    [
        (
            "root",
            None,
            "Plain assignment plus arithmetic, bitwise, and shift compound assignments.",
            ["Baseline"],
            """int SimpleAssign()
{
	int X = 0;
	X = 5;
	return X;
}

int AddAssign()
{
	int X = 0;
	X += 5;
	return X;
}

int SubAssign()
{
	int X = 10;
	X -= 3;
	return X;
}

int MulAssign()
{
	int X = 2;
	X *= 3;
	return X;
}

int DivAssign()
{
	int X = 10;
	X /= 2;
	return X;
}

int ModAssign()
{
	int X = 10;
	X %= 3;
	return X;
}

int BitAndAssign()
{
	int X = 255;
	X &= 15;
	return X;
}

int BitOrAssign()
{
	int X = 0;
	X |= 255;
	return X;
}

int BitXorAssign()
{
	int X = 255;
	X ^= 15;
	return X;
}

int ShiftLAssign()
{
	int X = 1;
	X <<= 4;
	return X;
}

int ShiftRAssign()
{
	int X = 16;
	X >>= 2;
	return X;
}
""",
        ),
        (
            "invalid-assign-to-literal",
            "root",
            "A literal cannot be the target of assignment.",
            ["Negative"],
            """void Test()
{
	5 = 1;
}
""",
        ),
        (
            "invalid-compound-on-const",
            "root",
            "A const local cannot be compound-assigned.",
            ["Negative"],
            """void Test()
{
	const int X = 1;
	X += 1;
}
""",
        ),
    ],
)

FILES["Operators/DefiniteAssignment.as"] = container(
    "Branch and partial definite-assignment forms without observation wrappers.",
    "Operators",
    [
        (
            "root",
            None,
            "Both branches assign the same local before it is read.",
            ["Baseline"],
            """int BothBranchesAssign(bool Flag)
{
	int X;
	if (Flag)
	{
		X = 1;
	}
	else
	{
		X = 2;
	}
	return X;
}
""",
        ),
        (
            "valid-partial-then-complete",
            "root",
            "A later assignment completes a path that left the local unset.",
            ["Operators"],
            """int CompleteAfterPartial(bool Flag)
{
	int X;
	if (Flag)
	{
		X = 1;
	}
	X = 3;
	return X;
}
""",
        ),
        (
            "invalid-unassigned-read",
            "root",
            "Reading a local that is not definitely assigned is invalid.",
            ["Negative"],
            """int Test(bool Flag)
{
	int X;
	if (Flag)
	{
		X = 1;
	}
	return X;
}
""",
        ),
    ],
)

FILES["Operators/Bitwise.as"] = container(
    "Bitwise and shift operator forms without observation wrappers.",
    "Operators",
    [
        (
            "root",
            None,
            "And, or, xor, not, and both shift directions on integers.",
            ["Baseline"],
            """int BitAnd()
{
	return 12 & 10;
}

int BitOr()
{
	return 12 | 10;
}

int BitXor()
{
	return 12 ^ 10;
}

int BitNot()
{
	return ~0;
}

int ShiftLeft()
{
	return 1 << 4;
}

int ShiftRight()
{
	return 16 >> 2;
}
""",
        ),
        (
            "invalid-bitwise-on-float",
            "root",
            "Bitwise and cannot take float operands.",
            ["Negative"],
            """void Test()
{
	float X = 1.0f & 2.0f;
}
""",
        ),
        (
            "invalid-shift-on-bool",
            "root",
            "Shift operators cannot take boolean operands.",
            ["Negative"],
            """void Test()
{
	bool X = true << 1;
}
""",
        ),
    ],
)

FILES["Operators/Comparison.as"] = container(
    "Relational and equality comparison forms without observation wrappers.",
    "Operators",
    [
        (
            "root",
            None,
            "Equality, inequality, and ordered comparisons on integers and floats.",
            ["Baseline"],
            """int EqualInt()
{
	return (1 == 1) ? 1 : 0;
}

int NotEqualInt()
{
	return (1 != 2) ? 1 : 0;
}

int LessInt()
{
	return (1 < 2) ? 1 : 0;
}

int LessEqualInt()
{
	return (2 <= 2) ? 1 : 0;
}

int GreaterInt()
{
	return (3 > 2) ? 1 : 0;
}

int GreaterEqualInt()
{
	return (3 >= 3) ? 1 : 0;
}

int CompareFloat()
{
	return (1.0f < 2.5f) ? 1 : 0;
}
""",
        ),
        (
            "invalid-compare-incompatible-types",
            "root",
            "A struct value cannot be compared with an integer.",
            ["Negative"],
            """struct FPair
{
	int X;
}

void Test()
{
	FPair Value;
	bool Result = Value == 1;
}
""",
        ),
    ],
)

FILES["Operators/Logical.as"] = container(
    "Logical conjunction, disjunction, negation, and short-circuit forms.",
    "Operators",
    [
        (
            "root",
            None,
            "And, or, not, a compound mix, and a short-circuit probe.",
            ["Baseline"],
            """int ConjunctionHolds()
{
	bool Result = (true && true);
	return Result ? 1 : 0;
}

int DisjunctionHolds()
{
	bool Result = (false || true);
	return Result ? 1 : 0;
}

int NegationHolds()
{
	return (!false) ? 1 : 0;
}

int CompoundExpressionHolds()
{
	bool Result = ((true && !false) || (false && true));
	return Result ? 1 : 0;
}

int ShortCircuitSkipsDivisor()
{
	int Z = 0;
	bool Result = (false && (1 / Z) == 0);
	return Result ? 1 : 0;
}
""",
        ),
        (
            "invalid-logical-on-int",
            "root",
            "Logical and requires boolean operands.",
            ["Negative"],
            """void Test()
{
	bool Result = 1 && 2;
}
""",
        ),
    ],
)

FILES["Operators/Ternary.as"] = container(
    "Conditional-expression forms without observation wrappers.",
    "Operators",
    [
        (
            "root",
            None,
            "A ternary selecting between two integer arms.",
            ["Baseline"],
            """int Pick(bool Flag)
{
	return Flag ? 1 : 2;
}

int NestedPick(bool First, bool Second)
{
	return First ? (Second ? 1 : 2) : 3;
}
""",
        ),
        (
            "invalid-ternary-non-bool-condition",
            "root",
            "The ternary condition must be boolean.",
            ["Negative"],
            """int Test()
{
	return 1 ? 2 : 3;
}
""",
        ),
        (
            "invalid-ternary-mismatched-arms",
            "root",
            "Ternary arms must share a common type.",
            ["Negative"],
            """void Test(bool Flag)
{
	int X = Flag ? 1 : true;
}
""",
        ),
    ],
)

FILES["Operators/Precedence.as"] = container(
    "Mixed-operator precedence chains without observation wrappers.",
    "Operators",
    [
        (
            "root",
            None,
            "Arithmetic, shift, comparison, bitwise, and logical precedence mixes.",
            ["Baseline"],
            """int ArithmeticBindsTighter()
{
	return 2 + 3 * 4 - 1;
}

int ShiftVersusAdd()
{
	return 1 + 2 << 3;
}

int ComparisonVersusArithmetic()
{
	return (1 + 2 < 5 - 1) ? 1 : 0;
}

int BitwiseVersusComparison()
{
	int X = 5;
	bool Result = (X > 0 && (X & 1) == 1);
	return Result ? 1 : 0;
}

int LogicalVersusComparison()
{
	bool Result = (1 < 2 || 3 > 4 && 5 == 6);
	return Result ? 1 : 0;
}
""",
        ),
        (
            "valid-parenthesized-override",
            "root",
            "Parentheses override the default arithmetic binding.",
            ["Operators"],
            """int ForcedAddFirst()
{
	return (2 + 3) * 4;
}
""",
        ),
    ],
)

FILES["Operators/ExpressionEdges.as"] = container(
    "Deep parentheses, long chains, and assignment-in-expression forms.",
    "Operators",
    [
        (
            "root",
            None,
            "Nested parentheses, a long addition chain, and assignment used as a statement sequence.",
            ["Baseline"],
            """int MaxParens()
{
	return ((((1 + 2))));
}

int LongChain()
{
	return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10;
}

int PrecedenceMix()
{
	return 2 + 3 * 4 - 1;
}

int AssignThenRead()
{
	int X = 0;
	X = 5;
	int Y = X;
	return Y;
}
""",
        ),
        (
            "invalid-unmatched-paren",
            "root",
            "An unmatched opening parenthesis is invalid.",
            ["Negative"],
            """int Test()
{
	return ((1 + 2);
}
""",
        ),
    ],
)

FILES["Operators/Overload.as"] = container(
    "Value-type operator overload declarations without observation wrappers.",
    "Operators",
    [
        (
            "root",
            None,
            "A two-axis value type with add, subtract, multiply, negate, and equality overloads.",
            ["Baseline"],
            """struct FVec
{
	int X;
	int Y;

	FVec opAdd(const FVec& Other) const
	{
		FVec Result;
		Result.X = X + Other.X;
		Result.Y = Y + Other.Y;
		return Result;
	}

	FVec opSub(const FVec& Other) const
	{
		FVec Result;
		Result.X = X - Other.X;
		Result.Y = Y - Other.Y;
		return Result;
	}

	FVec opMul(int Scale) const
	{
		FVec Result;
		Result.X = X * Scale;
		Result.Y = Y * Scale;
		return Result;
	}

	FVec opNeg() const
	{
		FVec Result;
		Result.X = -X;
		Result.Y = -Y;
		return Result;
	}

	bool opEquals(const FVec& Other) const
	{
		return X == Other.X && Y == Other.Y;
	}

	FVec& opAddAssign(const FVec& Other)
	{
		X += Other.X;
		Y += Other.Y;
		return this;
	}
}

int UseOverloads()
{
	FVec A;
	A.X = 1;
	A.Y = 2;
	FVec B;
	B.X = 3;
	B.Y = 4;
	FVec Sum = A + B;
	FVec Diff = B - A;
	FVec Scaled = A * 2;
	FVec Negated = -A;
	A += B;
	return (Sum.X + Diff.Y + Scaled.X + Negated.Y + (A == B ? 1 : 0));
}
""",
        ),
        (
            "valid-compare-overload",
            "root",
            "A comparable value type with a dedicated less-than overload.",
            ["Operators"],
            """struct FVal
{
	int Score;

	bool opCmp(const FVal& Other) const
	{
		if (Score < Other.Score)
		{
			return true;
		}
		return false;
	}
}
""",
        ),
        (
            "invalid-unknown-operator",
            "root",
            "An unknown operator name is not a valid overload.",
            ["Negative"],
            """struct FBad
{
	int opUnknown(int Other) const
	{
		return Other;
	}
}
""",
        ),
    ],
)

FILES["ControlFlow/If.as"] = container(
    "Single-branch if statements and condition forms.",
    "ControlFlow",
    [
        (
            "root",
            None,
            "A boolean if that assigns only on the true path, plus comparison conditions.",
            ["Baseline"],
            """int IfBasic(bool Flag)
{
	int X = 0;
	if (Flag)
	{
		X = 1;
	}
	return X;
}

int IfComparison(int Value)
{
	int X = 0;
	if (Value > 0)
	{
		X = 1;
	}
	if (Value == 0)
	{
		X = 2;
	}
	return X;
}
""",
        ),
        (
            "invalid-if-non-bool",
            "root",
            "An if condition must be boolean.",
            ["Negative"],
            """void Test()
{
	if (1)
	{
		return;
	}
}
""",
        ),
    ],
)

FILES["ControlFlow/IfElse.as"] = container(
    "If-else and else-if ladder forms.",
    "ControlFlow",
    [
        (
            "root",
            None,
            "A two-arm if-else and a three-arm else-if ladder.",
            ["Baseline"],
            """int IfElseForms(int Value)
{
	int X = 0;
	if (Value > 0)
	{
		X = 1;
	}
	else
	{
		X = -1;
	}
	return X;
}

int ElseIfLadder(int Value)
{
	if (Value < 0)
	{
		return -1;
	}
	else if (Value == 0)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}
""",
        ),
        (
            "invalid-else-without-if",
            "root",
            "An else clause cannot stand alone.",
            ["Negative"],
            """void Test()
{
	else
	{
		return;
	}
}
""",
        ),
    ],
)

FILES["ControlFlow/IfNested.as"] = container(
    "Nested if statements without observation wrappers.",
    "ControlFlow",
    [
        (
            "root",
            None,
            "An inner if nested in both arms of an outer if.",
            ["Baseline"],
            """int IfNested(bool Outer, bool Inner)
{
	int X = 0;
	if (Outer)
	{
		if (Inner)
		{
			X = 1;
		}
		else
		{
			X = 2;
		}
	}
	else
	{
		if (Inner)
		{
			X = 3;
		}
		else
		{
			X = 4;
		}
	}
	return X;
}
""",
        ),
        (
            "invalid-dangling-else-token",
            "root",
            "A second else on the same if is invalid.",
            ["Negative"],
            """void Test(bool Flag)
{
	if (Flag)
	{
		return;
	}
	else
	{
		return;
	}
	else
	{
		return;
	}
}
""",
        ),
    ],
)

FILES["ControlFlow/While.as"] = container(
    "While-loop forms without observation wrappers.",
    "ControlFlow",
    [
        (
            "root",
            None,
            "A counted while loop that advances a local.",
            ["Baseline"],
            """int WhileLoop(int Limit)
{
	int Index = 0;
	int Total = 0;
	while (Index < Limit)
	{
		Total += Index;
		++Index;
	}
	return Total;
}
""",
        ),
        (
            "invalid-while-non-bool",
            "root",
            "A while condition must be boolean.",
            ["Negative"],
            """void Test()
{
	while (1)
	{
		break;
	}
}
""",
        ),
    ],
)

FILES["ControlFlow/DoWhile.as"] = container(
    "Do-while loop forms without observation wrappers.",
    "ControlFlow",
    [
        (
            "root",
            None,
            "A do-while that executes the body before testing the condition.",
            ["Baseline"],
            """int DoWhileLoop(int Limit)
{
	int Index = 0;
	int Total = 0;
	do
	{
		Total += Index;
		++Index;
	}
	while (Index < Limit);
	return Total;
}
""",
        ),
        (
            "invalid-do-without-while",
            "root",
            "A do body must be followed by while.",
            ["Negative"],
            """void Test()
{
	do
	{
		return;
	}
}
""",
        ),
    ],
)

FILES["ControlFlow/Switch.as"] = container(
    "Integer and enum switch forms with break.",
    "ControlFlow",
    [
        (
            "root",
            None,
            "A defaulted integer switch, an explicit-break switch, and an enum switch.",
            ["Baseline"],
            """enum EKind
{
	Alpha,
	Beta,
	Gamma
}

int SwitchBasic(int Value)
{
	switch (Value)
	{
		case 0:
			return 10;
		case 1:
			return 20;
		default:
			return 0;
	}
}

int SwitchBreak(int Value)
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

int SwitchEnum(EKind Kind)
{
	switch (Kind)
	{
		case EKind::Alpha:
			return 1;
		case EKind::Beta:
			return 2;
		case EKind::Gamma:
			return 3;
	}
	return 0;
}
""",
        ),
        (
            "invalid-switch-on-float",
            "root",
            "A float cannot be the switch selector.",
            ["Negative"],
            """void Test()
{
	float Value = 1.0f;
	switch (Value)
	{
		case 1.0f:
			return;
	}
}
""",
        ),
        (
            "invalid-duplicate-case",
            "root",
            "Duplicate case labels are invalid.",
            ["Negative"],
            """void Test(int Value)
{
	switch (Value)
	{
		case 1:
			return;
		case 1:
			return;
	}
}
""",
        ),
    ],
)

FILES["ControlFlow/LoopJump.as"] = container(
    "Break and continue inside loops.",
    "ControlFlow",
    [
        (
            "root",
            None,
            "A while that breaks early and a while that continues on even values.",
            ["Baseline"],
            """int BreakInLoop(int Limit)
{
	int Index = 0;
	int Total = 0;
	while (Index < Limit)
	{
		if (Index == 3)
		{
			break;
		}
		Total += Index;
		++Index;
	}
	return Total;
}

int ContinueInLoop(int Limit)
{
	int Index = 0;
	int Total = 0;
	while (Index < Limit)
	{
		++Index;
		if ((Index % 2) == 0)
		{
			continue;
		}
		Total += Index;
	}
	return Total;
}
""",
        ),
        (
            "invalid-break-outside-loop",
            "root",
            "Break is invalid outside a loop or switch.",
            ["Negative"],
            """void Test()
{
	break;
}
""",
        ),
        (
            "invalid-continue-outside-loop",
            "root",
            "Continue is invalid outside a loop.",
            ["Negative"],
            """void Test()
{
	continue;
}
""",
        ),
    ],
)

FILES["ControlFlow/Return.as"] = container(
    "Integer, boolean, float, and void return forms.",
    "ControlFlow",
    [
        (
            "root",
            None,
            "Early return, expression return, multiple returns, and a void return.",
            ["Baseline"],
            """int ReturnInt()
{
	return 7;
}

bool ReturnBool(int Value)
{
	return Value > 0;
}

float ReturnFloat()
{
	return 1.5f;
}

int ReturnEarly(bool Flag)
{
	if (Flag)
	{
		return 1;
	}
	return 0;
}

int MultipleReturns(int Value)
{
	if (Value < 0)
	{
		return -1;
	}
	if (Value == 0)
	{
		return 0;
	}
	return Value;
}

void ReturnVoid()
{
	return;
}

int ReturnExpression(int Left, int Right)
{
	return Left + Right;
}
""",
        ),
        (
            "invalid-missing-return",
            "root",
            "A value-returning function cannot fall off the end.",
            ["Negative"],
            """int Test(bool Flag)
{
	if (Flag)
	{
		return 1;
	}
}
""",
        ),
        (
            "invalid-return-type-mismatch",
            "root",
            "A boolean cannot be returned from an integer function.",
            ["Negative"],
            """int Test()
{
	return true;
}
""",
        ),
    ],
)

FILES["ControlFlow/Foreach.as"] = container(
    "Foreach over an array with break, continue, and element reads.",
    "ControlFlow",
    [
        (
            "root",
            None,
            "Foreach that reads values, skips one index, and breaks after a match.",
            ["Baseline"],
            """int ForeachValues(array<int> Values)
{
	int Total = 0;
	for (int Value : Values)
	{
		Total += Value;
	}
	return Total;
}

int ForeachBreakContinue(array<int> Values)
{
	int Total = 0;
	int Index = 0;
	for (int Value : Values)
	{
		++Index;
		if (Index == 1)
		{
			continue;
		}
		if (Value < 0)
		{
			break;
		}
		Total += Value;
	}
	return Total;
}
""",
        ),
        (
            "invalid-foreach-on-int",
            "root",
            "Foreach requires an iterable collection.",
            ["Negative"],
            """void Test()
{
	int Value = 1;
	for (int Item : Value)
	{
		Item = Item;
	}
}
""",
        ),
    ],
)

FILES["Casting/NumericImplicit.as"] = container(
    "Implicit numeric widening and narrowing conversion forms.",
    "Casting",
    [
        (
            "root",
            None,
            "Int/float/int64/uint8 implicit conversions and a bool-to-int form.",
            ["Baseline"],
            """float ImplicitIntToFloat()
{
	int X = 3;
	float Y = X;
	return Y;
}

int ImplicitFloatToInt()
{
	float X = 3.9f;
	int Y = X;
	return Y;
}

int64 ImplicitIntToInt64()
{
	int X = 7;
	int64 Y = X;
	return Y;
}

int ImplicitInt64ToInt()
{
	int64 X = 9;
	int Y = X;
	return Y;
}

int ImplicitUint8ToInt()
{
	uint8 X = 5;
	int Y = X;
	return Y;
}

uint8 ImplicitFloatToUint8()
{
	float X = 2.2f;
	uint8 Y = X;
	return Y;
}

float ImplicitLiteralToFloat()
{
	float X = 4;
	return X;
}

int ImplicitBoolToInt()
{
	bool Flag = true;
	int X = Flag;
	return X;
}
""",
        ),
        (
            "invalid-implicit-struct-to-int",
            "root",
            "A struct cannot convert implicitly to int.",
            ["Negative"],
            """struct FBox
{
	int X;
}

void Test()
{
	FBox Value;
	int X = Value;
}
""",
        ),
    ],
)

FILES["Casting/NumericExplicit.as"] = container(
    "Explicit numeric cast forms without observation wrappers.",
    "Casting",
    [
        (
            "root",
            None,
            "Explicit int/float/uint8 casts.",
            ["Baseline"],
            """int ExplicitFloatToInt()
{
	float X = 3.9f;
	return int(X);
}

float ExplicitIntToFloat()
{
	int X = 3;
	return float(X);
}

uint8 ExplicitIntToUint8()
{
	int X = 300;
	return uint8(X);
}
""",
        ),
        (
            "invalid-explicit-unknown-type",
            "root",
            "An unknown target type cannot be used as a cast.",
            ["Negative"],
            """void Test()
{
	int X = NotAType(1);
}
""",
        ),
    ],
)

FILES["Casting/Nullptr.as"] = container(
    "Null handle assignment, comparison, and cast forms.",
    "Casting",
    [
        (
            "root",
            None,
            "A reference class handle assigned null and compared with is-null.",
            ["Baseline"],
            """class ANode
{
	int Value;
}

bool NullptrHandleAssignment()
{
	ANode@ Node = null;
	return Node is null;
}

bool NullptrComparison(ANode@ Node)
{
	if (Node is null)
	{
		return true;
	}
	return Node !is null;
}

bool CastNullptrIsNull()
{
	ANode@ Node = null;
	ANode@ Casted = cast<ANode>(Node);
	return Casted is null;
}
""",
        ),
        (
            "invalid-null-to-value",
            "root",
            "A value type cannot be assigned null.",
            ["Negative"],
            """void Test()
{
	int X = null;
}
""",
        ),
    ],
)

FILES["Casting/ClassCast.as"] = container(
    "Upcast, downcast, and round-trip class handle casts.",
    "Casting",
    [
        (
            "root",
            None,
            "Derived-to-base implicit handle conversion and an explicit downcast.",
            ["Baseline"],
            """class ABase
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

ADerived@ CastDowncast(ABase@ Parent)
{
	return cast<ADerived>(Parent);
}

ADerived@ CastRoundTrip(ADerived@ Child)
{
	ABase@ Parent = Child;
	ADerived@ Again = cast<ADerived>(Parent);
	if (Again is null)
	{
		return null;
	}
	return Again;
}
""",
        ),
        (
            "invalid-unrelated-cast",
            "root",
            "Unrelated class types cannot be cast to each other.",
            ["Negative"],
            """class ALeft
{
	int X;
}

class ARight
{
	int Y;
}

void Test(ALeft@ Left)
{
	ARight@ Right = cast<ARight>(Left);
}
""",
        ),
    ],
)

FILES["Namespace/QualifiedName.as"] = container(
    "Qualified namespace names and qualified calls.",
    "Namespace",
    [
        (
            "root",
            None,
            "A named namespace function invoked through a qualified name.",
            ["Baseline"],
            """namespace Tools
{
	int Offset()
	{
		return 3;
	}
}

int QualifiedCall()
{
	return Tools::Offset();
}
""",
        ),
        (
            "invalid-unknown-qualifier",
            "root",
            "A qualifier that names no namespace is invalid.",
            ["Negative"],
            """int Test()
{
	return Missing::Offset();
}
""",
        ),
    ],
)

FILES["Namespace/Nested.as"] = container(
    "Nested namespace scope and qualified access.",
    "Namespace",
    [
        (
            "root",
            None,
            "An inner namespace reached through a two-segment qualifier.",
            ["Baseline"],
            """namespace Outer
{
	namespace Inner
	{
		int Value()
		{
			return 4;
		}
	}
}

int NestedAccess()
{
	return Outer::Inner::Value();
}
""",
        ),
        (
            "invalid-skip-inner-qualifier",
            "root",
            "The outer name alone does not expose the inner function.",
            ["Negative"],
            """int Test()
{
	return Outer::Value();
}
""",
        ),
    ],
)

FILES["Namespace/GlobalVersusScoped.as"] = container(
    "Global and scoped names that share a spelling.",
    "Namespace",
    [
        (
            "root",
            None,
            "A global helper and a same-named scoped helper selected by qualification.",
            ["Baseline"],
            """int Amount()
{
	return 1;
}

namespace Game
{
	int Amount()
	{
		return 2;
	}
}

int PickGlobal()
{
	return Amount();
}

int PickScoped()
{
	return Game::Amount();
}
""",
        ),
        (
            "invalid-ambiguous-unqualified-after-using",
            "root",
            "An unqualified name is invalid when a using-directive makes it ambiguous.",
            ["Negative"],
            """using namespace Game;

int Test()
{
	return Amount();
}
""",
        ),
    ],
)

FILES["Namespace/Shadowing.as"] = container(
    "Inner-scope names that shadow outer namespace names.",
    "Namespace",
    [
        (
            "root",
            None,
            "A local that shadows a namespace function of the same name.",
            ["Baseline"],
            """namespace Game
{
	int Score()
	{
		return 10;
	}
}

int ShadowedLocal()
{
	int Score = 1;
	return Score + Game::Score();
}
""",
        ),
        (
            "invalid-shadowed-type-as-value",
            "root",
            "A shadowed type name cannot be used as a value.",
            ["Negative"],
            """namespace Game
{
	int Score = 1;
}

void Test()
{
	int Game = 2;
	return Game::Score;
}
""",
        ),
    ],
)

FILES["Namespace/Enum.as"] = container(
    "Enumerations declared inside a namespace.",
    "Namespace",
    [
        (
            "root",
            None,
            "A namespaced enum selected through a qualified enumerator.",
            ["Baseline"],
            """namespace Game
{
	enum EPhase
	{
		Start,
		Play,
		End
	}
}

int PhaseValue()
{
	Game::EPhase Phase = Game::EPhase::Play;
	if (Phase == Game::EPhase::Play)
	{
		return 1;
	}
	return 0;
}
""",
        ),
        (
            "invalid-unqualified-namespaced-enum",
            "root",
            "A namespaced enum type is not visible without its qualifier.",
            ["Negative"],
            """void Test()
{
	EPhase Phase = EPhase::Play;
}
""",
        ),
    ],
)

FILES["Syntax/Comments.as"] = container(
    "Line, block, documentation, and escaped-annotation comment forms.",
    "Syntax",
    [
        (
            "root",
            None,
            "A function preceded by line and block comments, with an inline comment.",
            ["Baseline"],
            """// single-line comment before the function
/* block comment
   on two lines */
int Commented()
{
	int X = 1; // trailing line comment
	/* inline block */ int Y = 2;
	return X + Y;
}
""",
        ),
        (
            "valid-escaped-annotation-comment",
            "root",
            "An escaped annotation comment remains literal source text.",
            ["Syntax"],
            """int Documented()
{
	/** @@point name */
	int X = 1;
	return X;
}
""",
        ),
        (
            "invalid-unterminated-block-comment",
            "root",
            "A block comment must close.",
            ["Negative"],
            """int Test()
{
	/* unterminated
	return 1;
}
""",
        ),
    ],
)

FILES["Syntax/EmptyFunction.as"] = container(
    "Empty function bodies without observation wrappers.",
    "Syntax",
    [
        (
            "root",
            None,
            "An empty void function and an empty int function that still returns.",
            ["Baseline"],
            """void EmptyVoid()
{
}

int EmptyThenReturn()
{
	return 0;
}
""",
        ),
        (
            "invalid-function-without-body",
            "root",
            "A function declaration without a body is invalid in this corpus.",
            ["Negative"],
            """void MissingBody();
""",
        ),
    ],
)

FILES["Syntax/FunctionReturn.as"] = container(
    "A minimal integer-return function.",
    "Syntax",
    [
        (
            "root",
            None,
            "A function that returns a constant integer.",
            ["Baseline"],
            """int Answer()
{
	return 42;
}
""",
        ),
        (
            "invalid-void-result-as-int",
            "root",
            "A void call cannot be returned as int.",
            ["Negative"],
            """void Work()
{
}

int Test()
{
	return Work();
}
""",
        ),
    ],
)

FILES["Syntax/DefaultParameters.as"] = container(
    "Defaulted function parameters for bool, int, and float.",
    "Syntax",
    [
        (
            "root",
            None,
            "Trailing defaults on mixed primitive parameters.",
            ["Baseline"],
            """int WithDefaults(int Count = 1, bool Flag = true, float Scale = 1.0f)
{
	int Added = Flag ? Count : 0;
	return Added + int(Scale);
}

int CallAllDefaults()
{
	return WithDefaults();
}

int CallPartialDefaults()
{
	return WithDefaults(3);
}
""",
        ),
        (
            "invalid-default-before-required",
            "root",
            "A required parameter cannot follow a defaulted one.",
            ["Negative"],
            """int Bad(int Count = 1, int Extra)
{
	return Count + Extra;
}
""",
        ),
        (
            "invalid-default-type-mismatch",
            "root",
            "A default expression must match the parameter type.",
            ["Negative"],
            """int Bad(int Count = true)
{
	return Count;
}
""",
        ),
    ],
)

FILES["Syntax/Overload.as"] = container(
    "Function overload sets resolved by arity and numeric type.",
    "Syntax",
    [
        (
            "root",
            None,
            "Overloads distinguished by arity and by int versus float.",
            ["Baseline"],
            """int Combine(int Value)
{
	return Value;
}

int Combine(int Left, int Right)
{
	return Left + Right;
}

int Combine(float Value)
{
	return int(Value);
}

int PickArity()
{
	return Combine(1) + Combine(2, 3);
}

int PickNumeric()
{
	return Combine(1.5f);
}
""",
        ),
        (
            "invalid-duplicate-signature",
            "root",
            "Two functions cannot share the same signature.",
            ["Negative"],
            """int Combine(int Value)
{
	return Value;
}

int Combine(int Value)
{
	return Value + 1;
}
""",
        ),
    ],
)

FILES["Syntax/NamedArguments.as"] = container(
    "Named argument calls with mixed positional order.",
    "Syntax",
    [
        (
            "root",
            None,
            "A call that names later arguments and keeps one positional.",
            ["Baseline"],
            """int Mix(int First, int Second, int Third)
{
	return First + Second * 10 + Third * 100;
}

int NamedPartial()
{
	return Mix(1, Third: 3, Second: 2);
}
""",
        ),
        (
            "invalid-named-unknown",
            "root",
            "A named argument must match a parameter name.",
            ["Negative"],
            """int Mix(int First, int Second)
{
	return First + Second;
}

int Test()
{
	return Mix(First: 1, Missing: 2);
}
""",
        ),
        (
            "invalid-named-duplicate",
            "root",
            "The same parameter cannot be named twice.",
            ["Negative"],
            """int Mix(int First, int Second)
{
	return First + Second;
}

int Test()
{
	return Mix(First: 1, First: 2);
}
""",
        ),
    ],
)

FILES["Syntax/Parameters.as"] = container(
    "Value, reference, in, and inout parameter combinations.",
    "Syntax",
    [
        (
            "root",
            None,
            "By-value, const-in, out, and inout integer parameters.",
            ["Baseline"],
            """int ValueParam(int Amount)
{
	return Amount + 1;
}

int ConstInParam(const int& In Amount)
{
	return Amount;
}

void OutParam(int& Out Amount)
{
	Amount = 4;
}

void InOutParam(int& InOut Amount)
{
	Amount += 1;
}

int UseDirections()
{
	int Value = ValueParam(1);
	int Read = ConstInParam(Value);
	int Written = 0;
	OutParam(Written);
	InOutParam(Written);
	return Read + Written;
}
""",
        ),
        (
            "invalid-void-parameter",
            "root",
            "Void is not a legal parameter type.",
            ["Negative"],
            """void Bad(void Amount)
{
}
""",
        ),
    ],
)

FILES["Syntax/StructConstructors.as"] = container(
    "Struct constructors and constructed locals.",
    "Syntax",
    [
        (
            "root",
            None,
            "A struct with a default constructor and a two-argument constructor.",
            ["Baseline"],
            """struct FPoint
{
	int X;
	int Y;

	FPoint()
	{
		X = 0;
		Y = 0;
	}

	FPoint(int InX, int InY)
	{
		X = InX;
		Y = InY;
	}
}

int Constructed()
{
	FPoint Origin;
	FPoint Offset(2, 3);
	return Origin.X + Offset.Y;
}
""",
        ),
        (
            "invalid-constructor-wrong-arity",
            "root",
            "A constructor call must match a declared arity.",
            ["Negative"],
            """struct FPoint
{
	int X;
	FPoint(int InX)
	{
		X = InX;
	}
}

void Test()
{
	FPoint Value(1, 2);
}
""",
        ),
    ],
)

FILES["Syntax/StructConst.as"] = container(
    "Const methods on structs.",
    "Syntax",
    [
        (
            "root",
            None,
            "A const reader method that does not mutate members.",
            ["Baseline"],
            """struct FSize
{
	int Width;
	int Height;

	int Area() const
	{
		return Width * Height;
	}
}

int ReadArea()
{
	FSize Value;
	Value.Width = 2;
	Value.Height = 3;
	return Value.Area();
}
""",
        ),
        (
            "invalid-mutate-in-const-method",
            "root",
            "A const method cannot assign a member.",
            ["Negative"],
            """struct FSize
{
	int Width;

	void Grow() const
	{
		Width += 1;
	}
}
""",
        ),
    ],
)

FILES["Syntax/Enum.as"] = container(
    "Enum declarations, explicit values, and local use.",
    "Syntax",
    [
        (
            "root",
            None,
            "An implicit enum and an explicitly numbered enum used as a local.",
            ["Baseline"],
            """enum EColor
{
	Red,
	Green,
	Blue
}

enum EMask
{
	None = 0,
	Read = 1,
	Write = 2,
	ReadWrite = 3
}

int LocalEnum()
{
	EColor Color = EColor::Green;
	EMask Mask = EMask::Read;
	if (Color == EColor::Green)
	{
		return int(Mask);
	}
	return 0;
}
""",
        ),
        (
            "invalid-duplicate-enumerator",
            "root",
            "Enumerator names must be unique in one enum.",
            ["Negative"],
            """enum EColor
{
	Red,
	Red
}
""",
        ),
        (
            "invalid-enum-without-name",
            "root",
            "An enum declaration requires a name.",
            ["Negative"],
            """enum
{
	Red
}
""",
        ),
    ],
)

FILES["Syntax/ForClauses.as"] = container(
    "For-loop clause shapes including omitted and comma clauses.",
    "Syntax",
    [
        (
            "root",
            None,
            "A basic for, omitted clauses, and a comma increment.",
            ["Baseline"],
            """int ForBasic()
{
	int Total = 0;
	for (int Index = 0; Index < 4; ++Index)
	{
		Total += Index;
	}
	return Total;
}

int ForOmittedInit(int Start)
{
	int Total = 0;
	int Index = Start;
	for (; Index < 4; ++Index)
	{
		Total += Index;
	}
	return Total;
}

int ForCommaClauses()
{
	int Total = 0;
	for (int Index = 0, Step = 1; Index < 4; Index += Step, Step = 1)
	{
		Total += Index;
	}
	return Total;
}
""",
        ),
        (
            "invalid-for-without-parens",
            "root",
            "A for header requires parentheses.",
            ["Negative"],
            """void Test()
{
	for int Index = 0; Index < 1; ++Index
	{
		return;
	}
}
""",
        ),
        (
            "invalid-for-non-bool-condition",
            "root",
            "A for condition must be boolean.",
            ["Negative"],
            """void Test()
{
	for (int Index = 0; Index; ++Index)
	{
		return;
	}
}
""",
        ),
    ],
)

FILES["Syntax/ForNested.as"] = container(
    "Nested for loops without observation wrappers.",
    "Syntax",
    [
        (
            "root",
            None,
            "An inner for nested inside an outer for.",
            ["Baseline"],
            """int NestedFors()
{
	int Total = 0;
	for (int Row = 0; Row < 3; ++Row)
	{
		for (int Column = 0; Column < 3; ++Column)
		{
			Total += Row + Column;
		}
	}
	return Total;
}
""",
        ),
        (
            "invalid-inner-index-escape",
            "root",
            "A for-declared index is not visible after the loop.",
            ["Negative"],
            """int Test()
{
	for (int Index = 0; Index < 1; ++Index)
	{
	}
	return Index;
}
""",
        ),
    ],
)

FILES["Syntax/Variables.as"] = container(
    "Primitive locals, references, and block-scoped variables.",
    "Syntax",
    [
        (
            "root",
            None,
            "Typed locals, a reference alias, and an inner-block variable.",
            ["Baseline"],
            """int PrimitiveLocals()
{
	int Count = 1;
	float Scale = 2.0f;
	bool Flag = true;
	int Total = Count + int(Scale);
	if (Flag)
	{
		int Inner = 3;
		Total += Inner;
	}
	return Total;
}

int ReferenceLocal()
{
	int Value = 1;
	int& Alias = Value;
	Alias = 4;
	return Value;
}
""",
        ),
        (
            "invalid-use-before-declaration",
            "root",
            "A local cannot be read before its declaration.",
            ["Negative"],
            """int Test()
{
	int Y = X;
	int X = 1;
	return Y;
}
""",
        ),
        (
            "invalid-duplicate-local",
            "root",
            "Two locals cannot share a name in one scope.",
            ["Negative"],
            """int Test()
{
	int X = 1;
	int X = 2;
	return X;
}
""",
        ),
        (
            "invalid-void-variable",
            "root",
            "Void is not a legal variable type.",
            ["Negative"],
            """void Test()
{
	void X;
}
""",
        ),
    ],
)

FILES["Syntax/Const.as"] = container(
    "Const locals, const parameters, and const methods.",
    "Syntax",
    [
        (
            "root",
            None,
            "A const local and a const method that only reads.",
            ["Baseline"],
            """struct FHolder
{
	int Value;

	int Read() const
	{
		return Value;
	}
}

int ConstLocal()
{
	const int Limit = 3;
	FHolder Holder;
	Holder.Value = Limit;
	return Holder.Read();
}
""",
        ),
        (
            "invalid-assign-const-local",
            "root",
            "A const local cannot be reassigned.",
            ["Negative"],
            """void Test()
{
	const int Limit = 3;
	Limit = 4;
}
""",
        ),
        (
            "invalid-const-without-initializer",
            "root",
            "A const local requires an initializer.",
            ["Negative"],
            """void Test()
{
	const int Limit;
}
""",
        ),
    ],
)

FILES["Syntax/References.as"] = container(
    "Reference parameters and reference locals.",
    "Syntax",
    [
        (
            "root",
            None,
            "In, out, and inout references plus a local alias.",
            ["Baseline"],
            """void WriteRef(int& Out Value)
{
	Value = 5;
}

void AdjustRef(int& InOut Value)
{
	Value += 2;
}

int ReadRef(const int& In Value)
{
	return Value;
}

int UseReferences()
{
	int Value = 0;
	WriteRef(Value);
	AdjustRef(Value);
	int& Alias = Value;
	Alias += 1;
	return ReadRef(Value);
}
""",
        ),
        (
            "invalid-ref-to-literal",
            "root",
            "A non-const reference cannot bind a literal.",
            ["Negative"],
            """void Write(int& Out Value)
{
	Value = 1;
}

void Test()
{
	Write(3);
}
""",
        ),
    ],
)

FILES["Syntax/Blocks.as"] = container(
    "Nested blocks, chained addition, and short-circuit skip forms.",
    "Syntax",
    [
        (
            "root",
            None,
            "Deep blocks, parenthesized addition, a long chain, and short-circuit skip.",
            ["Baseline"],
            """int DeeplyNestedBlocks()
{
	int Total = 0;
	{
		{
			{
				Total = 1;
			}
		}
	}
	return Total;
}

int DeeplyParenthesizedAddition()
{
	return ((((1 + 2) + 3) + 4));
}

int LongChainedAddition()
{
	return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8;
}

int MultipleStatements()
{
	int X = 1;
	int Y = 2;
	int Z = X + Y;
	return Z;
}

int ShortCircuitSkip()
{
	int Z = 0;
	bool Result = (false && (1 / Z) == 1);
	return Result ? 1 : 0;
}
""",
        ),
        (
            "invalid-unmatched-opening-brace",
            "root",
            "A block must close.",
            ["Negative"],
            """int Test()
{
	{
		return 1;
}
""",
        ),
        (
            "invalid-extra-closing-brace",
            "root",
            "An extra closing brace is invalid.",
            ["Negative"],
            """int Test()
{
	return 1;
}
}
""",
        ),
    ],
)

FILES["Preprocessor/IfElifElse.as"] = container(
    "Preprocessor if, elif, else, and endif branch skeletons.",
    "Preprocessor",
    [
        (
            "root",
            None,
            "A three-arm directive chain selecting among integer returns.",
            ["Baseline", "SourceOnly"],
            """int Entry()
{
#if FIRST_BRANCH
	return 1;
#elif SECOND_BRANCH
	return 2;
#else
	return 3;
#endif
}
""",
        ),
        (
            "valid-editor-flag-branch",
            "root",
            "A single #if/#else pair guarded by an editor configuration flag.",
            ["Preprocessor", "SourceOnly"],
            """int EditorBranch()
{
#if WITH_EDITOR
	return 1;
#else
	return 0;
#endif
}
""",
        ),
        (
            "invalid-missing-endif",
            "root",
            "A #if chain must close with #endif.",
            ["Negative", "SourceOnly"],
            """int Test()
{
#if FLAG
	return 1;
#else
	return 0;
}
""",
        ),
    ],
)

FILES["Preprocessor/DirectiveInString.as"] = container(
    "String text that looks like a directive but is only source characters.",
    "Preprocessor",
    [
        (
            "root",
            None,
            "A string literal contains #if text that is not a directive.",
            ["Baseline", "SourceOnly"],
            """int CountLiteral()
{
	string Text = "#if 0 this is not a directive";
	return Text.length();
}
""",
        ),
        (
            "valid-elif-in-string",
            "root",
            "Elif text inside quotes remains a string payload.",
            ["Preprocessor", "SourceOnly"],
            """int ElifLiteral()
{
	string Text = "#elif NEVER";
	return Text.length();
}
""",
        ),
        (
            "invalid-directive-outside-string",
            "root",
            "A bare unknown directive token is not valid source.",
            ["Negative", "SourceOnly"],
            """int Test()
{
#unknown
	return 1;
}
""",
        ),
    ],
)


def main() -> None:
    skip = {"Operators/Arithmetic.as", "Syntax/StructFields.as"}
    for rel, text in FILES.items():
        if rel in skip:
            continue
        write(rel, text)
    print(f"wrote {len(FILES)} containers")


if __name__ == "__main__":
    main()
