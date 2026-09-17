/**
 * @version v1
 * @summary An import statement must end with a semicolon. Omitting it is a syntax error reported at the import row. This file is the illegal program itself; do not add the semicolon or extra declarations, since the missing.
 * @topic Language
 */
/**
 * @version root
 * @summary An import statement must end with a semicolon. Omitting it is a syntax error reported at the import row. This file is the illegal program itself; do not add the semicolon or extra declarations, since the missing.
 * @topic Negative
 */
import Tests.Preprocessor.MissingSemicolon.Shared

/**
 * Uses the imported module. It never runs, since the malformed import is
 * rejected first.
 *
 * @Covers Preprocessor.Imports
 * @Inputs the imported module's SharedValue
 * @Return the imported value, never reached
 */
int UseShared()
{
	return SharedValue();
}
/** @end */
