/**
 * @version v1
 * @summary Compile-fail cases for Foreach.
 * @topic Language
 * @topic ControlFlow
 *
 * invalid-foreach-on-int                   // Foreach requires an iterable collection.
 * invalid-foreach-over-integer-literal     // An integer literal is not a foreach range.
 * invalid-foreach-missing-colon            // Foreach header requires a colon before the range.
 * invalid-foreach-element-type-mismatch    // Foreach variable type must accept the range value.
 * invalid-foreach-over-string-literal      // A string literal is not a foreach range.
 * invalid-foreach-missing-next             // An iterable must declare opForNext.
 * invalid-foreach-over-primitive           // Compile-rejection form retained from legacy foreach over primitive.
 * invalid-foreach-missing-begin            // An iterable must declare opForBegin.
 * invalid-foreach-missing-value            // An iterable must declare opForValue.
 */
/**
 * @begin invalid-foreach-on-int
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
 * @begin invalid-foreach-over-integer-literal
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
 * @begin invalid-foreach-missing-colon
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
 * @begin invalid-foreach-element-type-mismatch
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
 * @begin invalid-foreach-over-string-literal
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
 * @begin invalid-foreach-missing-next
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
/**
 * @begin invalid-foreach-over-primitive
 * @summary Compile-rejection form retained from legacy foreach over primitive.
 * @topic Negative
 */
void Test()
{
	int X = 5;
	for (int Val : X)
	{
	}
}
/** @end */
/**
 * @begin invalid-foreach-missing-begin
 * @summary An iterable must declare opForBegin.
 * @topic Negative
 */
struct FBrokenRange
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
/** @end */
/**
 * @begin invalid-foreach-missing-value
 * @summary An iterable must declare opForValue.
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
/** @end */
