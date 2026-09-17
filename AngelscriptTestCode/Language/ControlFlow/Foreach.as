/**
 * @version v1
 * @summary Foreach over a script iterable using the opFor protocol.
 * @topic Language
 * @topic ControlFlow
 *
 * foreach                       // Complete opForBegin/opForEnd/opForNext/opForValue range and a summing foreach.
 * foreach-break-continue        // Foreach that skips the first value and breaks on a negative sentinel.
 * foreach-container-mutation    // Foreach that writes through opForValue references into stored elements.
 * foreach-value-reference       // Value, reference, and const-reference foreach variables over one range.
 * foreach-empty-range           // Foreach over an empty opFor range visits nothing.
 * foreach-over-array            // Explicitly typed foreach over a TArray visits each element.
 * foreach-keyword-syntax        // The foreach keyword iterates an opFor range with an explicit type.
 */
/**
 * @begin foreach
 * @summary Complete opForBegin/opForEnd/opForNext/opForValue range and a summing foreach.
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
 * @begin foreach-break-continue
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
 * @begin foreach-container-mutation
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
 * @begin foreach-value-reference
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
 * @begin foreach-empty-range
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
 * @begin foreach-over-array
 * @summary Explicitly typed foreach over a TArray visits each element.
 * @topic ControlFlow
 */
int ForeachOverArray()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(3);
	int Total = 0;
	for (int Value : Values)
	{
		Total += Value;
	}
	return Total;
}
/** @end */
/**
 * @begin foreach-keyword-syntax
 * @summary The foreach keyword iterates an opFor range with an explicit type.
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

int ForeachKeyword()
{
	FIntRange Values;
	Values.First = 1;
	Values.Last = 4;
	int Total = 0;
	foreach (int Value : Values)
	{
		Total += Value;
	}
	return Total;
}
/** @end */
