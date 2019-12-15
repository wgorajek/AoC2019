program Day15;

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
    procedure SetInput(AInput : Int64);
    function GetOutput : Int64;
  end;

  const
    StartPointXY = 500;


var
  LGrid : Array of array of ShortString;


function ExecProgram(AOperation, AInput1, AInput2 : Int64) : Int64;
begin
  case AOperation of
    1 : Result := AInput1 + AInput2;
    2 : Result := AInput1 * AInput2;
    else
      raise Exception.Create('Unknown operation ' + AOperation.ToString);
  end;

end;

function MoveVector(AInput : Integer) : TPoint;
begin
  if AInput = 1 then
  begin
    Result := TPoint.Create(0, -1);
  end else if AInput = 2 then
  begin
    Result := TPoint.Create(0, 1);
  end else if AInput = 3 then
  begin
    Result := TPoint.Create(-1, 0);
  end else if AInput = 4 then
  begin
    Result := TPoint.Create(1, 0);
  end;
end;

function IsOpositeMove(A1 : Integer; A2 : Integer) :Boolean;
begin
  Result := False;
  Result := Result or ((A1 = 1) and (A2 = 2));
  Result := Result or ((A1 = 2) and (A2 = 1));
  Result := Result or ((A1 = 3) and (A2 = 4));
  Result := Result or ((A1 = 4) and (A2 = 3));

end;

function FindClosestUnExploredPoint(APosition : TPoint) : Integer;
var
  LPossiblePoints : TQueue<TPair<TPoint, Integer>>;
  LVisitedPoints : TList<TPoint>;
  LTmpPoint : TPoint;
  LFound : Boolean;
  LPointPair : TPair<TPoint, Integer>;
  I : Integer;
begin
  Result := -1;
  LFound := False;
  LPossiblePoints :=  TQueue<TPair<TPoint, Integer>>.Create;
  LVisitedPoints := TList<TPoint>.Create;
  for I := 1 to 4 do
  begin
    var TmpPoint := APosition + MoveVector(I);
    if LGrid[TmpPoint.X][TmpPoint.Y] = '.' then
    begin
      LPossiblePoints.Enqueue(TPair<TPoint, integer>.Create(TmpPoint, I));
      LVisitedPoints.Add(TmpPoint);
    end;
  end;

  try
    while (LPossiblePoints.Count > 0 ) and not LFound do
    begin
      LPointPair := LPossiblePoints.Dequeue;
      for I := 1 to 4 do
      begin
        LTmpPoint := LPointPair.Key + MoveVector(I);
        If not LVisitedPoints.Contains(LTmpPoint) then
        begin
          if LGrid[LTmpPoint.X][LTmpPoint.Y] = ' ' then
          begin
            LFound := True;
            Result := LPointPair.Value;
            Break;
          end else if LGrid[LTmpPoint.X][LTmpPoint.Y] = '.' then
          begin
            LPossiblePoints.Enqueue(TPair<TPoint, integer>.Create(LTmpPoint, LPointPair.Value));
            LVisitedPoints.Add(LTmpPoint);
          end;
        end;
      end;
    end;
  finally
    LPossiblePoints.Free;
    LVisitedPoints.Free;
  end;
end;

function FindClosestWay(APosition : TPoint) : Integer;
var
  LPossiblePoints : TQueue<TPair<TPoint, Integer>>;
  LVisitedPoints : TList<TPoint>;
  LTmpPoint : TPoint;
  LFound : Boolean;
  LPointPair : TPair<TPoint, Integer>;
  I : Integer;
begin
  Result := -1;
  LFound := False;
  LPossiblePoints :=  TQueue<TPair<TPoint, Integer>>.Create;
  LVisitedPoints := TList<TPoint>.Create;
  for I := 1 to 4 do
  begin
    var TmpPoint := APosition + MoveVector(I);
    if LGrid[TmpPoint.X][TmpPoint.Y] = '.' then
    begin
      LPossiblePoints.Enqueue(TPair<TPoint, integer>.Create(TmpPoint, 1));
      LVisitedPoints.Add(TmpPoint);
    end;
  end;

  try
    while (LPossiblePoints.Count > 0 ) and not LFound do
    begin
      LPointPair := LPossiblePoints.Dequeue;
      for I := 1 to 4 do
      begin
        LTmpPoint := LPointPair.Key + MoveVector(I);
        If not LVisitedPoints.Contains(LTmpPoint) then
        begin
          if LGrid[LTmpPoint.X][LTmpPoint.Y] = '*' then
          begin
            LFound := True;
            Result := LPointPair.Value+1;
            Break;
          end else if LGrid[LTmpPoint.X][LTmpPoint.Y] = '.' then
          begin
            LPossiblePoints.Enqueue(TPair<TPoint, integer>.Create(LTmpPoint, LPointPair.Value+1));
            LVisitedPoints.Add(LTmpPoint);
          end;
        end;
      end;
    end;
  finally
    LPossiblePoints.Free;
    LVisitedPoints.Free;
  end;
end;

function FindLongestWay(APosition : TPoint) : Integer;
var
  LPossiblePoints : TQueue<TPair<TPoint, Integer>>;
  LVisitedPoints : TList<TPoint>;
  LTmpPoint : TPoint;
  LFound : Boolean;
  LPointPair : TPair<TPoint, Integer>;
  I : Integer;
