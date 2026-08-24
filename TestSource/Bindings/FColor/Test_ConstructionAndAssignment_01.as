// Purpose: Observe in-place channel addition of FColor values, including copy
// independence of the addend.
// AS-facing API: Color += ColorB;
// Inputs: Color (10, 20, 30, 40), ColorB (1, 2, 3, 4), a copied ColorB, and
// Black as the zero addend.
// Expected observations: After += the destination channels increase by ColorB.
// ColorB is unchanged. Adding Black leaves Color unchanged.
// Boundary/ownership: += mutates Color in place and saturates per byte
// channel. ColorB is not owned or consumed.

namespace TS_FColor_ConstructionAndAssignment_01
{
	bool Observe_AddAssign_Nominal()
	{
		FColor Color(10, 20, 30, 40);
		FColor ColorB(1, 2, 3, 4);
		FColor CopiedAddend = ColorB;
		Color += ColorB;
		FColor Restored(10, 20, 30, 40);
		Restored += FColor::Black;
		return Color.R == 11 && Color.G == 22 && Color.B == 33 && Color.A == 44 && ColorB.R == CopiedAddend.R && ColorB.G == CopiedAddend.G && Restored.R == 10 && Restored.G == 20 && Restored.B == 30;
	}
}
