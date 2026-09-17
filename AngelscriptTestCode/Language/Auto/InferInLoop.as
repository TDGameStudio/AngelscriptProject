/**
 * @version v1
 * @summary Auto infers loop locals in for initializers and foreach variables.
 * @topic Language
 * @topic Auto
 *
 * infer-for-initializer      // for (auto Index = 0; ...) infers the loop index from its initializer.
 * infer-for-increment-use    // An inferred for-index is used in the increment and the body.
 * infer-foreach-value        // foreach (auto Value : Values) infers the opForValue type.
 * infer-foreach-reference    // foreach (auto& Value : Values) infers a reference to each element.
 * infer-foreach-key-value    // foreach (auto Value, auto Key : Values) infers both protocol results.
 */
/**
 * @begin infer-for-initializer
 * @summary for (auto Index = 0; ...) infers the loop index from its initializer.
 * @topic Auto
 */
int ForInitializer()
{
	int Total = 0;
	for (auto Index = 0; Index < 3; ++Index)
	{
		Total += 1;
	}
	return Total;
}
/** @end */
/**
 * @begin infer-for-increment-use
 * @summary An inferred for-index is used in the increment and the body.
 * @topic Auto
 */
int ForIncrementUse()
{
	int Total = 0;
	for (auto Index = 0; Index < 3; ++Index)
	{
		Total += Index;
	}
	return Total;
}
/** @end */
/**
 * @begin infer-foreach-value
 * @summary foreach (auto Value : Values) infers the opForValue type.
 * @topic Auto
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

int ForeachValue()
{
	FIntRange Values;
	Values.First = 1;
	Values.Last = 4;
	int Total = 0;
	foreach (auto Value : Values)
	{
		Total += Value;
	}
	return Total;
}
/** @end */
/**
 * @begin infer-foreach-reference
 * @summary foreach (auto& Value : Values) infers a reference to each element.
 * @topic Auto
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

int ForeachReference()
{
	FMutableRange Values;
	foreach (auto& Value : Values)
	{
		Value *= 2;
	}
	int Total = 0;
	foreach (auto Value : Values)
	{
		Total += Value;
	}
	return Total;
}
/** @end */
/**
 * @begin infer-foreach-key-value
 * @summary foreach (auto Value, auto Key : Values) infers both protocol results.
 * @topic Auto
 */
struct FKeyedRange
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

	int opForKey(int Iterator) const
	{
		return Iterator;
	}
}

int ForeachKeyValue()
{
	FKeyedRange Values;
	Values.First = 1;
	Values.Last = 4;
	int Total = 0;
	foreach (auto Value, auto Key : Values)
	{
		Total += Value + Key;
	}
	return Total;
}
/** @end */
