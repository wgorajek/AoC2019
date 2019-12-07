program Day7;

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
    ProgramArray : TArray<Integer>;
    OperationPointer : Integer;
    Status : TAmplifierStatus;
    Output : Integer;
    Input : Integer;
    procedure Reset(AProgramArray : TArray<Integer>);
    constructor Create(AProgramArray: TArray<Integer>); reintroduce;
    procedure Run;
  end;




function ExecProgram(AOperation, AInput1, AInput2 : Integer) : Integer;
begin
  case AOperation of
    1 : Result := AInput1 + AInput2;
    2 : Result := AInput1 * AInput2;
    else
      raise Exception.Create('Unknown operation ' + AOperation.ToString);
  end;

end;

function GetValue(AValue, AMode : Integer; AProgramArray : TArray<Integer>) : Integer;
begin
  if AMode = 1  then
  begin
    Result := AValue;
  end else
  begin
    Result := AProgramArray[AValue];
  end;
end;

function CalculateProgram(AProgramArray : TArray<Integer>; APhaseSetting : Integer; AInputArray : TArray<Integer>) : TArray<Integer>;
var
  I: Integer;
  J : Integer;
  {InstructionA, }InstructionB, InstructionC, InstructionDE : Integer;
  LProgramArray : TArray<Integer>;
begin
  I := 0;
  J := 0;
  SetLength(Result, 1);
  Result[0] := -1; //Future place for ThrusterSIgnal

  SetLength(LProgramArray, Length(AProgramArray));
  for var K := 0 to Length(AProgramArray) - 1 do
  begin
    LProgramArray[K] := AProgramArray[K];
  end;


  while LProgramArray[I] <> 99 do
  begin
    InstructionDE := LProgramArray[I] mod 100;
    InstructionC := Floor((LProgramArray[I])/100) mod 10;
    InstructionB := Floor((LProgramArray[I])/1000) mod 10;
//    InstructionA := Floor((ProgramArray[I])/10000) mod 10;
    if InstructionDE in [1,2] then begin
      LProgramArray[LProgramArray[I + 3]] := ExecProgram(InstructionDE, GetValue(LProgramArray[I + 1], InstructionC, LProgramArray), GetValue(LProgramArray[I + 2], InstructionB, LProgramArray));
      Inc(I, 4);
    end else if InstructionDE = 3 then begin
      LProgramArray[LProgramArray[I + 1]] := AInputArray[J];
      Inc(J);
      Inc(I, 2);
    end else if InstructionDE = 4 then begin
      SetLength(Result, Length(Result)+1);
      Result[Length(Result)-1] := GetValue(LProgramArray[I + 1], InstructionC, LProgramArray);
      Inc(I, 2);
    end else if InstructionDE = 5 then begin
      if GetValue(LProgramArray[I + 1], InstructionC, LProgramArray) <> 0 then
      begin
        I := GetValue(LProgramArray[I + 2], InstructionB, LProgramArray);
      end else
      begin
        Inc(I, 3);
      end;
    end else if InstructionDE = 6 then begin
      if GetValue(LProgramArray[I + 1], InstructionC, LProgramArray) = 0 then
      begin
        I := GetValue(LProgramArray[I + 2], InstructionB, LProgramArray);
      end else
      begin
        Inc(I, 3);
      end;
    end else if InstructionDE = 7 then begin
      if GetValue(LProgramArray[I + 1], InstructionC, LProgramArray) < GetValue(LProgramArray[I + 2], InstructionB, LProgramArray)  then
      begin
        LProgramArray[LProgramArray[I + 3]] := 1;
      end else
      begin
        LProgramArray[LProgramArray[I + 3]] := 0;
      end;
      Inc(I, 4);
    end else if InstructionDE = 8 then begin
      if GetValue(LProgramArray[I + 1], InstructionC, LProgramArray) = GetValue(LProgramArray[I + 2], InstructionB, LProgramArray)  then
      begin
        LProgramArray[LProgramArray[I + 3]] := 1;
      end else
      begin
        LProgramArray[LProgramArray[I + 3]] := 0;
      end;
      Inc(I, 4);
    end else begin
      raise Exception.Create('Unknown operation ' + InstructionDE.ToString);
    end;
  end;

end;

