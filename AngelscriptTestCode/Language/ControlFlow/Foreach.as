/**
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
/**
 * @version invalid-foreach-over-primitive
 * @parent root
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
 * @version valid-foreach-empty-range
 * @parent root
 * @summary Foreach over an empty opFor range visits nothing.
 * @topic ControlFlow
 */
struct FEmptyRange
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
/** @end */
/**
 * @version invalid-foreach-missing-begin
 * @parent root
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
 * @version invalid-foreach-missing-value
 * @parent root
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
