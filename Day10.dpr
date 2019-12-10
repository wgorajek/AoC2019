program Day10;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.Generics.Collections,
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

function CheckLocation(const AXPoint, AYPoint : Integer) : Integer;
var
  I,J : Integer;
  X,Y : Integer;
  AX, AY : Integer;
  XVector : Integer;
  YVector : Integer;
  LGcd : Integer;
  DetectionStarMap : TArray<string>;
begin
  Result := 0;
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
      if (StarMap[Y][X] = '#') and (DetectionStarMap[Y][X] = '.') then
        Inc(Result);
    end;
//  if Result = 8 then
//    Writeln('A' + AXPoint.ToString + ' '  + AYPoint.ToString);
end;

function PartA(AData : string): string;
var
  I, J: Integer;
  MaxResult : Integer;
begin
  StarMap := AData.Split([#13#10]);
  MaxY := Length(StarMap)-1;
  MaxX := StarMap[1].Length;


  for I := 1 to Length(StarMap)-1 do
  begin
    writeln(StarMap[I]);
  end;
  for I := 1 to MaxY do
    for J := 1 to MaxX do
//  for I := 1 to 1 do
//    for J := 5 to 5 do
    begin
      if StarMap[I][J] = '#' then
      begin
        MaxResult := Max(MaxResult, CheckLocation(J, I));
      end;
    end;


  Result := MaxResult.ToString;
end;


//function PartB(AData : string): string;
//begin
//
//end;


begin
  try
    writeln(PartA(T_WGUtils.OpenFile('..\..\day10.txt')));
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day10Test.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day10.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
