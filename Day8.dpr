program Day8;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.Generics.Collections,
  System.SysUtils;


function PartA(AData : string): string;
var
  I: Integer;
  Min0 : Integer;
  TmpMin0 : Integer;
  Max12 : Integer;
  LLayer : string;
begin
  Min0 := 151;
  I := 0;
  while I < Length(AData) do
  begin
    LLayer := AData.Substring(I, 150);
    TmpMin0 := LLayer.CountChar('0');
    if TmpMin0 < Min0 then
    begin
      Min0 := TmpMin0;
      Max12 := LLayer.CountChar('1')*LLayer.CountChar('2');
    end;
    Inc(I,150);
  end;
  Result := Max12.ToString;
end;


function PartB(AData : string): string;
var
  LayersArray : TArray<string>;
  I, J : Integer;
  NumberOfLayers : Integer;

begin
  Result := '';
  NumberOfLayers := Round(AData.Length/150);
  SetLength(LayersArray, NumberOfLayers);
  for I := 0 to NumberOfLayers - 1 do
  begin
    LayersArray[I] := AData.Substring(I*150,150);
  end;

  for I := 1 to 150 do
  begin
    Result := Result + '3';
    J := 0;
    while (Result[I] = '3') and (J < NumberOfLayers)  do
    begin
      if LayersArray[J][I] = '0' then
      begin
        Result[I] := ' ';
      end else if LayersArray[J][I] = '1' then
      begin
        Result[I] := '#';
      end;
      Inc(J);
    end;
  end;

  for I := 0 to 5 do
  begin
    Writeln(Result.Substring(I*25, 25));
  end;
end;


begin
  try
    writeln(PartA(T_WGUtils.OpenFile('..\..\day8.txt')));
    PartB(T_WGUtils.OpenFile('..\..\day8.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
