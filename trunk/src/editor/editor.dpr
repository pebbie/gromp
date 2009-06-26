program editor;

uses
  Forms,
  _main in '_main.pas' {main},
  _tile in 'tile\_tile.pas' {frmTile},
  _map in 'map\_map.pas' {frmMap},
  _util in '_util.pas',
  _about in '_about.pas' {frmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tmain, main);
  Application.CreateForm(TfrmTile, frmTile);
  Application.CreateForm(TfrmMap, frmMap);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.
