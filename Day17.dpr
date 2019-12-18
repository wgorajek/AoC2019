program Day17;

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
  LGrid : Array of array of String;


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

  if AInput = 0 then
  begin
    Result := TPoint.Create(0, -1);
  end else if AInput = 1 then
  begin
    Result := TPoint.Create(1, 0);
  end else if AInput = 2 then
  begin
    Result := TPoint.Create(0, 1);
  end else if AInput = 3 then
  begin
    Result := TPoint.Create(-1, 0);
  end;
end;

function FindTurn(AOrientation, AX, AY : Integer): Integer;
var TMPVector : TPoint;
begin
  Result := 0;
  TMPVector := MoveVector((AOrientation+1) mod 4);
  if LGrid[AX+TMPVector.X][AY+TMPVector.Y] = '#' then
  begin
    Result := 1
  end;
  TMPVector := MoveVector((AOrientation+3) mod 4);
  if LGrid[AX+TMPVector.X][AY+TMPVector.Y] = '#' then
  begin
    Result := -1;
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

//function NextMove(APosition : TPoint; AStacked : Boolean = false) : Int64;
//begin
//  Result := 0;
//  if LGrid[APosition.X][APosition.Y-1] = ' ' then
//  begin
//    Result := 1;
//  end else if LGrid[APosition.X][APosition.Y+1] = ' ' then
//  begin
//    Result := 2;
//  end else if LGrid[APosition.X-1][APosition.Y] = ' ' then
//  begin
//    Result := 3;
//  end else if LGrid[APosition.X+1][APosition.Y] = ' ' then
//  begin
//    Result := 4;
//  end;
//
//  if Result = 0 then begin
//    Result := FindClosestUnExploredPoint(APosition);
//  end;
//end;

function IsCrossRoad(const AX, AY : Integer) : Boolean;
var
  RoadsCount : Integer;
begin
  Result := False;
  if LGrid[AX][AY] = '#' then
  begin
    RoadsCount := 0;
    if (AX > 0) and (LGrid[AX-1][AY] = '#') then
    begin
      Inc(RoadsCount);
    end;
    if (AY > 0) and (LGrid[AX][AY-1] = '#') then
    begin
      Inc(RoadsCount);
    end;
    if LGrid[AX+1][AY] = '#' then
    begin
      Inc(RoadsCount);
    end;
    if LGrid[AX][AY+1] = '#' then
    begin
      Inc(RoadsCount);
    end;

    Result := RoadsCount > 2;
  end;


end;


function writeWay(AX, AY : Integer) : string;
var
  LMoveVector : TPoint;
  LMoveCount : Integer;
  TmpTurn : Integer;
  LOrientation : Integer;
begin
  Result := '';
  LOrientation := 0;



  TmpTurn := FindTurn(0, AX, AY);

  while TmpTurn <> 0 do
    begin
    if TmpTurn = 1 then
    begin
      Result := Result + 'R,'
    end else
    begin
      Result := Result + 'L,'
    end;
    LOrientation := (LOrientation + 4 + TmpTurn) mod 4;
    LMoveVector := MoveVector(LOrientation);
    LMoveCount := 0;
    while LGrid[AX + LMoveVector.X][AY + LMoveVector.Y] = '#' do
    begin
      AX := LMoveVector.X + AX;
      AY := LMoveVector.Y + AY;
      Inc(LMoveCount);
    end;
    TmpTurn := FindTurn(LOrientation, AX, AY);
    Result := Result + LMoveCount.ToString + ',';
  end;
  Writeln(Result);

end;

function PartA(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
  ProgramArray : TArray<Int64>;
  LAmplifier : TAmplifier;
  LOutput : Int64;
  LSum : Integer;
begin
  LSum := 0;
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
    SetLength(LGrid, 1000, 1000);
    for I := 0 to 999 do
      for J := 0 to 999 do
      begin
        LGrid[I][J] := ' ';
      end;
    while not (LAmplifier.Status = TASFinished) do
    begin
      LAmplifier.Run;

      I := 0;
      J := 0;

      for LOutput in LAmplifier.Output do
      begin
        write(Chr(LOutput));
        if LOutput = 10 then
        begin
          Inc(J);
          I := 0;
        end else
        begin
          LGrid[I][J] := Chr(LOutput);
          Inc(I);
        end;
      end;
      for J := 0 to 44 do
        for I := 0 to 37 do
        begin
          if IsCrossRoad(I, J) then
          begin
            Inc(LSum, (I)*(J));
          end;
        end;
    end;

  finally
    LAmplifier.Free;
  end;

  Result := LSum.ToString;
end;

function PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
  ProgramArray : TArray<Int64>;
  LAmplifier : TAmplifier;
  LSum : Integer;
  LInput : TQueue<Int64>;
begin
  LSum := 0;
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

  LInput := TQueue<Int64>.Create;
  LAmplifier := TAmplifier.Create(ProgramArray);
  try
    SetLength(LGrid, 1000, 1000);
    for I := 0 to 999 do
      for J := 0 to 999 do
      begin
        LGrid[I][J] := ' ';
      end;
//    LGrid[500][500] := '.';

    for var MyChar in 'B,B,A,C,B,C,A,C,B,A' do begin
      LInput.Enqueue(Ord(MyChar));
    end;
    LInput.Enqueue(10);
    for var MyChar in 'L,6,L,4,R,8,R,8' do begin
      LInput.Enqueue(Ord(MyChar));
    end;
    LInput.Enqueue(10);
    for var MyChar in 'L,4,L,10,L,6' do begin
      LInput.Enqueue(Ord(MyChar));
    end;
    LInput.Enqueue(10);
    for var MyChar in 'L,6,R,8,L,10,L,8,L,8' do begin
      LInput.Enqueue(Ord(MyChar));
    end;
    LInput.Enqueue(10);

//    LInput :=

    while not (LAmplifier.Status = TASFinished) do
    begin

//B,B,A,C,B,C,A,C,B,A,
//A L,6,L,4,R,8,R,8
//B L,4,L,10,L,6
//C L,6,R,8,L,10,L,8,L,8
      if LAmplifier.Status = TASWaitForInput then
      begin
        if LInput.Count = 0 then
          LAmplifier.Input := 10
        else
          LAmplifier.Input := LInput.Dequeue;
        LAmplifier.Status := TASReady;
      end;

      LAmplifier.Run;

//      I := 1;
//      J := 1;

//      for LOutput in LAmplifier.Output do
//      begin
//        write(Chr(LOutput));
//        if LOutput = 10 then
//        begin
//          Inc(J);
//          I := 1;
//        end else
//        begin
//          LGrid[I][J] := Chr(LOutput);
//          Inc(I);
//        end;
//      end;
//      for J := 0 to 44 do
//        for I := 0 to 37 do
//        begin
//          if IsCrossRoad(I, J) then
//          begin
//            Inc(LSum, (I)*(J));
//          end;
////          if LGrid[I][J] = '^' then //8, 18
////            Writeln('a');
//        end;


//      Writeln(I.ToString + ' ' + J.ToString);

//      writeWay(9,19);

    end;
    writeln(LAmplifier.Output.ExtractAt(LAmplifier.Output.Count-1));
  finally
    LAmplifier.Free;
    LInput.Free;
  end;

  Result := LSum.ToString;
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
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day17.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day17B.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
