program Day16;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.Generics.Collections,
  System.Types,
  System.SysUtils;

var
  InputArray : TArray<Integer>;
  BasePatern : TArray<Integer>;
  OutputArray : TArray<Integer>;

function Calculate(AIndex : Integer) : Integer;
var
  BasePaternIndex : Integer;
begin
  Result := 0;
  for var I := 0 to Length(InputArray)-1 do
  begin
    BasePaternIndex := ((I + 1) div (AIndex+1)) mod 4;
    Result := Result + InputArray[I] * (BasePatern[BasePaternIndex]);
  end;
  Result := Abs(Result mod 10);
end;

function PartA(AData : string): string;
var
  I, J: Int64;
begin
  Result := '';
  BasePatern := [0,1,0,-1];
  SetLength(InputArray, AData.Length);
  SetLength(OutputArray, AData.Length);
  for I := 1 to AData.Length do
  begin
    InputArray[I-1] := StrToInt(AData[I]);
  end;

  J := 0;
  while J < 100 do
  begin
    for I := 0 to Length(InputArray) - 1 do
    begin
      OutputArray[I] := Calculate(I);
    end;

    Inc(J);
    for I := 0 to Length(OutputArray) - 1 do
    begin
      InputArray[I] := OutputArray[I];
      write(OutputArray[I]);
    end;
    Writeln;
  end;
  for I := 0 to  7 do
  begin
    Result := Result + InputArray[I].ToString;
  end;
end;

function PartB(AData : string): string;
var
  I, J: Int64;
  LMessageOffset : Int64;
  LShortOffset : Integer;
  LCalculatedDataLength : Int64;
begin
  Result := '';
  LMessageOffset := StrToInt(AData.Substring(0, 7));
  LCalculatedDataLength := AData.Length * 10000 - LMessageOffset;

  SetLength(InputArray, LCalculatedDataLength);
  LShortOffset := LMessageOffset mod AData.Length;

  for I := 0 to Length(InputArray) - 1 do
  begin
    var TmpIndex := ((I+LShortOffset) mod AData.Length) + 1;
    InputArray[I] := StrToInt(AData[TmpIndex]);
  end;

  J := 0;
  while J < 100 do
  begin
    for I := Length(InputArray) - 2 downto 0 do
    begin
      InputArray[I] := (InputArray[I] + InputArray[I+1]) mod 10 ;
    end;
    Inc(J);
  end;
  for I := 0 to  7 do
  begin
    Result := Result + InputArray[I].ToString;
  end;
end;

begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day16Test.txt')));
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day16.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day16Test.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day16.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
