program Day24;

{$APPTYPE CONSOLE}

{$R *.res}

uses
    System.Generics.Collections
  , System.Math
  , System.RegularExpressions
  , System.StrUtils
  , System.SysUtils
  , WGUtils
  ;

type
  TSpaceCardsCommand = (TSCDealNewStack, TSCCutCards, TSCDealWithIncrement);

type
  TGrid = class
    DataArray : TArray<TArray<Integer>>;
    NewDataArray : TArray<TArray<Integer>>;
    Level : Integer;
    NextLevel : TGrid;
    PreviousLevel : TGrid;
    function LeftSum : Integer;
    function RightSum : Integer;
    function UpSum : Integer;
    function DownSum : Integer;
    procedure CalculateNextStep;
    procedure ReplaceNextStep;
    function CountBugs : Integer;
    function CountPreviousLevelNeighbours(AX, AY : Integer) : Integer;
    function CountNextLevelNeighbours(AX, AY : Integer) : Integer;
    function CountLocalNeighbours(AX, AY : Integer) : Integer;
    constructor Create(ALevel : Integer);
  end;


function NumberOfNeighbours(ADataArray : TArray<Tarray<Integer>>; AX, AY : Integer) : Integer;
begin
  Result := 0;
  if (AY >= 1) then
  begin
    if ADataArray[AX][AY-1] = 1 then
    begin
      Inc(Result);
    end;
  end;
  if (AX >= 1)  then
  begin
    if ADataArray[AX-1][AY] = 1 then
    begin
      Inc(Result);
    end;
  end;
  if (AX <= 3)  then
  begin
    if ADataArray[AX+1][AY] = 1 then
    begin
      Inc(Result);
    end;
  end;
  if (AY <= 3) then
  begin
    if ADataArray[AX][AY+1] = 1 then
    begin
      Inc(Result);
    end;
  end;  
end;

function PartA(AData : string): string;
var
  DataArray : TArray<Tarray<Integer>>;
  NewDataArray : TArray<Tarray<Integer>>;
  BiodiversityList : TList<Int64>;
  Biodiversity : Int64;
