program Day3;

{$APPTYPE CONSOLE}

{$R *.res}

uses
    System.Generics.Collections
  , System.Math
  , System.StrUtils
  , System.SysUtils
  , System.Types
  , WGUtils
  ;

var
  ClosestCross : Double;
  ClosestCrossPartB : Double;
  GridDictionary : TDictionary<TPoint, Integer>;

const
  CrossRoadSign = 2;

procedure SetMove(AX, AY, ALength, XVector, YVector : Integer; AWireLength, AWireSign : Integer);
var
  I : Integer;
  LPoint : TPoint;
begin
  for I := 1 to ALength do
  begin
    LPoint := TPoint.Create(AX+XVector*I, AY+YVector*I);
    If not GridDictionary.ContainsKey(LPoint) then
    begin
      GridDictionary.Add(LPoint, AWireLength + AWireSign*I)  //Value is wireLength*sign of wire (-1 or 1)
    end else begin
      if (Sign(GridDictionary[LPoint]) <> Sign(AWireSign)) then
      begin
        var TmpDistance := Abs(AX+XVector*I) + Abs(AY+YVector*I);
        if TmpDistance <= ClosestCross then
        begin
          ClosestCross := TmpDistance;
        end;

        var TmpDistance2 := Abs(AWireLength + AWireSign*I) + Abs(GridDictionary[LPoint]);
        if TmpDistance2 <= ClosestCrossPartB then
        begin
          ClosestCrossPartB := TmpDistance2;
        end;
      end;
    end;
  end;
end;

function PartAB(AData : string; PartB : Boolean = False): string;
var
  LWireDataArray : TArray<string>;
  LDataArray : TArray<string>;
  I, K: Integer;
  X, Y : Integer;
  LCommand : string;
  LMove : Integer;
  LWireSign, LWireLength : Integer;
begin
  LDataArray := AData.Split([#13#10]);
  ClosestCross := 999999;
  ClosestCrossPartB := 999999;
  GridDictionary := TDictionary<TPoint,Integer>.Create;

  for K := 0 to 1 do begin
    LWireDataArray := LDataArray[K].Split([',']);
    X := 0;
    Y := 0;
    LWireSign := K*2-1;
    LWireLength := 0;
    for I := 0 to Length(LWireDataArray) - 1 do
    begin
      LCommand := LWireDataArray[I].Remove(1);
      LMove := StrToInt(Trim(LWireDataArray[I].Substring(1)));
      if LCommand = 'U' then
      begin
        SetMove(X, Y, LMove, 0, -1, LWireLength, LWireSign);
        Y := Y-LMove;
      end else
      if LCommand = 'D' then
      begin
        SetMove(X, Y, LMove, 0, 1, LWireLength, LWireSign);
        Y := Y+LMove;
      end else
      if LCommand = 'L' then
      begin
        SetMove(X, Y, LMove, -1, 0, LWireLength, LWireSign);
        X := X-LMove;
      end else
      if LCommand = 'R' then
      begin
        SetMove(X, Y, LMove, +1, 0, LWireLength, LWireSign);
        X := X+LMove;
      end;
      LWireLength := LWireLength+LMove*LWireSign;
    end;
  end;

  if PartB then begin
    Result := ClosestCrossPartB.ToString;
  end else
  begin
    Result := ClosestCross.ToString;
  end;
end;


function PartA(AData : string): string;
begin
  Result := PartAB(AData);
end;

function PartB(AData : string): string;
begin
  Result := PartAB(AData, True);
end;

begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day3Test.txt')));
    writeln(PartA(T_WGUtils.OpenFile('..\..\day3.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day3Test.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day3.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
