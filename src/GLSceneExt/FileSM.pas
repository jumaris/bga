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
 * The Original Code is FileSM (http://code.google.com/p/bga)
 *
 * The Initial Developer of the Original Code is
 * Yann Papouin <yann.papouin at @ gmail.com>
 *
 * ***** END LICENSE BLOCK ***** *)

unit FileSM;

interface

{$DEFINE DEBUG_SM}
{.$DEFINE DEBUG_SM_DETAILS}

uses Classes, TypesSM, VectorTypes, VectorGeometry;

type

  // TFileSM
  //
  TFileSM = class
  private
    FBBox : TSMBBox;
    FHeader : Longword;
    FCollMeshCount : Longword;
    FCollMeshes : array of TSMMeshData;
    FMeshCount : Longword;
    FMeshes : array of TSMMesh;
    function GetCollMesh(Index: Longword): TSMMeshData;
    function GetMesh(Index: Longword): TSMMesh;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure LoadFromStream(aStream : TStream);

    function CollVertexFromFaceId(CollMeshID : Longword; FaceID: Longword): TMatrix3f;
    function CollNormaleFromFaceId(CollMeshID : Longword; FaceID: Longword): TMatrix3f;

    function MeshVertexFromMatFaceId(MeshID : Longword; LodID: Longword; FaceID: Longword): TMatrix3f;
    function MeshNormaleFromMatFaceId(MeshID : Longword; LodID: Longword; FaceID: Longword): TMatrix3f;
    function MeshTextureFromMatFaceId(MeshID, LodID, FaceID: Longword): TTexPoint3;

    property Header : Longword read FHeader;
    property CollMeshCount : Longword read FCollMeshCount;
    property CollMeshes[Index : Longword] : TSMMeshData read GetCollMesh;
    property MeshCount : Longword read FMeshCount;
    property Meshes[Index : Longword] : TSMMesh read GetMesh; default;

  end;


implementation

uses
  DbugIntf,
  SysUtils, Math;

const
  DWORD_SIZE = 4;
  WORD_SIZE = 2;
  BYTE_SIZE = 1;
  FLOAT_SIZE = 4;

{ TFileSM }

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

constructor TFileSM.Create;
begin
  FHeader := 0;
  FCollMeshCount := 0;
end;

destructor TFileSM.Destroy;
begin

  inherited;
end;

function TFileSM.GetCollMesh(Index: Longword): TSMMeshData;
begin
  Result := FCollMeshes[Index];
end;


function TFileSM.GetMesh(Index: Longword): TSMMesh;
begin
  Result := FMeshes[Index];
end;

procedure TFileSM.LoadFromStream(aStream: TStream);
var
  SizeOfSection : Longword;
  endOffset : int64;
  ptFace : PSMFace;
  ptVertex : PSMVertex;
  ptNormale: PSMNormale;
  ptMaterial : PSMMaterial;
  ptMeshdata : PSMMeshData;
  Unknown1, Unknown2: Longword;
  FaceValues : array of word;
  tmpFace : TSMFace;
  i, j, k : integer;
