program Day9;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.Generics.Collections,
  System.SysUtils;

type
  TAmplifierStatus = (TASReady, TASWaitForInput, TASFinished);


  TAmplifier = class
    ProgramArray : TArray<Int64>;
    OperationPointer : Int64;
    Status : TAmplifierStatus;
    Output : Int64;
    Input : Int64;
    RelativeBase : Int64;
    procedure Reset(AProgramArray : TArray<Int64>);
    constructor Create(AProgramArray: TArray<Int64>); reintroduce;
    procedure Run;
    function GetValue(AValue, AMode : Int64) : Int64;
  end;




function ExecProgram(AOperation, AInput1, AInput2 : Int64) : Int64;
begin
  case AOperation of
    1 : Result := AInput1 + AInput2;
    2 : Result := AInput1 * AInput2;
    else
      raise Exception.Create('Unknown operation ' + AOperation.ToString);
  end;

end;


function PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I: Int64;
  ProgramArray : TArray<Int64>;
//  AmplifierArray : TArray<TAmplifier>;
  LAmplifier : TAmplifier;
begin
  DataArray := AData.Split([',']);
  SetLength(ProgramArray, Length(DataArray)+999999);

  for I := 0 to Length(DataArray) - 1 do
  begin
    ProgramArray[I] := StrToInt64(Trim(DataArray[I]));
  end;

  for I := Length(DataArray) to 999999 do
  begin
    ProgramArray[I] := 0;
  end;

  LAmplifier := TAmplifier.Create(ProgramArray);
  LAmplifier.Input := 1;
//  LAmplifier.Input := 0;

  LAmplifier.Run;

  Result := LAmplifier.Output.ToString;
end;

constructor TAmplifier.Create(AProgramArray: TArray<Int64>);
begin
  Reset(AProgramArray);
end;

function TAmplifier.GetValue(AValue, AMode: Int64): Int64;
begin
  if AMode = 1  then
  begin
    Result := AValue;
  end else if AMode = 0  then
  begin
    Result := ProgramArray[AValue];
  end else if AMode = 2  then
  begin
    if (AValue + RelativeBase> 9999) then
      Writeln(AValue);

    Result := AValue + RelativeBase;
  end else
    raise Exception.Create('Uknown Operation Mode ' + AMode.ToString);
end;

procedure TAmplifier.Reset(AProgramArray: TArray<Int64>);
begin
  OperationPointer := 0;
  Status := TASReady;
  Output := -1;
  Input := -1;
  RelativeBase := 0;
  SetLength(ProgramArray, Length(AProgramArray));
  for var K := 0 to Length(AProgramArray) - 1 do
  begin
    ProgramArray[K] := AProgramArray[K];
  end;
end;

procedure TAmplifier.Run;
var
  I, J: Int64;
  InstructionA, InstructionB, InstructionC, InstructionDE : Int64;
begin
  I := OperationPointer;
  J := 0;
  while (Status = TASReady) and (ProgramArray[I] <> 99) do
  begin
    Inc(J);
    InstructionDE := ProgramArray[I] mod 100;
    InstructionC := Floor((ProgramArray[I])/100) mod 10;
    InstructionB := Floor((ProgramArray[I])/1000) mod 10;
    InstructionA := Floor((ProgramArray[I])/10000) mod 10;
    Writeln(ProgramArray[I].ToString + ' ' +  ProgramArray[I+1].ToString+ ' ' +  ProgramArray[I+2].ToString+ ' ' +  ProgramArray[I+3].ToString);
    if InstructionDE in [1,2] then begin
      ProgramArray[ProgramArray[I + 3]] := ExecProgram(InstructionDE, GetValue(ProgramArray[I + 1], InstructionC), GetValue(ProgramArray[I + 2], InstructionB));
      Inc(I, 4);
    end else if InstructionDE = 3 then begin
      if Input <> - 1  then begin
        ProgramArray[GetValue(ProgramArray[I + 1], InstructionC)] := Input;
        Input := -1;
        Inc(I, 2);
      end else
      begin
        Status := TASWaitForInput;
      end;
    end else if InstructionDE = 4 then begin
      Output := GetValue(ProgramArray[I + 1], InstructionC);
      Writeln('output = ' + Output.ToString);
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
    end else if InstructionDE = 9 then begin
      RelativeBase := RelativeBase + GetValue(ProgramArray[I + 1], InstructionC);
      Inc(I, 2);
    end else begin
      raise Exception.Create('Unknown operation ' + InstructionDE.ToString);
    end;
  end;
  If (ProgramArray[I] = 99) then
  begin
    Status := TASFinished;
  end;
  OperationPointer := I;
end;

begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day9Test.txt')));
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day9.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day9Test.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day9.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
