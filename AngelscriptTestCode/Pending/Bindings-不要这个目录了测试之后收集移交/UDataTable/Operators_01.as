/**
 * @version v1
 * @summary Observe equality of FDataTableRowHandle and FDataTableCategoryHandle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe equality of FDataTableRowHandle and FDataTableCategoryHandle.
 * @topic Baseline
 */
// bool bEqual = LeftCategoryHandle == RightCategoryHandle;
// Inputs: Default-empty handles, copies of those defaults, and handles whose
// RowName/ColumnName/RowContents differ (n"Alpha" vs n"Beta", n"Category"
// vs n"Other").
// Expected observations: Two defaults compare true. Copy identity is true.
// Changing RowName or category fields makes equality false.
// Boundary/ownership: Comparison uses table, row, and category identity. The
// operators do not mutate either handle.

namespace TS_UDataTable_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FDataTableRowHandle LeftRowHandle;
		FDataTableRowHandle RightRowHandle;
		bool bDefaultRowsEqual = LeftRowHandle == RightRowHandle;
		RightRowHandle.RowName = n"Alpha";
		bool bRowNameDifference = LeftRowHandle == RightRowHandle;
		FDataTableRowHandle CopiedRow = LeftRowHandle;
		CopiedRow.RowName = n"Alpha";
		FDataTableRowHandle MatchingRow;
		MatchingRow.RowName = n"Alpha";
		bool bMatchingRowNamesEqual = CopiedRow == MatchingRow;
		MatchingRow.RowName = n"Beta";
		bool bDifferentRowNamesUnequal = CopiedRow == MatchingRow;

		FDataTableCategoryHandle LeftCategoryHandle;
		FDataTableCategoryHandle RightCategoryHandle;
		bool bDefaultCategoriesEqual = LeftCategoryHandle == RightCategoryHandle;
		RightCategoryHandle.ColumnName = n"Category";
		RightCategoryHandle.RowContents = n"Enemy";
		bool bCategoryFieldsDifference = LeftCategoryHandle == RightCategoryHandle;
		FDataTableCategoryHandle MatchingCategory;
		MatchingCategory.ColumnName = n"Category";
		MatchingCategory.RowContents = n"Enemy";
		bool bMatchingCategoriesEqual = RightCategoryHandle == MatchingCategory;
		MatchingCategory.RowContents = n"Item";
		bool bDifferentCategoryContentsUnequal = RightCategoryHandle == MatchingCategory;

		return bDefaultRowsEqual &&
			!bRowNameDifference &&
			bMatchingRowNamesEqual &&
			!bDifferentRowNamesUnequal &&
			bDefaultCategoriesEqual &&
			!bCategoryFieldsDifference &&
			bMatchingCategoriesEqual &&
			!bDifferentCategoryContentsUnequal;
	}
}
/** @end */
