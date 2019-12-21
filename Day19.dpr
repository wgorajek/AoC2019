program Day19;

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
  LPosition : TPoint;
  LOutput : Int64;
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
  LPosition := TPoint.Create(500, 500);

  LAmplifier := TAmplifier.Create(ProgramArray);
  try
    LAmplifier.Input := 0;
    LOutput := 0;
    for I := 0 to 49 do
      for J := 0 to 49 do

    begin
      LAmplifier.SetInput(I);
      LAmplifier.Run;
      LAmplifier.SetInput(J);
      LAmplifier.Run;
      LOutput := LOutput + LAmplifier.GetOutput;
      LAmplifier.Reset(ProgramArray);
	      end;
  finally
    LAmplifier.Free;
  end;
  Result := LOutput.tostring;
end;

function PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
  ProgramArray : TArray<Int64>;
  LAmplifier : TAmplifier;
  LPosition : TPoint;
  LOutput : Int64;
  LLeftBorder : Int64;
  LRightBorder : Int64;
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
  LPosition := TPoint.Create(500, 500);

  LAmplifier := TAmplifier.Create(ProgramArray);
  try
    LAmplifier.Input := 0;
    LOutput := 0;
    I := 1050;
    while True do
    begin
      var FoundLeftBorder := False;
      //J := LLeftBorder;
      J := Round(I*1.16); //from part A

      var LastBeamValue := -1;
      while not FoundLeftBorder do
      begin
        LAmplifier.Reset(ProgramArray);
        LAmplifier.SetInput(I);
        LAmplifier.Run;
        LAmplifier.SetInput(J);
        LAmplifier.Run;
        var TmpOutput := LAmplifier.GetOutput;
        if LastBeamValue < 0 then
        begin
          LastBeamValue := TmpOutput;
        end else
        begin
          if TmpOutput <> LastBeamValue then
          begin
            FoundLeftBorder := True;
            if TmpOutput = 1 then
            begin
              LLeftBorder := J;
            end else
            begin
              LLeftBorder := J+1;
            end;
          end else begin
            if LastBeamValue = 1 then
            begin
              Dec(J);
            end else
            begin
              Inc(J);
            end;
          end;
        end;
      end;
      if (I > 100) then
      begin
        LAmplifier.Reset(ProgramArray);
        LAmplifier.SetInput(I-99);
        LAmplifier.Run;
        LAmplifier.SetInput(LLeftBorder+99);
        LAmplifier.Run;
        var TmpOutput := LAmplifier.GetOutput;
        if TmpOutput = 1 then
        begin
          LOutput := (I-99)*10000 + LLeftBorder;
          Writeln('found' + LOutput.ToString);
          Break;
        end else
          Writeln('I = ' + I.ToString + ' J = ' +  LLeftBorder.ToString);
      end;
      Inc(I);
    end;
  finally
    LAmplifier.Free;
  end;


  Result := LOutput.ToString
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
    writeln(PartA(T_WGUtils.OpenFile('..\..\day19.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day19.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
