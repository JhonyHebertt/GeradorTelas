unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait, Vcl.StdCtrls, Data.DB,
  FireDAC.Comp.Client;

type
  TuGeradorTelas = class(TForm)
    FDConnection1: TFDConnection;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    procedure GerarController(aTableName : String);
    procedure GerarClassController(aPath, aTableName : String);
    procedure GerarJS(aTableName : String; Fields : TStringList);
    procedure GerarLista(aPath, aTableName : String; Fields : TStringList);
    procedure GerarForm(aPath, aTableName : String; Fields : TStringList);
    
  public
    { Public declarations }
  end;

const
  DataBaseName = 'dbreact.';

var
  uGeradorTelas: TuGeradorTelas;

implementation

{$R *.dfm}

procedure TuGeradorTelas.Button1Click(Sender: TObject);
var
  Tabelas : TStringList;
  I: Integer;
  a, nomeTab: string;
begin
  FDConnection1.Connected := True;
  Tabelas := TStringList.Create;
  try
    FDConnection1.GetTableNames('','','',Tabelas, [osMy]);
    for I := 0 to Pred(Tabelas.Count) do
    begin
      Tabelas[I];
      nomeTab:=StringReplace(Tabelas[I], DataBaseName, '', [rfReplaceAll]);
      GerarController(nomeTab);
    end;
  finally
    FDConnection1.Connected := False;
    Tabelas.Free;
    ShowMessage('Controller Gerado com Sucesso');
  end;
end;

procedure TuGeradorTelas.Button2Click(Sender: TObject);
var
  Tabelas, Fields : TStringList;
  I: Integer;
begin
  FDConnection1.Connected := True;
  Tabelas := TStringList.Create;
  try
    FDConnection1.GetTableNames('', '', '', Tabelas, [osMy]);
    for I := 0 to Pred(Tabelas.Count) do
    begin
      Fields := TStringList.Create;
      try
        FDConnection1.GetFieldNames('', '', Tabelas[I], '', Fields);
        GerarJS(StringReplace(Tabelas[I], DataBaseName, '', [rfReplaceAll]), Fields);
      finally
        Fields.Free;
      end;
    end;
  finally
    FDConnection1.Connected := False;
    Tabelas.Free;
    ShowMessage('Arquivos Gerados com Sucesso');
  end;
end;

procedure TuGeradorTelas.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TuGeradorTelas.GerarClassController(aPath, aTableName: String);
var
  ArqController : TStringList;
  tamanho :Integer;
