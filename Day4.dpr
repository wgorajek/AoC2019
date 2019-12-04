program Day4;

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


function CheckNumber(ANumber : Integer; AIsPartB : Boolean) : Boolean;
var
  StrNumber : string;
  I: Integer;
  NoDoubleChar : Boolean;
begin
  Result := True;
  NoDoubleChar := True;
  StrNumber := ANumber.ToString;
  Result := Result and (StrNumber.Length = 6);

  if Result then begin
    for I := 1 to 5 do
    begin
      if StrNumber[I] > StrNumber[I+1] then
      begin
        Result := False;
      end else
      if StrNumber[I] = StrNumber[I+1] then
      begin
        if NoDoubleChar then
        begin

          if not AIsPartB then
          begin
            NoDoubleChar := False;
          end else
          begin
            NoDoubleChar := False;
            if I <= 4 then
            begin
              NoDoubleChar := NoDoubleChar or (StrNumber[I+1] = StrNumber[I+2]);
            end;
            if I >= 2 then
            begin
              NoDoubleChar := NoDoubleChar or (StrNumber[I-1] = StrNumber[I]);
            end;
          end;
        end;

      end;
    end;
  end;
  Result := Result and (not NoDoubleChar);
end;


function PartAB(IsPartB : Boolean = false): string;
var
  LowestNumber, HighestNumber : Integer;
  I: Integer;
  PasswordCount : Integer;
begin
  LowestNumber := 265275;
  HighestNumber := 781584;
  PasswordCount := 0;
  for I := LowestNumber to HighestNumber do
  begin
    if CheckNumber(I, IsPartB) then
    begin
      Inc(PasswordCount);
    end;
  end;
  Result := PasswordCount.ToString;
end;


begin
  try
    writeln(PartAB);
    writeln(PartAB(True));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