function PartA(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Integer;
  ProgramArray : TArray<Integer>;
  InputOutputArray : TArray<Integer>;
  ThrustersSignals : TArray<Integer>;
  MaxSignal : Integer;
  PermutationList : TList<Integer>;
begin
  DataArray := AData.Split([',']);
  SetLength(ProgramArray, Length(DataArray));

  for I := 0 to Length(DataArray) - 1 do
  begin
    ProgramArray[I] := StrToInt(Trim(DataArray[I]));
  end;


  setLength(ThrustersSignals,5);
  MaxSignal := 0;

  ThrustersSignals[0] := 1;
  ThrustersSignals[1] := 0;
  ThrustersSignals[2] := 4;
  ThrustersSignals[3] := 3;
  ThrustersSignals[4] := 2;

  PermutationList := TList<Integer>.Create;
  try
    for var A := 0 to 4 do
      for var B := 0 to 3 do
        for var C := 0 to 2 do
          for var D := 0 to 1 do
            for var E := 0 to 0 do
            begin
                PermutationList.Clear;
                PermutationList.AddRange([0,1,2,3,4]);
                ThrustersSignals[0] := PermutationList.Items[A];
                PermutationList.Remove(PermutationList.Items[A]);
                ThrustersSignals[1] := PermutationList.Items[B];
                PermutationList.Remove(PermutationList.Items[B]);
                ThrustersSignals[2] := PermutationList.Items[C];
                PermutationList.Remove(PermutationList.Items[C]);
                ThrustersSignals[3] := PermutationList.Items[D];
                PermutationList.Remove(PermutationList.Items[D]);
                ThrustersSignals[4] := PermutationList.Items[E];
                PermutationList.Remove(PermutationList.Items[E]);


              setLength(InputOutputArray,10);
              for I := 1 to Length(InputOutputArray) - 1 do
              begin
                InputOutputArray[I] := 0;
              end;

              for J := 0 to 4 do
              begin
                InputOutputArray[0] := ThrustersSignals[J];
                InputOutputArray := CalculateProgram(ProgramArray, 1, InputOutputArray);
              end;
              MaxSignal := Max(MaxSignal, InputOutputArray[Length(InputOutputArray) - 1 ]);
            end;
  finally
    PermutationList.Free;
  end;
  Result := MaxSignal.ToString;
end;


function PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Integer;
  ProgramArray : TArray<Integer>;
  InputOutputArray : TArray<Integer>;
  ThrustersSignals : TArray<Integer>;
  MaxSignal : Integer;
  AmplifierArray : TArray<TAmplifier>;
  FirstInput : Boolean;
  PermutationList : TList<Integer>;
begin
  DataArray := AData.Split([',']);
  SetLength(ProgramArray, Length(DataArray));

  for I := 0 to Length(DataArray) - 1 do
  begin
    ProgramArray[I] := StrToInt(Trim(DataArray[I]));
  end;


  setLength(ThrustersSignals,5);
  MaxSignal := 0;

  SetLength(AmplifierArray,5);
  for I := 0 to 4 do
  begin
    AmplifierArray[I] := TAmplifier.Create(ProgramArray);
  end;


  ThrustersSignals[0] := 1;
  ThrustersSignals[1] := 0;
  ThrustersSignals[2] := 4;
  ThrustersSignals[3] := 3;
  ThrustersSignals[4] := 2;


  PermutationList := TList<Integer>.Create;
  try
    for var A := 0 to 4 do
      for var B := 0 to 3 do
        for var C := 0 to 2 do
          for var D := 0 to 1 do
            for var E := 0 to 0 do
            begin
              PermutationList.Clear;
              PermutationList.AddRange([0,1,2,3,4]);
              ThrustersSignals[0] := PermutationList.Items[A]+5;
              PermutationList.Remove(PermutationList.Items[A]);
              ThrustersSignals[1] := PermutationList.Items[B]+5;
              PermutationList.Remove(PermutationList.Items[B]);
              ThrustersSignals[2] := PermutationList.Items[C]+5;
              PermutationList.Remove(PermutationList.Items[C]);
              ThrustersSignals[3] := PermutationList.Items[D]+5;
              PermutationList.Remove(PermutationList.Items[D]);
              ThrustersSignals[4] := PermutationList.Items[E]+5;
              PermutationList.Remove(PermutationList.Items[E]);

              FirstInput := True;
              for J := 0 to 4 do
              begin
                AmplifierArray[J].Reset(ProgramArray);
                AmplifierArray[J].Input := ThrustersSignals[J];
              end;

              while not (AmplifierArray[4].Status = TASFinished) do
              begin
                if FirstInput and (AmplifierArray[0].Status = TASWaitForInput) then
                begin
                  FirstInput := False;
                  AmplifierArray[0].Input := 0;
                  AmplifierArray[0].Status := TASReady;
                end;
                for J := 0 to 4 do
                begin
                  If (AmplifierArray[J].Status = TASWaitForInput) and (AmplifierArray[(J+4) mod 5].Output <> -1) then
                  begin
                    AmplifierArray[J].Input := AmplifierArray[(J+4) mod 5].Output;
                    AmplifierArray[(J+4) mod 5].Output := -1;
                    AmplifierArray[J].Status := TASReady;
                  end;
                  AmplifierArray[J].Run;
                end;
              end;

              MaxSignal := Max(MaxSignal, AmplifierArray[4].Output);
            end;
  finally
    PermutationList.Free;
  end;
  Result := MaxSignal.ToString;
end;

constructor TAmplifier.Create(AProgramArray: TArray<Integer>);
begin
  Reset(AProgramArray);
end;

procedure TAmplifier.Reset(AProgramArray: TArray<Integer>);
begin
  OperationPointer := 0;
  Status := TASReady;
  Output := -1;
  Input := -1;
  SetLength(ProgramArray, Length(AProgramArray));
  for var K := 0 to Length(AProgramArray) - 1 do
  begin
    ProgramArray[K] := AProgramArray[K];
  end;
end;

procedure TAmplifier.Run;
var
  I: Integer;
  {InstructionA, }InstructionB, InstructionC, InstructionDE : Integer;
begin
  I := OperationPointer;

  while (Status = TASReady) and (ProgramArray[I] <> 99) do
  begin
    InstructionDE := ProgramArray[I] mod 100;
    InstructionC := Floor((ProgramArray[I])/100) mod 10;
    InstructionB := Floor((ProgramArray[I])/1000) mod 10;
//    InstructionA := Floor((ProgramArray[I])/10000) mod 10;
    if InstructionDE in [1,2] then begin
      ProgramArray[ProgramArray[I + 3]] := ExecProgram(InstructionDE, GetValue(ProgramArray[I + 1], InstructionC, ProgramArray), GetValue(ProgramArray[I + 2], InstructionB, ProgramArray));
      Inc(I, 4);
    end else if InstructionDE = 3 then begin
      if Input <> - 1  then begin
        ProgramArray[ProgramArray[I + 1]] := Input;
        Input := -1;
        Inc(I, 2);
      end else
      begin
        Status := TASWaitForInput;
      end;
    end else if InstructionDE = 4 then begin
      Output := GetValue(ProgramArray[I + 1], InstructionC, ProgramArray);
      Inc(I, 2);
    end else if InstructionDE = 5 then begin
      if GetValue(ProgramArray[I + 1], InstructionC, ProgramArray) <> 0 then
      begin
        I := GetValue(ProgramArray[I + 2], InstructionB, ProgramArray);
      end else
      begin
        Inc(I, 3);
      end;
    end else if InstructionDE = 6 then begin
      if GetValue(ProgramArray[I + 1], InstructionC, ProgramArray) = 0 then
      begin
        I := GetValue(ProgramArray[I + 2], InstructionB, ProgramArray);
      end else
      begin
        Inc(I, 3);
      end;
    end else if InstructionDE = 7 then begin
      if GetValue(ProgramArray[I + 1], InstructionC, ProgramArray) < GetValue(ProgramArray[I + 2], InstructionB, ProgramArray)  then
      begin
        ProgramArray[ProgramArray[I + 3]] := 1;
      end else
      begin
        ProgramArray[ProgramArray[I + 3]] := 0;
      end;
      Inc(I, 4);
    end else if InstructionDE = 8 then begin
      if GetValue(ProgramArray[I + 1], InstructionC, ProgramArray) = GetValue(ProgramArray[I + 2], InstructionB, ProgramArray)  then
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
  If (ProgramArray[I] = 99) then
  begin
    Status := TASFinished;
  end;
  OperationPointer := I;
end;

begin
  try
    writeln(PartA(T_WGUtils.OpenFile('..\..\day7Test.txt')));
    writeln(PartA(T_WGUtils.OpenFile('..\..\day7.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day7BTest.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day7.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
