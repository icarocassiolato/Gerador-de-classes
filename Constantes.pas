unit Constantes;

interface

const
  cSQL_METADADOS =
    'SELECT * FROM %s WHERE 1 = 0';

  cTABULACAO_6 =
    sLineBreak + '      ';

  cTABULACAO_2 =
    '  ';

  cUSES = 'uses ' + sLineBreak + cTABULACAO_2;

  cESQUELETO_UNIT =
    'unit @Prefixo@Tabela@Sufixo;' + sLineBreak + sLineBreak +
    'interface                   ' + sLineBreak + sLineBreak +
    '@UsesInterface              ' + sLineBreak +
    'type                        ' + sLineBreak +
    '  T@Tabela = class@Heranca  ' + sLineBreak +
    '    private                 ' + sLineBreak +
    '      @Private              ' + sLineBreak +
    '      @GettersAndSettersCab ' + sLineBreak +
    '    public                  ' + sLineBreak +
    '      @Public               ' + sLineBreak +
    '    end;                    ' + sLineBreak + sLineBreak +
    'implementation              ' + sLineBreak + sLineBreak +
    '@UsesImplementation         ' + sLineBreak +
    '{ T@Tabela }                ' + sLineBreak + sLineBreak +
    '@GettersAndSettersImp       ' + sLineBreak +
    'end.                        ';

  cESQUELETO_GETTERS_AND_SETTERS_IMPLEMENTATION =
    '{$REGION ''Getters''}' + sLineBreak +
    '@Getters             ' + sLineBreak +
    '{$ENDREGION}         ' + sLineBreak + sLineBreak +
    '{$REGION ''Setters''}' + sLineBreak +
    '@Setters             ' + sLineBreak +
    '{$ENDREGION}         ' + sLineBreak;

  cESQUELETO_GET_CABECALHO =
    cTABULACAO_6 + 'function Get@Campo: @TipoCampo;';

  cESQUELETO_SET_CABECALHO =
    cTABULACAO_6 + 'procedure Set@Campo(Value: @TipoCampo);';

  cESQUELETO_GET_IMPLEMENTATION =
    'function T@Tabela.Get@Campo: @TipoCampo;' + sLineBreak +
    'begin                                   ' + sLineBreak +
    '  Result := F@Campo;                    ' + sLineBreak +
    'end;                                    ' + sLineBreak;

  cESQUELETO_SET_IMPLEMENTATION =
    'procedure T@Tabela.Set@Campo(Value: @TipoCampo);' + sLineBreak +
    'begin                                           ' + sLineBreak +
    '  F@Campo := Value;                             ' + sLineBreak +
    'end;                                            ' + sLineBreak;

implementation

end.
