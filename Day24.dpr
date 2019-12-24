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
begin
  Result := 'todo';
end;

begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day24test.txt')));
    writeln(PartA(T_WGUtils.OpenFile('..\..\day24.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day24.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
