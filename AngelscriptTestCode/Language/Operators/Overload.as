/**
 * @version v1
 * @summary Value-type operator overload declarations without observation wrappers.
 * @topic Language
 * @topic Operators
 */
/**
 * @version root
 * @summary A two-axis value type with add, subtract, multiply, negate, and equality overloads.
 * @topic Baseline
 */
struct FVec
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
/** @end */
/**
 * @version valid-compare-overload
 * @parent root
 * @summary A comparable value type with a dedicated less-than overload.
 * @topic Operators
 */
struct FVal
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
/** @end */
/**
 * @version invalid-unknown-operator
 * @parent root
 * @summary An unknown operator name is not a valid overload.
 * @topic Negative
 */
struct FBad
{
	int opUnknown(int Other) const
	{
		return Other;
	}
}
/** @end */
/**
 * @version valid-container-op-index
 * @parent root
 * @summary Positive language form retained from legacy container op index.
 * @topic Operators
 */
struct FMyContainer
	{
		array<int> Data;

		int opIndex(int Index) const
		{
			return Data[Index];
		}
	}
/** @end */
/**
 * @version valid-f-val-cmp-overload
 * @parent root
 * @summary Positive language form retained from legacy f val cmp overload.
 * @topic Operators
 */
struct FValCmp
	{
		int Value = 0;

		int opCmp(const FValCmp&in Other) const
		{
			return Value - Other.Value;
		}
	}
/** @end */
/**
 * @version valid-f-vec-add-assign-overload
 * @parent root
 * @summary Positive language form retained from legacy f vec add assign overload.
 * @topic Operators
 */
struct FVecAddAssign
	{
		int X = 0;
		int Y = 0;

		FVecAddAssign& opAddAssign(const FVecAddAssign&in Other)
		{
			X += Other.X;
			Y += Other.Y;
			return this;
		}
	}
/** @end */
/**
 * @version valid-f-vec-add-overload
 * @parent root
 * @summary Positive language form retained from legacy f vec add overload.
 * @topic Operators
 */
struct FVecAdd
	{
		int X = 0;
		int Y = 0;

		FVecAdd opAdd(const FVecAdd&in Other) const
		{
			FVecAdd Result;
			Result.X = X + Other.X;
			Result.Y = Y + Other.Y;
			return Result;
		}
	}
/** @end */
/**
 * @version valid-f-vec-equals-overload
 * @parent root
 * @summary Positive language form retained from legacy f vec equals overload.
 * @topic Operators
 */
struct FVecEquals
	{
		int X = 0;
		int Y = 0;

		bool opEquals(const FVecEquals&in Other) const
		{
			if (X != Other.X)
			{
				return false;
			}
			return Y == Other.Y;
		}
	}
/** @end */
/**
 * @version valid-f-vec-mul-overload
 * @parent root
 * @summary Positive language form retained from legacy f vec mul overload.
 * @topic Operators
 */
struct FVecMul
	{
		int X = 0;
		int Y = 0;

		FVecMul opMul(int Scalar) const
		{
			FVecMul Result;
			Result.X = X * Scalar;
			Result.Y = Y * Scalar;
			return Result;
		}
	}
/** @end */
/**
 * @version valid-f-vec-neg-overload
 * @parent root
 * @summary Positive language form retained from legacy f vec neg overload.
 * @topic Operators
 */
struct FVecNeg
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
/** @end */
/**
 * @version valid-f-vec-sub-overload
 * @parent root
 * @summary Positive language form retained from legacy f vec sub overload.
 * @topic Operators
 */
struct FVecSub
	{
		int X = 0;
		int Y = 0;

		FVecSub opSub(const FVecSub&in Other) const
		{
			FVecSub Result;
			Result.X = X - Other.X;
			Result.Y = Y - Other.Y;
			return Result;
		}
	}
/** @end */
/**
 * @version valid-f-vec-usage-overload
 * @parent root
 * @summary Positive language form retained from legacy f vec usage overload.
 * @topic Operators
 */
struct FVecUsage
	{
		int X = 0;
		int Y = 0;

		FVecUsage opAdd(const FVecUsage&in Other) const
		{
			FVecUsage Result;
			Result.X = X + Other.X;
			Result.Y = Y + Other.Y;
			return Result;
		}

		bool opEquals(const FVecUsage&in Other) const
		{
			if (X != Other.X)
			{
				return false;
			}
			return Y == Other.Y;
		}
	}
/** @end */
/**
 * @version valid-score-operator-suite
 * @parent root
 * @summary Positive language form retained from legacy score operator suite.
 * @topic Operators
 */
