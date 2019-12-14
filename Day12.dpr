program Day12;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.Generics.Collections,
  System.RegularExpressions,
  System.SysUtils;

type
  TMoon = class
    X : Integer;
    Y : Integer;
    Z : Integer;
    VX : Integer;
    VY : Integer;
    VZ : Integer;
    procedure AdjustSpeed(AMoon : TMoon);
    procedure Move;
    function GetEnergy : Integer;
    constructor Create(AX, AY, AZ : Integer);
    destructor Destroy; override;
    function ISSpeedZeroX (AMoon : TMoon): Boolean;
    function ISSpeedZeroY (AMoon : TMoon): Boolean;
    function ISSpeedZeroZ (AMoon : TMoon): Boolean;
  end;


function PartA(AData : string): string;
var
  I, J : Integer;
  K : Int64;
  MoonsList : TList<TMoon>;
begin
  MoonsList := TList<TMoon>.Create;
  try
    MoonsList.Add(TMoon.Create(19, -10, 7));
    MoonsList.Add(TMoon.Create(1, 2, -3));
    MoonsList.Add(TMoon.Create(14, -4, 1));
    MoonsList.Add(TMoon.Create(8, 7, -6));

    K := 0;
    while K < 1000 do
    begin
      for I := 0 to MoonsList.Count - 1 do
        for J := 0 to MoonsList.Count - 1 do
      begin
        if I <> J then
        begin
          MoonsList[I].AdjustSpeed( MoonsList[J]);
        end;
      end;

      for I := 0 to MoonsList.Count - 1 do
      begin
        MoonsList[I].Move;
      end;
      Inc(K);
    end;



    Result := (MoonsList[0].getEnergy + MoonsList[1].getEnergy + MoonsList[2].getEnergy + MoonsList[3].getEnergy).ToString;
  finally
    MoonsList.Free;
  end;
end;



function greatestCommonDivisor(a, b: Int64): Int64;
var
  temp: Int64;
begin
  while b <> 0 do
  begin
    temp := b;
    b := a mod b;
    a := temp
  end;
  result := a
end;

function leastCommonMultiple(a, b: Int64): Int64;
begin
  result := b * (a div greatestCommonDivisor(a, b));
end;


function PartB(AData : string): string;
var
  I, J : Integer;
  K : Int64;
  MoonsList : TList<TMoon>;
  MoonsStartList : TList<TMoon>;
  XZeroTimePoint : Integer;
  YZeroTimePoint : Integer;
  ZZeroTimePoint : Integer;
  TmpBool : Boolean;
begin
  XZeroTimePoint := -1;
  YZeroTimePoint := -1;
  ZZeroTimePoint := -1;

  MoonsList := TList<TMoon>.Create;
  MoonsStartList := TList<TMoon>.Create;
  try
    MoonsList.Add(TMoon.Create(19, -10, 7));
    MoonsList.Add(TMoon.Create(1, 2, -3));
    MoonsList.Add(TMoon.Create(14, -4, 1));
    MoonsList.Add(TMoon.Create(8, 7, -6));

    for var Tmp in MoonsList do begin
      MoonsStartList.Add(TMoon.Create(Tmp.X, Tmp.Y, Tmp.Z));
    end;

    K := 0;
    while (XZeroTimePoint = -1) or (YZeroTimePoint = -1) or (ZZeroTimePoint = -1) do
    begin
      for I := 0 to MoonsList.Count - 1 do
        for J := 0 to MoonsList.Count - 1 do
      begin
        if I <> J then
        begin
          MoonsList[I].AdjustSpeed( MoonsList[J]);
        end;
      end;

      for I := 0 to MoonsList.Count - 1 do
      begin
        MoonsList[I].Move;
      end;

      if XZeroTimePoint = -1 then
      begin
        TmpBool := True;
        for J := 0 to 3 do
        begin
          TmpBool :=TmpBool and (MoonsList[J].ISSpeedZeroX(MoonsStartList[J]));
        end;
        if TmpBool then XZeroTimePoint := K;
      end;
      if YZeroTimePoint = -1 then
      begin
        TmpBool := True;
        for J := 0 to 3 do
        begin
          TmpBool :=TmpBool and (MoonsList[J].ISSpeedZeroY(MoonsStartList[J]));
        end;
        if TmpBool then YZeroTimePoint := K;
      end;
      if ZZeroTimePoint = -1 then
      begin
        TmpBool := True;
        for J := 0 to 3 do
        begin
          TmpBool :=TmpBool and (MoonsList[J].ISSpeedZeroZ(MoonsStartList[J]));
        end;
        if TmpBool then ZZeroTimePoint := K;
      end;
        
