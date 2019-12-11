program Day10;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.Types,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.SysUtils;

var
  StarMap : TArray<string>;
  MaxX, MaxY : Integer;

function GCD(a,b : integer):integer;
begin
  if (a = 0) or (b = 0) then
  begin
    Result := Max(a,b);
  end else
  begin
    if (b mod a) = 0 then
    begin
      Result := a;
    end else
    begin
      Result := GCD(b, a mod b) ;
    end;
  end;
end;


function GetVisibleAsteroids(const AXPoint, AYPoint : Integer) : TList<TPoint>;
var
  I,J : Integer;
  X,Y : Integer;
  AX, AY : Integer;
  XVector : Integer;
  YVector : Integer;
  LGcd : Integer;
  DetectionStarMap : TArray<string>;
  Comparison: TComparison<TPoint>;
  AResult : TList<TPoint>;
begin
  AResult := TList<TPoint>.Create;
  SetLength(DetectionStarMap, MaxY+1);
  for I := 1 to MaxY do begin
    SetLength(DetectionStarMap[I], MaxX+1);
    for J := 1 to MaxX do
      begin
        DetectionStarMap[I][J] := '.';//Copy()
      end;
  end;
  DetectionStarMap[AYPoint][AXPoint] := ' ';
  for Y := 1 to MaxY do
    for X := 1 to MaxX do
    begin
      if (StarMap[Y][X] = '#') and not ((X = AXPoint) and (Y=AYPoint))  then
      begin
        LGcd := GCD(Abs(Y - AYPoint), Abs(X - AXPoint));
        XVector := Round((X - AXPoint) / LGcd);
        YVector := Round((Y - AYPoint) / LGcd);
        I := 1;
        AY := Y + YVector*I;
        AX := X + XVector*I;
        while (AY > 0) and (AY <= MaxY) and (AX > 0) and (AX <= MaxX) do //todo
        begin
          DetectionStarMap[AY][AX] := ' ';
          Inc(I);
          AY := Y + YVector*I;
          AX := X + XVector*I;
        end;
      end;
    end;

  for Y := 1 to MaxY do
    for X := 1 to MaxX do
    begin
      if (StarMap[Y][X] = '#') and (DetectionStarMap[Y][X] = '.') then begin
        DetectionStarMap[Y][X] := '#';
        AResult.Add(TPoint.Create(X,Y));
      end else
      begin
        DetectionStarMap[Y][X] := '.';
      end;
    end;

  Result := AResult;

end;

function CheckLocation(const AXPoint, AYPoint : Integer) : Integer;
begin
  Result := GetVisibleAsteroids(AXPoint, AYPoint).Count;
//  if Result = 214 then
//    writeln(AXPoint.ToString  + ' ' + AYPoint.ToString);
end;

function PartA(AData : string): string;
var
  I, J: Integer;
  MaxResult : Integer;
begin
  StarMap := AData.Split([#13#10]);
  MaxY := Length(StarMap)-1;
  MaxX := StarMap[1].Length;

  for I := 1 to MaxY do
    for J := 1 to MaxX do
    begin
      if StarMap[I][J] = '#' then
      begin
        MaxResult := Max(MaxResult, CheckLocation(J, I));
      end;
    end;

  Result := MaxResult.ToString;
end;


function PartB(AData : string): string;
var
  DestroyCounter : Integer;
  VisibleAsteroids : TList<TPoint>;
  AsteroidToDestroy : TPoint;
  I, J: Integer;
begin


  StarMap := AData.Split([#13#10]);
  MaxY := Length(StarMap)-1;
  MaxX := StarMap[1].Length;


  DestroyCounter := 0;
  VisibleAsteroids := GetVisibleAsteroids(9, 17);


  VisibleAsteroids.Sort(
      TComparer<TPoint>.Construct(
          function(const A1, B1: TPoint): Integer
          var A, B: TPoint;
          begin
            A.X := A1.X-9;
            A.Y := -(A1.Y-17);
            B.X := B1.X-9;
            B.Y := -(B1.Y-17);
            if (A.X >= 0) and (B.X >= 0) then //--X >=0 is destoryed first so it doesnt matter
              Result := A.X*100+A.Y - B.X*100-B.Y
            else if (A.X < 0) and (B.X >=0)  then
              Result := 1
            else if (A.X >= 0) and (B.X < 0)  then
              Result := -1
            else //--thus really sorts last asteroids
              Result := -1*Sign((A.Y/A.X - B.Y/B.X));
          end
        )
    );

  while DestroyCounter < 200 do
  begin
    AsteroidToDestroy := VisibleAsteroids.ExtractAt(0);
    StarMap[AsteroidToDestroy.Y][AsteroidToDestroy.X] := '.';
    Inc(DestroyCounter);
  end;


  Result := ((AsteroidToDestroy.X-1)*100 + (AsteroidToDestroy.Y-1)).ToString;
end;


function ComparePoints(Item1, Item2: TPoint): Integer;
begin
  Result := Item1.X - Item2.X;
end;
begin
  try
    writeln(PartA(T_WGUtils.OpenFile('..\..\day10.txt')));
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day10Test.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day10.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
