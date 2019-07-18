unit GerarClasseController;

interface

uses
  Classes, FireDAC.Comp.Client, FireDAC.Stan.Intf, Data.DB,
  FireDAC.Stan.Def, FireDAC.DApt, FireDAC.Stan.Async,
  //CursorWait
  FireDAC.UI.Intf, FireDAC.FMXUI.Wait, FireDAC.Comp.UI,
  //Firebird
  FireDAC.Phys.FBDef, FireDAC.Phys, FireDAC.Phys.IBBase, FireDAC.Phys.FB
  ;

type
  TTipoGetSet = (tgsGetCabecalho, tgsSetCabecalho, tgsGetImplementation, tgsSetImplementation);

  TGerarClasse = class
  private
    FConexao: TFDConnection;
    FQuery: TFDQuery;

    FTabela: String;
    FPrefixo: string;
    FSufixo: string;
    FGerarGetSet: boolean;
    FGerarGettersAndSetters: boolean;
    FConteudoClasse: TStringList;
    FHeranca: string;
    FUsesInterface: string;
    FUsesImplementation: string;
    procedure CriarConexao(psArquivoConfiguracaoConexao: string);
    procedure CriarQuery;
    procedure AbrirQuery;
    function PegarTipoCampo(pfCampo: TField): string;
    function FormatarLinhaCampoPrivate(pfCampo: TField): string;
    function FormatarLinhaCampoPropriedade(pfCampo: TField): string;
    function FormatarCampoTipo(pfCampo: TField): string;
    function GetCaminhoArquivoFormatado(psCaminhoArquivo: string): string;
    procedure IncluirCamposEstrutura(psCamposPrivate, psCamposPropriedades: string);
    function FormatarPrimeiraLetraMaiuscula(psTexto: string): string;
    procedure IncluirGetSetEstrutura(psGettersCab, psSettersCab, psGettersImp, psSettersImp: string);
    function FormatarGetSetCab(ptgsTipo: TTipoGetSet; pfCampo: TField): string;
    function FormatarGetSetImp(ptgsTipo: TTipoGetSet; pfCampo: TField): string;
  public
    constructor Create(psArquivoConfiguracaoConexao: string);
    destructor Destroy; override;
    function GerarClasse(psTabela: string): boolean;
    function PegarConteudoArquivoGerado: string;
    procedure SalvarArquivo(psCaminhoArquivo: string = '');
    property Prefixo: string read FPrefixo write FPrefixo;
    property Sufixo: string read FSufixo write FSufixo;
    property GerarGettersAndSetters: boolean read FGerarGettersAndSetters write FGerarGettersAndSetters;
    property GerarGetSet: boolean read FGerarGetSet write FGerarGetSet;
    property Heranca: string read FHeranca write FHeranca;
    property UsesInterface: string read FUsesInterface write FUsesInterface;
    property UsesImplementation: string read FUsesImplementation write FUsesImplementation;
  end;

implementation

uses
  SysUtils, Constantes, StrUtils;

{ TGerarClasse }

{$REGION 'Construtores'}
constructor TGerarClasse.Create(psArquivoConfiguracaoConexao: string);
begin
  CriarConexao(psArquivoConfiguracaoConexao);
  FConteudoClasse := TStringList.Create;
end;

destructor TGerarClasse.Destroy;
begin
  if Assigned(FQuery) then
  begin
    FreeAndNil(FQuery);
    FreeAndNil(FConexao);
  end;
  FreeAndNil(FConteudoClasse);
  inherited;
end;
{$ENDREGION}

{$REGION 'Conexão com o banco'}
procedure TGerarClasse.CriarConexao(psArquivoConfiguracaoConexao: string);
begin
  FConexao := TFDConnection.Create(nil);
  FConexao.Params.LoadFromFile(psArquivoConfiguracaoConexao);
  FConexao.Open;
end;

procedure TGerarClasse.CriarQuery;
begin
  if not Assigned(FQuery) then
  begin
    FQuery := TFDQuery.Create(nil);
    FQuery.Connection := FConexao;
  end;
end;

