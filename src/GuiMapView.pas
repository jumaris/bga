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
  * The Original Code is GuiRAWView (http://code.google.com/p/bga)
  *
  * The Initial Developer of the Original Code is
  * Yann Papouin <yann.papouin at @ gmail.com>
  *
  * ***** END LICENSE BLOCK ***** *)

unit GuiMapView;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  StdCtrls,
  Forms,
  SpTBXEditors,
  SpTBXItem,
  SpTBXControls,
  GuiFormCommon,
  Dialogs,
  GLScene,
  GLGraph,
  GLCoordinates,
  GLCrossPlatform,
  BaseClasses,
  GLWin32Viewer,
  GLObjects,
  GLColor,
  GLTexture,
  TB2Item,
  DDSImage,
  VectorGeometry,
  VectorTypes,
  GLSimpleNavigation,
  JvExControls,
  JvInspector,
  GLVectorFileObjects,
  GLMesh,
  BGALib,
  generics.defaults,
  generics.Collections,
  GLMaterial,
  GLState,
  GLKeyboard,
  GLHeightData,
  GLTerrainRenderer,
  GLROAMPatch,
  GLBitmapFont,
  GLWindowsFont,
  GLHUDObjects,
  GLCadencer,
  GLRenderContextInfo,
  oge2_TerrainRendering,
  oge2_TerrainDataSource,
  oge2_HeightMap;


type


  TMapViewForm = class(TFormCommon)
    Viewer: TGLSceneViewer;
    Scene: TGLScene;
    Camera: TGLCamera;
    Navigation: TGLSimpleNavigation;
    WaterPlane: TGLPlane;
    CameraTarget: TGLDummyCube;
    StatusBar: TSpTBXStatusBar;
    ZLabel: TSpTBXLabelItem;
    YLabel: TSpTBXLabelItem;
    XLabel: TSpTBXLabelItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBSeparatorItem2: TTBSeparatorItem;
    GLMaterialLibrary: TGLMaterialLibrary;
    Root: TGLDummyCube;
    WindowsBitmapFont: TGLWindowsBitmapFont;
    GLInfos: TGLHUDText;
    Cadencer: TGLCadencer;
    GLLightSource1: TGLLightSource;
    GLMaterialLibrary1: TGLMaterialLibrary;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ViewerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ViewerPostRender(Sender: TObject);
    procedure ViewerDblClick(Sender: TObject);
    procedure ViewerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure CadencerProgress(Sender: TObject; const deltaTime, newTime: Double);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    v: TAffineVector;
    M: TPoint;

    FFirstRow : Integer;
    FFirstCol : Integer;
    FLastRow : Integer;
    FLastCol : Integer;

    // Terrain ranges
    FRangeMin : TPoint;
    FRangeMax : TPoint;

    FInitLoad: boolean;
    FMouseMoveMutex: boolean;
    FBuffer: TMemoryStream;
    FMapSize: Integer;
    FWorldSize: Integer;
    FRawStep: Integer;
    FMapHeightScale: Single;

    FMinZ: Single;
    FMaxZ: Single;
    FWireFrame: boolean;
    FRestrict: boolean;
    { D�clarations priv�es }

    procedure BattlefieldHDSStartPreparingData(heightData: TOGEHeightMap);

    procedure SetMapSize(const Value: Integer);
    procedure SetMapHeightScale(const Value: Single);
    procedure SetWorldSize(const Value: Integer);

    procedure LoadTerrain(Data: TStream); overload;
    procedure LoadHeightmap(Data: TStream); overload;
    procedure CalcTerrainRange;
    procedure CalcCameraPosition;

    procedure InvalidateTerrain;
    procedure SetWireFrame(const Value: boolean);
    procedure SetRestrict(const Value: boolean);
  public
    { D�clarations publiques }
    TerrainRenderer: TOGETerrainRendering;
    TerrainData: TOGEHeightDataSource;

    GetFileByPath: TBgaGetFileByPath;

    TexturePart: Integer;
    TextureSize: Integer;
    TextureOffset : TPoint;
    TextureBaseName: string;
    DetailBaseName: string;
    HeightMap: string;
    WaterLevel : single;
    UseTexture : boolean;

    procedure LoadTerrain(Filename: string); overload;
    property MapSize: Integer read FMapSize write SetMapSize;
    property MapHeightScale: Single read FMapHeightScale write SetMapHeightScale;
    property WorldSize: Integer read FWorldSize write SetWorldSize;

    property WireFrame : boolean read FWireFrame write SetWireFrame;
    property Restrict : boolean read FRestrict write SetRestrict;
  end;

