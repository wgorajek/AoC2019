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
  end;


function PartA(AData : string): string;
var
//  DataArray : TArray<string>;
  I, J, K : Integer;
  MoonsList : TList<TMoon>;
begin
  MoonsList := TList<TMoon>.Create;
  try
//    MoonsList.Add(TMoon.Create(19, -1, 7));
//    MoonsList.Add(TMoon.Create(1, 2, 3));
//    MoonsList.Add(TMoon.Create(14, -4, 1));
//    MoonsList.Add(TMoon.Create(8, 7, -6));

    MoonsList.Add(TMoon.Create(-1, 0, 2));
    MoonsList.Add(TMoon.Create(2, -10, -7));
    MoonsList.Add(TMoon.Create(4, 8, 8));
    MoonsList.Add(TMoon.Create(3, 5, -1));

    K := 0;
//    while K < 1000 do
    while K < 1 do
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
    //51 nie    1655 nie
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
  Result := (X + Y + Z) * ( VX + VY + VZ);
end;

procedure TMoon.Move;
begin
  X := X + VX;
  Y := Y + VY;
  Z := Z + VZ;
end;

begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day12Test.txt')));
    writeln(PartA(T_WGUtils.OpenFile('..\..\day12.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day12Test.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day12.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