//(         and
//         ((MoonsList[0].X = MoonsList2[0].X) and
//         (MoonsList[1].X = MoonsList2[1].X) and
//         (MoonsList[2].X = MoonsList2[2].X) and
//         (MoonsList[3].X = MoonsList2[3].X)    )
//
//      begin
//      for I := 0 to MoonsList.Count - 1 do
//      begin
//        Writeln(K.ToString + '     ' + MoonsList[I].X.ToString + ' ' + MoonsList[I].Y.ToString + ' ' + MoonsList[I].Z.ToString
//        + ' ' + MoonsList[I].VX.ToString + ' ' + MoonsList[I].VY.ToString + ' ' + MoonsList[I].VZ.ToString);
//      end;
//      end;
      Inc(K);
    end;
//    Writeln(XZeroTimePoint.tostring);
//    Writeln(YZeroTimePoint.tostring);
//    Writeln(ZZeroTimePoint.tostring);
    Result := leastCommonMultiple(XZeroTimePoint+1 , leastCommonMultiple(YZeroTimePoint+1, ZZeroTimePoint+1)).ToString;

//    Result := (MoonsList[0].getEnergy + MoonsList[1].getEnergy + MoonsList[2].getEnergy + MoonsList[3].getEnergy).ToString;
  finally
    MoonsList.Free;
  end;
end;

{ TMoon }

procedure TMoon.AdjustSpeed(AMoon: TMoon);
begin
  if X <> AMoon.X then
  begin
    VX := VX + IfThen(X < AMoon.X, 1, -1);
  end;
  if Y <> AMoon.Y then
  begin
    VY := VY + IfThen(Y < AMoon.Y, 1, -1);
  end;
  if Z <> AMoon.Z then
  begin
    VZ := VZ + IfThen(Z < AMoon.Z, 1, -1);
  end;
end;

constructor TMoon.Create(AX, AY, AZ: Integer);
begin
  X := AX;
  Y := AY;
  Z := AZ;
  VX := 0;
  VY := 0;
  VZ := 0;
end;

destructor TMoon.Destroy;
begin

  inherited;
end;

function TMoon.GetEnergy: Integer;
begin
  Result := (Abs(X) + Abs(Y) + Abs(Z)) * ( Abs(VX) + Abs(VY) + Abs(VZ));
end;

function TMoon.ISSpeedZeroX(AMoon: TMoon): Boolean;
begin
  Result := (VX = 0) and (X = AMoon.X);
end;

function TMoon.ISSpeedZeroY(AMoon: TMoon): Boolean;
begin
  Result := (VY = 0) and (Y = AMoon.Y);
end;

function TMoon.ISSpeedZeroZ(AMoon: TMoon): Boolean;
begin
  Result := (VZ = 0) and (Z = AMoon.Z);
end;

procedure TMoon.Move;
begin
  X := X + VX;
  Y := Y + VY;
  Z := Z + VZ;
end;

begin
  try
//  X 268296‬
//Y 193052
//Z 102356
//    writeln(leastCommonMultiple(18 , leastCommonMultiple(28, 44)).ToString);
//    writeln(leastCommonMultiple(268296 , leastCommonMultiple(193052, 102356)).ToString);
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day12Test.txt')));
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day12.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day12Test.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day12.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
