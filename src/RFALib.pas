(* ***** BEGIN LICENSE BLOCK *****
 * Version: GNU GPL 2.0
 *
 * The contents of this file are subject to the
 * GNU General Public License Version 2.0; you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * http://www.gnu.org/licenses/gpl.html
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is RFALib (http://code.google.com/p/bga)
 *
 * The Initial Developer of the Original Code is
 * Yann Papouin <yann.papouin at @ gmail.com>
 *
 * ***** END LICENSE BLOCK ***** *)

unit RFALib;

interface

{$DEFINE DEBUG_RFA}

uses
  DbugIntf, Windows, Classes, SysUtils, Contnrs;

type
  RFA_Result = record
    offset : integer;
    size : integer;
  end;

  function RFANew(src: string): integer;
  function RFAOpen(src: string): integer;
  function RFASave(dst: string): integer;

  procedure RFADecompressToStream(outputstream: TStream; Offset, Size: int64; silent: boolean = true);
  procedure RFAExtractToStream(Data: TStream; Offset, Size, UcSize: int64);
  procedure RFACopyToStream(Data: TStream; Offset, Size: int64);

  function RFADeleteData(Buf : TMemoryStream; Offset : int64; Size : int64) : RFA_Result; overload;
  function RFADeleteData(Offset : int64; Size : int64) : RFA_Result; overload;
  function RFADeleteFile(Offset : int64; Size : int64) : RFA_Result;
  function RFADeleteEntry(FullPath : AnsiString) : RFA_Result;

  function RFAInsertData(Data : TStream; Offset : Int64) : RFA_Result;
  function RFAInsertDataCompressed(Data : TStream; Offset : Int64) : RFA_Result;

  function RFAInsertFile(Data : TStream; Compressed : boolean = false) : RFA_Result;
  procedure RFAInsertEntry(FullPath : AnsiString; Offset, Size : Int64; cSize : Int64; Index : Cardinal);

  procedure RFAUpdateEntry(FullPath : AnsiString; NewOffset, NewUcSize, NewCSize : int64);
  procedure RFAReplaceData(Data : TStream; Offset : Int64; OldSize : int64);
  function RFAReplaceFile(Data : TStream) : Cardinal;



// -------------------------------------------------------------------------- //
// Battlefield 1942 .RFA support ============================================ //
// -------------------------------------------------------------------------- //

type
    pRFA_Entry = ^RFA_Entry;
    RFA_Entry = packed record
      csize: integer;
      ucsize: integer;
      offset: integer;
      unknown: array[0..2] of integer;
    end;

    pRFA_DataHeader = ^RFA_DataHeader;
    RFA_DataHeader = packed record
      csize: longword;
      ucsize: longword;
      doffset: longword;
    end;


  TFseAdd = procedure(Name: AnsiString; Offset, ucSize: Int64; Compressed : boolean; cSize : integer);
  TFseDetails = procedure(Total : integer; Index: integer; Offset, Size : Int64);

var
  FHandle: TStream = nil;
  FLargeBuf : TMemoryStream;
  FseAddProc : TFseAdd;
  FseDetailsProc : TFseDetails;

const
  NORMAL_DATA = false;
  COMPRESSED_DATA = true;

implementation

uses
  Math, CommonLib, MiniLZO;

const
  ENTRY_SIZE = 24;
  DWORD_SIZE = 4;
  SEGMENT_HEADER_SIZE = DWORD_SIZE*3;
  BUFFER_SIZE = 8192;
  SEGMENT_MAX_SIZE = 32768;
  VERSION_HEADER = 'Refractor2 FlatArchive 1.1  ';
  LZO1X_1_MEM_COMPRESS = 16384 * 4;

(*
RFA File format description
|==============================================
|-RFA_Header (6 Words [Exists only in DEMO])
|
|-RFA_DataSize (2 Words)
   |
   |-RFA_DATA  (each RFA_DATA has its own size)
   |-RFA_DATA
   |-RFA_DATA
   |-RFA_DATA
   |-...
   |-...
   |-...
   |-RFA_DATA
   |-RFA_DATA
   |-RFA_DATA
   |-RFA_DATA  -> At the end of this part, total raw data = RFA_DataSize

|-Element_Quantity (2 Words)
   |
   |-RFA_Entry (each entry has a fixed length of 12 words)
      |
      |-csize   (2 Words)
      |-ucsize  (2 Words)
      |-offset  (2 Words)
      |-dummy0  (2 Words)
      |-dummy1  (2 Words)
      |-dummy2  (2 Words)

   |-RFA_Entry
   |-RFA_Entry
   |-RFA_Entry
   |-RFA_Entry
   |-...
   |-...
   |-...
   |-RFA_Entry
   |-RFA_Entry
   |-RFA_Entry
 __|-RFA_Entry
|==============================================
*)


function StringFrom(AStream: TStream): AnsiString;
var
  Size: Cardinal;
begin
  AStream.Read(Size,4);   // Read string length (stored in a 32bits value)
  if Size > 255 then
  begin
    Size := 0;
    Result := EmptyStr;
    //raise Exception.Create('Max AnsiString size is 255');
  end
    else
  begin
    try
      SetLength(Result, Size);
      AStream.Read(Result[1], Size);
    finally

    end;
  end;
end;


// Jump to header, return true if we are using the retail format (not the demo one)
function RFA_Header : boolean;
var
  ID: array[0..27] of AnsiChar;
begin
  FHandle.Position := 0;
  FHandle.Read(ID, 28);
  Result := false;

  if ID <> VERSION_HEADER then
  begin
    FHandle.Position := 0;
    Result := true;
  end;
end;


function GetDataSize : LongWord;
begin
  RFA_Header;

  {$IfDef DEBUG_RFA}
  SendDebugFmt('Reading data size at 0x%x',[FHandle.Position]);
  {$EndIf}

  FHandle.Read(Result, DWORD_SIZE);   // Read data length (32bits)

  {$IfDef DEBUG_RFA}
  SendDebugFmt('Data size == %s',[SizeToStr(Result)]);
  {$EndIf}
end;


procedure SetElementQuantity(Quantity : LongWord);
begin
  FHandle.Seek(GetDataSize, soBeginning);  // Jump segment
  FHandle.Write(Quantity, DWORD_SIZE);     // write element quantity (32bits)
end;


function GetElementQuantity : LongWord;
begin
  FHandle.Seek(GetDataSize, soBeginning);  // Jump segment
  {$IfDef DEBUG_RFA}
  SendDebugFmt('Reading element quantity at 0x%x',[FHandle.Position]);
  {$EndIf}
  FHandle.Read(Result, DWORD_SIZE);           // Read element quantity (32bits)
  {$IfDef DEBUG_RFA}
  SendDebugFmt('Element quantity == %d',[Result]);
  {$EndIf}
end;


procedure SetDataSize(Size : LongWord);
begin
  RFA_Header;
  FHandle.Write(Size, DWORD_SIZE);     // write data Size (32bits)
  {$IfDef DEBUG_RFA}
  SendDebugFmt('New Data size == %s',[SizeToStr(Size)]);
  {$EndIf}
end;


function RFANew(src: string): integer;
var
  FileHandle : TStream;
  Value : longword;
begin
  Result := -1;
  FileHandle := TFileStream.Create(src, fmOpenReadWrite or fmCreate);
  if Assigned(FileHandle) then
  begin
    Value := 0;
    FileHandle.Write(Value, DWORD_SIZE);
    FileHandle.Write(Value, DWORD_SIZE);
    Result := 0;

    FileHandle.Free;
  end;
end;

function RFAOpen(src: string): integer;
var
  ENT: RFA_Entry;
  Path: AnsiString;
  NumE, x: integer;
  Position : integer;
  IsRetail: boolean;
begin
  Assert(Assigned(FseAddProc));
  Assert(Assigned(FseDetailsProc));

  if Assigned(FHandle) then
    FHandle.Free;

  try
    Fhandle := TFileStream.Create(src, fmOpenReadWrite);
  except
    on e:exception do
    try
      FHandle.Free;
      Fhandle := TFileStream.Create(src, fmOpenRead);
      Result := -1;
    except
      FHandle.Free;
      Result := -3;
    end;
  end;

  if Assigned(FHandle) then
  begin

    IsRetail := RFA_Header;
    NumE := GetElementQuantity;

    if NumE > 65535 then
      raise Exception.Create('NumE seems too high');

    for x:= 1 to NumE do
    begin

      Position := FHandle.Position;
      //Path := get32(FHandle);

      Path := StringFrom(FHandle);      // Read entire Path\Filename
      FHandle.Read(ENT, ENTRY_SIZE);    // Read rfa entry data (24 bytes);

      if IsRetail then
      begin
        if (ENT.ucsize = ENT.csize) then
        begin
          FseAddProc(Path, ENT.offset, ENT.ucsize, NORMAL_DATA, ENT.ucsize);
        end
          else
        begin
          FseAddProc(Path, ENT.offset, ENT.ucsize, COMPRESSED_DATA, ENT.csize);
        end;
      end
        else
      begin
        FseAddProc(Path, ENT.offset, ENT.ucsize, false, 0);
      end;

      FseDetailsProc(NumE, x, Position, FHandle.Position - Position);
    end;

    Result := NumE;

  end
  else
    Result := -2;

end;


function RFASave(dst: string): integer;
begin
  if Assigned(FHandle) and (FHandle is TFileStream) then
  begin
    if dst = (FHandle as TFileStream).FileName then
    //
  end;
end;

// Quicker if ReAllocated size of Buf is near the last one
function RFADeleteData(Buf : TMemoryStream; Offset : int64; Size : int64) : RFA_Result;
var
  NewSize : Int64;
begin
  Assert(Offset+Size <= FHandle.Size, 'Out of range');

  // Put final data in Buf
  FHandle.Seek(Offset+Size, soBeginning);
  NewSize := FHandle.Size - FHandle.Position;
  Buf.Size := NewSize;
  Buf.Seek(0, soBeginning);
  Buf.CopyFrom(FHandle, Buf.Size);

  // Write back shifted data into stream
  Buf.Seek(0, soBeginning);
  FHandle.Size := FHandle.Size - Size;
  FHandle.Seek(Offset, soBeginning);
  FHandle.CopyFrom(Buf, Buf.Size);

  Result.offset := Offset;
  Result.size := Size;
end;

function RFADeleteData(Offset : int64; Size : int64) : RFA_Result;
var
  Buf : TMemoryStream;
begin
  Buf := TMemoryStream.Create;
  Result := RFADeleteData(Buf, Offset, Size);
  Buf.Free;
end;

function RFADeleteFile(Offset : int64; Size : int64) : RFA_Result;
begin
  {$IfDef DEBUG_RFA}
  SendDebugFmt('Delete file at 0x%.8x with a size of %d',[Offset, Size]);
  {$EndIf}

  Result := RFADeleteData(FLargeBuf, Offset, Size);
  SetDataSize(GetDataSize - Size);
end;


procedure RFAUpdateEntry(FullPath : AnsiString; NewOffset, NewUcSize, NewCSize : int64);
var
  ENT: RFA_Entry;
  Path: AnsiString;
  NumE, x: integer;
begin
  NumE := GetElementQuantity;

  // Search the wanted entry
  for x:= 1 to NumE do
  begin
    Path := StringFrom(FHandle);
    FHandle.Read(ENT, ENTRY_SIZE);

    if Path = FullPath then
    begin
      ENT.offset := NewOffset;
      ENT.ucsize := NewUcSize;
      Ent.csize := NewCSize;
      FHandle.Position := FHandle.Position - ENTRY_SIZE;
      FHandle.Write(ENT, ENTRY_SIZE);
      Break;
    end;

    if x = NumE then
      raise Exception.Create('Path not found');
  end;
end;



function RFADeleteEntry(FullPath : AnsiString) : RFA_Result;
var
  ENT: RFA_Entry;
  Path: AnsiString;
  NumE, x: integer;
  Offset, DataOffset : Int64;
  Size, DataSize : Int64;
begin
  {$IfDef DEBUG_RFA}
  SendDebugFmt('Delete entry %s',[FullPath]);
  {$EndIf}

  Offset := 0;
  Size := 0;
  DataOffset := 0;
  DataSize := 0;

  NumE := GetElementQuantity;

  // Search the wanted entry
  for x:= 1 to NumE do
  begin
    Offset := FHandle.Position;
    Path := StringFrom(FHandle);
    FHandle.Read(ENT, ENTRY_SIZE);
    Size := FHandle.Position - Offset;

    if Path = FullPath then
    begin
      DataOffset := ENT.offset;
      DataSize := ENT.csize;
      Break;
    end;

    if x = NumE then
      raise Exception.Create('Path not found');
  end;

  // Delete this entry
  Result := RFADeleteData(Offset, Size);
  SetElementQuantity(GetElementQuantity-1);

  NumE := GetElementQuantity;
(*
  // Update all indexes
  for x:= 1 to NumE do
  begin
    Path := StringFrom(FHandle);
    FHandle.Read(ENT, ENTRY_SIZE);

    if ENT.offset >= DataOffset then
    begin
      SendDebugFmt('Changing offset of %d',[x]);
      ENT.offset := ENT.offset - DataSize;

      FHandle.Seek(-ENTRY_SIZE, soFromCurrent);
      FHandle.Write(ENT, ENTRY_SIZE);
    end;
  end;
*)
end;


procedure RFAReplaceData(Data : TStream; Offset : Int64; OldSize : int64);
begin
  RFADeleteData(Offset, OldSize);
  RFAInsertData(Data, Offset);
end;

function RFAReplaceFile(Data : TStream) : Cardinal;
begin
  Result := 0;
end;

function RFAInsertData(Data : TStream; Offset : Int64) : RFA_Result;
var
  Buf : TMemoryStream;
begin
  Buf := TMemoryStream.Create;

  FHandle.Seek(Offset, soBeginning);

  // Put final data in Buf
  Buf.Size := FHandle.Size - FHandle.Position;
  Buf.Seek(0, soBeginning);
  Buf.CopyFrom(FHandle, Buf.Size);

  // Expand current archive
  FHandle.Size := FHandle.Size + Data.Size;

  // Write the new data
  Data.Seek(0, soBeginning);
  FHandle.Position := Offset;
  FHandle.CopyFrom(Data, Data.Size);

  // Write back shifted data
  Buf.Seek(0, soBeginning);
  FHandle.CopyFrom(Buf, Buf.Size);
  Buf.Free;

  // The result is the offset position of the file and its size
  Result.offset := Offset;
  Result.size := Data.Size;
end;


function RFAInsertFile(Data : TStream; Compressed : boolean = false) : RFA_Result;
var
  CurrentSize : cardinal;
begin
  CurrentSize := GetDataSize;

  if Compressed then
  begin
    {$IfDef DEBUG_RFA}
    SendDebugFmt('RFAInsertFile::Data.Size=%d',[Data.Size]);
    {$EndIf}
    Result := RFAInsertDataCompressed(Data, CurrentSize);
  end
    else
  begin
    Result := RFAInsertData(Data, CurrentSize);
  end;

  //SetDataSize(CurrentSize+Data.Size);
  SetDataSize(CurrentSize + Result.size);
end;

procedure RFAInsertEntry(FullPath : AnsiString; Offset, Size : Int64; cSize : Int64; Index : Cardinal);
var
  Buf : TMemoryStream;
  Len : LongWord;
  ENT: RFA_Entry;
  Path: AnsiString;
  NumE, x: Cardinal;
begin
  Len := Length(FullPath);
  ENT.offset := Offset;
  ENT.csize := cSize;
  ENT.ucsize := Size;

  Buf := TMemoryStream.Create;
  Buf.Size := DWORD_SIZE + Len + ENTRY_SIZE;
  Buf.Seek(0, soFromBeginning);

  Buf.Write(Len, DWORD_SIZE);
  Buf.Write(FullPath[1], Len);
  Buf.Write(ENT, ENTRY_SIZE);

  NumE := GetElementQuantity;
  if (Index = 0) or (Index > NumE) then
    Index := NumE;

  for x:= 1 to NumE do
  begin
    Path := StringFrom(FHandle);
    FHandle.Read(ENT, ENTRY_SIZE);

    if Index = x then
      Break;
  end;

  RFAInsertData(Buf, FHandle.Position);
  SetElementQuantity(GetElementQuantity+1);

  Buf.Free;
end;

//  Same as ExtractRFAToStream but with a buffer
procedure RFACopyToStream(Data: TStream; Offset, Size: int64);
var
  i,numbuf, Restbuf: Integer;
begin
  FHandle.Seek(Offset, 0);
  numbuf := Size div BUFFER_SIZE;
  Restbuf := Size mod BUFFER_SIZE;

  Data.Seek(0,soFromBeginning);

  for i := 1 to numbuf do
  begin
    Data.CopyFrom(FHandle, BUFFER_SIZE);
  end;

  Data.CopyFrom(FHandle, Restbuf);
end;

procedure RFAExtractToStream(Data: TStream; Offset, Size, UcSize: int64);
var
  Buffer : TMemoryStream;
begin

  Buffer := TMemoryStream.Create;

  Buffer.Size := Size;

  Buffer.Seek(0, soFromBeginning);
  FHandle.Seek(Offset, soFromBeginning);

  Buffer.CopyFrom(FHandle, Size);
  Buffer.Seek(0, soFromBeginning);

  {$IfDef DEBUG_RFA}
  SendDebugFmt('Buffer size = %d',[Buffer.Size]);
  {$EndIf}
  Buffer.SaveToStream(Data);

  Buffer.Free;
end;


function RFAInsertDataCompressed(Data : TStream; Offset : Int64) : RFA_Result;
var
  WBuff: PByteArray; // Working buffer
  SBuff: PByteArray; // Source buffer
  OBuff: PByteArray; // Output buffer
  DataH: RFA_DataHeader;
  SegmentHeader, SegmentData : TMemoryStream;
  RemainingSize : integer;
  CompressedSize : cardinal;
  LzoResult : integer;
  SegmentCounter : integer;
  Buf : TMemoryStream;
  PreviousPos : integer;
begin

  SegmentCounter := 0;
  Data.Position := 0;

  SegmentData := TMemoryStream.Create;
  SegmentData.Size := 0;

  SegmentHeader := TMemoryStream.Create;
  SegmentHeader.Size := 0;
  SegmentHeader.Write(SegmentCounter, DWORD_SIZE);

  {We want to compress the data block at `in' with length `IN_LEN' to
  the block at `out'. Because the input block may be incompressible,
  we must provide a little more output space in case that compression
  is not possible.}

  GetMem(SBuff, SEGMENT_MAX_SIZE);
  GetMem(OBuff, SEGMENT_MAX_SIZE + SEGMENT_MAX_SIZE div 64 + 16 + 3);
  GetMem(WBuff, LZO1X_1_MEM_COMPRESS);

  while True do
  begin
    // Write a new segment in the source buffer
    RemainingSize := Min(SEGMENT_MAX_SIZE, Data.Size - Data.Position);

    //FillChar(SBuff^, SEGMENT_MAX_SIZE, #0);
    Data.Read(SBuff^, RemainingSize);
   // Data.Position := Data.Position + RemainingSize; // Position need to be set manually on TFileStream

    // Compress the new segment
    LzoResult := _lzo1x_1_compress(SBuff, RemainingSize, OBuff, CompressedSize, WBuff);

    // Add compressed segment with others
    if LzoResult = LZO_E_OK then
    begin
      SegmentData.Write(OBuff^, CompressedSize);
      Inc(SegmentCounter);

      if SegmentCounter = 1 then
        DataH.doffset := 0
      else
        DataH.doffset := DataH.doffset + DataH.csize;

      DataH.csize := CompressedSize;
      DataH.ucsize := RemainingSize;

      {$IfDef DEBUG_RFA}
      SendSeparator;
      SendDebugFmt('RFAInsertDataCompressed::SegmentCounter=%d',[SegmentCounter]);
      SendDebugFmt('RFAInsertDataCompressed::DataH.csize=%d',[DataH.csize]);
      SendDebugFmt('RFAInsertDataCompressed::SegmentData.size=%d',[DataH.ucsize]);
      {$EndIf}

      SegmentHeader.Write(DataH.csize,DWORD_SIZE);
      SegmentHeader.Write(DataH.ucsize,DWORD_SIZE);
      SegmentHeader.Write(DataH.doffset,DWORD_SIZE);
    end;

    if (Data.Size = Data.Position) then
    begin
      SegmentHeader.Position := 0;
      SegmentHeader.Write(SegmentCounter, DWORD_SIZE);
      Break;
    end;
  end;

  FreeMem(WBuff); WBuff:= nil;
  FreeMem(OBuff); OBuff:= nil;
  FreeMem(SBuff); SBuff:= nil;

  // Finally wrote full data
  Buf := TMemoryStream.Create;
  FHandle.Seek(Offset, soBeginning);

  // Put final data in Buf
  Buf.Size := FHandle.Size - FHandle.Position;
  Buf.Seek(0, soBeginning);
  Buf.CopyFrom(FHandle, Buf.Size);

  // Expand current archive
  FHandle.Size := FHandle.Size + SegmentHeader.Size + SegmentData.Size;

  // Write the new data
  SegmentHeader.Seek(0, soBeginning);
  SegmentData.Seek(0, soBeginning);
  FHandle.Position := Offset;
  FHandle.CopyFrom(SegmentHeader, SegmentHeader.Size);
  FHandle.CopyFrom(SegmentData, SegmentData.Size);

  // Write back shifted data
  Buf.Seek(0, soBeginning);
  FHandle.CopyFrom(Buf, Buf.Size);
  Buf.Free;

  // The result is the offset position of the file and its size
  Result.offset := Offset;
  Result.size := SegmentHeader.Size + SegmentData.Size;

  {$IfDef DEBUG_RFA}
  SendSeparator;
  SendDebugFmt('RFAInsertDataCompressed::SegmentHeader.size=%d',[SegmentHeader.size]);
  SendDebugFmt('RFAInsertDataCompressed::SegmentData.size=%d',[SegmentData.size]);
  SendDebugFmt('RFAInsertDataCompressed::SegmentCounter=%d',[SegmentCounter]);
  SendDebugFmt('RFAInsertDataCompressed::Result.offset=%d',[Result.offset]);
  SendDebugFmt('RFAInsertDataCompressed::Result.size=%d',[Result.size]);
  {$EndIf}

  SegmentHeader.Free;
  SegmentData.Free;
end;


procedure RFADecompressToStream(outputstream: TStream; Offset, Size: int64; silent: boolean);
var
  SBuff: PByteArray;
  OBuff: PByteArray;
  Result: integer;

  DataH: array of RFA_DataHeader;
  i, Segments: longword;
begin
  // Reinit variables;
  SetLength(DataH,0);
  Segments := 0;

  // A compressed file is made of multi-segment

  // Reading quantity of segment for this file
  FHandle.Seek(offset,0);
  FHandle.Read(segments,DWORD_SIZE);

  // Creating as much as Data header than segments
  SetLength(DataH,Segments);

  // Filling each header with usable values
  for i := 0 to Segments-1 do
  begin
    FHandle.Read(DataH[i].csize,DWORD_SIZE);
    FHandle.Read(DataH[i].ucsize,DWORD_SIZE);
    FHandle.Read(DataH[i].doffset,DWORD_SIZE);

    {$IfDef DEBUG_RFA}
    SendDebugFmt('DecompressRFAToStream::FHandle.Position = %d', [FHandle.Position]);
    SendDebugFmt('DecompressRFAToStream::Segment No_%d (%d)(%d)(%d)', [i, DataH[i].csize, DataH[i].ucsize, DataH[i].doffset]);
    {$EndIf}
  end;


  {$IfDef DEBUG_RFA}
  SendDebugFmt('DecompressRFAToStream::Start', []);
  {$EndIf}
  for i := 0 to Segments-1 do
  begin

    GetMem(SBuff, DataH[i].csize);
    GetMem(OBuff, DataH[i].ucsize);

    FHandle.Seek(Offset+(segments*SEGMENT_HEADER_SIZE)+DataH[i].doffset+DWORD_SIZE,0);

    {$IfDef DEBUG_RFA}
    SendDebugFmt('DecompressRFAToStream::FHandle.Position = %d', [FHandle.Position]);
    {$EndIf}
		FHandle.Read(SBuff^,DataH[i].csize);

    Result := _lzo1x_decompress_safe(SBuff, DataH[i].csize, OBuff, DataH[i].ucsize, nil);

    if Result <> LZO_E_OK then
    begin
      raise Exception.Create('not LZO_E_OK');

      FreeMem(SBuff);
      FreeMem(OBuff);
      Break;
    end;

    outputstream.WriteBuffer(OBuff^, DataH[i].ucsize);
    FreeMem(SBuff);
    FreeMem(OBuff);
  end;

end;

initialization
  FHandle := nil;
  FLargeBuf := TMemoryStream.Create;

finalization
  if Assigned(FHandle) then
    FHandle.Free;

  if Assigned(FLargeBuf) then
    FLargeBuf.Free;

end.
