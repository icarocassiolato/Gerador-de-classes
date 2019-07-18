unit GerarClasseView;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit;

type
  TGerarClasseFrm = class(TForm)
    EdtTabela: TEdit;
    EdtCaminhoArquivo: TEdit;
    BtnGerarClasse: TButton;
    CbxImplemetarGettersSetters: TCheckBox;
    EdtHeranca: TEdit;
    EdtUsesInterface: TEdit;
    EdtUsesImplementation: TEdit;
    procedure BtnGerarClasseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GerarClasseFrm: TGerarClasseFrm;

implementation

uses
  GerarClasseController;

{$R *.fmx}

procedure TGerarClasseFrm.BtnGerarClasseClick(Sender: TObject);
var
  oGerarClasse: TGerarClasse;
begin
  oGerarClasse := TGerarClasse.Create(ExtractFilePath(ParamStr(0))+ 'Config.ini');
  try
    oGerarClasse.Heranca := EdtHeranca.Text;
    oGerarClasse.UsesInterface := EdtUsesInterface.Text;
    oGerarClasse.UsesImplementation := EdtUsesImplementation.Text;
    oGerarClasse.GerarGettersAndSetters := CbxImplemetarGettersSetters.IsChecked;
    if oGerarClasse.GerarClasse(EdtTabela.Text) then
      ShowMessage('Classe gerada com sucesso!')
    else
      ShowMessage('Erro ao gerar classe.');

    oGerarClasse.SalvarArquivo(EdtCaminhoArquivo.Text);
  finally
    FreeAndNil(oGerarClasse);
  end;
end;

end.
