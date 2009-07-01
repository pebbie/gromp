unit _main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, ExtCtrls, Menus, ExtDlgs, StdCtrls, ComCtrls, inifiles,
  ImgList, citra, ToolWin;

const
  APP_VERSION = '09.06.26';

type
  Tmain = class(TForm)
    MainMenu1: TMainMenu;
    Actions: TActionList;
    Panel1: TPanel;
    editorPanel: TPanel;
    CreateProject: TAction;
    OpenProject: TAction;
    SaveProject: TAction;
    CloseProject: TAction;
    AppExit: TAction;
    Project1: TMenuItem;
    CreateProject1: TMenuItem;
    N1: TMenuItem;
    OpenProject1: TMenuItem;
    SaveProject1: TMenuItem;
    N2: TMenuItem;
    CloseProject1: TMenuItem;
    AppExit1: TMenuItem;
    tv: TTreeView;
    Splitter1: TSplitter;
    od: TOpenDialog;
    sd: TSaveDialog;
    opd: TOpenPictureDialog;
    spd: TSavePictureDialog;
    ppProject: TPopupMenu;
    ppMap: TPopupMenu;
    ppTile: TPopupMenu;
    ppSprite: TPopupMenu;
    ImageList1: TImageList;
    Splitter2: TSplitter;
    lv: TListView;
    ImageList2: TImageList;
    sb: TStatusBar;
    CreateMap1: TMenuItem;
    DeleteMap1: TMenuItem;
    Open1: TMenuItem;
    Remove1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    appicon: TImageList;
    N3: TMenuItem;
    Import1: TMenuItem;
    New1: TMenuItem;
    N4: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    procedure AppExitExecute(Sender: TObject);
    procedure OpenProjectExecute(Sender: TObject);
    procedure CloseProjectExecute(Sender: TObject);
    procedure SaveProjectExecute(Sender: TObject);
    procedure CreateProjectExecute(Sender: TObject);
    procedure tvClick(Sender: TObject);
    procedure CreateMap1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Import1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure open2Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure DeleteMap1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    rpg: TIniFile;
  end;

var
  main: Tmain;
  rootdir: string;

implementation

uses _util, _tile, _map, _about;

{$R *.dfm}



procedure Tmain.AppExitExecute(Sender: TObject);
begin
  Close;
end;

procedure Tmain.OpenProjectExecute(Sender: TObject);
begin
  od.Filter := 'RPG Project File|*.rpg';
  od.InitialDir := ExtractFilePath(Application.ExeName)+'games';
  if od.Execute then begin
    sd.FileName := od.FileName;
    rootdir := od.InitialDir+'\'+ChangeFileExt(ExtractFileName(od.FileName), '');
    sb.Panels[0].Text := rootdir;
    rpg := TIniFile.Create(od.FileName);
    tv.Enabled := True;
    tv.FullExpand;
    lv.Clear;
    
    SaveProject.Enabled := True;
    CloseProject.Enabled := True;
  end;
end;

procedure Tmain.CloseProjectExecute(Sender: TObject);
begin
  tv.FullCollapse;
  tv.Enabled := False;
  lv.Clear;
  SaveProject.Enabled := False;
  CloseProject.Enabled := False;
end;

procedure Tmain.SaveProjectExecute(Sender: TObject);
begin
  //
  showmessage('not implemented');
end;

procedure Tmain.CreateProjectExecute(Sender: TObject);
begin
  sd.Filter := 'RPG Project File|*.rpg';
  sd.InitialDir := ExtractFilePath(Application.ExeName)+'games';
  if sd.Execute then begin
    rootdir := sd.InitialDir+'\'+ChangeFileExt(ExtractFileName(sd.FileName), '');
    sb.Panels[0].Text := rootdir;
    ForceDirectories(rootdir);
    ForceDirectories(rootdir+'\image');
    ForceDirectories(rootdir+'\map');
    ForceDirectories(rootdir+'\sprite');
    rpg := TIniFile.Create(ChangeFileExt(sd.FileName, '.rpg'));
    rpg.WriteString('project','version',APP_VERSION);
    rpg.WriteString('setting','screensize','640x480');
    rpg.UpdateFile;
    rpg.Free;
  end;
end;

procedure Tmain.tvClick(Sender: TObject);
var
  b, b2 : TBitmap;
