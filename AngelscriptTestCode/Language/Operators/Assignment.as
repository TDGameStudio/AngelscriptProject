/**
 * @version v1
 * @summary Assignment and compound assignment forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * assignment
 * string-concatenation-plus-assign
 */
/**
 * @begin assignment
 * @summary Plain assignment plus arithmetic, bitwise, and shift compound assignments.
 */
int SimpleAssign()
{
	int X = 0;
	X = 5;
	return X;
}

int AddAssign()
{
	int X = 0;
	X += 5;
	return X;
}

int SubAssign()
{
	int X = 10;
	X -= 3;
	return X;
}

int MulAssign()
{
	int X = 2;
	X *= 3;
	return X;
}

int DivAssign()
{
	int X = 10;
	X /= 2;
	return X;
}

int ModAssign()
{
	int X = 10;
	X %= 3;
	return X;
}

int BitAndAssign()
{
	int X = 255;
	X &= 15;
	return X;
}

int BitOrAssign()
{
	int X = 0;
	X |= 255;
	return X;
}

int BitXorAssign()
{
	int X = 255;
	X ^= 15;
	return X;
}

int ShiftLAssign()
{
	int X = 1;
	X <<= 4;
	return X;
}

int ShiftRAssign()
{
	int X = 16;
	X >>= 2;
	return X;
}
/** @end */
/**
 * @begin string-concatenation-plus-assign
 * @summary Plus-assign concatenates onto a string local.
 * @topic Operators
 */
string ConcatAssign()
{
	string Text = "Hello";
	Text += " World";
	return Text;
}
/** @end */