begin
  ArqController := TStringList.Create;
  try
    //usando uDAOGenerico e SimpleORM
    tamanho:= Length(aTableName);
    ArqController.Add('unit u'+aTableName+';');
    ArqController.Add('');
    ArqController.Add('interface');
    ArqController.Add('');
    ArqController.Add('uses');
    ArqController.Add('Horse,');
    ArqController.Add('System.JSON,');
    ArqController.Add('uDAOGenerico,');
    ArqController.Add('u'+copy(aTableName,1,(tamanho-1))+';');
    ArqController.Add('');
    ArqController.Add('procedure Registry(App : THorse);');
    ArqController.Add('procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);');
    ArqController.Add('procedure GetID(Req: THorseRequest; Res: THorseResponse; Next: TProc);');
    ArqController.Add('procedure Insert(Req: THorseRequest; Res: THorseResponse; Next: TProc);');
    ArqController.Add('procedure Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);');
    ArqController.Add('procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);');
    ArqController.Add('');
    ArqController.Add('implementation');
    ArqController.Add('');
    ArqController.Add('procedure Registry(App : THorse);');
    ArqController.Add('begin');
    ArqController.Add('App.Get(''/'+LowerCase(aTableName)+''', Get);');
    ArqController.Add('App.Get(''/'+LowerCase(aTableName)+'/:id'', GetID);');
    ArqController.Add('App.Post(''/'+LowerCase(aTableName)+''', Insert);');
    ArqController.Add('App.Put(''/'+LowerCase(aTableName)+'/:id'', Update);');
    ArqController.Add('App.Delete(''/'+LowerCase(aTableName)+'/:id'', Delete);');
    ArqController.Add('end;');
    ArqController.Add('');
    ArqController.Add('procedure Insert(Req: THorseRequest; Res: THorseResponse; Next: TProc);');
    ArqController.Add('var');
    ArqController.Add('FDAO : iDAOGeneric<T'+aTableName+'>;');
    ArqController.Add('begin');
    ArqController.Add('FDAO := TDAOGeneric<T'+aTableName+'>.New;');
    ArqController.Add('Res.Send<TJSONObject>(FDAO.Insert(Req.Body<TJsonObject>));');
    ArqController.Add('end;');
    ArqController.Add('');
    ArqController.Add('procedure GetID(Req: THorseRequest; Res: THorseResponse; Next: TProc);');
    ArqController.Add('var');
    ArqController.Add('FDAO : iDAOGeneric<T'+aTableName+'>;');
    ArqController.Add('begin');
    ArqController.Add('FDAO := TDAOGeneric<T'+aTableName+'>.New;');
    ArqController.Add('Res.Send<TJsonObject>(FDAO.Find(Req.Params.Items[''id'']));');
    ArqController.Add('end;');
    ArqController.Add('');
    ArqController.Add('procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);');
    ArqController.Add('var');
    ArqController.Add('FDAO : iDAOGeneric<T'+aTableName+'>;');
    ArqController.Add('begin');
    ArqController.Add('FDAO := TDAOGeneric<T'+aTableName+'>.New;');
    ArqController.Add('Res.Send<TJsonArray>(FDAO.Find);');
    ArqController.Add('end;');
    ArqController.Add('');
    ArqController.Add('procedure Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);');
    ArqController.Add('var');
    ArqController.Add('FDAO : iDAOGeneric<T'+aTableName+'>;');
    ArqController.Add('begin');
    ArqController.Add('FDAO := TDAOGeneric<T'+aTableName+'>.New;');
    ArqController.Add('Res.Send<TJsonObject>(FDAO.Update(Req.Body<TJsonObject>));');
    ArqController.Add('end;');
    ArqController.Add('');
    ArqController.Add('procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);');
    ArqController.Add('var');
    ArqController.Add('FDAO : iDAOGeneric<T'+aTableName+'>;');
    ArqController.Add('begin');
    ArqController.Add('FDAO := TDAOGeneric<T'+aTableName+'>.New;');
    ArqController.Add('Res.Send<TJsonObject>(FDAO.Delete(''ID'', Req.Params.Items[''id'']));');
    ArqController.Add('end;');
    ArqController.Add('');
    ArqController.Add('end.');

    //Controller "comum"

  finally
    ArqController.SaveToFile(aPath + '/u' + aTableName + '.pas');
    ArqController.Free;
  end;
end;

procedure TuGeradorTelas.GerarController(aTableName: String);
var
  Path : String;
begin
  Path := ExtractFilePath(Application.ExeName) + '/src';
  if not DirectoryExists(Path) then
    ForceDirectories(Path);

  Path := Path + '/Controller';
  if not DirectoryExists(Path) then
    ForceDirectories(Path);

  GerarClassController(Path, aTableName);

end;

procedure TuGeradorTelas.GerarForm(aPath, aTableName: String; Fields: TStringList);
var
  ArqJS : TStringList;
  I, X: Integer;
