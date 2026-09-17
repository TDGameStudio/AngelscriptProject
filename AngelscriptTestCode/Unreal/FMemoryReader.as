/**
 * @version v1
 * @summary FMemoryReader host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FMemoryReader
 *
 * tell
 * seek
 * skip
 * total-size
 * reader
 * read-int-8
 * read-u-int-8
 * read-int-16
 * read-u-int-16
 * read-int-32
 * read-u-int-32
 * read-int-64
 * read-u-int-64
 * read-float
 * read-double
 * read-bytes
 * read-ansi-string
 */
/**
 * @begin tell
 * @summary Seeking or skipping past TotalSize is the out-of-bounds diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveTellNominal
 * @summary Seeking or skipping past TotalSize is the out-of-bounds diagnostic path.
 * @covers FMemoryReader.tell
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTellNominal()
{
	TArray<uint8> Data = MakeCursorProbeData();
	FMemoryReader Reader(Data);
	int FreshTell = Reader.Tell();
	Reader.ReadUInt8();
	int AfterReadTell = Reader.Tell();
	TArray<uint8> Empty;
	FMemoryReader EmptyReader(Empty);
	int EmptyTell = EmptyReader.Tell();
	return FreshTell == 0 && AfterReadTell == 1 && EmptyTell == 0;
}
/** @end */
/**
 * @begin seek
 * @summary Seeking or skipping past TotalSize is the out-of-bounds diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveSeekNominal
 * @summary Seeking or skipping past TotalSize is the out-of-bounds diagnostic path.
 * @covers FMemoryReader.seek
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSeekNominal()
{
	TArray<uint8> Data = MakeCursorProbeData();
	FMemoryReader Reader(Data);
	int Before = Reader.Tell();
	Reader.Seek(4);
	int AfterSeek = Reader.Tell();
	Reader.Seek(4);
	int AfterRepeat = Reader.Tell();
	Reader.Seek(0);
	int Restored = Reader.Tell();
	return Before == 0 && AfterSeek == 4 && AfterRepeat == 4 && Restored == 0;
}
/** @end */
/**
 * @begin skip
 * @summary Seeking or skipping past TotalSize is the out-of-bounds diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveSkipNominal
 * @summary Seeking or skipping past TotalSize is the out-of-bounds diagnostic path.
 * @covers FMemoryReader.skip
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSkipNominal()
{
	TArray<uint8> Data = MakeCursorProbeData();
	FMemoryReader Reader(Data);
	Reader.Seek(2);
	int BeforeSkip = Reader.Tell();
	Reader.Skip(2);
	int AfterSkip = Reader.Tell();
	Reader.Skip(0);
	int AfterZeroSkip = Reader.Tell();
	return BeforeSkip == 2 && AfterSkip == 4 && AfterZeroSkip == 4;
}
/** @end */
/**
 * @begin total-size
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveTotalSizeNominal
 * @summary Expected
 * @covers FMemoryReader.total-size
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: TotalSize() is 12 for the filled buffer and 0 for
// the empty buffer. The value does not change after Tell/Seek because size
// is not the cursor.
// Boundary/ownership: TotalSize reports the borrowed array length. The reader
// does not copy Data solely to answer size.
bool ObserveTotalSizeNominal()
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
/** @end */
/**
 * @begin reader
 * @summary does not take ownership of Data.
 * @topic Unreal
 */
/**
 * @function ObserveReaderNominal
 * @summary does not take ownership of Data.
 * @covers FMemoryReader.reader
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReaderNominal()
{
	TArray<uint8> Data = MakeIntegerProbeData();
	FMemoryReader DefaultReader(Data);
	int DefaultSize = DefaultReader.TotalSize();
	FMemoryReader SwappedReader(Data, true);
	int SwappedSize = SwappedReader.TotalSize();
	return DefaultSize == 16 && SwappedSize == 16;
}
/** @end */
/**
 * @begin read-int-8
 * @summary does not take ownership of Data.
 * @topic Unreal
 */
/**
 * @function ObserveReadInt8Nominal
 * @summary does not take ownership of Data.
 * @covers FMemoryReader.read-int-8
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReadInt8Nominal()
{
	TArray<uint8> Data = MakeIntegerProbeData();
	FMemoryReader Reader(Data);
	int8 Value = Reader.ReadInt8();
	return Value == 0x01 && Reader.Tell() == 1;
}
/** @end */
/**
 * @begin read-u-int-8
 * @summary does not take ownership of Data.
 * @topic Unreal
 */
/**
 * @function ObserveReadUInt8Nominal
 * @summary does not take ownership of Data.
 * @covers FMemoryReader.read-u-int-8
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReadUInt8Nominal()
{
	TArray<uint8> Data = MakeIntegerProbeData();
	FMemoryReader Reader(Data);
	uint8 First = Reader.ReadUInt8();
	uint8 Second = Reader.ReadUInt8();
	return First == 0x01 && Second == 0x02 && Reader.Tell() == 2;
}
/** @end */
/**
 * @begin read-int-16
 * @summary does not take ownership of Data.
 * @topic Unreal
 */
/**
 * @function ObserveReadInt16Nominal
 * @summary does not take ownership of Data.
 * @covers FMemoryReader.read-int-16
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReadInt16Nominal()
{
	TArray<uint8> Data = MakeIntegerProbeData();
	FMemoryReader Reader(Data);
	int16 Value = Reader.ReadInt16();
	return Value == 0x0201 && Reader.Tell() == 2;
}
/** @end */
/**
 * @begin read-u-int-16
 * @summary does not take ownership of Data.
 * @topic Unreal
 */