var
  MapViewForm: TMapViewForm;

const
  MOUSEWIDTH = 2;

implementation

{$R *.dfm}

uses
  Math,
  DbugIntf,
  StringFunction,
  AppLib,
  CommonLib,
  CONLib;

{ TRAWViewForm }



procedure TMapViewForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited;
  Cadencer.Enabled := False;
end;

procedure TMapViewForm.FormCreate(Sender: TObject);
var
  Key : Char;
  Color : TColorVector;
begin
  inherited;
  FMapSize := -1;
  FBuffer := TMemoryStream.Create;

  TerrainRenderer := TOGETerrainRendering.CreateAsChild(Root);

  TerrainData := TOGEHeightDataSource.Create;
  TerrainRenderer.HeightDataSource := TerrainData;
  TerrainRenderer.MaterialLibrary := GLMaterialLibrary1;
  TerrainRenderer.lodType := tlodIllyriumVBO;
  TerrainRenderer.DrawTextured := true;
  TerrainRenderer.DrawWireframe := true;
  TerrainData.OnStartPreparingData := BattlefieldHDSStartPreparingData;// HDSPreparingData;
  //TerrainData.MarkDirty(-200, -200, 200, 200);

end;

procedure TMapViewForm.FormActivate(Sender: TObject);
begin
  inherited;
  if Cadencer.Tag = 1 then
  begin
    Cadencer.Tag := 0;
    Cadencer.Enabled := true;
  end;
end;

procedure TMapViewForm.FormDeactivate(Sender: TObject);
begin
  inherited;
  if Cadencer.Enabled then
  begin
    Cadencer.Tag := 1;
    Cadencer.Enabled := False;
  end;
end;

procedure TMapViewForm.FormDestroy(Sender: TObject);
begin
  FBuffer.Free;
end;

procedure TMapViewForm.FormKeyPress(Sender: TObject; var Key: Char);
var
  i :integer;
  MaterialOptions : TMaterialOptions;
begin
  inherited;
   case Key of
        'X','x' :
      for i := 0 to GLMaterialLibrary.Materials.Count - 1 do
      begin
        MaterialOptions := GLMaterialLibrary.Materials[i].Material.MaterialOptions;
        if moNoLighting in MaterialOptions then
          Exclude(MaterialOptions, moNoLighting)
        else
          Include(MaterialOptions, moNoLighting);

        GLMaterialLibrary.Materials[i].Material.MaterialOptions := MaterialOptions;
        TerrainRenderer.Material.MaterialOptions := MaterialOptions;
      end;
   end;
end;



procedure TMapViewForm.LoadTerrain(Data: TStream);
var
  TxtData: TStringList;
  flworldSize, flmaterialSize, flwaterLevel, flseaFloorLevel: extended;
  flyScale: extended;
  intTexOffsetX, intTexOffsetY : integer;
  strFile, strtexBaseName, strdetailTexName: string;
begin

  TxtData := TStringList.Create;
  try
    Data.Position := 0;
    TxtData.LoadFromStream(Data);

    strFile := GetStringFromProperty(TxtData, 'GeometryTemplate.file');
    strtexBaseName := GetStringFromProperty(TxtData, 'GeometryTemplate.texBaseName');
    strdetailTexName := GetStringFromProperty(TxtData, 'GeometryTemplate.detailTexName');

    flmaterialSize := GetFloatFromProperty(TxtData, 'GeometryTemplate.materialSize');
    flworldSize := GetFloatFromProperty(TxtData, 'GeometryTemplate.worldSize');
    flyScale := GetFloatFromProperty(TxtData, 'GeometryTemplate.yScale');
    flwaterLevel := GetFloatFromProperty(TxtData, 'GeometryTemplate.waterLevel');
    flseaFloorLevel := GetFloatFromProperty(TxtData, 'GeometryTemplate.seaFloorLevel');

    intTexOffsetX := GetIntFromProperty(TxtData, 'GeometryTemplate.texOffsetX');
    intTexOffsetY := GetIntFromProperty(TxtData, 'GeometryTemplate.texOffsetY');

    HeightMap := strFile + '.raw';
    TextureBaseName := strtexBaseName;
    DetailBaseName := strdetailTexName + '.dds';

    MapSize := Round(flmaterialSize);
    MapHeightScale := flyScale;
    WorldSize := Round(flworldSize);
    WaterLevel := flwaterLevel;
    WaterPlane.Position.z := WaterLevel;
    FRawStep := FWorldSize div MapSize;

    TextureSize := WorldSize * 4;
    TexturePart := TextureSize div 256;

    TextureOffset.X := intTexOffsetX;
    TextureOffset.Y := intTexOffsetY;
  finally
    TxtData.Free;
  end;