begin
  ArqJS := TStringList.Create;
  try
    ArqJS.Add('import { useEffect, useState } from ''react'';');
    ArqJS.Add('import { useHistory } from ''react-router-dom'';');
    ArqJS.Add('import Api from ''../../services/api'';');
    ArqJS.Add('');
    ArqJS.Add('export default function Form(props) {');

    for I := 1 to Pred(Fields.Count) do //começa com 1 para não levar  ID
    begin
      ArqJS.Add('const ['+Fields[I]+', set'+Fields[I]+'] = useState('''');');
    end;
    ArqJS.Add('');
    ArqJS.Add('const [insert, setInsert] = useState(false);');
    ArqJS.Add('const { ID } = props.match.params;');
    ArqJS.Add('const voltar = useHistory();');
    ArqJS.Add('');
    ArqJS.Add('useEffect(() => {');
    ArqJS.Add('if (typeof ID !== "undefined") {');
    ArqJS.Add('async function fCarregando'+aTableName+'() {');
    ArqJS.Add('const '+aTableName+' = await Api.get(`'+aTableName+'/${ID}`);');

    for I := 1 to Pred(Fields.Count) do  //começa com 1 para não levar  ID
    begin
      ArqJS.Add('set'+Fields[I]+'('+aTableName+'.data.'+Fields[I]+');');
    end;
    ArqJS.Add('}');
    ArqJS.Add('setInsert(false);');
    ArqJS.Add('fCarregando'+aTableName+'();');
    ArqJS.Add('}');
    ArqJS.Add('else { setInsert(true); }');
    ArqJS.Add('');
    ArqJS.Add('return () => { }');
    ArqJS.Add('');
    ArqJS.Add('}, [ID]);');

    ArqJS.Add('');
    ArqJS.Add('function fVoltar() {');
    ArqJS.Add('voltar.push(''/'+aTableName+''');');
    ArqJS.Add('}');
    ArqJS.Add('');
    ArqJS.Add('async function fRegistrar(e) {');
    ArqJS.Add('e.preventDefault();');
    ArqJS.Add('');
    ArqJS.Add('if (insert !== false) {');
    ArqJS.Add('Api.post(''/'+aTableName+''', { ');

    X:=1;
    for I := 1 to Pred(Fields.Count) do //começa com 1 para não levar  ID
    begin
      X:=X+1;
      if (X < Fields.Count) then
        ArqJS.Add(''+Fields[I]+',')
      else
        ArqJS.Add(''+Fields[I]+'')
    end;

    ArqJS.Add('})');
    ArqJS.Add('.then((res) => {');
    ArqJS.Add('console.log(res);');
    ArqJS.Add('fVoltar();');
    ArqJS.Add('})');
    ArqJS.Add('.catch((res) => { console.log(res) })');
    ArqJS.Add('}');
    ArqJS.Add('else {');
    ArqJS.Add('Api.put(`/'+aTableName+'/${ID}`, { ');

    X:=0;
    for I := 0 to Pred(Fields.Count) do
    begin
      X:=X+1;
      if (X < Fields.Count) then
      ArqJS.Add(''+Fields[I]+',')
      else
      ArqJS.Add(''+Fields[I]+'');
    end;

    ArqJS.Add('})');
    ArqJS.Add('.then((res) => {');
    ArqJS.Add('console.log(res);');
    ArqJS.Add('fVoltar();');
    ArqJS.Add('})');
    ArqJS.Add('.catch((res) => { console.log(res) })');
    ArqJS.Add('}');
    ArqJS.Add('}');
    ArqJS.Add('');
    ArqJS.Add('return (');
    ArqJS.Add('<div className="col-sm-12">');
    ArqJS.Add('<form onSubmit={fRegistrar} autoComplete="false" >');

    for I := 1 to Pred(Fields.Count) do //começa com 1 para não levar ID
    begin
      ArqJS.Add('');
      ArqJS.Add('<div className="form-group">');
      ArqJS.Add('<label>'+Fields[I]+'</label>');
      ArqJS.Add('<input type="text" name="'+Fields[I]+'" value={'+Fields[I]+'} onChange={(e)=> set'+Fields[I]+'(e.target.value) } className="form-control" />');
      ArqJS.Add('</div>');
      ArqJS.Add('');
    end;

    ArqJS.Add('<button type="button" onClick={fVoltar} className="btn btn-danger" > Voltar</button>');
    ArqJS.Add('<button type="submit" className="btn btn-primary">Gravar</button>');
    ArqJS.Add('</form>');
    ArqJS.Add('</div>');
      ArqJS.Add(')}');
    
  finally
    ArqJS.SaveToFile(aPath + '/form.js');
    ArqJS.Free;
  end;
end;

procedure TuGeradorTelas.GerarJS(aTableName: String; Fields: TStringList);
var
  Path : String;
begin
  Path := ExtractFilePath(Application.ExeName) + '/src';
  if not DirectoryExists(Path) then
    ForceDirectories(Path);

  Path := Path + '/components';
  if not DirectoryExists(Path) then
    ForceDirectories(Path);

  Path := Path + '/' + LowerCase(aTableName);
  if not DirectoryExists(Path) then
    ForceDirectories(Path);

  GerarLista(Path, LowerCase(aTableName), Fields);
  GerarForm(Path, LowerCase(aTableName), Fields);
end;

procedure TuGeradorTelas.GerarLista(aPath, aTableName: String; Fields: TStringList);
var
  ArqJS : TStringList;
  I: Integer;
begin
  ArqJS := TStringList.Create;
  try
    ArqJS.Add('import React from ''react'';');
    ArqJS.Add('import { useEffect, useState } from ''react'';');
    ArqJS.Add('import { Link } from ''react-router-dom'';');
    ArqJS.Add('import Api from ''../../services/api'';');
    ArqJS.Add('');
    ArqJS.Add('');
    ArqJS.Add('export default function List() {');
    ArqJS.Add('');
    ArqJS.Add('const ['+aTableName+', set'+aTableName+'] = useState([]);');
    ArqJS.Add('');
    ArqJS.Add('useEffect(() => {');
    ArqJS.Add('fCarregando'+aTableName+'();');
    ArqJS.Add('return () => { }');
    ArqJS.Add('}, []);');
    ArqJS.Add('');
    ArqJS.Add('async function fCarregando'+aTableName+'() {');
    ArqJS.Add('const lista'+aTableName+' = await Api.get('''+aTableName+''');');
    ArqJS.Add('//console.log(lista'+aTableName+'.data);');
    ArqJS.Add('');
    ArqJS.Add('if (Array.isArray(lista'+aTableName+'.data)) {');
    ArqJS.Add('set'+aTableName+'(lista'+aTableName+'.data)');
    ArqJS.Add('}');
    ArqJS.Add('}');
    ArqJS.Add('');
    ArqJS.Add('function fDelete(id) {');
    ArqJS.Add('Api.delete(`/'+aTableName+'/${id}`)');
    ArqJS.Add('.then((res) => {');
    ArqJS.Add('console.log(res);');
    ArqJS.Add('fCarregando'+aTableName+'();');
    ArqJS.Add('})');
    ArqJS.Add('}');
    ArqJS.Add('');
    ArqJS.Add('return (');
    ArqJS.Add('<div className="col-sm-12">');
    ArqJS.Add('<h2>Lista de '+aTableName+' ({'+aTableName+'.length})</h2>');
    ArqJS.Add('<br />');
    ArqJS.Add('<div className="row">');
    ArqJS.Add('<div className="col-sm-12">');
    ArqJS.Add('<Link to="'+aTableName+'/new" className="btn btn-success"> Novo '+aTableName+' </Link>');
    ArqJS.Add('</div>');
    ArqJS.Add('</div>');
    ArqJS.Add('<br />');
    ArqJS.Add('');
    ArqJS.Add('{'+aTableName+'.length === 0 ? ( //Se Ñ tiver '+aTableName+'');
    ArqJS.Add('<div className="container">');
    ArqJS.Add('<span>Nenhum '+aTableName+' registrado...</span>');
    ArqJS.Add('</div>');
    ArqJS.Add('');
    ArqJS.Add(') : ( //se tiver '+aTableName+'');
    ArqJS.Add('<>');
    ArqJS.Add('<table className="table table-hover">');
    ArqJS.Add('<thead>');
    ArqJS.Add('<tr>');

    for I := 0 to pred(Fields.Count) do
    begin
      ArqJS.Add('<th> '+Fields[I]+' </th>');
    end;

    ArqJS.Add('<th >Opções</th>');
    ArqJS.Add('</tr>');
    ArqJS.Add('</thead>');
    ArqJS.Add('<tbody>');
    ArqJS.Add('{'+aTableName+'.map(('+aTableName+', index) => {');
    ArqJS.Add('return (');
    ArqJS.Add('<tr key={index}>');
    for I := 0 to pred(Fields.Count) do
    begin
    ArqJS.Add('<td> {'+aTableName+'.'+Fields[I]+'}</td>');
    end;

    ArqJS.Add('<td>');
    ArqJS.Add('<Link to={`/'+aTableName+'/${'+aTableName+'.ID}`} > <i className="fa fa-pencil" ></i></Link>');
    ArqJS.Add('<Link to={''''} onClick={(d) => fDelete('+aTableName+'.ID)}> <i className="fa fa-trash" ></i> </Link>');
    ArqJS.Add('</td>');
    ArqJS.Add('</tr>');
    ArqJS.Add(')');
    ArqJS.Add('})}');
    ArqJS.Add('</tbody>');
    ArqJS.Add('</table>');
    ArqJS.Add('</>');
    ArqJS.Add(')');
    ArqJS.Add('}');
    ArqJS.Add('</div >');
    ArqJS.Add(')');
    ArqJS.Add('}');


  finally
    ArqJS.SaveToFile(aPath + '/list.js');
    ArqJS.Free;
  end;
end;

end.