begin
  Result := -1;
  LFound := False;
  LPossiblePoints :=  TQueue<TPair<TPoint, Integer>>.Create;
  LVisitedPoints := TList<TPoint>.Create;
  for I := 1 to 4 do
  begin
    var TmpPoint := APosition + MoveVector(I);
    if LGrid[TmpPoint.X][TmpPoint.Y] = '.' then
    begin
      LPossiblePoints.Enqueue(TPair<TPoint, integer>.Create(TmpPoint, 1));
      LVisitedPoints.Add(TmpPoint);
    end;
  end;

  try
    while (LPossiblePoints.Count > 0 ) and not LFound do
    begin
      LPointPair := LPossiblePoints.Dequeue;
      Result := Max(LPointPair.Value, Result);
      for I := 1 to 4 do
      begin
        LTmpPoint := LPointPair.Key + MoveVector(I);
        If not LVisitedPoints.Contains(LTmpPoint) then
        begin
//          if LGrid[LTmpPoint.X][LTmpPoint.Y] = '*' then
//          begin
//            LFound := True;
//            Result := LPointPair.Value+1;
//            Break;
//          end else
          if LGrid[LTmpPoint.X][LTmpPoint.Y] = '.' then
          begin
            LPossiblePoints.Enqueue(TPair<TPoint, integer>.Create(LTmpPoint, LPointPair.Value+1));
            LVisitedPoints.Add(LTmpPoint);
          end;
        end;
      end;
    end;
  finally
    LPossiblePoints.Free;
    LVisitedPoints.Free;
  end;
end;

function NextMove(APosition : TPoint; AStacked : Boolean = false) : Int64;
begin
  Result := 0;
  if LGrid[APosition.X][APosition.Y-1] = ' ' then
  begin
    Result := 1;
  end else if LGrid[APosition.X][APosition.Y+1] = ' ' then
  begin
    Result := 2;
  end else if LGrid[APosition.X-1][APosition.Y] = ' ' then
  begin
    Result := 3;
  end else if LGrid[APosition.X+1][APosition.Y] = ' ' then
  begin
    Result := 4;
  end;

  if Result = 0 then begin
    Result := FindClosestUnExploredPoint(APosition);
  end;
end;

function PartA(AData : string; AIsPartB : Boolean = False): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
  ProgramArray : TArray<Int64>;
  LAmplifier : TAmplifier;
  LPosition : TPoint;
  LMoveVector : TPoint;
  LOutput : Int64;
  LOxygenFound : Boolean;
  LLongestWay : Integer;
begin
  LOxygenFound := False;

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
  LPosition := TPoint.Create(500, 500);

  LAmplifier := TAmplifier.Create(ProgramArray);
  try
    SetLength(LGrid, 1000, 1000);
    for I := 0 to 999 do
      for J := 0 to 999 do
      begin
        LGrid[I][J] := ' ';
      end;
    LGrid[500][500] := '.';
    J := 0;
    while (J < 15000) and (not LOxygenFound) and not (LAmplifier.Status = TASFinished) do
    begin
      LAmplifier.SetInput(NextMove(LPosition));
      LMoveVector := MoveVector(LAmplifier.Input);
      LAmplifier.Run;
      LOutput := LAmplifier.GetOutput;
      if LOutput = 0 then
      begin
        LGrid[LPosition.X+LMoveVector.X][LPosition.Y+LMoveVector.Y] := '#'
      end else if LOutput = 1 then
      begin
        LPosition := LPosition + LMoveVector;
        LGrid[LPosition.X][LPosition.Y] := '.'
      end else if LOutput = 2 then
      begin
        LPosition := LPosition + LMoveVector;
        LGrid[LPosition.X][LPosition.Y] := '*';
        LOxygenFound := True;
        LLongestWay := FindLongestWay(LPosition);
      end;
      Inc(J);
    end;
  finally
    LAmplifier.Free;
  end;

  if not AIsPartB then
  begin
    Result := FindClosestWay(TPoint.Create(500, 500)).ToString;
  end else
  begin
    Result := LLongestWay.ToString;
  end;
end;

function PartB(AData : string): string;
begin
    Result := 'tod';
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

function TAmplifier.GetOutput: Int64;
begin
  Result := Output.ExtractAt(0);
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
//        Writeln('Input ' + Input.ToString);
        ProgramArray[GetIndexValue(ProgramArray[I + 1], InstructionC)] := Input;
        Input := -2;
        Inc(I, 2);
      end else
      begin
        Status := TASWaitForInput;
      end;
    end else if InstructionDE = 4 then begin
      Output.Add(GetValue(ProgramArray[I + 1], InstructionC));
//      Writeln('output ' + GetValue(ProgramArray[I + 1], InstructionC).ToString);
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

procedure TAmplifier.SetInput(AInput: Int64);
begin
  Input := AInput;
  Status := TASReady;
end;

begin
  try
    writeln(PartA(T_WGUtils.OpenFile('..\..\day15.txt')));
    writeln(PartA(T_WGUtils.OpenFile('..\..\day15.txt'), True));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
