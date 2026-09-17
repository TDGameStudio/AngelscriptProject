/**
 * @version v1
 * @summary Implicit numeric widening and narrowing conversion forms.
 * @topic Language
 * @topic Casting
 */
/**
 * @version root
 * @summary Int/float/int64/uint8 implicit conversions and a bool-to-int form.
 * @topic Baseline
 */
float ImplicitIntToFloat()
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
/** @end */
/**
 * @version invalid-implicit-struct-to-int
 * @parent root
 * @summary A struct cannot convert implicitly to int.
 * @topic Negative
 */
struct FBox
{
	int X;
}

void Test()
{
	FBox Value;
	int X = Value;
}
/** @end */
/**
 * @version valid-numeric-enum-and-string-conversions
 * @parent root
 * @summary Positive language form retained from legacy numeric enum and string conversions.
 * @topic Casting
 */
enum ECoverageConversionState
{
	None = 0,
	Ready = 3
}
/** @end */
/**
 * @version valid-unary-index-and-conversion-operators
 * @parent root
 * @summary Positive language form retained from legacy unary index and conversion operators.
 * @topic Casting
 */
struct FIndexedScores
{
	array<int> Values;

	int opIndex(int Index) const
	{
		return Values[Index];
	}
}

struct FUnaryScore
{
	int Value = 0;

	FUnaryScore opNeg() const
	{
		FUnaryScore Result;
		Result.Value = -Value;
		return Result;
	}

	int opImplConv() const
	{
		return Value;
	}
}
/** @end */
/**
 * @version invalid-implicit-array-to-int
 * @parent root
 * @summary Compile-rejection form retained from legacy implicit array to int.
 * @topic Negative
 */
void Test()
{
	array<int> Arr;
	int X = Arr;
}
/** @end */
/**
 * @version invalid-implicit-int-to-bool
 * @parent root
 * @summary Compile-rejection form retained from legacy implicit int to bool.
 * @topic Negative
 */
void Test()
{
	int X = 1;
	bool B = X;
}
/** @end */
/**
 * @version invalid-implicit-string-to-int
 * @parent root
 * @summary Compile-rejection form retained from legacy implicit string to int.
 * @topic Negative
 */
void Test()
{
	string S = "5";
	int X = S;
}
/** @end */
/**
 * @version valid-implicit-bool-to-int
 * @parent root
 * @summary Authored language form for implicit bool to int.
 * @topic Casting
 */
int ImplicitBoolToInt()
{
	bool Flag = true;
	int Value = Flag;
	return Value;
}
/** @end */
/**
 * @version valid-implicit-int-to-float
 * @parent root
 * @summary Authored language form for implicit int to float.
 * @topic Casting
 */
float ImplicitIntToFloat()
{
	int Value = 3;
	float Wide = Value;
	return Wide;
}
/** @end */
/**
 * @version valid-implicit-float-to-int
 * @parent root
 * @summary Authored language form for implicit float to int.
 * @topic Casting
 */
int ImplicitFloatToInt()
{
	float Value = 3.9f;
	int Narrow = Value;
	return Narrow;
}
/** @end */
/**
 * @version valid-implicit-int-to-int64
 * @parent root
 * @summary Authored language form for implicit int to int64.
 * @topic Casting
 */
int64 ImplicitIntToInt64()
{
	int Value = 7;
	int64 Wide = Value;
	return Wide;
}
/** @end */
/**
 * @version valid-implicit-int64-to-int
 * @parent root
 * @summary Authored language form for implicit int64 to int.
 * @topic Casting
 */
int ImplicitInt64ToInt()
{
	int64 Value = 9;
	int Narrow = Value;
	return Narrow;
}
/** @end */
/**
 * @version valid-implicit-uint8-to-int
 * @parent root
 * @summary Authored language form for implicit uint8 to int.
 * @topic Casting
 */
int ImplicitUint8ToInt()
{
	uint8 Value = 5;
	int Wide = Value;
	return Wide;
}
/** @end */
/**
 * @version valid-implicit-float-to-uint8
 * @parent root
 * @summary Authored language form for implicit float to uint8.
 * @topic Casting
 */
uint8 ImplicitFloatToUint8()
{
	float Value = 2.2f;
	uint8 Narrow = Value;
	return Narrow;
}
/** @end */
/**
 * @version valid-implicit-literal-to-float
 * @parent root
 * @summary Authored language form for implicit literal to float.
 * @topic Casting
 */
float ImplicitLiteralToFloat()
{
	float Value = 4;
	return Value;
}
/** @end */
/**
 * @version valid-numeric-enum-conversions
 * @parent root
 * @summary Authored language form for numeric enum conversions.
 * @topic Casting
 */
enum ELane
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
/** @end */
