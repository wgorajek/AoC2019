program Day11;

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
  TRobotDirection = (TRDUp=0, TRDRight=1, TRDDown=2, TRDLeft=3);


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

function Move(APoint : TPoint; ADirection : TRobotDirection) : TPoint;
begin
  if ADirection = TRDUp then
  begin
    Inc(APoint.Y);
  end else if ADirection = TRDRight then
  begin
    Inc(APoint.X);
  end else if ADirection = TRDDown then
  begin
    Dec(APoint.Y);
  end else if ADirection = TRDLeft then
  begin
    Dec(APoint.X);
  end;
  Result := APoint;
end;

function PartAB(AData : string; IsPartB : Boolean = False): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
  ProgramArray : TArray<Int64>;
  LAmplifier : TAmplifier;
  LGrid : Array of array of char;
  RobotLocation : TPoint;
  RobotDirection : TRobotDirection;
  LVisited : TDictionary<TPoint, Boolean>;
begin
  LVisited := TDictionary<TPoint, Boolean>.Create;
  try
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

    RobotLocation := TPoint.Create(5000,5000);
    RobotDirection := TRDUp;

    LAmplifier := TAmplifier.Create(ProgramArray);
    try
      SetLength(LGrid, 10000, 10000);
      for I := 0 to 9999 do
        for J := 0 to 9999 do
        begin
          LGrid[I][J] := '.';
        end;

      if IsPartB then
        LGrid[5000][5000] := '#';

      repeat
        begin
          LAmplifier.Output.Clear;
          if LGrid[RobotLocation.X][RobotLocation.Y] = '.' then
          begin
            LAmplifier.Input := 0;
          end else
          begin
            LAmplifier.Input := 1;
          end;
          LAmplifier.Status := TASReady;
          LAmplifier.Run;
          if LAmplifier.Output.Count > 0 then
          begin
            If LAmplifier.Output[0] = 0 then
            begin
              LGrid[RobotLocation.X][RobotLocation.Y] := '.'
            end
            else If LAmplifier.Output[0] = 1 then
            begin
              LGrid[RobotLocation.X][RobotLocation.Y] := '#'
            end else
              raise Exception.Create('Wrong output color');
            LVisited.AddOrSetValue(RobotLocation, True);
            If LAmplifier.Output[1] = 0 then
            begin
              RobotDirection := TRobotDirection((Integer(RobotDirection) + 3) mod 4);
            end
            else If LAmplifier.Output[1] = 1 then
            begin
              RobotDirection := TRobotDirection((Integer(RobotDirection) + 1) mod 4);
            end else
              raise Exception.Create('Wrong output direction');
            RobotLocation := Move(RobotLocation, RobotDirection);
          end;
        end
      until LAmplifier.Status = TASFinished;

    finally
      LAmplifier.Free;
    end;
    Result := (LVisited.Count).ToString;

    if IsPartB then
    begin
      for J := 5 downto -10 do
      begin
        for I := 0 to 40 do
        begin
          Write(LGrid[5000+I][5000+J]);
        end;
        Write(#13#10);
      end;
    end;

  finally
    LVisited.Free;
  end;
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
      if Input <> - 1  then begin
        ProgramArray[GetIndexValue(ProgramArray[I + 1], InstructionC)] := Input;
        Input := -1;
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
    writeln(PartAB(T_WGUtils.OpenFile('..\..\day11.txt')));
    PartAB(T_WGUtils.OpenFile('..\..\day11.txt'), True);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
