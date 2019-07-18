program ProjetoGerarClasse;

uses
  System.StartUpCopy,
  FMX.Forms,
  GerarClasseView in 'GerarClasseView.pas' {GerarClasseFrm},
  GerarClasseController in 'GerarClasseController.pas',
  Constantes in 'Constantes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGerarClasseFrm, GerarClasseFrm);
  Application.Run;
end.
