/**
 * @version v1
 * @summary For-loop clause shapes including omitted and comma clauses.
 * @topic Language
 * @topic Syntax
 *
 * for-clauses
 * for-basic-shapes
 * for-comma-clauses
 * for-omitted-clauses
 * for-positive-syntax-forms
 * for-infinite-with-break
 */
/**
 * @begin for-clauses
 * @summary A basic for, omitted clauses, and a comma increment.
 */
int ForBasic()
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
/** @end */
/**
 * @begin for-basic-shapes
 * @summary Positive language form retained from legacy for basic shapes.
 * @topic Syntax
 */
int ForCountUp()
	{
		int Sum = 0;
		for (int i = 0; i < 10; i++)
		{
			Sum += i;
		}
		return Sum;
	}

	int ForCountDown()
	{
		int Sum = 0;
		for (int i = 10; i >= 0; i--)
		{
			Sum += i;
		}
		return Sum;
	}

	int ForStepTwo()
	{
		int Sum = 0;
		for (int i = 0; i < 10; i += 2)
		{
			Sum += i;
		}
		return Sum;
	}

	int ForEmptyBody()
	{
		int Count = 0;
		for (int i = 0; i < 5; i++)
			Count++;
		return Count;
	}

	int ForMultipleVars()
	{
		int Sum = 0;
		for (int i = 0, j = 10; i < 5; i++, j--)
		{
			Sum += i + j;
		}
		return Sum;
	}
/** @end */
/**
 * @begin for-comma-clauses
 * @summary Positive language form retained from legacy for comma clauses.
 * @topic Syntax
 */
int ForCommaClauses()
	{
		int Sum = 0;
		for (int i = 0, j = 10; i < 5; i++, j--)
		{
			Sum += i + j;
		}
		return Sum;
	}
/** @end */
/**
 * @begin for-omitted-clauses
 * @summary Positive language form retained from legacy for omitted clauses.
 * @topic Syntax
 */
int ForNoInit()
	{
		int i = 0;
		int Sum = 0;
		for (; i < 5; i++)
		{
			Sum += i;
		}
		return Sum;
	}

	int ForNoCondition()
	{
		int Sum = 0;
		int i = 0;
		for (;;)
		{
			Sum += i;
			i++;
			if (i >= 5)
				break;
		}
		return Sum;
	}

	int ForNoIncrement()
	{
		int Sum = 0;
		for (int i = 0; i < 5;)
		{
			Sum += i;
			i++;
		}
		return Sum;
	}

	int ForAllEmpty()
	{
		int Sum = 0;
		int i = 0;
		for (;;)
		{
			Sum += i;
			i++;
			if (i >= 3)
				break;
		}
		return Sum;
	}

	int ForDecrementStep()
	{
		int Sum = 0;
		for (int i = 20; i > 0; i -= 3)
		{
			Sum += i;
		}
		return Sum;
	}
/** @end */
/**
 * @begin for-positive-syntax-forms
 * @summary Positive language form retained from legacy for positive syntax forms.
 * @topic Syntax
 */
int BasicFor()
	{
		int S = 0;
		for (int I = 0; I < 5; ++I)
		{
			S += I;
		}
		return S;
	}

	int Decrement()
	{
		int S = 0;
		for (int I = 3; I > 0; --I)
		{
			S += I;
		}
		return S;
	}

	int Empty()
	{
		int I = 0;
		for (;;)
		{
			if (I >= 3)
			{
				break;
			}
			++I;
		}
		return I;
	}

	int Nested()
	{
		int S = 0;
		for (int I = 0; I < 3; ++I)
		{
			for (int J = 0; J < 2; ++J)
			{
				++S;
			}
		}
		return S;
	}

	int CompoundStep()
	{
		int S = 0;
		for (int I = 0; I < 100; I += 25)
		{
			++S;
		}
		return S;
	}
/** @end */
/**
 * @begin for-infinite-with-break
 * @summary A for with omitted clauses that exits by break.
 * @topic Syntax
 */
int UntilThree()
{
	int Index = 0;
	for (;;)
	{
		if (Index == 3)
		{
			break;
		}
		++Index;
	}
	return Index;
}
/** @end */