begin
  Assert(Assigned(aStream));

  aStream.Position := 0;
  aStream.Read(FHeader , DWORD_SIZE);
  aStream.Position := aStream.Position+(4);

  if InRange(FHeader, 9, 10) then
  begin

    /// Extracting bounding box
    aStream.Read(FBBox.P1.V[0] , FLOAT_SIZE);
    FBBox.P1.V[0] := FBBox.P1.V[0] *DSM_SCALE;
    aStream.Read(FBBox.P1.V[1] , FLOAT_SIZE);
    FBBox.P1.V[1] := FBBox.P1.V[1] *DSM_SCALE;
    aStream.Read(FBBox.P1.V[2] , FLOAT_SIZE);
    FBBox.P1.V[2] := FBBox.P1.V[2] *DSM_SCALE;

    aStream.Read(FBBox.P2.V[0] , FLOAT_SIZE);
    FBBox.P2.V[0] := FBBox.P2.V[0] *DSM_SCALE;
    aStream.Read(FBBox.P2.V[1] , FLOAT_SIZE);
    FBBox.P2.V[1] := FBBox.P2.V[1] *DSM_SCALE;
    aStream.Read(FBBox.P2.V[2] , FLOAT_SIZE);
    FBBox.P2.V[2] := FBBox.P2.V[2] *DSM_SCALE;

    // Apply an offset on version 10
    if FHeader = 10 then
      aStream.Position := aStream.Position+(1);

    aStream.Read(FCollMeshCount , DWORD_SIZE);
    if FCollMeshCount > 0 then
    begin
      SetLength(FCollMeshes, FCollMeshCount);

      for i := 0 to FCollMeshCount-1 do
      begin
        {$IfDef DEBUG_SM}
        SendDebugFmt('Current Collision Mesh is %d/%d',[i+1,FCollMeshCount]);
        {$EndIf}

        aStream.Read(SizeOfSection , DWORD_SIZE);
        endOffset := aStream.Position + SizeOfSection;

        // These 8 bytes seems to be a header
        aStream.Position := aStream.Position+(8);

        aStream.Read(FCollMeshes[i].VertexCount , DWORD_SIZE);
        SetLength(FCollMeshes[i].Vertex, FCollMeshes[i].VertexCount);

        for j := 0 to FCollMeshes[i].VertexCount-1 do
        begin
          ptVertex := @(FCollMeshes[i].Vertex[j]);

          aStream.Read(ptVertex.Value.V[0] , FLOAT_SIZE);
          ptVertex.Value.V[0] := ptVertex.Value.V[0] * DSM_SCALE;
          aStream.Read(ptVertex.Value.V[1] , FLOAT_SIZE);
          ptVertex.Value.V[1] := ptVertex.Value.V[1] * DSM_SCALE;
          aStream.Read(ptVertex.Value.V[2] , FLOAT_SIZE);
          ptVertex.Value.V[2] := ptVertex.Value.V[2] * DSM_SCALE;

          aStream.Read(ptVertex.MaterialID, WORD_SIZE); //MatID
          aStream.Position := aStream.Position+(2); //Stuff of vert1 Repeated

          {$IfDef DEBUG_SM_DETAILS}
          SendDebugFmt('Current vertex is %d/%d (X=%.3f, Y=%.3f, Z=%.3f)',[j+1, FCollMeshes[i].VertexCount, ptVertex.Value[0], ptVertex.Value[1], ptVertex.Value[2]]);
          {$EndIf}
        end;

        aStream.Read(FCollMeshes[i].FaceCount , DWORD_SIZE);
        SetLength(FCollMeshes[i].Faces, FCollMeshes[i].FaceCount);

        for j := 0 to FCollMeshes[i].FaceCount-1 do
        begin
          ptFace := @FCollMeshes[i].Faces[j];

          aStream.Read(ptFace.A, WORD_SIZE);
          aStream.Read(ptFace.B, WORD_SIZE);
          aStream.Read(ptFace.C, WORD_SIZE);

          aStream.Read(ptFace.MaterialID , WORD_SIZE);
          ptFace.MaterialID := ptFace.MaterialID +1;

          if ptFace.MaterialID = 0 then
            ptFace.MaterialID := 10000; // 10000 equals 0

          {$IfDef DEBUG_SM_DETAILS}
          SendDebugFmt('Current face is %d/%d (%d,%d,%d) MatID=[%d]',[j+1, FCollMeshes[i].FaceCount, ptFace.A, ptFace.B, ptFace.C, ptFace.MaterialID]);
          {$EndIf}
        end;

        aStream.Read(Unknown1, DWORD_SIZE);
        aStream.Read(Unknown2, DWORD_SIZE);

        aStream.Read(FCollMeshes[i].NormaleCount , DWORD_SIZE);
        SetLength(FCollMeshes[i].Normales, FCollMeshes[i].NormaleCount);

        for j := 0 to FCollMeshes[i].NormaleCount-1 do
        begin
          {$IfDef DEBUG_SM_DETAILS}
          SendDebugFmt('Current normale is %d/%d',[j+1,FCollMeshes[i].NormaleCount]);
          {$EndIf}

          ptNormale := @FCollMeshes[i].Normales[j];

          aStream.Read(ptNormale.Value.V[0], FLOAT_SIZE);
          aStream.Read(ptNormale.Value.V[1], FLOAT_SIZE);
          aStream.Read(ptNormale.Value.V[2], FLOAT_SIZE);

          ptNormale.MaterialID := 0;
        end;

        // Ignore data until end
        aStream.Position := endOffset;
      end;

    end;

    aStream.Read(FMeshCount , DWORD_SIZE);
    if FMeshCount > 0 then
    begin
      SetLength(FMeshes, FMeshCount);

      for i := 0 to FMeshCount-1 do
      begin
        {$IfDef DEBUG_SM}
        SendDebugFmt('Current Mesh is %d/%d',[i+1, FMeshCount]);
        {$EndIf}

        aStream.Read(FMeshes[i].MatMeshCount, DWORD_SIZE);

        if FMeshes[i].MatMeshCount > 0 then
        begin
          SetLength(FMeshes[i].MatMeshes, FMeshes[i].MatMeshCount);

          for j := 0 to FMeshes[i].MatMeshCount-1 do
          begin
            {$IfDef DEBUG_SM}
            SendDebugFmt('Current MatMesh is %d/%d',[j+1, FMeshes[i].MatMeshCount]);
            {$EndIf}

            ptMaterial := @(FMeshes[i].MatMeshes[j].Material);
            ptMeshdata := @(FMeshes[i].MatMeshes[j].MeshData);

            ptMaterial.Name := StringFrom(aStream);

            {$IfDef DEBUG_SM}
            SendDebugFmt('Material name is %s',[ptMaterial.Name]);
            {$EndIf}

            // Unknown data (12 bytes)
            aStream.Position := aStream.Position + 12;

            aStream.Read(ptMaterial.RenderType, DWORD_SIZE);
            aStream.Read(ptMaterial.VertFormat, DWORD_SIZE);
            aStream.Read(ptMaterial.VertLength, DWORD_SIZE);
            aStream.Read(ptMeshdata.VertexCount, DWORD_SIZE);

            {$IfDef DEBUG_SM}
            case ptMaterial.RenderType of
              TRIANGLE_LIST  : SendDebug('Render type is TRIANGLE_LIST');
              TRIANGLE_STRIP : SendDebug('Render type is TRIANGLE_STRIP');
              else
                SendDebugError('Unknown render type');
            end;

            case ptMaterial.VertLength of
              BS_32 : SendDebug('Vertex structure length is BS_32 bytes');
              BS_40 : SendDebug('Vertex structure length is BS_40 bytes');
              BS_64 : SendDebug('Vertex structure length is BS_64 bytes');
              else
                SendDebugError(Format('Unknown vertex structure length (%d)',[ptMaterial.VertLength]));
            end;
            {$EndIf}

            ptMeshdata.NormaleCount := ptMeshdata.VertexCount;
            ptMaterial.TextureCoordCount := ptMeshdata.VertexCount;
            ptMaterial.LightmapCoordCount := ptMeshdata.VertexCount;

            aStream.Read(ptMaterial.IndexNum, DWORD_SIZE);

            case ptMaterial.RenderType of
              TRIANGLE_LIST  : ptMeshdata.FaceCount := ptMaterial.IndexNum div 3;
              TRIANGLE_STRIP : ptMeshdata.FaceCount := ptMaterial.IndexNum - 2;
              else
              ptMeshdata.FaceCount := ptMaterial.IndexNum;
            end;

            // Unknown data (4 bytes)
            aStream.Position := aStream.Position + 4;
          end;

          /// Read geometry data
          for j := 0 to FMeshes[i].MatMeshCount-1 do
          begin
            ptMaterial := @(FMeshes[i].MatMeshes[j].Material);
            ptMeshdata := @(FMeshes[i].MatMeshes[j].MeshData);

            SetLength(ptMeshdata.Vertex, ptMeshdata.VertexCount);
            SetLength(ptMeshdata.Normales, ptMeshdata.NormaleCount);

            SetLength(ptMaterial.TextureCoord, ptMaterial.TextureCoordCount);
            SetLength(ptMaterial.LightmapCoord, ptMaterial.LightmapCoordCount);

            if ptMeshdata.VertexCount > 0 then
            begin
              for k := 0 to ptMeshdata.VertexCount - 1 do
              begin
                ptVertex := @(ptMeshdata.Vertex[k]);

                aStream.Read(ptVertex.Value.V[0] , FLOAT_SIZE);
                ptVertex.Value.V[0] := ptVertex.Value.V[0] * DSM_SCALE;
                aStream.Read(ptVertex.Value.V[1] , FLOAT_SIZE);
                ptVertex.Value.V[1] := ptVertex.Value.V[1] * DSM_SCALE;
                aStream.Read(ptVertex.Value.V[2] , FLOAT_SIZE);
                ptVertex.Value.V[2] := ptVertex.Value.V[2] * DSM_SCALE;

                {$IfDef DEBUG_SM_DETAILS}
                SendDebugFmt('Current vertex is %d/%d (X=%.3f, Y=%.3f, Z=%.3f)',[k+1, ptMeshdata.VertexCount, ptVertex.Value[0], ptVertex.Value[1], ptVertex.Value[2]]);
                {$EndIf}

                {$IfDef DEBUG_SM_DETAILS}
                SendDebugFmt('Current normale is %d/%d',[k+1, ptMeshdata.NormaleCount]);
                {$EndIf}

                ptNormale := @(ptMeshdata.Normales[k]);

                aStream.Read(ptNormale.Value.V[0], FLOAT_SIZE);
                aStream.Read(ptNormale.Value.V[1], FLOAT_SIZE);
                aStream.Read(ptNormale.Value.V[2], FLOAT_SIZE);

                aStream.Read(ptMaterial.TextureCoord[k].S, FLOAT_SIZE);
                aStream.Read(ptMaterial.TextureCoord[k].T, FLOAT_SIZE);
                ptMaterial.TextureCoord[k].T := 1.0 - ptMaterial.TextureCoord[k].T;

                if ptMaterial.VertLength = BS_40 then
                begin
                  aStream.Read(ptMaterial.LightmapCoord[k].S, FLOAT_SIZE);
                  aStream.Read(ptMaterial.LightmapCoord[k].T, FLOAT_SIZE);
                  ptMaterial.LightmapCoord[k].T := 1.0 - ptMaterial.LightmapCoord[k].T;
                end;

              end;

              if ptMaterial.VertLength = BS_64 then
              begin
                for k := 0 to ptMeshdata.VertexCount - 1 do
                begin
                  aStream.Read(ptMaterial.LightmapCoord[k].S, FLOAT_SIZE);
                  aStream.Read(ptMaterial.LightmapCoord[k].T, FLOAT_SIZE);
                  ptMaterial.LightmapCoord[k].T := 1.0 - ptMaterial.LightmapCoord[k].T;

                  // Unused data (24 bytes)
                  aStream.Position := aStream.Position + 24;
                end;
              end;
            end;

            if ptMaterial.IndexNum > 0 then
            begin
              SetLength(FaceValues, ptMaterial.IndexNum);

              for k := 0 to ptMaterial.IndexNum - 1 do
              begin
                aStream.Read(FaceValues[k], WORD_SIZE);
              end;

              if ptMaterial.RenderType = TRIANGLE_LIST then
              begin
                SetLength(ptMeshdata.Faces, ptMeshdata.FaceCount);

                k := 0;
                while k < ptMaterial.IndexNum do
                begin
                  ptFace := @ptMeshdata.Faces[k div 3];

                  ptFace.A := FaceValues[k+0];
                  ptFace.B := FaceValues[k+1];
                  ptFace.C := FaceValues[k+2];

                  k := k+3;
                end;
              end
                else
              if ptMaterial.RenderType = TRIANGLE_STRIP then
              begin
                SetLength(ptMeshdata.Faces, ptMeshdata.FaceCount);

                ptFace := @ptMeshdata.Faces[0];
                ptFace.A := FaceValues[0];
                ptFace.B := FaceValues[1];
                ptFace.C := FaceValues[2];

                k := 1;
                while k < ptMeshdata.FaceCount do
                begin
                  ptFace := @ptMeshdata.Faces[k];

                  ptFace.A := 1;
                  ptFace.B := 2;
                  ptFace.C := 3;

                  ptFace.A := ptMeshdata.Faces[k-1].B;
                  ptFace.B := ptMeshdata.Faces[k-1].C;
                  ptFace.C := FaceValues[k+2];

                  k := k+1;
                end;

                k := 0;
                while k < ptMeshdata.FaceCount do
                begin
                  ptFace := @ptMeshdata.Faces[k];
                  tmpFace := ptface^;

                  ptFace.A := tmpFace.C;
                  ptFace.B := tmpFace.B;
                  ptFace.C := tmpFace.A;

                  k := k+2;
                end;
              end
            end;
          end;
        end;
      end;

    end;

  end
    else
  begin
    //Invalid format
  end;

