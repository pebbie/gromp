unit _tile;

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
  ExtCtrls,
  ToolWin,
  ComCtrls,
  pngimage;

type
  TfrmTile = class( TForm )
    ToolBar1: TToolBar;
    ScrollBox1: TScrollBox;
    Image1: TImage; //checker image
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    SaveTile: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ScrollBox2: TScrollBox;
    Image2: TImage; //palette
    Image3: TImage;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    curcol: TShape;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    Image4: TImage;
    Panel1: TPanel;
    ToolButton1: TToolButton;
    tbAlpha: TTrackBar;
    ToolButton12: TToolButton;
    procedure ToolButton6Click( Sender: TObject );
    procedure ToolButton8Click( Sender: TObject );
    procedure SaveTileClick( Sender: TObject );
    procedure Image3MouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure Image3MouseUp( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure Image3MouseMove( Sender: TObject; Shift: TShiftState; X,
      Y: Integer );
    procedure Image2MouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
    procedure FormCreate( Sender: TObject );
    procedure ToolButton10Click( Sender: TObject );
    procedure ToolButton2Click( Sender: TObject );
    procedure ToolButton4Click( Sender: TObject );
    procedure ToolButton5Click( Sender: TObject );
    procedure ToolButton9Click( Sender: TObject );
    procedure Image2MouseMove( Sender: TObject; Shift: TShiftState; X,
      Y: Integer );
    procedure FormDestroy( Sender: TObject );
    procedure ToolButton1Click( Sender: TObject );
    procedure ToolButton12Click( Sender: TObject ); //current image
  private
    { Private declarations }

    checkerboard: TBitmap;
    rgb_image: TBitmap;
    alpha_image: TBitmap;
    p1, p2: TPoint;
    procedure DrawTool;
    procedure ClearTool;
    procedure setCurrentColor( color: TColor );
    function getCurrentColor: TColor;
    procedure display;
    procedure load_image( filename: string );
    procedure save_image( filename: string );
    procedure flood_fill( x, y: integer );
    procedure flood_alpha( x, y: integer );
  public
    { Public declarations }
    filename: string;
    procedure go( filename: string );
    procedure newtile;
    property CurrentColor: TColor read getCurrentColor write setCurrentColor;
  end;

var
  frmTile           : TfrmTile;

implementation

uses citra,
  _main;

{$R *.dfm}

{ TfrmTile }

var
  bdown             : boolean = false;
var
  oldmode           : integer = 1;
  mode              : integer = 1;
  scale             : integer = 8;
var
  pm                : array of PArrRGB; //checkerboard mask
  has_alpha         : boolean = false;

procedure TfrmTile.go( filename: string );
begin
  self.filename := filename;
  if extractfileext( filename ) = '.png' then
    load_image( filename )
  else
    citra_load( Image1.Picture.Bitmap, filename );
  with Image1.Picture.Bitmap do begin
    Image1.Width := Width * scale;
    Image1.Height := Height * scale;
    Image3.Width := Width * scale;
    Image3.Height := Height * scale;
    Image3.Picture.Bitmap.Width := Width;
    Image3.Picture.Bitmap.Height := Height;
    scale := Image1.Width div Width;
  end;
 // if has_alpha then
  display;
end;

procedure TfrmTile.newtile;
begin
  Image1.Picture.Bitmap := TBitmap.Create;
  with Image1.Picture.Bitmap do begin
    Width := 32;
    Height := 32;
    Image1.Width := Width * scale;
    Image1.Height := Height * scale;
    Image3.Width := Width * scale;
    Image3.Height := Height * scale;
    Image3.Picture.Bitmap.Width := Width;
    Image3.Picture.Bitmap.Height := Height;
  end;
end;

procedure TfrmTile.ToolButton6Click( Sender: TObject );
begin
  //zoom in
  with Image1 do begin
    if scale > 1 then begin
      scale := scale div 2;
    end;
    Width := Picture.Bitmap.Width * scale;
    Height := Picture.Bitmap.Height * scale;
    Image3.Width := Width;
    Image3.Height := Height;
  end;

end;

procedure TfrmTile.ToolButton8Click( Sender: TObject );
begin
  with Image1 do begin
    if scale < 100 then begin
      scale := scale * 2;
    end;
    Width := Picture.Bitmap.Width * scale;
    Height := Picture.Bitmap.Height * scale;
    Image3.Width := Width;
    Image3.Height := Height;
  end;
end;

procedure TfrmTile.SaveTileClick( Sender: TObject );
begin
  if extractfileext( filename ) = '.png' then
    save_image( filename )
  else
    citra_save( Image1.Picture.Bitmap, filename );
  main.tvClick( nil );
end;

procedure TfrmTile.Image3MouseDown( Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer );
begin
  p1 := Point( X, Y );
  bdown := true;
  case mode of
    0: begin
        CurrentColor := Image1.Picture.Bitmap.Canvas.Pixels[X div scale, Y div scale];
        mode := oldmode;
      end;
    1: begin
        rgb_image.Canvas.Pixels[X div scale, Y div scale] := CurrentColor;
        alpha_image.Canvas.Pixels[X div scale, Y div scale] := clWhite;
      end;

    3: begin
        //rgb_image.Canvas.Brush.Color := CurrentColor;
        //rgb_image.Canvas.FloodFill( X div scale, Y div scale, Image1.Picture.Bitmap.Canvas.Pixels[X div scale, Y div scale], fsSurface );
        flood_fill( X div scale, Y div scale );
      end;
    4: begin
        Image1.Picture.Bitmap.Canvas.Pixels[X div scale, Y div scale] := clWhite;
        alpha_image.Canvas.Pixels[X div scale, Y div scale] := clBlack;
      end;
    5: begin
        flood_alpha( X div scale, Y div scale );
      end;
  end;
  display;
end;

procedure TfrmTile.Image3MouseUp( Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer );
begin
  if bdown then begin
    if mode = 2 then begin
      with rgb_image.Canvas do begin
        Pen.Color := CurrentColor;
        MoveTo( p1.X div scale, p1.Y div scale );
        LineTo( p2.X div scale, p2.Y div scale );
        display;
      end;
    end;
    if mode = 4 then begin
      with alpha_image.Canvas do begin
        Pen.Color := clBlack;
        MoveTo( p1.X div scale, p1.Y div scale );
        LineTo( p2.X div scale, p2.Y div scale );
        display;
      end;
    end;
    ClearTool;

  end;
  bdown := false;
end;

procedure TfrmTile.Image3MouseMove( Sender: TObject; Shift: TShiftState; X,
  Y: Integer );
begin
  main.sb.Panels[2].Text := format( 'X:%3d Y:%3d', [X div scale, Y div scale] );
  if bdown then begin
    p2 := Point( X, Y );
    DrawTool;
    display;
  end;
end;

procedure TfrmTile.DrawTool;
begin
  with Image3.Picture.Bitmap.Canvas do begin
    if mode = 1 then begin
      Image1.Picture.Bitmap.Canvas.Pen.Color := curcol.Brush.Color;
      Image1.Picture.Bitmap.Canvas.Pen.Style := psSolid;
      Image1.Picture.Bitmap.Canvas.MoveTo( p1.X div scale, p1.Y div scale );
      Image1.Picture.Bitmap.Canvas.LineTo( p2.X div scale, p2.Y div scale );
      p1 := p2;
    end;
    Lock;
    FillRect( Image3.ClientRect );
    if mode = 2 then begin
      MoveTo( p1.X div scale, p1.Y div scale );
      LineTo( p2.X div scale, p2.Y div scale );
    end;
    Unlock;
  end;
end;

procedure TfrmTile.Image2MouseDown( Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer );
begin
  if Button = mbLeft then
    curcol.Brush.Color := Image2.Canvas.Pixels[X, Y];
end;

var
  colhex            : array[0..5] of byte = ( $00, $33, $66, $99, $CC, $FF );

procedure TfrmTile.FormCreate( Sender: TObject );
var
  r, g, b           : byte;
  y, x              : integer;
begin
  rgb_image := TBitmap.Create;
  alpha_image := TBitmap.Create;
  checkerboard := citra_create( 4, 4, pf24bit );
  setlength( pm, checkerboard.Height );
  with checkerboard.Canvas do begin
    Brush.Color := clSilver;
    FillRect( Bounds( 0, 0, 4, 4 ) );
    Brush.Color := clWhite;
    FillRect( Bounds( 0, 0, 2, 2 ) );
    FillRect( Bounds( 2, 2, 2, 2 ) );
  end;
  for y := 0 to high( pm ) do
    pm[y] := checkerboard.ScanLine[y];

  //setup properties
  Image3.ControlStyle := Image3.ControlStyle + [csOpaque];
  //draw palette
  Image2.Canvas.Pen.Style := psClear;
  x := 0;
  y := 0;
  for r := 0 to 5 do
    for g := 0 to 5 do
      for b := 0 to 5 do begin
        Image2.Canvas.Brush.Color := RGB( colhex[r], colhex[g], colhex[b] );
        Image2.Canvas.Rectangle( x * 16, y * 16, ( x + 1 ) * 16, ( y + 1 ) * 16 );
        inc( y );
        if y > 5 then begin
          y := 0;
          inc( x );
        end;
      end;

  Image3.Canvas.Pen.Style := psClear;
  Image3.Canvas.Brush.Color := clFuchsia;
  Image3.Picture.Bitmap.Transparent := true;
  Image3.Picture.Bitmap.TransparentMode := tmAuto;
  Image3.Canvas.FillRect( Image3.ClientRect );
  newtile;
end;

procedure TfrmTile.ToolButton10Click( Sender: TObject );
begin
  if mode <> 0 then oldmode := mode;
  mode := 0;
  ClearTool;
end;

procedure TfrmTile.ToolButton2Click( Sender: TObject );
begin
  mode := 1;
  ClearTool;
end;

procedure TfrmTile.ToolButton4Click( Sender: TObject );
begin
  mode := 2;
  ClearTool;
end;

procedure TfrmTile.ToolButton5Click( Sender: TObject );
begin
  mode := 3;
  ClearTool;
end;

procedure TfrmTile.ToolButton9Click( Sender: TObject );
begin
  with Image1 do begin
    scale := 1;
    Width := Picture.Bitmap.Width * scale;
    Height := Picture.Bitmap.Height * scale;
    Image3.Width := Width;
    Image3.Height := Height;
  end;
end;

procedure TfrmTile.ClearTool;
begin
  with Image3.Canvas do begin
    Pen.Style := psClear;
    FillRect( Image3.ClientRect );
  end;
  if mode = 2 then begin
    Image3.Canvas.Pen.Style := psSolid;
    Image3.Canvas.Pen.Color := CurrentColor;
  end;
end;

procedure TfrmTile.Image2MouseMove( Sender: TObject; Shift: TShiftState; X,
  Y: Integer );
var
  p                 : tColor;
  tmp               : string;
begin
  p := Image2.Canvas.Pixels[X, Y];
  tmp := format( 'R:%.3d G:%.3d B:%.3d', [GetRValue( p ), GetGValue( p ), GetBValue( p )] );
  if tmp <> main.sb.Panels[1].Text then
    main.sb.Panels[1].Text := tmp;
end;

procedure TfrmTile.setCurrentColor( color: TColor );
begin
  curcol.Brush.Color := color;
end;

function TfrmTile.getCurrentColor: TColor;
begin
  result := curcol.Brush.Color;
end;

procedure TfrmTile.display;
var
  p, p2, p3         : PArrRGB;
  i, j              : integer;
  a                 : real;
begin
  with Image1.Picture.Bitmap do begin
    for j := 0 to Height - 1 do begin
      p := Scanline[j]; //target image
      p3 := rgb_image.ScanLine[j]; //rgb image
      p2 := alpha_image.ScanLine[j]; //alpha mask
      for i := 0 to Width - 1 do begin
        a := p2[i].r / 255;

        p[i].r := clamp( round( p3[i].r * a + pm[j mod checkerboard.Height][i mod checkerboard.Width].r * ( 1 - a ) ) );
        p[i].g := clamp( round( p3[i].g * a + pm[j mod checkerboard.Height][i mod checkerboard.Width].g * ( 1 - a ) ) );
        p[i].b := clamp( round( p3[i].b * a + pm[j mod checkerboard.Height][i mod checkerboard.Width].b * ( 1 - a ) ) );

      end;
    end;
  end;
  Image1.Refresh;
end;

procedure TfrmTile.FormDestroy( Sender: TObject );
begin
  checkerboard.Free;
  rgb_image.Free;
  alpha_image.Free;
end;

procedure TfrmTile.load_image( filename: string );
var
  png               : TPNGObject;
  i, j              : integer;
  col               : cardinal;
  p                 : PArrRGB;
  pa                : PByteArray;
begin
  png := TPNGObject.Create;
  png.LoadFromFile( filename );
  rgb_image.Assign( png );
  rgb_image.PixelFormat := pf24bit;
  alpha_image.Assign( rgb_image );
  case png.TransparencyMode of
    ptmNone: begin
        //showmessage('no alpha');
        alpha_image.Canvas.Brush.Color := clWhite;
        alpha_image.Canvas.FillRect( Bounds( 0, 0, alpha_image.Width, alpha_image.Height ) );
      end;

    ptmBit: begin
        col := rgb_image.TransparentColor and $00FFFFFF;
        for j := 0 to rgb_image.Height - 1 do begin
          p := alpha_image.scanline[j];
          for i := 0 to rgb_image.Width - 1 do begin
            if rgb_image.Canvas.Pixels[i, j] = col then
              p[i] := rgb_hitam
            else
              p[i] := rgb_putih;
          end;
        end;
        has_alpha := true;
      end;

    ptmPartial: begin
        for j := 0 to png.Height - 1 do begin
          pa := png.AlphaScanline[j];
          p := alpha_image.ScanLine[j];
          for i := 0 to png.Width - 1 do begin
            p[i] := warna_create( pa[i], pa[i], pa[i] );
          end;
        end;
        has_alpha := true;
      end;
  end;
  png.Free;
  Image1.Picture.Bitmap.Assign( rgb_image );
end;

procedure TfrmTile.save_image( filename: string );
var
  png               : TPNGObject;
  p                 : PArrRGB;
  pa                : PByteArray;
  i, j              : integer;
begin
  png := TPNGObject.Create;
  png.Assign( rgb_image );
  png.CreateAlpha;
  for j := 0 to rgb_image.Height - 1 do begin
    p := alpha_image.scanline[j];
    pa := png.AlphaScanline[j];
    for i := 0 to rgb_image.Width - 1 do begin
      pa[i] := p[i].r;
    end;
  end;
  png.SaveToFile( filename );
  png.Free;
end;

procedure TfrmTile.ToolButton1Click( Sender: TObject );
begin
  mode := 4;
  ClearTool;
end;

procedure TfrmTile.ToolButton12Click( Sender: TObject );
begin
  mode := 5;
  ClearTool;
end;

procedure TfrmTile.flood_alpha( x, y: integer );
var
  st                : array of TPoint;
  p                 : TPoint;
  yy, y1, y2        : integer;
  sl, sr            : boolean;
  pi                : array of PArrRGB;
  pa                : array of PArrRGB;
  newcol, col       : TWarnaRGB;

  procedure push( x, y: integer );
  begin
    setlength( st, length( st ) + 1 );
    st[high( st )] := point( x, y );
  end;

  function pop( var pp: TPoint ): boolean;
  begin
    result := length( st ) > 0;
    if result then begin
      pp := st[high( st )];
      setlength( st, length( st ) - 1 );
    end;
  end;

  function same_col( w1, w2: TWarnaRGB ): boolean;
  begin
    result := ( w1.r = w2.r ) and ( w1.g = w2.g ) and ( w1.b = w2.b );
  end;

begin
  setlength( pi, rgb_image.Height );
  for yy := 0 to high( pi ) do
    pi[yy] := rgb_image.ScanLine[yy];
  setlength( pa, alpha_image.Height );
  for yy := 0 to high( pa ) do
    pa[yy] := alpha_image.ScanLine[yy];

  setlength( st, 0 );
  col := pi[y][x];
  newcol := warna_create( GETRValue( CurrentColor ), GETGValue( CurrentColor ), GETBValue( CurrentColor ) );
  push( x, y );
  while pop( p ) do begin
    y1 := p.Y;
    while ( y1 > 0 ) and same_col( pi[y1 - 1][p.X], col ) do
      dec( y1 );
    y2 := p.Y;
    while ( y2 < rgb_image.Height - 1 ) and same_col( pi[y2 + 1][p.X], col ) do
      inc( y2 );

    sl := False;
    sr := False;
    for yy := y1 to y2 do begin
      if p.X > 0 then begin
        if not sl and same_col( pi[yy][p.X - 1], col ) then begin
          sl := True;
          push( p.X - 1, yy );
        end
        else
          if sl and not same_col( pi[yy][p.X - 1], col ) then
            sl := false;
      end;
      if p.X < rgb_image.Width - 1 then begin
        if not sr and same_col( pi[yy][p.X + 1], col ) then begin
          sr := True;
          push( p.X + 1, yy );
        end
        else
          if sr and not same_col( pi[yy][p.X + 1], col ) then
            sr := false;
      end;
      pi[yy][p.X] := newcol;
      pa[yy][p.X] := rgb_hitam;
    end;
  end;
end;

procedure TfrmTile.flood_fill( x, y: integer );
var
  st                : array of TPoint;
  p                 : TPoint;
  yy, y1, y2        : integer;
  sl, sr            : boolean;
  pi                : array of PArrRGB;
  pa                : array of PArrRGB;
  newcol, col       : TWarnaRGB;

  procedure push( x, y: integer );
  begin
    setlength( st, length( st ) + 1 );
    st[high( st )] := point( x, y );
  end;

  function pop( var pp: TPoint ): boolean;
  begin
    result := length( st ) > 0;
    if result then begin
      pp := st[high( st )];
      setlength( st, length( st ) - 1 );
    end;
  end;

  function same_col( w1, w2: TWarnaRGB ): boolean;
  begin
    result := ( w1.r = w2.r ) and ( w1.g = w2.g ) and ( w1.b = w2.b );
  end;

begin
  setlength( pi, rgb_image.Height );
  for yy := 0 to high( pi ) do
    pi[yy] := rgb_image.ScanLine[yy];
  setlength( pa, alpha_image.Height );
  for yy := 0 to high( pa ) do
    pa[yy] := alpha_image.ScanLine[yy];

  setlength( st, 0 );
  col := pi[y][x];
  newcol := warna_create( GETRValue( CurrentColor ), GETGValue( CurrentColor ), GETBValue( CurrentColor ) );
  push( x, y );
  while pop( p ) do begin
    y1 := p.Y;
    while ( y1 > 0 ) and same_col( pi[y1 - 1][p.X], col ) do
      dec( y1 );
    y2 := p.Y;
    while ( y2 < rgb_image.Height - 1 ) and same_col( pi[y2 + 1][p.X], col ) do
      inc( y2 );

    sl := False;
    sr := False;
    for yy := y1 to y2 do begin
      if p.X > 0 then begin
        if not sl and same_col( pi[yy][p.X - 1], col ) then begin
          sl := True;
          push( p.X - 1, yy );
        end
        else
          if sl and not same_col( pi[yy][p.X - 1], col ) then
            sl := false;
      end;
      if p.X < rgb_image.Width - 1 then begin
        if not sr and same_col( pi[yy][p.X + 1], col ) then begin
          sr := True;
          push( p.X + 1, yy );
        end
        else
          if sr and not same_col( pi[yy][p.X + 1], col ) then
            sr := false;
      end;
      pi[yy][p.X] := newcol;
      pa[yy][p.X] := rgb_putih;
    end;
  end;
end;

end.

