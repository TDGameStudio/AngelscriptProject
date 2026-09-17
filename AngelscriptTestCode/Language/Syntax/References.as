/**
 * @version v1
 * @summary Reference parameters and reference locals.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary In, out, and inout references plus a local alias.
 * @topic Baseline
 */
void WriteRef(int& Out Value)
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
/** @end */
/**
 * @version invalid-ref-to-literal
 * @parent root
 * @summary A non-const reference cannot bind a literal.
 * @topic Negative
 */
void Write(int& Out Value)
{
	Value = 1;
}

void Test()
{
	Write(3);
}
/** @end */
/**
 * @version valid-function-reference-parameter-combinations
 * @parent root
 * @summary Positive language form retained from legacy function reference parameter combinations.
 * @topic Syntax
 */
void DefaultAndOut(int&out Result, int Value = 10)
	{
		Result = Value * 2;
	}

	void DefaultAndOutUsingDefault(int&out Result)
	{
		DefaultAndOut(Result);
	}

	void MultipleOutOrder(int Seed, int&out A, int&out B, int&out C)
	{
		A = Seed + 1;
		B = Seed + 2;
		C = Seed + 3;
	}

	void PreserveInOut(int&inout Value)
	{
		int Original = Value;
		Value = Original * 2 + 1;
	}

	int ConstInValue(const int&in Value)
	{
		return Value + 1;
	}
/** @end */
/**
 * @version valid-ref-to-local
 * @parent root
 * @summary A reference parameter writes through a local.
 * @topic Syntax
 */
void Write(int& Amount)
{
	Amount = 9;
}

int UseRef()
{
	int Value = 0;
	Write(Value);
	return Value;
}
/** @end */
/**
 * @version valid-ref-inout-chain
 * @parent root
 * @summary Two inout references update the same local in sequence.
 * @topic Syntax
 */
void AddOne(int& InOut Amount)
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
/** @end */
/**
 * @version invalid-ref-to-const-then-write
 * @parent root
 * @summary A const reference cannot be written.
 * @topic Negative
 */
void Test()
{
	const int Value = 1;
	int& Written = Value;
	Written = 2;
}
/** @end */