begin

  var TmpArray := AData.Split([#13#10]);
  SetLength(DataArray, 5, 5);
  SetLength(NewDataArray, 5, 5);  
  for var I := 0 to Length(TmpArray) - 1 do
  begin
    for var J := 0 to TmpArray[I].Length - 1 do
    begin
      DataArray[I][J] :=  Ifthen(TmpArray[I][J+1] = '#', 1, 0)
    end;
  end;

  BiodiversityList := TList<Int64>.Create;
  try
    while True  do begin
      for var I := 0 to Length(DataArray) - 1 do
      begin
        for var J := 0 to Length(DataArray[I]) - 1 do
        begin
          var LNeighbours := NumberOfNeighbours(DataArray, I, J);
          if (LNeighbours <> 1) and (DataArray[I][J] = 1) then
          begin
            NewDataArray[I][J] := 0;
          end else if ((LNeighbours = 1) or (LNeighbours = 2)) and (DataArray[I][J] = 0) then
          begin
            NewDataArray[I][J] := 1;
          end else
          begin
            NewDataArray[I][J] := DataArray[I][J];
          end;
      
        end;
      end;
      Biodiversity := 0;
      for var I := 0 to Length(DataArray) - 1 do
      begin
        for var J := 0 to Length(DataArray) - 1 do
        begin
          DataArray[I][J] := NewDataArray[I][J];
          if DataArray[I][J] = 1 then
          begin
            Biodiversity := Biodiversity + Round(Power(2, 5*I+J));
          end;
        end;
      end;
      if BiodiversityList.Contains(Biodiversity) then
      begin
        Result := Biodiversity.tostring;
        Break;
      end;
      BiodiversityList.Add(Biodiversity);
    end;
  finally
    BiodiversityList.Free;
  end;


//  for var I := 0 to Length(TmpArray) - 1 do
//  begin
//    for var J := 0 to TmpArray[I].Length - 1 do
//    begin
//      write(DataArray[I][J]);
//    end;
//    Writeln;
//  end;


end;



function PartB(AData : string): string;
var
  DataArray : TArray<Tarray<Integer>>;
  StartLevel : Int64;
  GridArray : TArray<TGrid>;
  NumberOfBugs : Integer;
begin

  var TmpArray := AData.Split([#13#10]);
  SetLength(DataArray, 5, 5);
  for var I := 0 to Length(TmpArray) - 1 do
  begin
    for var J := 0 to TmpArray[I].Length - 1 do
    begin
      DataArray[I][J] :=  Ifthen(TmpArray[I][J+1] = '#', 1, 0)
    end;
  end;

  StartLevel := 110;
  SetLength(GridArray, 220);
  for var I := 0 to Length(GridArray) - 1 do
  begin
    GridArray[I] := TGrid.Create(I);
  end;

  GridArray[0].NextLevel := GridArray[1];
  GridArray[Length(GridArray)-1].PreviousLevel := GridArray[Length(GridArray)-2];
  for var I := 1 to Length(GridArray) - 2 do
  begin
    GridArray[I].NextLevel := GridArray[I+1];
    GridArray[I].PreviousLevel := GridArray[I-1];
  end;

  for var I := 0 to Length(TmpArray) - 1 do
  begin
    for var J := 0 to TmpArray[I].Length - 1 do
    begin
      GridArray[StartLevel].DataArray[I][J] := DataArray[I][J];
    end;
  end;

  for var I := 0 to 199 do
  begin
    for var J := 0 to Length(GridArray) - 1 do
    begin
      GridArray[J].CalculateNextStep;
    end;
    for var J := 0 to Length(GridArray) - 1 do
    begin
      GridArray[J].ReplaceNextStep;
    end;
  end;

  NumberOfBugs := 0;
  for var J := 0 to Length(GridArray) - 1 do
  begin
    Inc(NumberOfBugs, GridArray[J].CountBugs);
  end;
  Result := NumberOfBugs.ToString;
end;

{ TGrid }

procedure TGrid.CalculateNextStep;
begin
  for var I := 0 to 4 do
  begin
    for var J := 0 to 4 do
    begin
      var LNeighbours := CountLocalNeighbours(I, J);
      Inc(LNeighbours, CountPreviousLevelNeighbours(I, J));
      Inc(LNeighbours, CountNextLevelNeighbours(I, J));

      if (LNeighbours <> 1) and (DataArray[I][J] = 1) then
      begin
        NewDataArray[I][J] := 0;
      end else if ((LNeighbours = 1) or (LNeighbours = 2)) and (DataArray[I][J] = 0) then
      begin
        NewDataArray[I][J] := 1;
      end else
      begin
        NewDataArray[I][J] := DataArray[I][J];
      end;

    end;
  end;
  NewDataArray[2][2] := 0;
end;

function TGrid.CountBugs: Integer;
begin
  Result := 0;
  for var I := 0 to 4 do
  begin
    for var J := 0 to 4 do
    begin
      Inc(Result, DataArray[I][J]);
    end;
  end;
end;

function TGrid.CountLocalNeighbours(AX, AY : Integer) : Integer;
begin
  Result := 0;
  if (AY >= 1) then
  begin
    if DataArray[AX][AY-1] = 1 then
    begin
      Inc(Result);
    end;
  end;
  if (AX >= 1)  then
  begin
    if DataArray[AX-1][AY] = 1 then
    begin
      Inc(Result);
    end;
  end;
  if (AX <= 3)  then
  begin
    if DataArray[AX+1][AY] = 1 then
    begin
      Inc(Result);
    end;
  end;
  if (AY <= 3) then
  begin
    if DataArray[AX][AY+1] = 1 then
    begin
      Inc(Result);
    end;
  end;
end;

function TGrid.CountNextLevelNeighbours(AX, AY : Integer) : Integer;
begin
  Result := 0;
  if Assigned(NextLevel) then
  begin
    if (AX = 2) and (AY = 1) then
    begin
      Inc(Result, NextLevel.UpSum);
    end;
    if (AX = 2) and (AY = 3) then
    begin
      Inc(Result, NextLevel.DownSum);
    end;
    if (AX = 1) and (AY = 2) then
    begin
      Inc(Result, NextLevel.LeftSum);
    end;
    if (AX = 3) and (AY = 2) then
    begin
      Inc(Result, NextLevel.RightSum);
    end;
  end;
end;

function TGrid.CountPreviousLevelNeighbours(AX, AY : Integer) : Integer;
begin
  Result := 0;
  if Assigned(PreviousLevel) then
  begin
    if AX = 0 then
    begin
      Inc(Result, PreviousLevel.DataArray[2][1]);
    end;
    if AX = 4 then
    begin
      Inc(Result, PreviousLevel.DataArray[2][3]);
    end;
    if AY = 0 then
    begin
      Inc(Result, PreviousLevel.DataArray[1][2]);
    end;
    if AY = 4 then
    begin
      Inc(Result, PreviousLevel.DataArray[3][2]);
    end;
  end;
end;

constructor TGrid.Create(ALevel : Integer);
begin
  Level := ALevel;
  NextLevel := nil;
  PreviousLevel := nil;
  SetLength(DataArray, 5, 5);
  SetLength(NewDataArray, 5, 5);
  for var I := 0 to 4 do
  begin
    for var J := 0 to 4 do
    begin
      DataArray[I][J] := 0;
      NewDataArray[I][J] := 0;
    end;
  end;
end;

function TGrid.DownSum: Integer;
begin
  Result := 0;
  for var I := 0 to 4 do
  begin
    Inc(Result, DataArray[4][I]);
  end;
end;

function TGrid.LeftSum: Integer;
begin
  Result := 0;
  for var I := 0 to 4 do
  begin
    Inc(Result, DataArray[I][0]);
  end;
end;

procedure TGrid.ReplaceNextStep;
begin
  for var I := 0 to 4 do
  begin
    for var J := 0 to 4 do
    begin
      DataArray[I][J] := NewDataArray[I][J];
    end;
  end;
end;

function TGrid.RightSum: Integer;
begin
  Result := 0;
  for var I := 0 to 4 do
  begin
    Inc(Result, DataArray[I][4]);
  end;
end;

function TGrid.UpSum: Integer;
begin
  Result := 0;
  for var I := 0 to 4 do
  begin
    Inc(Result, DataArray[0][I]);
  end;
end;

begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day24test.txt')));
    writeln(PartA(T_WGUtils.OpenFile('..\..\day24.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day24test.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day24.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
