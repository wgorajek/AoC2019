program Day23;

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
    private
      function GetValue(AValue, AMode : Int64) : Int64;
      function GetIndexValue(AValue, AMode: Int64): Int64;
    public
      OperationPointer : Int64;
      Status : TAmplifierStatus;
      Output : TList<Int64>;
      InputList : TList<Int64>;
      RelativeBase : Int64;
      procedure Reset(AProgramArray : TArray<Int64>);
      constructor Create(AProgramArray: TArray<Int64>); reintroduce;
      destructor Destroy; override;
      procedure Run(AIterations : Int64; ACode : Int64);
      procedure SetInput(AInput : Int64);
      function GetOutput : Int64;
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
  I: Int64;
  ProgramArray : TArray<Int64>;
  NetworkArray : TArray<TAmplifier>;
  NIC : TArray<TQueue<Int64>>;
  TmpInt : Int64;
begin


  DataArray := AData.Split([',']);
  SetLength(ProgramArray, Length(DataArray));

  for I := 0 to Length(DataArray) - 1 do
  begin
    ProgramArray[I] := StrToInt64(Trim(DataArray[I]));
  end;
  for I := Length(DataArray) to Length(ProgramArray)-1 do
  begin
    ProgramArray[I] := 0;
  end;


  SetLength(NetworkArray, 50);
  SetLength(NIC, 50);
  for I := 0 to Length(NetworkArray) - 1 do
  begin
    NetworkArray[I] := TAmplifier.Create(ProgramArray);
    NetworkArray[I].SetInput(I);
    NIC[I] := TQueue<Int64>.Create;
  end;

  while True do
  begin
    for I := 0 to Length(NetworkArray) - 1 do
    begin
      while NIC[I].Count >= 2 do
      begin
        NetworkArray[I].SetInput(NIC[I].Dequeue);
        NetworkArray[I].SetInput(NIC[I].Dequeue);
      end;
      NetworkArray[I].Run(1, I);
      while NetworkArray[I].Output.Count >= 3 do
      begin
        var TmpAdres := NetworkArray[I].GetOutput;
        if TmpAdres <> 255 then
        begin
          TmpInt := NetworkArray[I].GetOutput;
          NIC[TmpAdres].Enqueue(TmpInt);
          TmpInt := NetworkArray[I].GetOutput;
          NIC[TmpAdres].Enqueue(TmpInt);
        end else
        begin
          TmpInt := NetworkArray[I].GetOutput;
          TmpInt := NetworkArray[I].GetOutput;
          Result := TmpInt.ToString;
          exit;
        end;
      end;
    end;
  end;
end;

function PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I: Int64;
  ProgramArray : TArray<Int64>;
  NetworkArray : TArray<TAmplifier>;
  NIC : TArray<TQueue<Int64>>;
  TmpInt : Int64;
  NatX : Int64;
  NatY : Int64;
  PreviousNatY : Int64;
begin
  DataArray := AData.Split([',']);
  SetLength(ProgramArray, Length(DataArray));
  NatX := 0;
  NatY := 0;

  for I := 0 to Length(DataArray) - 1 do
  begin
    ProgramArray[I] := StrToInt64(Trim(DataArray[I]));
  end;
  for I := Length(DataArray) to Length(ProgramArray)-1 do
  begin
    ProgramArray[I] := 0;
  end;


  SetLength(NetworkArray, 50);
  SetLength(NIC, 50);
  for I := 0 to Length(NetworkArray) - 1 do
  begin
    NetworkArray[I] := TAmplifier.Create(ProgramArray);
    NetworkArray[I].SetInput(I);
    NIC[I] := TQueue<Int64>.Create;
  end;

  while True do
  begin
    var IsIddleStatus := True;
    for I := 0 to Length(NetworkArray) - 1 do
    begin
      IsIddleStatus := IsIddleStatus and (NetworkArray[I].Status = TASWaitForInput);
    end;

    if IsIddleStatus then
    begin
      if PreviousNatY = NatY then
      begin
        Result := PreviousNatY.ToString;
        Break;
      end;
      NetworkArray[0].SetInput(NatX);
      NetworkArray[0].SetInput(NatY);
      PreviousNatY := NatY;
    end;

    for I := 0 to Length(NetworkArray) - 1 do
    begin
      while NIC[I].Count >= 2 do
      begin
        NetworkArray[I].SetInput(NIC[I].Dequeue);
        NetworkArray[I].SetInput(NIC[I].Dequeue);
      end;
      NetworkArray[I].Run(1, I);
      while NetworkArray[I].Output.Count >= 3 do
      begin
        var TmpAdres := NetworkArray[I].GetOutput;
        if TmpAdres <> 255 then
        begin
          TmpInt := NetworkArray[I].GetOutput;
          NIC[TmpAdres].Enqueue(TmpInt);
          TmpInt := NetworkArray[I].GetOutput;
          NIC[TmpAdres].Enqueue(TmpInt);
        end else
        begin
          NatX := NetworkArray[I].GetOutput;
          NatY := NetworkArray[I].GetOutput;
        end;
      end;
    end;
  end;
end;

constructor TAmplifier.Create(AProgramArray: TArray<Int64>);
begin
  Output := TList<Int64>.Create;
  InputList := TList<Int64>.Create;
  Reset(AProgramArray);
end;

destructor TAmplifier.Destroy;
begin
  Output.Free;
  InputList.Free;
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
  InputList.Clear;
  RelativeBase := 0;

  SetLength(ProgramArray, Length(AProgramArray));
  for var K := 0 to Length(AProgramArray) - 1 do
  begin
    ProgramArray[K] := AProgramArray[K];
  end;
end;

procedure TAmplifier.Run(AIterations : Int64; ACode : Int64);
var
  I, J: Int64;
  InstructionA, InstructionB, InstructionC, InstructionDE : Int64;
begin
  I := OperationPointer;
  J := 0;
  while (J < AIterations) do
  begin
    InstructionDE := ProgramArray[I] mod 100;
    InstructionC := Floor((ProgramArray[I])/100) mod 10;
    InstructionB := Floor((ProgramArray[I])/1000) mod 10;
    InstructionA := Floor((ProgramArray[I])/10000) mod 10;
    if InstructionDE in [1,2] then begin
      ProgramArray[GetIndexValue(ProgramArray[I + 3], InstructionA)] := ExecProgram(InstructionDE, GetValue(ProgramArray[I + 1], InstructionC), GetValue(ProgramArray[I + 2], InstructionB));
      Inc(I, 4);
    end else if InstructionDE = 3 then begin
      if InputList.Count > 0 then begin
        ProgramArray[GetIndexValue(ProgramArray[I + 1], InstructionC)] := InputList.ExtractAt(0);
        Inc(I, 2);
      end else
      begin
        ProgramArray[GetIndexValue(ProgramArray[I + 1], InstructionC)] := -1;
        Inc(I, 2);
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
    Inc(J);
  end;
  If (ProgramArray[I] = 99) then
  begin
    Status := TASFinished;
  end;
  OperationPointer := I;
end;

procedure TAmplifier.SetInput(AInput: Int64);
begin
  InputList.Add(AInput);
  Status := TASReady;
end;


begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day23.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day23.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
