unit _map;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ImgList,
  StdCtrls,
  ComCtrls,
  ExtCtrls,
  Spin,
  CheckLst,
  ToolWin,
  Menus,
  inifiles,
  Contnrs;

type
  TMap = class;
  TMapLayer = class
  protected
    FPos: array of array of integer;
    FTiles: TObjectList;
    FTileFilenames: TStrings;
    FName: string;
    FFilename: string;
    FID: string;
    FParent: TMap;
    FVisible: Boolean;
    procedure SetName( newName: string );
  public
    constructor Create( Parent: TMap; id: string; w, h: integer );
    destructor Free;

    procedure save( filename: string );
    procedure load( filename: string );
    procedure resize( nw, nh: integer );

    property Name: string read FName write setName;
    property Visible: boolean read FVisible write FVisible default True;
  end;

  TMap = class
  protected
    FWidth, FHeight: integer;
    FLayers: TObjectList;
    FFilename: string;
    FData: TIniFile;
    procedure SetFilename( newFilename: string );
  public
    constructor Create( w, h: integer ); overload;
    constructor Create( filename: string ); overload;
    destructor Free;

    procedure Resize( newWidth, newHeight: integer );

    procedure AddLayer( layername: string = '' );

    property Filename: string read FFilename write SetFilename;
    property Width: integer read FWidth;
    property Height: integer read FHeight;
  end;

  TfrmMap = class( TForm )
    ScrollBox1: TScrollBox;
    lbTiles: TListBox;
    ImageList1: TImageList;
    Image1: TImage;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    layers: TCheckListBox;
    Panel2: TPanel;
    ToolBar1: TToolBar;
    ppTileLib: TPopupMenu;
    ppLayer: TPopupMenu;
    SaveMap: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    NewLayer1: TMenuItem;
    DeleteLayer1: TMenuItem;
    N1: TMenuItem;
    toTop1: TMenuItem;
    MoveUp1: TMenuItem;
    MoveDown1: TMenuItem;
    Bottom1: TMenuItem;
    Remove1: TMenuItem;
    N2: TMenuItem;
    Import1: TMenuItem;
    N3: TMenuItem;
    Rename1: TMenuItem;
    Order1: TMenuItem;
    procedure layersClick( Sender: TObject );
    procedure FormCreate( Sender: TObject );
    procedure lbTilesDrawItem( Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState );
    procedure ToolButton7Click( Sender: TObject );
    procedure ToolButton8Click( Sender: TObject );
    procedure ToolButton9Click( Sender: TObject );
    procedure FormShow( Sender: TObject );
    procedure Image1MouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure Image1MouseUp( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure Image1MouseMove( Sender: TObject; Shift: TShiftState; X,
      Y: Integer );
    procedure ToolButton3Click( Sender: TObject );
    procedure ToolButton4Click( Sender: TObject );
    procedure ToolButton5Click( Sender: TObject );
    procedure SaveMapClick( Sender: TObject );
    procedure Import1Click( Sender: TObject );
    procedure NewLayer1Click( Sender: TObject );
    procedure Remove1Click( Sender: TObject );
    procedure DeleteLayer1Click(Sender: TObject);
    procedure toTop1Click(Sender: TObject);
    procedure Bottom1Click(Sender: TObject);
    procedure MoveUp1Click(Sender: TObject);
    procedure MoveDown1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
  private
    { Private declarations }
    procedure resizemap( nw, nh: integer );
    procedure clean;
    procedure setup;
    procedure redraw;
    procedure flood( layerid, value, x, y: integer );
  public
    { Public declarations }
    map: TIniFile;
    tlayers: array of array of array of integer;
    tlayertiles: array of array of Tbitmap;
    dirname: string;
    procedure Go( dirname: string );
    procedure newmap;
  end;

var
  frmMap            : TfrmMap;

implementation

{$R *.dfm}

uses _main,
  citra;
var
  tilesize          : integer = 32;
  scale             : integer = 1;
  tmpbmp            : array of TBitmap;
  p1, p2            : TPoint;
  bdown             : boolean = false;
  mode              : integer = 0;
  mw, mh            : integer;

procedure TfrmMap.clean;
var
  i, j, k           : integer;
begin
  if length( tlayers ) = 0 then exit;
  for j := 0 to high( tlayers ) do begin
    for i := 0 to high( tlayers[j] ) do
      setlength( tlayers[j][i], 0 );
    for i := 0 to high( tlayertiles[j] ) do
      tlayertiles[j][i].Free;
    setlength( tlayertiles[j], 0 );
    setlength( tlayers[j], 0 );
  end;
  setlength( tlayers, 0 );
  setlength( tlayertiles, 0 );
  self.map.Free;
end;

procedure TfrmMap.Go( dirname: string );
begin
  clean;
  self.dirname := dirname;
  self.map := TIniFile.Create( dirname + '\map.ini' );
  setup;
  layers.ItemIndex := 0;
  layersClick( nil );
  redraw;
end;

procedure TfrmMap.newmap;
var
  i,j : integer;
  s,l : TStrings;
begin
  ForceDirectories(dirname);
  map := TIniFile.Create( dirname + '\map.ini' );
  map.WriteInteger('map', 'width', 10);
  map.WriteInteger('map', 'height', 10);
  map.WriteInteger('map', 'numlayer', 1);
  map.WriteString('layer0','name','base');
  map.WriteString('layer0', 'tiles', '');
  map.UpdateFile;
  s := TStringlist.Create;
  l := TStringlist.Create;
  for i := 0 to 9 do
    l.Add('-1');
  for j := 0 to 9 do
    s.Add(l.CommaText);
  s.SaveToFile(dirname + '\map0.map');
  s.Free;
  l.Free;
  main.tvClick(nil);
end;

procedure TfrmMap.redraw;
var
  i, j, k           : integer;
begin
  Image1.Picture.Bitmap.Canvas.FillRect( Bounds( 0, 0, Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height ) );
  for j := 0 to high( tlayers ) do begin

    if layers.Checked[j] then
      for i := 0 to high( tlayers[j] ) do begin
        for k := 0 to high( tlayers[j][i] ) do begin
          if tlayers[j][i][k] > -1 then begin
            Image1.Picture.Bitmap.Canvas.Draw( k * tilesize, i * tilesize, tlayertiles[j][tlayers[j][i][k]] );
          end;
        end;
      end;
  end;
end;

procedure TfrmMap.resizemap( nw, nh: integer );
var
  j, i, k           : integer;
  oh, ow            : integer;
begin
  for j := 0 to high( tlayers ) do begin
    oh := length( tlayers[j] );
    setlength( tlayers[j], nh );
    for i := 0 to high( tlayers[j] ) do begin
      ow := length( tlayers[j][i] );
      setlength( tlayers[j][i], nw );
      if nw > ow then
        for k := ow to nw - 1 do
          tlayers[j][i][k] := -1;
    end;
    if oh < nh then
      for i := oh to nh - 1 do
        for k := 0 to nw - 1 do
          tlayers[j][i][k] := -1;
  end;
end;

procedure TfrmMap.setup;
var
  j, i, k           : integer;
  l                 : TStrings;
  ln                : TStrings;
  lname             : string;
begin
  l := TStringlist.Create;
  ln := TStringlist.Create;

  setlength( tlayers, map.ReadInteger( 'map', 'numlayer', 1 ) );
  setlength( tlayertiles, length( tlayers ) );
  mw := map.ReadInteger( 'map', 'width', 10 );
  mh := map.ReadInteger( 'map', 'height', 10 );

  with Image1.Picture.Bitmap do begin
    tilesize := map.ReadInteger( 'map', 'tilesize', 32 );
    Width := tilesize * mw;
    Height := tilesize * mh;
    Image1.Width := Width * scale;
    Image1.height := height * scale;
  end;

  Layers.Items.Clear;
  for j := 0 to high( tlayers ) do begin

    layers.AddItem( map.ReadString( 'layer' + inttostr( j ), 'name', 'layer' + inttostr( j ) ), nil );
    layers.Checked[layers.Count - 1] := True;

    setlength( tlayers[j], mh );
    for i := 0 to high( tlayers[j] ) do begin
      setlength( tlayers[j][i], mw );
      for k := 0 to mw - 1 do
        tlayers[j][i][k] := -1;
    end;

    //load tiles
    l.CommaText := map.ReadString( 'layer' + inttostr( j ), 'tiles', '' );
    setlength( tlayertiles[j], l.Count );
    for i := 0 to l.Count - 1 do begin
      tlayertiles[j][i] := citra_load( rootdir + '\image\' + l[i] );
    end;

    //load tile placements
    lname := dirname + '\map' + inttostr( j ) + '.map';
    if fileexists( lname ) then begin

      l.LoadFromFile( lname );

      for i := 0 to high( tlayers[j] ) do begin
        ln.CommaText := l[i];
        for k := 0 to high( tlayers[j][i] ) do
          tlayers[j][i][k] := strtoint( ln[k] );
      end;

    end;
  end;

  ln.Free;
  l.Free;
end;

procedure TfrmMap.layersClick( Sender: TObject );
var
  bmp               : Tbitmap;
  i, j              : integer;
begin
  if layers.ItemIndex = -1 then exit;
  j := layers.ItemIndex;
  for i := 0 to lbTiles.Count - 1 do begin
    tmpbmp[i].Free;
  end;
  setlength( tmpbmp, 0 );
  lbTiles.Clear;

  setlength( tmpbmp, length( tlayertiles[j] ) );
  for i := 0 to high( tlayertiles[j] ) do begin
    tmpbmp[i] := citra_create( lbTiles.ItemHeight, lbTiles.ItemHeight, tlayertiles[j][i].PixelFormat );
    tmpbmp[i].Canvas.StretchDraw( Bounds( 0, 0, tmpbmp[i].Width, tmpbmp[i].Height ), tlayertiles[j][i] );
    lbTiles.AddItem( '', tmpbmp[i] );
  end;
  lbTiles.ItemIndex := 0;
  redraw;
end;

procedure TfrmMap.FormCreate( Sender: TObject );
begin
  setlength( tmpbmp, 0 );
end;

procedure TfrmMap.lbTilesDrawItem( Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState );
var
  Offset            : integer;
  Bitmap            : TBitmap;
begin
  with ( Control as TListBox ).Canvas do { draw on control canvas, not on the form } begin
    FillRect( Rect ); { clear the rectangle }
    Offset := 2; { provide default offset }
    Bitmap := TBitmap( ( Control as TListBox ).Items.Objects[Index] ); { get the bitmap }
    if Bitmap <> nil then begin
      BrushCopy( Bounds( Rect.Left + Offset, Rect.Top, Bitmap.Width, Bitmap.Height ),
        Bitmap, Bounds( 0, 0, Bitmap.Width, Bitmap.Height ), clRed ); {render bitmap}
      Offset := Bitmap.width + 6; { add four pixels between bitmap and text}
    end;
    TextOut( Rect.Left + Offset, Rect.Top, ( Control as TListBox ).Items[Index] ) { display the text }
  end;

end;

procedure TfrmMap.ToolButton7Click( Sender: TObject );
begin
  with Image1.Picture.Bitmap do begin
    if scale > 1 then
      scale := scale div 2;
    Image1.Width := Width * scale;
    Image1.Height := Height * scale;
  end;
end;

procedure TfrmMap.ToolButton8Click( Sender: TObject );
begin
  with Image1.Picture.Bitmap do begin
    if scale < 100 then
      scale := scale * 2;
    Image1.Width := Width * scale;
    Image1.Height := Height * scale;
  end;
end;

procedure TfrmMap.ToolButton9Click( Sender: TObject );
begin
  with Image1.Picture.Bitmap do begin
    scale := 1;
    Image1.Width := Width * scale;
    Image1.Height := Height * scale;
  end;
end;

procedure TfrmMap.FormShow( Sender: TObject );
begin
  redraw;
end;

procedure TfrmMap.Image1MouseDown( Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer );
begin
  p1 := Point( X, Y );
  bdown := true;
  if ( layers.ItemIndex > -1 ) and ( lbTiles.ItemIndex > -1 ) then
    case mode of
      0: begin
          tlayers[layers.ItemIndex][Y div scale div tilesize][X div scale div tilesize] := lbTiles.ItemIndex;
          redraw;
        end;
      1: begin
          tlayers[layers.ItemIndex][Y div scale div tilesize][X div scale div tilesize] := -1;
          redraw;
        end;
      2: begin
          flood( layers.ItemIndex, lbTiles.ItemIndex, X div scale div tilesize, Y div scale div tilesize );
          redraw;
        end;
    end;
end;

procedure TfrmMap.Image1MouseUp( Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer );
begin
  p2 := Point( X, Y );
  bdown := false;
end;

procedure TfrmMap.Image1MouseMove( Sender: TObject; Shift: TShiftState; X,
  Y: Integer );
begin
  if bdown then begin
    p2 := Point( X, Y );
    if ( layers.ItemIndex > -1 ) and ( lbTiles.ItemIndex > -1 ) then begin
      case mode of
        0: tlayers[layers.ItemIndex][Y div scale div tilesize][X div scale div tilesize] := lbTiles.ItemIndex;
        1: tlayers[layers.ItemIndex][Y div scale div tilesize][X div scale div tilesize] := -1;
      end;
      redraw;
    end;
  end;
end;

procedure TfrmMap.ToolButton3Click( Sender: TObject );
begin
  mode := 0;
end;

procedure TfrmMap.ToolButton4Click( Sender: TObject );
begin
  mode := 1;
end;

procedure TfrmMap.ToolButton5Click( Sender: TObject );
begin
  mode := 2;
end;

procedure TfrmMap.flood( layerid, value, x, y: integer );
var
  stack             : array of TPoint;
  p                 : TPoint;
  yy, y1, y2        : integer;
  sl, sr            : boolean;
  col               : integer;

  procedure push( x, y: integer );
  begin
    setlength( stack, length( stack ) + 1 );
    stack[high( stack )] := point( x, y );
  end;

  function pop: TPoint;
  begin
    result := stack[high( stack )];
    setlength( stack, length( stack ) - 1 );
  end;

  function empty: boolean;
  begin
    result := length( stack ) <= 0;
  end;

begin
  setlength( stack, 0 );

  col := tlayers[layerid][y][x];
  if col = value then exit;
  push( x, y );
//  showmessage(inttostr(col));
  while not empty do begin
    p := pop;
    y1 := p.Y;
    while ( y1 > 0 ) and ( tlayers[layerid][y1 - 1][p.X] = col ) do
      dec( y1 );
    y2 := p.Y;
    while ( y2 < mh - 1 ) and ( tlayers[layerid][y2 + 1][p.X] = col ) do
      inc( y2 );
    //showmessage(format('y1 %d y2 %d', [y1, y2]));
    sl := false;
    sr := false;
    for yy := y1 to y2 do begin
      if p.X > 0 then begin
        if not sl and ( tlayers[layerid][yy][p.X - 1] = col ) then begin
          sl := true;
          push( p.X - 1, yy );
        end
        else
          if sl and not ( tlayers[layerid][yy][p.X - 1] = col ) then
            sl := false;
      end;
      if p.X < mw - 1 then begin
        if not sr and ( tlayers[layerid][yy][p.X + 1] = col ) then begin
          sr := true;
          push( p.X + 1, yy );
        end
        else
          if sr and not ( tlayers[layerid][yy][p.X + 1] = col ) then
            sr := false;
      end;
      tlayers[layerid][yy][p.X] := value;
    end;
  end;
end;

procedure TfrmMap.SaveMapClick( Sender: TObject );
var
  j, i              : integer;
  l, ln             : TStrings;
begin
  if layers.ItemIndex = -1 then exit;
  l := TStringlist.Create;
  ln := TStringlist.Create;

  for j := 0 to high( tlayers[layers.itemIndex] ) do begin
    ln.Clear;
    for i := 0 to high( tlayers[layers.itemIndex][j] ) do begin
      ln.Add( inttostr( tlayers[layers.ItemIndex][j][i] ) );
    end;
    l.Add( ln.CommaText );
  end;

  l.SaveToFile( dirname + '\map' + inttostr( layers.itemIndex ) + '.map' );
  ln.Free;
  l.Free;
end;

procedure TfrmMap.Import1Click( Sender: TObject );
var
  s                 : TStrings;
  tname             : string;
  bmp               : TBitmap;
begin
  main.opd.InitialDir := rootdir + '\image\';
  if main.opd.Execute then begin
    setlength( tlayertiles[layers.itemIndex], length( tlayertiles[layers.itemIndex] ) + 1 );
    bmp := citra_load( main.opd.FileName );
    tlayertiles[layers.ItemIndex][high( tlayertiles[layers.ItemIndex] )] := bmp;

    setlength( tmpbmp, length( tmpbmp ) + 1 );
    tmpbmp[high( tmpbmp )] := citra_create( lbTiles.ItemHeight, lbTiles.ItemHeight, bmp.PixelFormat );
    tmpbmp[high( tmpbmp )].Canvas.StretchDraw( Bounds( 0, 0, lbTiles.ItemHeight, lbTiles.ItemHeight ), bmp );

    lbTiles.AddItem( '', tmpbmp[high( tmpbmp )] );

    s := TStringlist.Create;
    s.CommaText := map.ReadString( 'layer' + inttostr( layers.ItemIndex ), 'tiles', '' );
    tname := ExtractFileName( main.opd.FileName );
    s.Add( tname );
    map.WriteString( 'layer' + inttostr( layers.ItemIndex ), 'tiles', s.CommaText );
    map.UpdateFile;
    s.Free;

    if lbTiles.ItemIndex = -1 then lbTiles.ItemIndex := lbTiles.Count-1;
  end;
end;

procedure TfrmMap.NewLayer1Click( Sender: TObject );
{
  reports:
  http://www.gamedevid.org/forum/showpost.php?p=102117&postcount=23
}
var
  j, i, k           : integer;
begin
  layers.Items.Add( 'layer' + inttostr( layers.Count ) );
  layers.Checked[layers.Count - 1] := True;

  map.WriteInteger( 'map', 'numlayer', layers.Count );
  map.WriteString( 'layer' + inttostr( layers.Count - 1 ), 'name', 'layer' + inttostr( layers.Count - 1 ) );
  map.WriteString( 'layer' + inttostr( layers.Count - 1 ), 'tiles', '' );
  map.UpdateFile;

  setlength( tlayers, length( tlayers ) + 1 );
  j := high( tlayers );
  setlength( tlayers[j], mh );
  for i := 0 to high( tlayers[j] ) do begin
    setlength( tlayers[j][i], mw );
    for k := 0 to high( tlayers[j][i] ) do begin
      tlayers[j][i][k] := -1;
    end;
  end;

  setlength( tlayertiles, length( tlayers ) );
  setlength( tlayertiles[j], 0 );

  layers.ItemIndex := j;
  SaveMapClick( nil );
  layersClick( nil );
end;

{ TMap }

constructor TMap.Create( w, h: integer );
begin
  FLayers := TObjectlist.Create( True );
  Resize( w, h );
end;

procedure TMap.AddLayer( layername: string );
var
  layer             : TMapLayer;
begin
  if layername = '' then layername := 'layer' + inttostr( FLayers.Count );
  layer := TMapLayer.Create( self, 'layer' + inttostr( FLayers.Count ), FWidth, FHeight );

  layer.FFilename := '';
  FLayers.Add( layer );
  FData.WriteInteger( 'map', 'numlayer', FLayers.Count );
  FData.UpdateFile;
end;

constructor TMap.Create( filename: string );
begin
  FLayers := TObjectlist.Create( True );
  self.Filename := filename;
end;

destructor TMap.Free;
begin
  FLayers.Free;
  if Assigned( FData ) then
    FData.Free;
end;

procedure TMap.Resize( newWidth, newHeight: integer );
var
  j                 : integer;
begin
  for j := 0 to FLayers.Count - 1 do
    ( FLayers[j] as TMapLayer ).resize( newWidth, newHeight );
  FData.WriteInteger( 'map', 'width', newWidth );
  FData.WriteInteger( 'map', 'height', newHeight );
  if ( newWidth <> FWidth ) or ( newHeight <> FHeight ) then
    FData.UpdateFile;
  FWidth := newWidth;
  FHeight := newHeight;
end;

procedure TMap.SetFilename( newFilename: string );
begin
  if Assigned( FData ) then FData.Free;

  FData := TIniFile.Create( filename );
end;

{ TMapLayer }

constructor TMapLayer.Create( Parent: TMap; id: string; w, h: integer );
begin
  FID := id;
  FTiles := TObjectList.Create( True );
  FTileFilenames := TStringlist.Create;
  resize( w, h );
end;

destructor TMapLayer.Free;
begin
  FTiles.Free;
  FTileFilenames.Free;
end;

procedure TMapLayer.load( filename: string );
var
  s, l              : TStrings;
  i, j              : integer;
begin
  FFilename := filename;
  s := TStringlist.Create;
  l := TStringlist.Create;
  s.LoadFromFile( FFilename );

  for j := 0 to high( FPos ) do begin
    l.CommaText := s[j];
    for i := 0 to High( FPos[j] ) do begin
      FPos[j][i] := StrToInt( l[i] );
    end;
  end;

  l.Free;
  s.Free;
end;

procedure TMapLayer.resize( nw, nh: integer );
var
  j, i              : integer;
  ow, oh            : integer;
begin
  oh := length( FPos );
  ow := length( FPos[0] );
  setlength( FPos, nh );
  for j := 0 to high( FPos ) do begin
    setlength( FPos[j], nw );
    if nw > ow then
      for i := ow to nw - 1 do
        FPos[j][i] := -1;
  end;
  if nh > oh then
    for j := oh to nh - 1 do
      for i := 0 to nw - 1 do
        FPos[j][i] := -1;
end;

procedure TMapLayer.save;
var
  s, l              : TStrings;
  i, j              : integer;
begin
  s := TStringlist.Create;
  l := TStringlist.Create;

  for j := 0 to high( FPos ) do begin
    l.Clear;
    for i := 0 to High( FPos[j] ) do begin
      l.Add( Inttostr( FPos[j][i] ) );
    end;
    s.Add( l.CommaText );
  end;

  s.SaveToFile( FFilename );
  l.Free;
  s.Free;
end;

procedure TMapLayer.SetName( newName: string );
begin
  FParent.FData.WriteString( FID, 'name', newName );
  if newName <> FName then
    FParent.FData.UpdateFile;
  FName := newName;
end;

procedure TfrmMap.Remove1Click( Sender: TObject );
var
  s                 : TStrings;
  l, i, y, x        : integer;

begin
  if lbTiles.ItemIndex = -1 then exit;
  s := TStringlist.Create;
  l := layers.ItemIndex;
  i := lbTiles.ItemIndex;
  s.CommaText := map.ReadString( 'layer' + inttostr( l ), 'tiles', '' );
  s.Delete( i );
  lbTiles.DeleteSelected;
  map.WriteString( 'layer' + inttostr( layers.ItemIndex ), 'tiles', s.CommaText );
  map.UpdateFile;
  for y := 0 to high( tlayers[l] ) do begin
    for x := 0 to high( tlayers[l][y] ) do begin
      if tlayers[l][y][x] = i then
        tlayers[l][y][x] := -1
      else
        if tlayers[l][y][x] > i then tlayers[l][y][x] := tlayers[l][y][x] - 1;
    end;
  end;
  SaveMapClick(nil);
  self.Go(dirname);
end;

procedure TfrmMap.DeleteLayer1Click(Sender: TObject);
var
  l, i : integer;
  names, tiles: TStrings;
begin
  l := layers.ItemIndex;
  if l = -1 then exit;
  if layers.Count=1 then begin
    MessageDlg('Cannot delete layer. Minimum number of layers in a map is 1', mtInformation, [mbOK], 0);
    exit;
  end;

  names := TStringlist.Create;
  tiles := TStringlist.Create;

  for i := 0 to layers.Count-1 do begin
    names.Add(map.ReadString('layer'+inttostr(i), 'name', ''));
    tiles.Add(map.ReadString('layer'+inttostr(i), 'tiles', ''));
  end;

  map.WriteInteger('map', 'numlayer', layers.Count-1);
  for i := l to layers.Count-2 do begin
    map.WriteString('layer'+inttostr(i), 'name', names[i+1]);
    map.WriteString('layer'+inttostr(i), 'tiles', tiles[i+1]);
  end;
  map.UpdateFile;

  names.Free;
  tiles.Free;  
  go(dirname);
end;

procedure TfrmMap.toTop1Click(Sender: TObject);
var
  l, i : integer;
  tmp : string;
  names, tiles, map1, map2: TStrings;
begin
  //move to layerCount-1
  l := layers.ItemIndex;
  if (l = -1) or (l=layers.Count-1) then exit;

  names := TStringlist.Create;
  tiles := TStringlist.Create;
  map1 := TStringlist.Create;
  map2 := TStringlist.Create;

  for i := 0 to layers.Count-1 do begin
    names.Add(map.ReadString('layer'+inttostr(i), 'name', ''));
    tiles.Add(map.ReadString('layer'+inttostr(i), 'tiles', ''));
  end;

  for i := l to layers.Count-2 do begin
    //swap name
    tmp := names[i];
    names[i] := names[i+1];
    names[i+1] := tmp;
    //swap tiles
    tmp := tiles[i];
    tiles[i] := tiles[i+1];
    tiles[i+1] := tmp;
    //swap file
    map1.LoadFromFile(dirname+'\map'+inttostr(i)+'.map');
    map2.LoadFromFile(dirname+'\map'+inttostr(i+1)+'.map');
    map1.SaveToFile(dirname+'\map'+inttostr(i+1)+'.map');
    map2.SaveToFile(dirname+'\map'+inttostr(i)+'.map');
    //save
    map.WriteString('layer'+inttostr(i), 'name', names[i]);
    map.WriteString('layer'+inttostr(i), 'tiles', tiles[i]);
  end;
  i := layers.Count-1;
  map.WriteString('layer'+inttostr(i), 'name', names[i]);
  map.WriteString('layer'+inttostr(i), 'tiles', tiles[i]);
  map.UpdateFile;

  names.Free;
  tiles.Free;
  map1.Free;
  map2.Free;
  go(dirname);
end;

procedure TfrmMap.Bottom1Click(Sender: TObject);
var
  l, i : integer;
  tmp : string;
  names, tiles, map1, map2: TStrings;
begin
  //move to 0
  l := layers.ItemIndex;
  if (l = -1) or (l=0) then exit;

  names := TStringlist.Create;
  tiles := TStringlist.Create;
  map1 := TStringlist.Create;
  map2 := TStringlist.Create;

  for i := 0 to layers.Count-1 do begin
    names.Add(map.ReadString('layer'+inttostr(i), 'name', ''));
    tiles.Add(map.ReadString('layer'+inttostr(i), 'tiles', ''));
  end;

  for i := l downto 1 do begin
    //swap name
    tmp := names[i];
    names[i] := names[i-1];
    names[i-1] := tmp;
    //swap tiles
    tmp := tiles[i];
    tiles[i] := tiles[i-1];
    tiles[i-1] := tmp;
    //swap file
    map1.LoadFromFile(dirname+'\map'+inttostr(i)+'.map');
    map2.LoadFromFile(dirname+'\map'+inttostr(i-1)+'.map');
    map1.SaveToFile(dirname+'\map'+inttostr(i-1)+'.map');
    map2.SaveToFile(dirname+'\map'+inttostr(i)+'.map');
    //save
    map.WriteString('layer'+inttostr(i), 'name', names[i]);
    map.WriteString('layer'+inttostr(i), 'tiles', tiles[i]);
  end;
  i := 0;
  map.WriteString('layer'+inttostr(i), 'name', names[i]);
  map.WriteString('layer'+inttostr(i), 'tiles', tiles[i]);
  map.UpdateFile;

  names.Free;
  tiles.Free;
  map1.Free;
  map2.Free;
  go(dirname);
end;

procedure TfrmMap.MoveUp1Click(Sender: TObject);
var
  l, i : integer;
  tmp : string;
  names, tiles, map1, map2: TStrings;
begin
  //move to layerCount-1
  l := layers.ItemIndex;
  if (l = -1) or (l=layers.Count-1) then exit;

  names := TStringlist.Create;
  tiles := TStringlist.Create;
  map1 := TStringlist.Create;
  map2 := TStringlist.Create;

  for i := 0 to layers.Count-1 do begin
    names.Add(map.ReadString('layer'+inttostr(i), 'name', ''));
    tiles.Add(map.ReadString('layer'+inttostr(i), 'tiles', ''));
  end;

  i := l;

    //swap name
    tmp := names[i];
    names[i] := names[i+1];
    names[i+1] := tmp;
    //swap tiles
    tmp := tiles[i];
    tiles[i] := tiles[i+1];
    tiles[i+1] := tmp;
    //swap file
    map1.LoadFromFile(dirname+'\map'+inttostr(i)+'.map');
    map2.LoadFromFile(dirname+'\map'+inttostr(i+1)+'.map');
    map1.SaveToFile(dirname+'\map'+inttostr(i+1)+'.map');
    map2.SaveToFile(dirname+'\map'+inttostr(i)+'.map');
    //save
    map.WriteString('layer'+inttostr(i), 'name', names[i]);
    map.WriteString('layer'+inttostr(i), 'tiles', tiles[i]);
    map.WriteString('layer'+inttostr(i+1), 'name', names[i+1]);
    map.WriteString('layer'+inttostr(i+1), 'tiles', tiles[i+1]);

  map.UpdateFile;

  names.Free;
  tiles.Free;
  map1.Free;
  map2.Free;
  go(dirname);
  //+1
end;

procedure TfrmMap.MoveDown1Click(Sender: TObject);
var
  l, i : integer;
  tmp : string;
  names, tiles, map1, map2: TStrings;
begin
  l := layers.ItemIndex;
  if (l = -1) or (l=0) then exit;

  names := TStringlist.Create;
  tiles := TStringlist.Create;
  map1 := TStringlist.Create;
  map2 := TStringlist.Create;

  for i := 0 to layers.Count-1 do begin
    names.Add(map.ReadString('layer'+inttostr(i), 'name', ''));
    tiles.Add(map.ReadString('layer'+inttostr(i), 'tiles', ''));
  end;

    i := l;
    //swap name
    tmp := names[i];
    names[i] := names[i-1];
    names[i-1] := tmp;
    //swap tiles
    tmp := tiles[i];
    tiles[i] := tiles[i-1];
    tiles[i-1] := tmp;
    //swap file
    map1.LoadFromFile(dirname+'\map'+inttostr(i)+'.map');
    map2.LoadFromFile(dirname+'\map'+inttostr(i-1)+'.map');
    map1.SaveToFile(dirname+'\map'+inttostr(i-1)+'.map');
    map2.SaveToFile(dirname+'\map'+inttostr(i)+'.map');
    //save
    map.WriteString('layer'+inttostr(i), 'name', names[i]);
    map.WriteString('layer'+inttostr(i), 'tiles', tiles[i]);
    map.WriteString('layer'+inttostr(i-1), 'name', names[i-1]);
    map.WriteString('layer'+inttostr(i-1), 'tiles', tiles[i-1]);

  map.UpdateFile;

  names.Free;
  tiles.Free;
  map1.Free;
  map2.Free;
  go(dirname);
  //-1
end;

procedure TfrmMap.Rename1Click(Sender: TObject);
var
  i : integer;
begin
  //rename
  i := layers.ItemIndex;
  
  layers.Items[i] := InputBox('layer Name', 'Rename Layer', layers.Items[i]);

  map.WriteString('layer'+inttostr(i), 'name', layers.Items[i]);
  map.UpdateFile;
end;

end.

