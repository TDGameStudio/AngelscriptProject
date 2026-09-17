/**
 * @version v1
 * @summary Initialising an FString from an integer literal is rejected: numbers do not convert to text implicitly. This file is the illegal program itself; do not quote the literal or use a formatting call, since the implicit.
 * @topic Language
 */
/**
 * @version root
 * @summary Initialising an FString from an integer literal is rejected: numbers do not convert to text implicitly. This file is the illegal program itself; do not quote the literal or use a formatting call, since the implicit.
 * @topic Negative
 */
/** */
void Test()
{
	FString S = 42;
}
/** @end */