end;

function TFileSM.MeshVertexFromMatFaceId(MeshID, LodID, FaceID: Longword): TMatrix3f;
var
  Face : TSMFace;
begin
  Assert(MeshID<FMeshCount);
  Assert(LodID<FMeshes[MeshID].MatMeshCount);
  Assert(FaceID<FMeshes[MeshID].MatMeshes[LodID].MeshData.FaceCount);

  Face := FMeshes[MeshID].MatMeshes[LodID].MeshData.Faces[FaceID];

  Assert(Face.A<FMeshes[MeshID].MatMeshes[LodID].MeshData.VertexCount);
  Assert(Face.B<FMeshes[MeshID].MatMeshes[LodID].MeshData.VertexCount);
  Assert(Face.C<FMeshes[MeshID].MatMeshes[LodID].MeshData.VertexCount);

  Result.V[0] := FMeshes[MeshID].MatMeshes[LodID].MeshData.Vertex[Face.A].Value;
  Result.V[1] := FMeshes[MeshID].MatMeshes[LodID].MeshData.Vertex[Face.B].Value;
  Result.V[2] := FMeshes[MeshID].MatMeshes[LodID].MeshData.Vertex[Face.C].Value;
end;

function TFileSM.MeshTextureFromMatFaceId(MeshID, LodID, FaceID: Longword): TTexPoint3;
var
  Face : TSMFace;