procedure TGerarClasse.AbrirQuery;
begin
  CriarQuery;

  if FQuery.Active then
    FQuery.Close;

  FQuery.Open(Format(cSQL_METADADOS, [FTabela]));
end;
{$ENDREGION}

{$REGION 'Construção da estrutura'}
function TGerarClasse.PegarTipoCampo(pfCampo: TField): string;
begin
  case pfCampo.DataType of
    ftString, ftMemo, ftWord: Result := 'string';
    ftWideString, ftWideMemo: Result := 'WideString';
    ftExtended: Result := 'Extended';
    ftFloat: Result := 'Double';
    ftCurrency: Result := 'Currency';
    ftSmallInt: Result := 'SmallInt';
    ftInteger, ftAutoInc, ftSingle: Result := 'Integer';
    ftTimeStamp: Result := 'TDateTime';
    ftLargeint: Result := 'Int64';
    ftShortInt: Result := 'ShortInt';
    ftBoolean: Result := 'Boolean';
  end;
end;

function TGerarClasse.FormatarCampoTipo(pfCampo: TField): string;
begin
  Result := FormatarPrimeiraLetraMaiuscula(pfCampo.FieldName) + ': ' + PegarTipoCampo(pfCampo);
end;

function TGerarClasse.FormatarLinhaCampoPrivate(pfCampo: TField): string;
begin
  Result := cTABULACAO_6 + 'F' + FormatarCampoTipo(pfCampo) + ';';
end;

function TGerarClasse.FormatarLinhaCampoPropriedade(pfCampo: TField): string;
var
  sGet,
  sSet: string;
begin
  sGet := IfThen(FGerarGettersAndSetters, 'Get', 'F');
  sSet := IfThen(FGerarGettersAndSetters, 'Set', 'F');
  Result := cTABULACAO_6 + 'property ' + FormatarCampoTipo(pfCampo) +
    ' read ' + sGet + FormatarPrimeiraLetraMaiuscula(pfCampo.FieldName) +
    ' write ' + sSet + FormatarPrimeiraLetraMaiuscula(pfCampo.FieldName) +';';
end;

function TGerarClasse.FormatarGetSetCab(ptgsTipo: TTipoGetSet; pfCampo: TField): string;
var
  sTipoEsqueleto: string;
begin
  case ptgsTipo of
    tgsGetCabecalho: sTipoEsqueleto := cESQUELETO_GET_CABECALHO;
    tgsSetCabecalho: sTipoEsqueleto := cESQUELETO_SET_CABECALHO;
  end;

  Result :=
    sTipoEsqueleto
    .Replace('@Campo', FormatarPrimeiraLetraMaiuscula(pfCampo.FieldName))
    .Replace('@TipoCampo', PegarTipoCampo(pfCampo));
end;

function TGerarClasse.FormatarGetSetImp(ptgsTipo: TTipoGetSet; pfCampo: TField): string;
var
  sTipoEsqueleto: string;
begin
  case ptgsTipo of
    tgsGetImplementation: sTipoEsqueleto := cESQUELETO_GET_IMPLEMENTATION;
    tgsSetImplementation: sTipoEsqueleto := cESQUELETO_SET_IMPLEMENTATION;
  end;

  Result :=
    sTipoEsqueleto
    .Replace('@Tabela', FTabela)
    .Replace('@Campo', FormatarPrimeiraLetraMaiuscula(pfCampo.FieldName))
    .Replace('@TipoCampo', PegarTipoCampo(pfCampo))
    + sLineBreak;
end;

procedure TGerarClasse.IncluirCamposEstrutura(psCamposPrivate, psCamposPropriedades: string);
var
  sHeranca,
  sUsesInterface,
  sUsesImplementation: string;
begin
  sHeranca := IfThen(FHeranca.Length > 0, '(' + FHeranca + ')');
  sUsesInterface := IfThen(FUsesInterface.Length > 0,
    cUSES + FUsesInterface + ';');
  sUsesImplementation := IfThen(FUsesImplementation.Length > 0,
    cUSES + FUsesImplementation + ';');

  FConteudoClasse.Text :=
    cESQUELETO_UNIT
    .Replace('@Prefixo', FPrefixo)
    .Replace('@Tabela', FTabela)
    .Replace('@Sufixo', FSufixo)
    .Replace('@Heranca', sHeranca)
    .Replace('@Private', Trim(psCamposPrivate))
    .Replace('@Public', Trim(psCamposPropriedades))
    .Replace('@UsesInterface', sUsesInterface)
    .Replace('@UsesImplementation', sUsesImplementation);
