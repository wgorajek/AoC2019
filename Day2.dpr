program Day2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.SysUtils;


function ExecProgram(AOperation, AInput1, AInput2 : Integer) : Integer;
begin
  Result := 0;
  case AOperation of
    1 : Result := AInput1 + AInput2;
    2 : Result := AInput1 * AInput2;
    else Exception.Create('Unknown operation ' + AOperation.ToString);
  end;

end;

function PartA(AData : string): string;
var
  DataArray : TArray<string>;
  I: Integer;
  ProgramArray : TArray<Integer>;
begin
  DataArray := AData.Split([',']);
  SetLength(ProgramArray, Length(DataArray));

  for I := 0 to Length(DataArray) - 1 do
  begin
    ProgramArray[I] := StrToInt(Trim(DataArray[I]));
  end;

  I := 0;

  while ProgramArray[I] <> 99 do
  begin
    ProgramArray[ProgramArray[I + 3]] := ExecProgram(ProgramArray[I], ProgramArray[ProgramArray[I + 1]], ProgramArray[ProgramArray[I + 2]]);
    Inc(I, 4);
  end;

  Result := ProgramArray[0].ToString;
end;


function PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I: Integer;
  ProgramArray : TArray<Integer>;
begin
  DataArray := AData.Split([',']);
  SetLength(ProgramArray, Length(DataArray));

  for var LNoun := 0 to 99 do begin
    for var LVerb := 0 to 99 do begin
      for I := 0 to Length(DataArray) - 1 do
      begin
        ProgramArray[I] := StrToInt(Trim(DataArray[I]));
      end;
      ProgramArray[1] := LNoun;
      ProgramArray[2] := LVerb;

      I := 0;
      while ProgramArray[I] <> 99 do
      begin
        ProgramArray[ProgramArray[I + 3]] := ExecProgram(ProgramArray[I], ProgramArray[ProgramArray[I + 1]], ProgramArray[ProgramArray[I + 2]]);
        Inc(I, 4);
      end;
      if ProgramArray[0] = 19690720 then
      begin
        Result := (LNoun * 100 + LVerb).ToString;
      end;
    end;
  end;
end;

begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day2Test.txt')));
    writeln(PartA(T_WGUtils.OpenFile('..\..\day2.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day2Test.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day2.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
