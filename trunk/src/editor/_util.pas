unit _util;

interface

uses Windows,
  SysUtils,
  Classes,
  Controls,
  ComCtrls,
  StdCtrls,
  ExtCtrls,
  Graphics,
  ImgList,
  Dialogs;

procedure FileCopy( sfrom, sto: string );
function ForceRmDir( directory: string ): boolean;
procedure ListDir( path, mask: string; s: TStrings );
function IsImageFile( filename: string ): boolean;
procedure ReadTreeNode( path: string; TV: TTreeView; parent: TTreeNode );
procedure ReadListViewDir( path: string; lv: TListView );
procedure ReadListViewCSV( filename: string; lv: TListView; filter: boolean = false;
  filterfields: string = '' );
procedure DirListView( path: string; lv: TListView );

implementation

function ForceRmDir( directory: string ): boolean;
var
  f                 : TStrings;
  i                 : integer;
begin
  f := TStringlist.Create;
  ListDir( directory, '*', f );
  for i := 0 to f.Count - 1 do begin
    DeleteFile( directory + '\' + f[i] );
  end;
  if DirectoryExists( directory ) then
    result := RemoveDir( directory );
end;

function IsImageFile( filename: string ): boolean;
var
  ext               : string;
begin
  ext := lowercase( extractfileext( filename ) );
  if ext = '' then begin
    result := false;
    exit;
  end;
  result := ( ext = '.bmp' ) or ( ext = '.jpg' ) or ( ext = '.gif' ) or ( ext = '.png' );
end;

procedure ReadTreeNode( path: string; TV: TTreeView; parent: TTreeNode );
var
  sr                : TSearchRec;
  FileAttrs         : integer;
  tmp               : string;
  mask              : string;
  child             : TTreeNode;
begin
  FileAttrs := faDirectory;
  //Result := TStringList.Create;
  mask := '*';
//  showmessage(path+'\'+mask);
  if FindFirst( Path + '\' + mask, FileAttrs, sr ) = 0 then begin
    repeat
//         showmessage(path+'\'+sr.Name);
      if ( Pos( '.', sr.Name ) <> 1 ) and ( ( sr.Attr and FileAttrs ) = FileAttrs ) then begin
        tmp := sr.Name;
//ShowMessage(tmp);
        if DirectoryExists( path + '\' + tmp ) then begin
          Child := TV.Items.AddChild( parent, tmp );
          ReadTreeNode( path + '\' + tmp, TV, child );
        end;
          //Result.Add(tmp);
      end;
    until FindNext( sr ) <> 0;
    FindClose( sr );
  end;
//   showmessage(path+'\'+mask);
end;

procedure ListDir( path, mask: string; s: TStrings );
var
  sr                : TSearchRec;
  FileAttrs         : integer;
  tmp               : string;
begin
  s.Clear;
  FileAttrs := faAnyFile or faDirectory;
  //Result := TStringList.Create;
  //showmessage(path+'\'+mask);
  if FindFirst( Path + '\' + mask, FileAttrs, sr ) = 0 then begin
    repeat
        //showmessage(path+'\'+sr.Name);
      if ( Pos( '.', sr.Name ) <> 1 ) {and ((sr.Attr and FileAttrs) = FileAttrs)} then begin
        tmp := sr.Name;
        if fileExists( path + '\' + tmp ) then begin
          S.Add( tmp );
        end;
      end;
    until FindNext( sr ) <> 0;
    FindClose( sr );
  end;
end;

procedure ListDirectory( path, mask: string; s: TStrings );
var
  sr                : TSearchRec;
  FileAttrs         : integer;
  tmp               : string;
begin
  s.Clear;
  FileAttrs := faAnyFile or faDirectory;
  //Result := TStringList.Create;
  //showmessage(path+'\'+mask);
  if FindFirst( Path + '\' + mask, FileAttrs, sr ) = 0 then begin
    repeat
        //showmessage(path+'\'+sr.Name);
      if ( Pos( '.', sr.Name ) <> 1 ) {and ((sr.Attr and FileAttrs) = FileAttrs)} then begin
        tmp := sr.Name;
        if directoryExists( path + '\' + tmp ) then begin
          S.Add( tmp );
        end;
      end;
    until FindNext( sr ) <> 0;
    FindClose( sr );
  end;
end;

procedure DirListView( path: string; lv: TListView );
var
  dirs              : TStrings;
  item              : TListItem;
  i                 : integer;
  imlist            : TCustomImageList;
begin
  dirs := TStringlist.Create;
  ListDirectory( path, '*', dirs );

  lv.Items.Clear;

  for i := 0 to dirs.Count - 1 do begin
    item := lv.Items.Add;
    item.Caption := dirs[i];
    item.ImageIndex := 0;
  end;

  dirs.Free;
end;

procedure ReadListViewDir( path: string; lv: TListView );
var
  sr                : TSearchRec;
  FileAttrs         : integer;
  tmp               : string;
  mask              : string;
  item              : TListItem;
  bmp               : TBitmap;
  imlist            : TCustomImageList;
  pic               : TPicture;
  ext               : string;
begin
  FileAttrs := faAnyFile or faDirectory;
  mask := '*';

  lv.Items.Clear;
  imlist := lv.SmallImages;

  bmp := TBitmap.Create;
  bmp.Width := imlist.Width;
  bmp.Height := imlist.Height;
  pic := TPicture.Create;

  if FindFirst( Path + '\' + mask, FileAttrs, sr ) = 0 then begin
    repeat

      if ( Pos( '.', sr.Name ) <> 1 ) {and ((sr.Attr and FileAttrs) = FileAttrs)} then begin
        tmp := sr.Name;
        if fileExists( path + '\' + tmp ) then begin
          if isimagefile( tmp ) then begin
            item := lv.Items.Add;
            item.Caption := tmp;

            pic.LoadFromFile( path + '\' + tmp );
            bmp.Canvas.FillRect(Bounds(0, 0, bmp.Width, bmp.Height));
            bmp.Canvas.StretchDraw( rect( 0, 0, bmp.Width - 1, bmp.Height - 1 ), pic.Graphic );
            item.ImageIndex := imlist.Add( bmp, nil );
          end
          else begin
            ext := lowercase( extractfileext( tmp ) );
            if ( ext = '.spr' ) or ( ext = '.map' ) then begin
              item := lv.Items.Add;
              item.Caption := tmp;
              item.ImageIndex := 0;
            end;
          end;
        end;

      end;
    until FindNext( sr ) <> 0;
    FindClose( sr );
  end;
end;

procedure FileCopy( sfrom, sto: string );
begin
  if not CopyFile( PAnsiChar( sfrom ), PAnsiChar( sto ), false ) then showmessage( 'Error Copying File ' + sfrom );
end;

procedure ReadListViewCSV( filename: string; lv: TListView; filter: boolean = false;
  filterfields: string = '' );
var
  s, l, h, f        : TStrings;
  i, j, ix          : integer;
  item              : TListItem;
begin
  ix := lv.itemindex;
  s := TStringlist.Create;
  l := TStringlist.Create;
  h := TStringlist.Create;
  f := TStringlist.Create;
  s.LoadFromFile( filename );
  lv.Items.BeginUpdate;
  lv.Items.Clear;
  h.CommaText := s[0];
  if filter then
    f.CommaText := filterfields
  else
    f.CommaText := h.Text;

  for i := 1 to s.Count - 1 do begin
    l.CommaText := s[i];
    item := lv.Items.Add;

    item.Caption := l[h.IndexOf( f[0] )];
    for j := 1 to f.Count - 1 do
      item.SubItems.Add( l[h.IndexOf( f[j] )] );
  end;
  lv.Items.EndUpdate;
  if ix > lv.Items.Count - 1 then ix := lv.Items.Count - 1;
  lv.itemindex := ix;

  s.Free;
  l.Free;
  h.Free;
  f.Free;
end;

end.

