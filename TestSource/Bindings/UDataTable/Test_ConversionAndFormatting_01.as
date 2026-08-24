// Purpose: Observe FDataTableRowHandle.ToDebugString for default and filled
// handles.
// AS-facing API: FString Text = RowHandle.ToDebugString(bool bUseFullPath = false) const;
// Inputs: Default-null handle, a handle pointing at a transient UDataTable
// with RowName n"Alpha", bUseFullPath false/default omission, and true.
// Expected observations: Default ToDebugString is a non-empty diagnostic
// string. Full-path true is also non-empty. Filling DataTable/RowName changes
// the diagnostic text relative to the null handle.
// Boundary/ownership: ToDebugString returns a new FString. bUseFullPath only
// selects whether the table's object path is included.

namespace TS_UDataTable_ConversionAndFormatting_01
{
	bool Observe_ToDebugString_Nominal()
	{
		FDataTableRowHandle RowHandle;
		FString DefaultText = RowHandle.ToDebugString();
		FString DefaultFull = RowHandle.ToDebugString(true);
		FString DefaultShort = RowHandle.ToDebugString(false);

		UDataTable Table = Cast<UDataTable>(
			NewObject(GetTransientPackage(), UDataTable::StaticClass(), n"TSDataTableDebug", true));
		if (Table is null)
		{
			throw("TS_UDataTable_ConversionAndFormatting_01 setup: required Table is null");
		}
		RowHandle.DataTable = Table;
		RowHandle.RowName = n"Alpha";
		FString FilledShort = RowHandle.ToDebugString(false);
		FString FilledFull = RowHandle.ToDebugString(true);

		return DefaultText.Len() > 0 &&
			DefaultFull.Len() > 0 &&
			DefaultShort.Len() > 0 &&
			FilledShort.Len() > 0 &&
			FilledFull.Len() > 0 &&
			FilledShort != DefaultShort;
	}
}