struct FScoreValue
	{
		int Value = 0;

		FScoreValue opAdd(const FScoreValue&in Other) const
		{
			FScoreValue Result;
			Result.Value = Value + Other.Value;
			return Result;
		}

		FScoreValue opSub(const FScoreValue&in Other) const
		{
			FScoreValue Result;
			Result.Value = Value - Other.Value;
			return Result;
		}

		FScoreValue opMul(int Scale) const
		{
			FScoreValue Result;
			Result.Value = Value * Scale;
			return Result;
		}

		FScoreValue& opAddAssign(const FScoreValue&in Other)
		{
			Value += Other.Value;
			return this;
		}

		bool opEquals(const FScoreValue&in Other) const
		{
			return Value == Other.Value;
		}

		int opCmp(const FScoreValue&in Other) const
		{
			if (Value < Other.Value)
			{
				return -1;
			}
			if (Value > Other.Value)
			{
				return 1;
			}
			return 0;
		}
	}

	FScoreValue MakeScore(int Value)
	{
		FScoreValue Result;
		Result.Value = Value;
		return Result;
	}

	int ArithmeticOperators()
	{
		FScoreValue A = MakeScore(10);
		FScoreValue B = MakeScore(3);
		FScoreValue Sum = A + B;
		FScoreValue Difference = A - B;
		FScoreValue Product = B * 4;
		return Sum.Value * 100 + Difference.Value * 10 + Product.Value;
	}

	int CompoundAssignmentOperator()
	{
		FScoreValue A = MakeScore(5);
		FScoreValue B = MakeScore(8);
		A += B;
		return A.Value;
	}

	bool EqualityOperator()
	{
		return MakeScore(9) == MakeScore(9);
	}

	bool ComparisonOperators()
	{
		FScoreValue Low = MakeScore(1);
		FScoreValue High = MakeScore(4);

		if (!(Low < High))
		{
			return false;
		}
		if (!(High > Low))
		{
			return false;
		}
		if (!(Low <= MakeScore(1)))
		{
			return false;
		}
		return High >= MakeScore(4);
	}
/** @end */
/**
 * @version invalid-addition-without-op-add
 * @parent root
 * @summary Compile-rejection form retained from legacy addition without op add.
 * @topic Negative
 */
struct FMyType
{
	int X = 0;
}

void Test()
{
	FMyType A;
	FMyType B;
	FMyType C = A + B;
}
/** @end */
/**
 * @version invalid-addition-without-op-add-coverage
 * @parent root
 * @summary Compile-rejection form retained from legacy addition without op add coverage.
 * @topic Negative
 */
struct FNoPlus
{
	int Value = 0;
}

void Test()
{
	FNoPlus A;
	FNoPlus B;
	FNoPlus C = A + B;
}
/** @end */
/**
 * @version invalid-duplicate-op-add
 * @parent root
 * @summary Compile-rejection form retained from legacy duplicate op add.
 * @topic Negative
 */
struct FVecDupAdd
{
	int X = 0;

	FVecDupAdd opAdd(const FVecDupAdd&in Other) const
	{
		return FVecDupAdd();
	}

	FVecDupAdd opAdd(const FVecDupAdd&in Other) const
	{
		return FVecDupAdd();
	}
}
/** @end */
/**
 * @version invalid-duplicate-op-add-coverage
 * @parent root
 * @summary Compile-rejection form retained from legacy duplicate op add coverage.
 * @topic Negative
 */
struct FDuplicateOp
{
	FDuplicateOp opAdd(const FDuplicateOp&in Other) const
	{
		return FDuplicateOp();
	}

	FDuplicateOp opAdd(const FDuplicateOp&in Other) const
	{
		return FDuplicateOp();
	}
}
/** @end */
/**
 * @version invalid-global-operator-overload
 * @parent root
 * @summary Compile-rejection form retained from legacy global operator overload.
 * @topic Negative
 */
int opAdd(int A, int B)
{
	return A + B;
}
/** @end */
/**
 * @version invalid-invalid-operator-name
 * @parent root
 * @summary Compile-rejection form retained from legacy invalid operator name.
 * @topic Negative
 */
struct FVecInvalid
{
	int X = 0;

	FVecInvalid opInvalid(const FVecInvalid&in Other) const
	{
		return FVecInvalid();
	}
}
/** @end */
/**
 * @version invalid-op-add-returns-void
 * @parent root
 * @summary Compile-rejection form retained from legacy op add returns void.
 * @topic Negative
 */
struct FVecAddVoid
{
	int X = 0;

	void opAdd(const FVecAddVoid&in Other) const
	{
	}
}
/** @end */
/**
 * @version invalid-op-add-without-parameter
 * @parent root
 * @summary Compile-rejection form retained from legacy op add without parameter.
 * @topic Negative
 */
struct FVecBadParams
{
	int X = 0;

	FVecBadParams opAdd() const
	{
		return FVecBadParams();
	}
}
/** @end */
/**
 * @version invalid-op-cmp-non-int-return
 * @parent root
 * @summary Compile-rejection form retained from legacy op cmp non int return.
 * @topic Negative
 */
struct FValCmpWrongRet
{
	int Value = 0;

	float opCmp(const FValCmpWrongRet&in Other) const
	{
		return 0.0f;
	}
}
/** @end */
/**
 * @version invalid-op-equals-non-bool-return
 * @parent root
 * @summary Compile-rejection form retained from legacy op equals non bool return.
 * @topic Negative
 */
struct FVecEqWrongRet
{
	int X = 0;

	int opEquals(const FVecEqWrongRet&in Other) const
	{
		return 0;
	}
}
/** @end */
/**
 * @version invalid-op-index-returns-void
 * @parent root
 * @summary Compile-rejection form retained from legacy op index returns void.
 * @topic Negative
 */
struct FContainerBadRet
{
	array<int> Data;

	void opIndex(int Index) const
	{
	}
}
/** @end */
/**
 * @version invalid-op-neg-with-parameter
 * @parent root
 * @summary Compile-rejection form retained from legacy op neg with parameter.
 * @topic Negative
 */
struct FVecNegParam
{
	int X = 0;

	FVecNegParam opNeg(int Dummy) const
	{
		return FVecNegParam();
	}
}
/** @end */
/**
 * @version valid-op-index-read-write
 * @parent root
 * @summary A value type with opIndex used on both sides of assignment.
 * @topic Operators
 */
struct FCells
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
/** @end */