begin
  //show corresponding content of directory
  if tv.Selected <> nil then begin
    frmTile.Hide;
    frmMap.Hide;
    lv.PopupMenu := nil;
    lv.OnClick := nil;
    if tv.Selected.Text = 'tile' then begin
      if frmTile.Parent = nil then
      frmTile.parent := editorPanel;
      frmTile.Show;
      lv.SmallImages.Clear;
      ReadListViewDir(rootdir+'\image', lv);
      lv.PopupMenu := ppTile;
      lv.OnClick := Open1Click;
    end else if tv.Selected.Text = 'map' then begin
      if frmMap.Parent = nil then
      frmMap.Parent := editorPanel;
      frmMap.Show;
      lv.SmallImages.Clear;

      b := TBitmap.Create;
      Imagelist1.GetBitmap(2, b);
      b2 := TBitmap.Create;
      b2.Width := lv.SmallImages.Width;
      b2.Height := lv.SmallImages.Height;
      b2.Canvas.StretchDraw(Bounds(0,0,b2.Width,b2.Height), b);
      lv.SmallImages.Add(b2, nil);
      b2.Free;
      b.Free;

      DirListView(rootdir+'\map', lv);
      lv.PopupMenu := ppMap;
      lv.OnClick := Open2Click;
    end else if tv.Selected.Text = 'sprite' then begin
      lv.SmallImages.Clear;

      b := TBitmap.Create;
      Imagelist1.GetBitmap(3, b);
      b2 := TBitmap.Create;
      b2.Width := lv.SmallImages.Width;
      b2.Height := lv.SmallImages.Height;
      b2.Canvas.StretchDraw(Bounds(0,0,b2.Width,b2.Height), b);
      lv.SmallImages.Add(b2, nil);
      b2.Free;
      b.Free;

      ReadListViewDir(rootdir+'\sprite', lv);
      lv.PopupMenu := ppSprite;
    end else if tv.Selected.Text = 'database' then begin
      ReadListViewDir(rootdir+'\db', lv);
    end else if tv.Selected.Text = 'user interface' then begin
      ReadListViewDir(rootdir+'\ui', lv);
    end else if tv.Selected.Text = 'script' then begin
      ReadListViewDir(rootdir+'\script', lv);
    end else if tv.Selected.Text = 'sound' then begin
      ReadListViewDir(rootdir+'\sound', lv);
    end else if tv.Selected.Text = 'music' then begin
      ReadListViewDir(rootdir+'\music', lv);
    end else if tv.Selected.Text = 'font' then begin
      ReadListViewDir(rootdir+'\font', lv);
    end;
  end;
end;

procedure Tmain.CreateMap1Click(Sender: TObject);
begin
  frmMap.dirname := rootdir+'\map\'+InputBox('Input New Map', 'Map Name', 'new_map');
  frmMap.newmap;
end;

procedure Tmain.Open1Click(Sender: TObject);
begin
  if lv.ItemIndex = -1 then exit;
  frmTile.go(rootdir+'\image\'+lv.ItemFocused.Caption);
end;

procedure Tmain.New1Click(Sender: TObject);
begin
  spd.InitialDir := rootdir+'\image\';
  if spd.Execute then begin
    frmTile.newtile;
    frmTile.filename := changeFileExt(spd.FileName, '.png');
    frmTile.SaveTile.Click;
  end;
end;

procedure Tmain.Import1Click(Sender: TObject);
begin
  if opd.Execute then begin
    frmTile.Go(opd.FileName);
    frmTile.filename := rootdir+'\image\'+ExtractFilename(opd.FileName);
    frmTile.SaveTile.Click;
  end;
end;

procedure Tmain.Remove1Click(Sender: TObject);
begin
  if lv.ItemIndex = -1 then exit;
  if MessageDlg('do you really want to remove this tile image?', mtConfirmation, mbOKCancel, 0) = mrOK then begin
    DeleteFile(rootdir+'\image\'+lv.ItemFocused.Caption);
    tvClick(self);
  end;
end;

procedure Tmain.open2Click(Sender: TObject);
begin
  if lv.ItemIndex = -1 then exit;
  frmMap.Go(rootdir+'\map\'+lv.ItemFocused.Caption);
end;

procedure Tmain.About1Click(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure Tmain.DeleteMap1Click(Sender: TObject);
var
  f : TStrings;
  i : integer;
  dir : string;
begin
  if lv.ItemIndex = -1 then exit;
  if MessageDlg('Do you really want to delete map '+lv.ItemFocused.Caption, mtConfirmation, mbOkCancel, 0) = mrOk then begin
    f := TStringlist.Create;
    dir := rootdir + '\map\'+lv.ItemFocused.Caption;
    ListDir(dir, '*', f);
    for i := 0 to f.Count-1 do
      DeleteFile(dir+'\'+f[i]);
    RmDir(dir);
    tvClick(nil);
  end;
end;

end.