end;

procedure TGerarClasse.IncluirGetSetEstrutura(psGettersCab, psSettersCab, psGettersImp, psSettersImp: string);
var
  sCabGettersAndSetters,
  sImpGettersAndSetters: string;
begin
  if FGerarGettersAndSetters then
  begin
    sImpGettersAndSetters :=
      cESQUELETO_GETTERS_AND_SETTERS_IMPLEMENTATION
      .Replace('@Getters', Trim(psGettersImp))
      .Replace('@Setters', Trim(psSettersImp));
    sCabGettersAndSetters := psGettersCab + sLineBreak + psSettersCab;
  end;

  FConteudoClasse.Text := FConteudoClasse.Text
    .Replace('@GettersAndSettersCab', sCabGettersAndSetters)
    .Replace('@GettersAndSettersImp', sImpGettersAndSetters);
end;

{$ENDREGION}

{$REGION 'Métodos públicos'}
function TGerarClasse.GerarClasse(psTabela: string): boolean;
var
  fCampo: TField;
  sCamposPrivate,
  sCamposPropriedades,
  sGettersCab,
  sSettersCab,
  sGettersImp,
  sSettersImp: string;
begin
  try
    FTabela := FormatarPrimeiraLetraMaiuscula(psTabela);
    AbrirQuery;

    for fCampo in FQuery.Fields do
    begin
      sCamposPrivate.Insert(sCamposPrivate.Length, FormatarLinhaCampoPrivate(fCampo));
      sCamposPropriedades.Insert(sCamposPropriedades.Length, FormatarLinhaCampoPropriedade(fCampo));

      if GerarGettersAndSetters then
      begin
        sGettersCab.Insert(sGettersCab.Length, FormatarGetSetCab(tgsGetCabecalho, fCampo));
        sSettersCab.Insert(sSettersCab.Length, FormatarGetSetCab(tgsSetCabecalho, fCampo));

        sGettersImp.Insert(sGettersImp.Length, FormatarGetSetImp(tgsGetImplementation, fCampo));
        sSettersImp.Insert(sSettersImp.Length, FormatarGetSetImp(tgsSetImplementation, fCampo));
      end;
    end;

    FConteudoClasse.Clear;
    IncluirCamposEstrutura(sCamposPrivate, sCamposPropriedades);
    IncluirGetSetEstrutura(sGettersCab, sSettersCab, sGettersImp, sSettersImp);
    Result := True;
  except
    Result := False;
  end;
end;

function TGerarClasse.PegarConteudoArquivoGerado: string;
begin
  Result := FConteudoClasse.Text;
end;

procedure TGerarClasse.SalvarArquivo(psCaminhoArquivo: string = '');
begin
  if FConteudoClasse.Text.Length = 0 then
    raise Exception.Create('Gere o arquivo antes de salvar!');

  FConteudoClasse.SaveToFile(GetCaminhoArquivoFormatado(psCaminhoArquivo));
end;
{$ENDREGION}

{$REGION 'Métodos auxiliares'}
function TGerarClasse.GetCaminhoArquivoFormatado(psCaminhoArquivo: string): string;
var
  sPasta: string;
begin
  sPasta := IfThen(psCaminhoArquivo.Length > 0,
    psCaminhoArquivo,
    ExtractFilePath(ParamStr(0)));

  Result := sPasta + FPrefixo + FTabela + FSufixo + '.pas';
end;

function TGerarClasse.FormatarPrimeiraLetraMaiuscula(psTexto: string): string;
begin
  if psTexto.Length > 1 then
    Result := UpperCase(psTexto.Chars[0]) + LowerCase(psTexto.Substring(1))
  else
    Result := UpperCase(psTexto);
end;


{$ENDREGION}

end.
