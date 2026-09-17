/**
 * @version v1
 * @summary Ordering two FTexts with the less-than operator is rejected: this fork exposes no ordering operator for text. This file is the illegal program itself; do not compare the underlying strings instead, since the missing.
 * @topic Language
 */
/**
 * @version root
 * @summary Ordering two FTexts with the less-than operator is rejected: this fork exposes no ordering operator for text. This file is the illegal program itself; do not compare the underlying strings instead, since the missing.
 * @topic Negative
 */
/** */
bool TryTextOrdering()
{
	FText Left = FText::FromString("A");
	FText Right = FText::FromString("B");
	return Left < Right;
}
/** @end */
