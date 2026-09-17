/**
 * @version v1
 * @summary Integer, boolean, float, and void return forms.
 * @topic Language
 * @topic ControlFlow
 *
 * return
 * function-return-bool-values
 * function-return-control-flow
 * function-return-float-values
 * function-return-integer-widths
 * return-early
 * return-expression
 * return-float-as-int
 * return-int
 * return-void
 * script-quat-return
 * script-matrix-return
 * geometric-struct-parameters-and-returns
 * string-function-return
 */
/**
 * @begin return
 * @summary Early return, expression return, multiple returns, and a void return.
 */
int ReturnInt()
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
/** @end */
/**
 * @begin function-return-bool-values
 * @summary Positive language form retained from legacy function return bool values.
 * @topic ControlFlow
 */
bool TrueReturn()
	{
		return true;
	}

	bool FalseReturn()
	{
		return false;
	}
/** @end */
/**
 * @begin function-return-control-flow
 * @summary Positive language form retained from legacy function return control flow.
 * @topic ControlFlow
 */
int AddPair(int A, int B)
	{
		return A + B;
	}

	int ExpressionReturn()
	{
		int A = 20;
		int B = 22;
		return A + B;
	}

	int CallReturn()
	{
		return AddPair(20, 22);
	}

	int ConditionalAbsoluteReturn(int Value)
	{
		return Value > 0 ? Value : -Value;
	}

	int EarlyReturnOnNegative(int Value)
	{
		if (Value < 0)
		{
			return -1;
		}

		return Value + 1;
	}
/** @end */
/**
 * @begin function-return-float-values
 * @summary Positive language form retained from legacy function return float values.
 * @topic ControlFlow
 */
float FloatReturn()
	{
		return 42.25f;
	}

	double DoubleReturn()
	{
		return 84.5;
	}
/** @end */
/**
 * @begin function-return-integer-widths
 * @summary Positive language form retained from legacy function return integer widths.
 * @topic ControlFlow
 */
int8 Int8Return()
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
/** @end */
/**
 * @begin return-early
 * @summary Positive language form retained from legacy return early.
 * @topic ControlFlow
 */
int ClampedEarlyReturn(int Value)
	{
		if (Value < 0)
			return -1;
		if (Value > 100)
			return 100;
		return Value;
	}

	int EarlyReturnInsideLoop()
	{
		for (int i = 0; i < 10; i++)
		{
			if (i == 5)
				return i;
		}
		return -1;
	}

	void EarlyReturnFromVoid(int Value)
	{
		if (Value < 0)
			return;
		if (Value > 10)
			return;
	}

	int GuardClauseDoublesInRange(int Value)
	{
		if (Value < 0)
			return 0;
		if (Value > 100)
			return 100;

		int Result = Value * 2;
		return Result;
	}

	int NestedEarlyReturn(int A, int B)
	{
		if (A > 0)
		{
			if (B > 0)
				return 1;
			return 2;
		}
		return 3;
	}
/** @end */
/**
 * @begin return-expression
 * @summary Positive language form retained from legacy return expression.
 * @topic ControlFlow
 */
int ComputedReturn()
	{
		int X = 5;
		return X * 2 + 1;
	}
/** @end */
/**
 * @begin return-float-as-int
 * @summary Positive language form retained from legacy return float as int.
 * @topic ControlFlow
 */
int TruncatedFloatReturn()
	{
		return 3.14f;
	}
/** @end */
/**
 * @begin return-int
 * @summary Positive language form retained from legacy return int.
 * @topic ControlFlow
 */
int FixedIntReturn()
	{
		return 42;
	}
/** @end */
/**
 * @begin return-void
 * @summary Positive language form retained from legacy return void.
 * @topic ControlFlow
 */
void BareVoidReturn()
	{
		return;
	}
/** @end */
/**
 * @begin script-quat-return
 * @summary Authored language form for script quat return.
 * @topic ControlFlow
 */
struct FScriptQuat
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
/** @end */
/**
 * @begin script-matrix-return
 * @summary Authored language form for script matrix return.
 * @topic ControlFlow
 */
struct FScriptMatrix
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
/** @end */
/**
 * @begin geometric-struct-parameters-and-returns
 * @summary Authored language form for geometric struct parameters and returns.
 * @topic ControlFlow
 */
struct FScriptVec
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
/** @end */
/**
 * @begin string-function-return
 * @summary A function that returns a string literal.
 * @topic ControlFlow
 */
string Message()
{
	return "ok";
}
/** @end */
