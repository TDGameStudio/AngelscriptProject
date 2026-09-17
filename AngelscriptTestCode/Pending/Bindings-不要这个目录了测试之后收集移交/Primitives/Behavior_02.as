/**
 * @version v1
 * @summary Observe internal single-precision math constants and normal tolerances used by float bindings. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe internal single-precision math constants and normal tolerances used by float bindings. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// const float32 <__THRESH_VECTOR_NORMALIZED_flt | __THRESH_NORMALS_ARE_PARALLEL_flt | __THRESH_NORMALS_ARE_ORTHOGONAL_flt>;
// Inputs: The published float32 constants themselves; 0.0 as the empty
// comparison and PI as the related double-width neighbor.
// Expected observations: Float32 PI family values are positive and ordered
// like the double constants. Thresholds are positive.
// Boundary/ownership: These identifiers are internal float32 companions of
// the public double constants. They are immutable and do not allocate.

namespace TS_Primitives_Behavior_02
{
	// Float32 math constants keep the same ordering as the double-width family.
	bool Observe_Surface011_Nominal()
	{
		return __EULERS_NUMBER_flt > 2.0 && __PI_flt > 3.0 && __HALF_PI_flt < __PI_flt && __TWO_PI_flt > __PI_flt && __SMALL_NUMBER_flt > 0.0 && __KINDA_SMALL_NUMBER_flt > __SMALL_NUMBER_flt && __BIG_NUMBER_flt > __TWO_PI_flt;
	}

	// Float32 normal thresholds are positive.
	bool Observe_Surface012_Nominal()
	{
		return __THRESH_VECTOR_NORMALIZED_flt > 0.0 && __THRESH_NORMALS_ARE_PARALLEL_flt > 0.0 && __THRESH_NORMALS_ARE_ORTHOGONAL_flt > 0.0;
	}
}
/** @end */
