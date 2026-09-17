/**
 * @version v1
 * @summary Assignment and compound assignment forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * assign-int                          // Plain assignment to an integer local.
 * assign-float                        // Plain assignment to a float local.
 * assign-bool                         // Plain assignment to a bool local.
 * add-assign-int                      // Integer plus-assign.
 * sub-assign-int                      // Integer minus-assign.
 * mul-assign-int                      // Integer multiply-assign.
 * div-assign-int                      // Integer divide-assign.
 * mod-assign-int                      // Integer remainder-assign.
 * power-assign-int                    // Integer power-assign using the live **= token.
 * and-assign-int                      // Integer bitwise and-assign using the live &= token.
 * or-assign-int                       // Integer bitwise or-assign using the live |= token.
 * xor-assign-int                      // Integer bitwise xor-assign using the live ^= token.
 * shift-left-assign-int               // Integer shift-left-assign using the live <<= token.
 * shift-right-assign-int              // Integer shift-right-assign using the live >>= token.
 * shift-right-arith-assign-int        // Integer arithmetic shift-right-assign using the live >>>= token.
 * string-concatenation-plus-assign    // Plus-assign concatenates onto a string local.
 */
/**
 * @begin assign-int
 * @summary Plain assignment to an integer local.
 */
int AssignInt()
{
	int X = 0;
	X = 5;
	return X;
}
/** @end */
/**
 * @begin assign-float
 * @summary Plain assignment to a float local.
 * @topic Operators
 */
float AssignFloat()
{
	float X = 0.0f;
	X = 1.5f;
	return X;
}
/** @end */
/**
 * @begin assign-bool
 * @summary Plain assignment to a bool local.
 * @topic Operators
 */
bool AssignBool()
{
	bool Flag = false;
	Flag = true;
	return Flag;
}
/** @end */
/**
 * @begin add-assign-int
 * @summary Integer plus-assign.
 * @topic Operators
 */
int AddAssignInt()
{
	int X = 0;
	X += 5;
	return X;
}
/** @end */
/**
 * @begin sub-assign-int
 * @summary Integer minus-assign.
 * @topic Operators
 */
int SubAssignInt()
{
	int X = 10;
	X -= 3;
	return X;
}
/** @end */
/**
 * @begin mul-assign-int
 * @summary Integer multiply-assign.
 * @topic Operators
 */
int MulAssignInt()
{
	int X = 2;
	X *= 3;
	return X;
}
/** @end */
/**
 * @begin div-assign-int
 * @summary Integer divide-assign.
 * @topic Operators
 */
int DivAssignInt()
{
	int X = 10;
	X /= 2;
	return X;
}
/** @end */
/**
 * @begin mod-assign-int
 * @summary Integer remainder-assign.
 * @topic Operators
 */
int ModAssignInt()
{
	int X = 10;
	X %= 3;
	return X;
}
/** @end */
/**
 * @begin power-assign-int
 * @summary Integer power-assign using the live **= token.
 * @topic Operators
 */
int PowerAssignInt()
{
	int X = 2;
	X **= 3;
	return X;
}
/** @end */
/**
 * @begin and-assign-int
 * @summary Integer bitwise and-assign using the live &= token.
 * @topic Operators
 */
int AndAssignInt()
{
	int X = 255;
	X &= 15;
	return X;
}
/** @end */
/**
 * @begin or-assign-int
 * @summary Integer bitwise or-assign using the live |= token.
 * @topic Operators
 */
int OrAssignInt()
{
	int X = 0;
	X |= 255;
	return X;
}
/** @end */
/**
 * @begin xor-assign-int
 * @summary Integer bitwise xor-assign using the live ^= token.
 * @topic Operators
 */
int XorAssignInt()
{
	int X = 255;
	X ^= 15;
	return X;
}
/** @end */
/**
 * @begin shift-left-assign-int
 * @summary Integer shift-left-assign using the live <<= token.
 * @topic Operators
 */
int ShiftLeftAssignInt()
{
	int X = 1;
	X <<= 4;
	return X;
}
/** @end */
/**
 * @begin shift-right-assign-int
 * @summary Integer shift-right-assign using the live >>= token.
 * @topic Operators
 */
int ShiftRightAssignInt()
{
	int X = 16;
	X >>= 2;
	return X;
}
/** @end */
/**
 * @begin shift-right-arith-assign-int
 * @summary Integer arithmetic shift-right-assign using the live >>>= token.
 * @topic Operators
 */
int ShiftRightArithAssignInt()
{
	int X = -8;
	X >>>= 2;
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
