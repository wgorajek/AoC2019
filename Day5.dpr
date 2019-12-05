program Day5;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.SysUtils;

var
  ProgramArray : TArray<Integer>;


function ExecProgram(AOperation, AInput1, AInput2 : Integer) : Integer;
begin
  case AOperation of
    1 : Result := AInput1 + AInput2;
    2 : Result := AInput1 * AInput2;
    else
      raise Exception.Create('Unknown operation ' + AOperation.ToString);
  end;

end;

function GetValue(AValue, AMode : Integer) : Integer;
begin
  if AMode = 1  then
  begin
    Result := AValue;
  end else
  begin
    Result := ProgramArray[AValue];
  end;
end;

function PartA(AData : string): string;
var
  DataArray : TArray<string>;
  I: Integer;
  {InstructionA, }InstructionB, InstructionC, InstructionDE : Integer;
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
    InstructionDE := ProgramArray[I] mod 100;
    InstructionC := Floor((ProgramArray[I])/100) mod 10;
    InstructionB := Floor((ProgramArray[I])/1000) mod 10;
//    InstructionA := Floor((ProgramArray[I])/10000) mod 10;
    if InstructionDE in [1,2] then begin
      ProgramArray[ProgramArray[I + 3]] := ExecProgram(InstructionDE, GetValue(ProgramArray[I + 1], InstructionC), GetValue(ProgramArray[I + 2], InstructionB));
      Inc(I, 4);
    end else if InstructionDE = 3 then begin
      ProgramArray[ProgramArray[I + 1]] := 1;
      Inc(I, 2);
    end else if InstructionDE = 4 then begin
      Writeln(GetValue(ProgramArray[I + 1], InstructionC));
      Inc(I, 2);
    end else begin
      raise Exception.Create('Unknown operation ' + InstructionDE.ToString);
    end;
  end;

  Result := 'end';
end;


function PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I: Integer;
  {InstructionA, }InstructionB, InstructionC, InstructionDE : Integer;
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
    InstructionDE := ProgramArray[I] mod 100;
    InstructionC := Floor((ProgramArray[I])/100) mod 10;
    InstructionB := Floor((ProgramArray[I])/1000) mod 10;
//    InstructionA := Floor((ProgramArray[I])/10000) mod 10;
    if InstructionDE in [1,2] then begin
      ProgramArray[ProgramArray[I + 3]] := ExecProgram(InstructionDE, GetValue(ProgramArray[I + 1], InstructionC), GetValue(ProgramArray[I + 2], InstructionB));
      Inc(I, 4);
    end else if InstructionDE = 3 then begin
      ProgramArray[ProgramArray[I + 1]] := 5;
      Inc(I, 2);
    end else if InstructionDE = 4 then begin
      Writeln(GetValue(ProgramArray[I + 1], InstructionC));
      Inc(I, 2);
    end else if InstructionDE = 5 then begin
      if GetValue(ProgramArray[I + 1], InstructionC) <> 0 then
      begin
        I := GetValue(ProgramArray[I + 2], InstructionB);
      end else
      begin
        Inc(I, 3);
      end;
    end else if InstructionDE = 6 then begin
      if GetValue(ProgramArray[I + 1], InstructionC) = 0 then
      begin
        I := GetValue(ProgramArray[I + 2], InstructionB);
      end else
      begin
        Inc(I, 3);
      end;
    end else if InstructionDE = 7 then begin
      if GetValue(ProgramArray[I + 1], InstructionC) < GetValue(ProgramArray[I + 2], InstructionB)  then
      begin
        ProgramArray[ProgramArray[I + 3]] := 1;
      end else
      begin
        ProgramArray[ProgramArray[I + 3]] := 0;
      end;
      Inc(I, 4);
    end else if InstructionDE = 8 then begin
      if GetValue(ProgramArray[I + 1], InstructionC) = GetValue(ProgramArray[I + 2], InstructionB)  then
      begin
        ProgramArray[ProgramArray[I + 3]] := 1;
      end else
      begin
        ProgramArray[ProgramArray[I + 3]] := 0;
      end;
      Inc(I, 4);
    end else begin
      raise Exception.Create('Unknown operation ' + InstructionDE.ToString);
    end;
  end;

  Result := 'end';
end;

begin
  try
    writeln(PartA(T_WGUtils.OpenFile('..\..\day5.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day5.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