begin
  Assert(MeshID<FMeshCount);
  Assert(LodID<FMeshes[MeshID].MatMeshCount);
  Assert(FaceID<FMeshes[MeshID].MatMeshes[LodID].MeshData.FaceCount);

  Face := FMeshes[MeshID].MatMeshes[LodID].MeshData.Faces[FaceID];

  Assert(Face.A<FMeshes[MeshID].MatMeshes[LodID].MeshData.VertexCount);
  Assert(Face.B<FMeshes[MeshID].MatMeshes[LodID].MeshData.VertexCount);
  Assert(Face.C<FMeshes[MeshID].MatMeshes[LodID].MeshData.VertexCount);

  Result[0] := FMeshes[MeshID].MatMeshes[LodID].Material.TextureCoord[Face.A];
  Result[1] := FMeshes[MeshID].MatMeshes[LodID].Material.TextureCoord[Face.B];
  Result[2] := FMeshes[MeshID].MatMeshes[LodID].Material.TextureCoord[Face.C];
end;

function TFileSM.MeshNormaleFromMatFaceId(MeshID, LodID, FaceID: Longword): TMatrix3f;
var
  Face : TSMFace;
begin
  Face := FMeshes[MeshID].MatMeshes[LodID].MeshData.Faces[FaceID];

  Result.V[0] := FMeshes[MeshID].MatMeshes[LodID].MeshData.Normales[Face.A].Value;
  Result.V[1] := FMeshes[MeshID].MatMeshes[LodID].MeshData.Normales[Face.B].Value;
  Result.V[2] := FMeshes[MeshID].MatMeshes[LodID].MeshData.Normales[Face.C].Value;