/**
 * @function ObserveReadUInt16Nominal
 * @summary does not take ownership of Data.
 * @covers FMemoryReader.read-u-int-16
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReadUInt16Nominal()
{
	TArray<uint8> Data = MakeIntegerProbeData();
	FMemoryReader Reader(Data);
	Reader.ReadUInt8();
	uint16 Value = Reader.ReadUInt16();
	return Value == 0x0302 && Reader.Tell() == 3;
}
/** @end */
/**
 * @begin read-int-32
 * @summary does not take ownership of Data.
 * @topic Unreal
 */
/**
 * @function ObserveReadInt32Nominal
 * @summary does not take ownership of Data.
 * @covers FMemoryReader.read-int-32
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReadInt32Nominal()
{
	TArray<uint8> Data = MakeIntegerProbeData();
	FMemoryReader Reader(Data);
	Reader.Seek(4);
	int32 Value = Reader.ReadInt32();
	return Value == 0x12345678 && Reader.Tell() == 8;
}
/** @end */
/**
 * @begin read-u-int-32
 * @summary does not take ownership of Data.
 * @topic Unreal
 */
/**
 * @function ObserveReadUInt32Nominal
 * @summary does not take ownership of Data.
 * @covers FMemoryReader.read-u-int-32
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReadUInt32Nominal()
{
	TArray<uint8> Data = MakeIntegerProbeData();
	FMemoryReader Reader(Data);
	Reader.Seek(4);
	uint32 Value = Reader.ReadUInt32();
	return Value == 0x12345678 && Reader.Tell() == 8;
}
/** @end */
/**
 * @begin read-int-64
 * @summary does not take ownership of Data.
 * @topic Unreal
 */
/**
 * @function ObserveReadInt64Nominal
 * @summary does not take ownership of Data.
 * @covers FMemoryReader.read-int-64
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReadInt64Nominal()
{
	TArray<uint8> Data = MakeIntegerProbeData();
	FMemoryReader Reader(Data);
	int64 Value = Reader.ReadInt64();
	int64 Expected = (int64(0x12345678) << 32) | int64(0x04030201);
	return Reader.Tell() == 8 && Value == Expected;
}
/** @end */
/**
 * @begin read-u-int-64
 * @summary does not take ownership of Data.
 * @topic Unreal
 */
/**
 * @function ObserveReadUInt64Nominal
 * @summary does not take ownership of Data.
 * @covers FMemoryReader.read-u-int-64
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReadUInt64Nominal()
{
	TArray<uint8> Data = MakeIntegerProbeData();
	FMemoryReader Reader(Data);
	uint64 Value = Reader.ReadUInt64();
	uint64 Expected = (uint64(0x12345678) << 32) | uint64(0x04030201);
	return Reader.Tell() == 8 && Value == Expected;
}
/** @end */
/**
 * @begin read-float
 * @summary does not take ownership of Data.
 * @topic Unreal
 */
/**
 * @function ObserveReadFloatNominal
 * @summary does not take ownership of Data.
 * @covers FMemoryReader.read-float
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReadFloatNominal()
{
	TArray<uint8> Data;
	Data.Add(0x00);
	Data.Add(0x00);
	Data.Add(0x80);
	Data.Add(0x3f);
	FMemoryReader Reader(Data);
	float32 Value = Reader.ReadFloat();
	return Reader.Tell() == 4 && Value == 1.0;
}
/** @end */
/**
 * @begin read-double
 * @summary observed by later Seek/Skip tests.
 * @topic Unreal
 */
/**
 * @function ObserveReadDoubleNominal
 * @summary observed by later Seek/Skip tests.
 * @covers FMemoryReader.read-double
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveReadDoubleNominal()
{
	TArray<uint8> Data = MakeTailProbeData();
	FMemoryReader Reader(Data);
	float64 Value = Reader.ReadDouble();
	return Reader.Tell() == 8 && Reader.TotalSize() == 12 && Math::IsFinite(Value);
}
/** @end */
/**
 * @begin read-bytes
 * @summary observed by later Seek/Skip tests.
 * @topic Unreal
 */
/**
 * @function ObserveReadBytesNominal
 * @summary observed by later Seek/Skip tests.
 * @covers FMemoryReader.read-bytes
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveReadBytesNominal()
{
	TArray<uint8> Data = MakeTailProbeData();
	FMemoryReader Reader(Data);
	Reader.Seek(8);
	TArray<uint8> TailBytes = Reader.ReadBytes(4);
	bool bCountMatches = TailBytes.Num() == 4;
	bool bOrderMatches = bCountMatches && TailBytes[0] == 0x43 && TailBytes[1] == 0x44 && TailBytes[2] == 0x45 && TailBytes[3] == 0x46;
	bool bCursorAtEnd = Reader.Tell() == 12;

	FMemoryReader EmptyReader(Data);
	TArray<uint8> EmptyBytes = EmptyReader.ReadBytes(0);
	return bCountMatches && bOrderMatches && bCursorAtEnd && EmptyBytes.Num() == 0;
}
/** @end */
/**
 * @begin read-ansi-string
 * @summary observed by later Seek/Skip tests.
 * @topic Unreal
 */
/**
 * @function ObserveReadAnsiStringNominal
 * @summary observed by later Seek/Skip tests.
 * @covers FMemoryReader.read-ansi-string
 * @inputs FMemoryReader values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveReadAnsiStringNominal()
{
	TArray<uint8> Data = MakeTailProbeData();
	FMemoryReader Reader(Data);
	Reader.Seek(8);
	FString Text = Reader.ReadAnsiString(4);
	bool bAnsiMatches = Text == "CDEF" && Reader.Tell() == 12;
	FMemoryReader EmptyReader(Data);
	FString EmptyText = EmptyReader.ReadAnsiString(0);
	return bAnsiMatches && EmptyText.IsEmpty();
}
/** @end */
