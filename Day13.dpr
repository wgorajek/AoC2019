program Day13;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.Generics.Collections,
  System.Types,
  System.SysUtils;

type
  TAmplifierStatus = (TASReady, TASWaitForInput, TASFinished);


  TAmplifier = class
    ProgramArray : TArray<Int64>;
    OperationPointer : Int64;
    Status : TAmplifierStatus;
    Output : TList<Int64>;
    Input : Int64;
    RelativeBase : Int64;
    procedure Reset(AProgramArray : TArray<Int64>);
    constructor Create(AProgramArray: TArray<Int64>); reintroduce;
    destructor Destroy; override;
    procedure Run;
    function GetValue(AValue, AMode : Int64) : Int64;
    function GetIndexValue(AValue, AMode: Int64): Int64;
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

function PartA(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
  ProgramArray : TArray<Int64>;
  LAmplifier : TAmplifier;
  LGrid : Array of array of Integer;
begin

  DataArray := AData.Split([',']);
  SetLength(ProgramArray, Length(DataArray)+99999999);

  for I := 0 to Length(DataArray) - 1 do
  begin
    ProgramArray[I] := StrToInt64(Trim(DataArray[I]));
  end;

  for I := Length(DataArray) to 99999999 do
  begin
    ProgramArray[I] := 0;
  end;


  LAmplifier := TAmplifier.Create(ProgramArray);
  try
    SetLength(LGrid, 10000, 10000);
    for I := 0 to 9999 do
      for J := 0 to 9999 do
      begin
        LGrid[I][J] := -1;
      end;
    LAmplifier.Run;
    I := 0;
    J := 0;
    while I <= LAmplifier.Output.Count - 1 do
    begin
      if (I mod 3 = 2) and (LAmplifier.Output[I] = 2) then
      begin
        Inc(J);
      end;
      Inc(I);
    end;


  finally
    LAmplifier.Free;
  end;
  Result := J.ToString;
end;


function GetSignChar(ANumber : Integer) : string;
begin
  if ANumber = 0 then
    Result := ' '
  else if ANumber = 1 then
    Result := '|'
  else if ANumber = 2 then
    Result := '#'
  else if ANumber = 3 then
    Result := '-'
  else if ANumber = 4 then
    Result := '*';
end;

function PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
  ProgramArray : TArray<Int64>;
  LAmplifier : TAmplifier;
  LGrid : Array of array of string;
  Ball : TPoint;
  Player : TPoint;
  NumberOfWalls : Integer;
  Score : Integer;
begin
    DataArray := AData.Split([',']);
    SetLength(ProgramArray, Length(DataArray)+99999999);

    for I := 0 to Length(DataArray) - 1 do
    begin
      ProgramArray[I] := StrToInt64(Trim(DataArray[I]));
    end;

    for I := Length(DataArray) to 99999999 do
    begin
      ProgramArray[I] := 0;
    end;

    SetLength(LGrid, 100, 100);


    LAmplifier := TAmplifier.Create(ProgramArray);
    try
      LAmplifier.Input := 0;
      NumberOfWalls := 1;
      while (LAmplifier.Status <> TASFinished) and (NumberOfWalls >0) do
      begin
        NumberOfWalls := 0;

        LAmplifier.Run;
        I := 0;
        while I <= LAmplifier.Output.Count - 1 do
        begin
          if LAmplifier.Output[I+2] = 3 then
          begin
            Player.X := LAmplifier.Output[I];
            Player.Y := LAmplifier.Output[I+1];
          end else if LAmplifier.Output[I+2] = 2 then
          begin

          end else if LAmplifier.Output[I+2] = 4 then
          begin
            Ball.X := LAmplifier.Output[I];
            Ball.Y := LAmplifier.Output[I+1];
          end;

          if LAmplifier.Output[I] >=0 then
            LGrid[LAmplifier.Output[I]][LAmplifier.Output[I+1]] := GetSignChar(LAmplifier.Output[I+2])
          else begin
            Score := LAmplifier.Output[I+2];
          end;
          Inc(I,3);
        end;

        for I := 0 to 99 do
          for J := 0 to 99 do
          begin
            If LGrid[I][I] = '#' then
              Inc(NumberOfWalls);
          end;

        LAmplifier.Input := 0;
        LAmplifier.Status := TASReady;
        LAmplifier.Output.Clear;
        if Ball.X > Player.x then begin
          LAmplifier.Input := 1;

        end else         if Ball.X < Player.x then begin
          LAmplifier.Input := -1;
        end else
          LAmplifier.Input := 0;
      end;

    finally
      LAmplifier.Free;
    end;
    Result := Score.ToString;
end;

constructor TAmplifier.Create(AProgramArray: TArray<Int64>);
begin
  Output := TList<Int64>.Create;
  Reset(AProgramArray);
end;

destructor TAmplifier.Destroy;
begin
  Output.Free;
  inherited;
end;

function TAmplifier.GetIndexValue(AValue, AMode: Int64): Int64;
begin
  if AMode = 0  then
  begin
    Result := AValue;
  end else if AMode = 2  then
  begin
    Result := AValue + RelativeBase;
  end else
    raise Exception.Create('Uknown Index Operation Mode ' + AMode.ToString);
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
    Result := ProgramArray[AValue + RelativeBase];
  end else
    raise Exception.Create('Uknown Operation Mode ' + AMode.ToString);
end;

procedure TAmplifier.Reset(AProgramArray: TArray<Int64>);
begin
  OperationPointer := 0;
  Status := TASReady;
  Output.Clear;
  Input := -2;
  RelativeBase := 0;

  SetLength(ProgramArray, Length(AProgramArray));
  for var K := 0 to Length(AProgramArray) - 1 do
  begin
    ProgramArray[K] := AProgramArray[K];
  end;
end;

procedure TAmplifier.Run;
var
  I: Int64;
  InstructionA, InstructionB, InstructionC, InstructionDE : Int64;
begin
  I := OperationPointer;
  while (Status = TASReady) and (ProgramArray[I] <> 99) do
  begin
    InstructionDE := ProgramArray[I] mod 100;
    InstructionC := Floor((ProgramArray[I])/100) mod 10;
    InstructionB := Floor((ProgramArray[I])/1000) mod 10;
    InstructionA := Floor((ProgramArray[I])/10000) mod 10;
    if InstructionDE in [1,2] then begin
      ProgramArray[GetIndexValue(ProgramArray[I + 3], InstructionA)] := ExecProgram(InstructionDE, GetValue(ProgramArray[I + 1], InstructionC), GetValue(ProgramArray[I + 2], InstructionB));
      Inc(I, 4);
    end else if InstructionDE = 3 then begin
      if Input <> - 2  then begin
        ProgramArray[GetIndexValue(ProgramArray[I + 1], InstructionC)] := Input;
        Input := -2;
        Inc(I, 2);
      end else
      begin
        Status := TASWaitForInput;
      end;
    end else if InstructionDE = 4 then begin
      Output.Add(GetValue(ProgramArray[I + 1], InstructionC));
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
        ProgramArray[GetIndexValue(ProgramArray[I + 3], InstructionA)] := 1;
      end else
      begin
        ProgramArray[GetIndexValue(ProgramArray[I + 3], InstructionA)] := 0;
      end;
      Inc(I, 4);
    end else if InstructionDE = 8 then begin
      if GetValue(ProgramArray[I + 1], InstructionC) = GetValue(ProgramArray[I + 2], InstructionB)  then
      begin
        ProgramArray[GetIndexValue(ProgramArray[I + 3], InstructionA)] := 1;
      end else
      begin
        ProgramArray[GetIndexValue(ProgramArray[I + 3], InstructionA)] := 0;
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
    writeln(PartA(T_WGUtils.OpenFile('..\..\day13.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day13B.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