end;


function TFileSM.CollVertexFromFaceId(CollMeshID : Longword; FaceID: Longword): TMatrix3f;
var
  Face : TSMFace;
begin
  Face := FCollMeshes[CollMeshID].Faces[FaceID];

  Result.V[0] := FCollMeshes[CollMeshID].Vertex[Face.A].Value;
  Result.V[1] := FCollMeshes[CollMeshID].Vertex[Face.B].Value;
  Result.V[2] := FCollMeshes[CollMeshID].Vertex[Face.C].Value;
end;

function TFileSM.CollNormaleFromFaceId(CollMeshID : Longword; FaceID: Longword): TMatrix3f;
var
  Face : TSMFace;
begin

  Assert(CollMeshID<FCollMeshCount);
  Assert(FaceID<FCollMeshes[CollMeshID].FaceCount);

  Face := FCollMeshes[CollMeshID].Faces[FaceID];

  Assert(Face.A<FCollMeshes[CollMeshID].NormaleCount);
  Assert(Face.B<FCollMeshes[CollMeshID].NormaleCount);
  Assert(Face.C<FCollMeshes[CollMeshID].NormaleCount);

  Result.V[0] := FCollMeshes[CollMeshID].Normales[Face.A].Value;
  Result.V[1] := FCollMeshes[CollMeshID].Normales[Face.B].Value;
  Result.V[2] := FCollMeshes[CollMeshID].Normales[Face.C].Value;
end;


end.
