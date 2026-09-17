/**
 * @version v1
 * @summary A comma expression outside a for clause is rejected: this fork supports the comma operator only inside for clauses. This file is the illegal program itself; do not wrap it in a for clause, since the comma expression is.
 * @topic Language
 */
/**
 * @version root
 * @summary A comma expression outside a for clause is rejected: this fork supports the comma operator only inside for clauses. This file is the illegal program itself; do not wrap it in a for clause, since the comma expression is.
 * @topic Negative
 */
/** */
int CommaExpression()
{
	int A = 1;
	int B = 2;
	int C = 3;
	int X = (A, B, C);
	return X;
}
/** @end */
