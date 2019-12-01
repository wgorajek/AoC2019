program Day1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  System.Generics.Collections,
  WGUtils,
  System.SysUtils;

function PartA(AData : string): string;
var
  Total : Integer;
  WeightArray : TArray<string>;
  FuelNedded : Integer;
begin
  Total := 0;
  WeightArray := AData.Split([#13#10]);
  for var I := 0 to Length(WeightArray)-1 do
  begin
    var Weight := StrToInt(WeightArray[I]);
    FuelNedded := (Weight div 3) - 2;
    Total := FuelNedded + Total;
  end;
  Result := Total.ToString;
end;


function PartB(AData : string): string;
var
  Total : Integer;
  WeightArray : TArray<string>;
  FuelNedded : Integer;
begin
  Total := 0;
  WeightArray := AData.Split([#13#10]);
  for var I := 0 to Length(WeightArray)-1 do
  begin
    var Weight := StrToInt(WeightArray[I]);

    while Weight >= 8 do begin
      FuelNedded := (Weight div 3) - 2;
      If FuelNedded > 0 then begin
        Total := FuelNedded + Total;
      end;
      Weight := FuelNedded;
    end;
  end;
  Result := Total.ToString;
end;

begin
  try
    writeln(PartA(T_WGUtils.OpenFile('..\..\day1Test.txt')));
    writeln(PartA(T_WGUtils.OpenFile('..\..\day1.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day1Test.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day1.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
