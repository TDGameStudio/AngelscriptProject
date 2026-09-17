/**
 * @version v1
 * @summary A module that imports another module which imports back forms an import cycle, which the preprocessor reports with the full chain. This file is one half of the cycle; the diagnostic names both modules. Do not add.
 * @topic Language
 */
/**
 * @version root
 * @summary A module that imports another module which imports back forms an import cycle, which the preprocessor reports with the full chain. This file is one half of the cycle; the diagnostic names both modules. Do not add.
 * @topic Negative
 */
import Tests.Preprocessor.ImportCycles.CircularB;

/**
 * Calls into the other half of the cycle. It never runs, since the cycle is
 * detected before any code is emitted.
 *
 * @Covers Preprocessor.Imports
 * @Inputs the imported module's FromB
 * @Return the imported value, never reached
 */
int FromA()
{
	return FromB();
}
/** @end */
