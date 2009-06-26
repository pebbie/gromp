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
  ComCtrls;

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
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); //current image
  private
    { Private declarations }

    p1, p2: TPoint;
    procedure DrawTool;
    procedure ClearTool;
  public
    { Public declarations }
    filename: string;
    procedure go( filename: string );
    procedure newtile;
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
  mode              : integer = 1;
  scale             : integer = 8;

procedure TfrmTile.go( filename: string );
begin
  self.filename := filename;
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
  citra_save( Image1.Picture.Bitmap, filename );
  main.tvClick( nil );
end;

procedure TfrmTile.Image3MouseDown( Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer );
begin
  p1 := Point( X, Y );
  bdown := true;
  case mode of
    0: curcol.Brush.Color := Image1.Picture.Bitmap.Canvas.Pixels[X div scale, Y div scale];
    1: Image1.Picture.Bitmap.Canvas.Pixels[X div scale, Y div scale] := curcol.Brush.Color;
    3: begin
        Image1.Canvas.Brush.Color := curcol.Brush.Color;
        Image1.Canvas.FloodFill( X div scale, Y div scale, Image1.Picture.Bitmap.Canvas.Pixels[X div scale, Y div scale], fsSurface );
      end;
  end;
end;

procedure TfrmTile.Image3MouseUp( Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer );
begin
  if bdown then begin
    if mode = 2 then begin
      with Image1.Picture.Bitmap.Canvas do begin
        Pen.Color := curcol.Brush.Color;
        MoveTo( p1.X div scale, p1.Y div scale );
        LineTo( p2.X div scale, p2.Y div scale );
      end;
    end;
    ClearTool;
  end;
  bdown := false;
end;

procedure TfrmTile.Image3MouseMove( Sender: TObject; Shift: TShiftState; X,
  Y: Integer );
begin
  main.sb.Panels[2].Text := format('X:%3d Y:%3d', [X div scale, Y div scale]);
  if bdown then begin
    p2 := Point( X, Y );
    DrawTool;
  end;
end;

procedure TfrmTile.DrawTool;
begin
  with Image3.Picture.Bitmap.Canvas do begin
    if mode = 1 then begin
      Image1.Picture.Bitmap.Canvas.Pixels[p2.X div scale, p2.Y div scale] := curcol.Brush.Color;
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
    Image3.Canvas.Pen.Color := curcol.Brush.Color;
  end;
end;

procedure TfrmTile.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  p : tColor;
  tmp : string;
begin
  p := Image2.Canvas.Pixels[X,Y];
  tmp := format('R:%.3d G:%.3d B:%.3d',[GetRValue(p), GetGValue(p), GetBValue(p)]);
  if tmp <> main.sb.Panels[1].Text then
    main.sb.Panels[1].Text := tmp;
end;

end.