end;

{.$DEFINE RAWVIEW_DRAW_NAME}

procedure TMapViewForm.LoadTerrain(Filename: string);
var
  Stream: TFileStream;
  TextureName, TextureFile, DetailFile, HeightMapFile: string;
  Row, Col: Integer;
  LibMaterial, DetailMaterial: TGLLibMaterial;
{$IFDEF RAWVIEW_DRAW_NAME}
  Bmp: TBitmap;
{$ENDIF}
begin
  Assert(Assigned(GetFileByPath));
  Cadencer.Enabled := false;
  GLMaterialLibrary.Materials.Clear;
  LibMaterial := nil;
  DetailMaterial := nil;

  FWireFrame := false;
  FRestrict := True;
  UseTexture := True;

  FFirstRow := -1;
  FFirstCol := -1;
  FLastRow := -1;
  FLastCol := -1;

  if FileExists(Filename) then
  begin
    Title := Filename;
    Stream := TFileStream.Create(Filename, fmOpenRead);
    LoadTerrain(Stream);
    Stream.Free;
 (*
    DetailFile := GetFileByPath(Self, DetailBaseName);
    if FileExists(DetailFile) then
    begin
      DetailMaterial := GLMaterialLibrary.AddTextureMaterial('Details', DetailFile);
      DetailMaterial.Material.MaterialOptions := [moNoLighting];
      DetailMaterial.Material.Texture.ImageBrightness := 2;
      DetailMaterial.Material.Texture.TextureMode := tmModulate;
      DetailMaterial.TextureScale.X := Sqrt(MapSize);
      DetailMaterial.TextureScale.Y := Sqrt(MapSize);
    end;
*)
    for Row := 0 to TexturePart - 1 do
      for Col := 0 to TexturePart - 1 do
      begin
        TextureName := Format('%s%.2dx%.2d.dds', [TextureBaseName, Col, Row]);
        // SendDebug(TextureName);
        TextureFile := GetFileByPath(Self, TextureName);

        if FileExists(TextureFile) then
        begin
          if FFirstRow = -1 then
            FFirstRow := Row + TextureOffset.X
          else
            FLastRow := Row + TextureOffset.X;

          if FFirstCol = -1 then
            FFirstCol := Col + TextureOffset.Y
          else
            FLastCol := Col + TextureOffset.Y;

          UseTexture := true;
          (*
          LibMaterial := GLMaterialLibrary.AddTextureMaterial(TextureName, TextureFile);
          LibMaterial.Material.MaterialOptions := [moNoLighting];

          if Assigned(DetailMaterial) then
            LibMaterial.Texture2Name := DetailMaterial.Name;
            *)

