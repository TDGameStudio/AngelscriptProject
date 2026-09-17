/**
 * @version v1
 * @summary Observe TotalSize as the archive byte count for empty and filled buffers.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TotalSize as the archive byte count for empty and filled buffers.
 * @topic Baseline
 */
// TArray as the zero/default value. No text specifier applies.
// Expected observations: TotalSize() is 12 for the filled buffer and 0 for
// the empty buffer. The value does not change after Tell/Seek because size
// is not the cursor.
// Boundary/ownership: TotalSize reports the borrowed array length. The reader
// does not copy Data solely to answer size.

namespace TS_FMemoryReader_ConversionAndFormatting_01
{
	bool Observe_TotalSize_Nominal()
	{
		TArray<uint8> Data;
		Data.Add(0x41);
		Data.Add(0x42);
		Data.Add(0x10);
		Data.Add(0x00);
		Data.Add(0x78);
		Data.Add(0x56);
		Data.Add(0x34);
		Data.Add(0x12);
		Data.Add(0x43);
		Data.Add(0x44);
		Data.Add(0x45);
		Data.Add(0x46);
		FMemoryReader Reader(Data);
		int FilledSize = Reader.TotalSize();
		Reader.Seek(4);
		int SizeAfterSeek = Reader.TotalSize();
		bool bFilledSizeStable = FilledSize == 12 && SizeAfterSeek == 12;

		TArray<uint8> Empty;
		FMemoryReader EmptyReader(Empty);
		int EmptySize = EmptyReader.TotalSize();
		return bFilledSizeStable && EmptySize == 0;
	}
}
/** @end */
