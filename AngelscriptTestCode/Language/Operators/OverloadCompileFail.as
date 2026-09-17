/**
 * @version v1
 * @summary Compile-fail cases for Overload.
 * @topic Language
 * @topic Operators
 *
 * invalid-unknown-operator
 * invalid-addition-without-op-add
 * invalid-addition-without-op-add-coverage
 * invalid-duplicate-op-add
 * invalid-duplicate-op-add-coverage
 * invalid-global-operator-overload
 * invalid-invalid-operator-name
 * invalid-op-add-returns-void
 * invalid-op-add-without-parameter
 * invalid-op-cmp-non-int-return
 * invalid-op-equals-non-bool-return
 * invalid-op-index-returns-void
 * invalid-op-neg-with-parameter
 */
/**
 * @begin invalid-unknown-operator
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
 * @begin invalid-addition-without-op-add
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
 * @begin invalid-addition-without-op-add-coverage
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
 * @begin invalid-duplicate-op-add
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
 * @begin invalid-duplicate-op-add-coverage
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
 * @begin invalid-global-operator-overload
 * @summary Compile-rejection form retained from legacy global operator overload.
 * @topic Negative
 */
int opAdd(int A, int B)
{
	return A + B;
}
/** @end */
/**
 * @begin invalid-invalid-operator-name
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
 * @begin invalid-op-add-returns-void
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
 * @begin invalid-op-add-without-parameter
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
 * @begin invalid-op-cmp-non-int-return
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
 * @begin invalid-op-equals-non-bool-return
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
 * @begin invalid-op-index-returns-void
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
 * @begin invalid-op-neg-with-parameter
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
