/**
 * @version v1
 * @summary The other half of the import cycle: this module imports the module that imports it. The preprocessor reports the chain in both directions, so this file reproduces the diagnostic from the opposite end. Do not add.
 * @topic Language
 */
/**
 * @version root
 * @summary The other half of the import cycle: this module imports the module that imports it. The preprocessor reports the chain in both directions, so this file reproduces the diagnostic from the opposite end. Do not add.
 * @topic Negative
 */
import Tests.Preprocessor.ImportCycles.CircularA;

/**
 * Calls into the other half of the cycle. It never runs, since the cycle is
 * detected before any code is emitted.
 *
 * @Covers Preprocessor.Imports
 * @Inputs the imported module's FromA
 * @Return the imported value, never reached
 */
int FromB()
{
	return FromA();
}
/** @end */
