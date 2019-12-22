program Day22;

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

function PartA(AData : string): string;
var
  CommandArray : TArray<string>;
  CommandList : TList<TPair<TSpaceCardsCommand, Int64>>;
  LDeckSize : Int64;
  LMyCardPosition : Int64;
  LCommand :TPair<TSpaceCardsCommand, Int64>;
begin
  CommandList := TList<TPair<TSpaceCardsCommand, Int64>>.Create;
  try
    CommandArray := AData.Split([#13#10]);
    for var LCommandStr in CommandArray do begin
      var TmpMatch := TRegEx.Match(LCommandStr, 'deal with increment (\d*)');
      If TmpMatch.Success then
      begin
        CommandList.Add(TPair<TSpaceCardsCommand, Int64>.Create(TSCDealWithIncrement, StrToInt(TmpMatch.Groups[1].Value)))
      end;
      TmpMatch := TRegEx.Match(LCommandStr, 'cut (-?\d*)');
      If TmpMatch.Success then
      begin
        CommandList.Add(TPair<TSpaceCardsCommand, Int64>.Create(TSCCutCards, StrToInt(TmpMatch.Groups[1].Value)));
      end;
      TmpMatch := TRegEx.Match(LCommandStr, 'deal into new stack');
      If TmpMatch.Success then
      begin
        CommandList.Add(TPair<TSpaceCardsCommand, Int64>.Create(TSCDealNewStack, 0));
      end;
    end;

    LMyCardPosition := 2019;
    LDeckSize := 10007;

    for LCommand in CommandList do
    begin
      if LCommand.Key = TSCDealNewStack then
      begin
        LMyCardPosition := (LDeckSize - 1) - LMyCardPosition;
      end;
      if LCommand.Key = TSCDealWithIncrement then
      begin
        LMyCardPosition := (LCommand.Value * LMyCardPosition) mod (LDeckSize);
      end;
      if LCommand.Key = TSCCutCards then
      begin
        If LCommand.Value > 0 then
        begin
          if LMyCardPosition <= LCommand.Value - 1 then
          begin
            LMyCardPosition := LMyCardPosition + (LDeckSize - LCommand.Value);
          end else
          begin
            LMyCardPosition := LMyCardPosition - LCommand.Value;
          end;
        end else
        begin
          var LIncrementValue := Abs(LCommand.Value);
          if LMyCardPosition <= (LDeckSize - 1 - LIncrementValue) then
          begin
            LMyCardPosition := LMyCardPosition + LIncrementValue;
          end else
          begin
            LMyCardPosition := LMyCardPosition - (LDeckSize - LIncrementValue);
          end;
        end;
      end;
    end;
    Result := LMyCardPosition.ToString;
  finally
    CommandList.Free;
  end;

end;

function BigMultiply(ABigInt : Int64; SmallerInt : Int64; ADeckSize : Int64) : Int64;
var
  small : Int64;
begin
  Result := 0;
  while SmallerInt > 0 do
  begin
    small := SmallerInt mod 10;
    Result := (Result + small * ABigInt) mod ADeckSize;
    SmallerInt := SmallerInt div 10;
    ABigInt := (ABigInt * 10 mod ADeckSize);
  end;
end;

function BigMultiplyByDeck(ABigInt : Int64; SmallerInt : Int64) : Int64;
var
  LDeckSize : Int64;
begin
  LDeckSize := 119315717514047;
  Result := BigMultiply(ABigInt, SmallerInt, LDeckSize);
end;


function PartB(AData : string): string;
var
  I : Int64;
  LMyCardPosition : Int64;
  LDeckSize : Int64;
  LMultiply, L0PointNumber, LPositionVector : Int64;
begin
  LDeckSize := 119315717514047;
  LMultiply := 101741582076661;
  L0PointNumber := 47995993305898;  //calculated from PartA
  LPositionVector := 18653708664353;  //calculated from PartA Point 0 - point 1
  LMyCardPosition := 2020;

  while LMultiply > 0 do
  begin
    var small := LMultiply mod 10;
    LMultiply := (LMultiply div 10);
    for I := 1 to small do
    begin
      LMyCardPosition := (LDeckSize+L0PointNumber-(BigMultiplyByDeck(LMyCardPosition, LPositionVector))) MOD LDeckSize;
    end;
    var TmpInt0 : Int64;
    var TmpInt1 : Int64;
    TmpInt0 := 0;
    TmpInt1 := 1;
    for I := 1 to 10 do
    begin
      TmpInt0 := (LDeckSize+L0PointNumber-(BigMultiplyByDeck(TmpInt0, LPositionVector))) MOD LDeckSize;
      TmpInt1 := (LDeckSize+L0PointNumber-(BigMultiplyByDeck(TmpInt1, LPositionVector))) MOD LDeckSize;
    end;
    L0PointNumber := TmpInt0;
    LPositionVector := ((TmpInt0 - TmpInt1)+LDeckSize) mod LDeckSize;
  end;

  Result := LMyCardPosition.ToString;
end;

begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day22Test.txt')));
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day22.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day22.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