{$IFDEF RAWVIEW_DRAW_NAME}
          Bmp := TBitmap.Create;
          Bmp.PixelFormat := pf24bit;
          LibMaterial.Material.Texture.Image.AssignToBitmap(Bmp);
          with Bmp.Canvas do
          begin
            Font.Size := 24;
            Font.color := clWhite;
            Brush.color := clBlack;
            TextOut(8, 8, SFRightRight('\', TextureName));
          end;
          LibMaterial.Material.Texture.Image.Assign(Bmp);
          Bmp.Free;
{$ENDIF}
        end;

      end;

    HeightMapFile := GetFileByPath(Self, HeightMap);
    if FileExists(HeightMapFile) then
    begin
      Stream := TFileStream.Create(HeightMapFile, fmOpenRead);
      LoadHeightmap(Stream);
      (*
      TerrainRenderer.Scale.X := FRawStep;
      TerrainRenderer.Scale.Y := FRawStep;
      TerrainRenderer.Scale.Z := FRawStep;
      *)
      Stream.Free;
    end;

    InvalidateTerrain;
    CalcCameraPosition;
    Cadencer.Enabled := true;
  end;
end;



procedure TMapViewForm.InvalidateTerrain;
begin
  CalcTerrainRange;
  TerrainData.MarkDirty(0, 0, 1024, 1024);
 // BattlefieldHDS.MarkDirty;
end;

procedure TMapViewForm.LoadHeightmap(Data: TStream);
begin
  FMinZ := MAXWORD;
  FMaxZ := 0;
  Data.Position := 0;
  FBuffer.LoadFromStream(Data);
  FInitLoad := true;
end;

procedure TMapViewForm.CalcCameraPosition;
begin
  CameraTarget.Position.X := 0;
  CameraTarget.Position.Z := 100;
  CameraTarget.Position.Y := 0;

  Camera.Position.X := 0;
  Camera.Position.Z := 0;
  Camera.Position.Y := WaterLevel*2;
end;

procedure TMapViewForm.CalcTerrainRange;
var
  TileSize : Integer;
  Rate : Integer;
begin

  // Init with maximum values
  FRangeMin.X := 0;
  FRangeMin.Y := 0;
  FRangeMax.X := (FWorldSize);
  FRangeMax.Y := (FWorldSize);
(*
  if FRestrict then
  begin
    TileSize := FWorldSize div TexturePart;
    Rate := Round(Sqrt(TileSize));

    FRangeMin.X := (FWorldSize div FRawStep) * (FFirstRow) div Rate;
    FRangeMin.Y := (FWorldSize div FRawStep) * (FFirstCol) div Rate;

    if FRangeMin.X > 0 then
      FRangeMin.X := FRangeMin.X -1;
    if FRangeMin.Y > 0 then
      FRangeMin.Y := FRangeMin.Y -1;

    FRangeMax.X := (FWorldSize div FRawStep) * (FLastRow)  div Rate + TileSize;
    FRangeMax.Y := (FWorldSize div FRawStep) * (FLastCol)  div Rate + TileSize;

    if FRangeMax.X > 0 then
      FRangeMax.X := FRangeMax.X -1;
    if FRangeMax.Y > 0 then
      FRangeMax.Y := FRangeMax.Y -1;
  end;
  *)

  // Set water plane position and size

  WaterPlane.Width := (FRangeMax.X - FRangeMin.X)*FRawStep;
  WaterPlane.Height := (FRangeMax.Y - FRangeMin.Y)*FRawStep;

  WaterPlane.Position.X := FRangeMin.X*FRawStep + WaterPlane.Width/2;
  WaterPlane.Position.Y := FRangeMin.Y*FRawStep + WaterPlane.Width/2;
end;



procedure TMapViewForm.BattlefieldHDSStartPreparingData(heightData: TOGEHeightMap);
type
  PRasterArray = PSingleArray;
const
  HdsType = hdtSingle;
var
  Y: Integer;
  X: Integer;
  Z: Single;
  RawValue: Word;
  RasterLine: PRasterArray;
  Position: Integer;
  i, j, n: Integer;
  offset: TTexPoint;

  MaxTileSize, OffsetModulo, TileSize: Integer;
  TextureScale: Extended;
begin
(*
  if not InRange(heightData.YTop, FRangeMin.Y, FRangeMax.Y)
  or not InRange(heightData.XLeft, FRangeMin.X, FRangeMax.X) then
  begin
    heightData.DataState := dsNone;
    Exit;
  end;
  *)

  heightData.DataState := dsPreparing;
  heightData.Allocate;
  //heightData.Allocate(HdsType);

  MaxTileSize := FWorldSize div TexturePart;
  OffsetModulo := Sqr(TexturePart);
  TileSize := TerrainRenderer.TileSize;
  TextureScale := TerrainRenderer.TileSize / MaxTileSize;

  heightData.MaterialName := 'LibMaterial';
(*
  i := (heightData.XLeft div MaxTileSize);
  j := (heightData.YTop div MaxTileSize);
  if (i < OffsetModulo) and (j < OffsetModulo) then
  begin

    if UseTexture then
    begin
      heightData.MaterialName := Format('%s%.2dx%.2d.dds', [TextureBaseName, i-TextureOffset.X, j-TextureOffset.Y]);

      // Auto remove material if it doesn't exists
      if GLMaterialLibrary.Materials.GetLibMaterialByName(heightData.MaterialName) = nil then
        heightData.MaterialName := '';
    end;

    //heightData.TextureCoordinatesMode := tcmLocal;
    n := (heightData.XLeft div TileSize) mod OffsetModulo;
    offset.S := n * TextureScale;
    n := (heightData.YTop div TileSize) mod OffsetModulo;
    offset.T := -n * TextureScale;
    //heightData.TextureCoordinatesOffset := offset;
    TextureScale := TextureScale;// - 0.0025;
    //heightData.TextureCoordinatesScale := TexPointMake(TextureScale, TextureScale);

  end;
*)
  for Y := heightData.YTop to heightData.YTop + heightData.Size - 1 do
  begin
    //RasterLine := heightData.SingleRaster[Y - heightData.YTop];
    for X := heightData.XLeft to heightData.XLeft + heightData.Size - 1 do
    begin
      if (Y < FWorldSize) and (X < FWorldSize) then
      begin
        Position := X*2 + Y*2 * (FWorldSize div FRawStep);
        //Position := X*2 + Y*2;
        FBuffer.Seek(Position, soFromBeginning);
        FBuffer.Read(RawValue, 2);

        Z := RawValue * (FMapHeightScale/2) * 1/FRawStep;
      end
      else
        Z := 0;

        heightData.SetHeight(X- heightData.XLeft,Y- heightData.YTop, Round(Z));

        //SendDebugFmt('[%d, %d]%f = (%d, %d)',[X,Y, Z, X- heightData.XLeft, Y- heightData.YTop]);

      //RasterLine[X - heightData.XLeft] := Z;
    end;
  end;

  heightData.DataState := dsReady;
end;


procedure TMapViewForm.CadencerProgress(Sender: TObject; const deltaTime, newTime: Double);
var
   speed : Single;
begin
   // handle keypresses
  if IsKeyDown(VK_SHIFT) then
    speed:=5*deltaTime
  else speed:=deltaTime;
  with Camera.Position do
  begin
    if IsKeyDown(VK_RIGHT) then
       CameraTarget.Translate(Z*speed, 0, -X*speed);
    if IsKeyDown(VK_LEFT) then
       CameraTarget.Translate(-Z*speed, 0, X*speed);
    if IsKeyDown(VK_UP) then
       CameraTarget.Translate(-X*speed, 0, -Z*speed);
    if IsKeyDown(VK_DOWN) then
       CameraTarget.Translate(X*speed, 0, Z*speed);
  end;
end;



procedure TMapViewForm.SetMapHeightScale(const Value: Single);
begin
  FMapHeightScale := Value;
end;

procedure TMapViewForm.SetWireFrame(const Value: boolean);
var
  i :integer;
  PolygonMode : TPolygonMode;
begin
  FWireFrame := Value;

  if FWireFrame then
    PolygonMode := pmLines
  else
    PolygonMode := pmFill;

  for i := 0 to GLMaterialLibrary.Materials.Count - 1 do
  begin
    GLMaterialLibrary.Materials[i].Material.PolygonMode := PolygonMode;
    //TerrainRenderer.Material.PolygonMode := TPolygonMode(PolygonMode);
  end;
end;

procedure TMapViewForm.SetWorldSize(const Value: Integer);
begin
  FWorldSize := Value;
end;

procedure TMapViewForm.SetMapSize(const Value: Integer);
begin
  FMapSize := Value;
end;

procedure TMapViewForm.SetRestrict(const Value: boolean);
begin
  FRestrict := Value;
  InvalidateTerrain;
end;

procedure TMapViewForm.ViewerDblClick(Sender: TObject);
begin
  inherited;
  CameraTarget.AbsoluteAffinePosition := v;
end;

procedure TMapViewForm.ViewerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  M.X := X;
  M.Y := Y;
end;

procedure TMapViewForm.ViewerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Coo3D: TVector3f;
begin

  if FMouseMoveMutex or not Assigned(Scene.CurrentBuffer) then
    Exit
  else
    FMouseMoveMutex := true;

  if not(ssLeft in Shift) and not(ssRight in Shift) then
  begin
    Coo3D := Scene.CurrentBuffer.OrthoScreenToWorld(X, Y);
    v := Scene.CurrentBuffer.PixelRayToWorld(X, Y);

    XLabel.Caption := Format('X=%.2f', [v[0]]);
    YLabel.Caption := Format('Y=%.2f', [v[1]]);
    ZLabel.Caption := Format('Z=%.2f', [v[2]]);
  end;

  FMouseMoveMutex := false;
end;

procedure TMapViewForm.ViewerPostRender(Sender: TObject);
begin
  if FInitLoad then
  begin
    FInitLoad := false;
  end;
end;



end.