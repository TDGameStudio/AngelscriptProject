/**
 * @version v1
 * @summary A triple ampersand is rejected: this language has no such operator, only && and the bitwise &. This file is the illegal program itself; do not reduce it to &&, since the triple form is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A triple ampersand is rejected: this language has no such operator, only && and the bitwise &. This file is the illegal program itself; do not reduce it to &&, since the triple form is the point.
 * @topic Negative
 */
/** */
void Test()
{
	bool X = true &&& false;
}
/** @end */
