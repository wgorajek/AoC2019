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
  I, J : Integer;
  CommandList : TList<TPair<TSpaceCardsCommand, Integer>>;
  Deck : TList<Integer>;
  LMyCardPosition : Integer;
begin
  CommandList := TList<TPair<TSpaceCardsCommand, Integer>>.Create;
  Deck := TList<Integer>.Create;
  try
    CommandArray := AData.Split([#13#10]);
    for var LCommand in CommandArray do begin
      var TmpMatch := TRegEx.Match(LCommand, 'deal with increment (\d*)');
      If TmpMatch.Success then
      begin
        CommandList.Add(TPair<TSpaceCardsCommand, Integer>.Create(TSCDealWithIncrement, StrToInt(TmpMatch.Groups[1].Value)))
      end;
      TmpMatch := TRegEx.Match(LCommand, 'cut (-?\d*)');
      If TmpMatch.Success then
      begin
        CommandList.Add(TPair<TSpaceCardsCommand, Integer>.Create(TSCCutCards, StrToInt(TmpMatch.Groups[1].Value)));
      end;
      TmpMatch := TRegEx.Match(LCommand, 'deal into new stack');
      If TmpMatch.Success then
      begin
        CommandList.Add(TPair<TSpaceCardsCommand, Integer>.Create(TSCDealNewStack, 0));
      end;
    end;
//    LMyCardPosition := 9;
    LMyCardPosition := 2019;
//    for I := 0 to 9 do
    for I := 0 to 10006 do
    begin
      Deck.Add(I);
    end;

    for var LCommand in CommandList do
    begin
      if LCommand.Key = TSCDealNewStack then
      begin
        LMyCardPosition := (Deck.Count - 1) - LMyCardPosition;
      end;
      if LCommand.Key = TSCDealWithIncrement then
      begin
        LMyCardPosition := (LCommand.Value * LMyCardPosition) mod (Deck.Count);
      end;
      if LCommand.Key = TSCCutCards then
      begin
        If LCommand.Value > 0 then
        begin
          if LMyCardPosition <= LCommand.Value - 1 then
          begin
            LMyCardPosition := LMyCardPosition + (Deck.Count - LCommand.Value);
          end else
          begin
            LMyCardPosition := LMyCardPosition - LCommand.Value;
          end;
        end else
        begin
          var LIncrementValue := Abs(LCommand.Value);
          if LMyCardPosition <= (Deck.Count - 1 - LIncrementValue) then
          begin
            LMyCardPosition := LMyCardPosition + LIncrementValue;
          end else
          begin
            LMyCardPosition := LMyCardPosition - (Deck.Count - LIncrementValue);
          end;
        end;
      end;
    end;

    Result := LMyCardPosition.ToString;
  finally
    CommandList.Free;
    Deck.Free;
  end;

end;


function PartB(AData : string): string;
var
  CommandArray : TArray<string>;
  I, J : Integer;
  CommandList : TList<TPair<TSpaceCardsCommand, Integer>>;
  Deck : TList<Integer>;
  LMyCardPosition : Integer;
begin
  CommandList := TList<TPair<TSpaceCardsCommand, Integer>>.Create;
  Deck := TList<Integer>.Create;
  try
    CommandArray := AData.Split([#13#10]);
    for var LCommand in CommandArray do begin
      var TmpMatch := TRegEx.Match(LCommand, 'deal with increment (\d*)');
      If TmpMatch.Success then
      begin
        CommandList.Add(TPair<TSpaceCardsCommand, Integer>.Create(TSCDealWithIncrement, StrToInt(TmpMatch.Groups[1].Value)))
      end;
      TmpMatch := TRegEx.Match(LCommand, 'cut (-?\d*)');
      If TmpMatch.Success then
      begin
        CommandList.Add(TPair<TSpaceCardsCommand, Integer>.Create(TSCCutCards, StrToInt(TmpMatch.Groups[1].Value)));
      end;
      TmpMatch := TRegEx.Match(LCommand, 'deal into new stack');
      If TmpMatch.Success then
      begin
        CommandList.Add(TPair<TSpaceCardsCommand, Integer>.Create(TSCDealNewStack, 0));
      end;
    end;
//    LMyCardPosition := 9;
    LMyCardPosition := 2019;
//    for I := 0 to 9 do
    for I := 0 to 10006 do
    begin
      Deck.Add(I);
    end;

    for var LCommand in CommandList do
    begin
      if LCommand.Key = TSCDealNewStack then
      begin
        LMyCardPosition := (Deck.Count - 1) - LMyCardPosition;
      end;
      if LCommand.Key = TSCDealWithIncrement then
      begin
        LMyCardPosition := (LCommand.Value * LMyCardPosition) mod (Deck.Count);
      end;
      if LCommand.Key = TSCCutCards then
      begin
        If LCommand.Value > 0 then
        begin
          if LMyCardPosition <= LCommand.Value - 1 then
          begin
            LMyCardPosition := LMyCardPosition + (Deck.Count - LCommand.Value);
          end else
          begin
            LMyCardPosition := LMyCardPosition - LCommand.Value;
          end;
        end else
        begin
          var LIncrementValue := Abs(LCommand.Value);
          if LMyCardPosition <= (Deck.Count - 1 - LIncrementValue) then
          begin
            LMyCardPosition := LMyCardPosition + LIncrementValue;
          end else
          begin
            LMyCardPosition := LMyCardPosition - (Deck.Count - LIncrementValue);
          end;
        end;
      end;
    end;

    Result := LMyCardPosition.ToString;
  finally
    CommandList.Free;
    Deck.Free;
  end;

end;

begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day22Test.txt')));
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day22.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day22Test.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day22.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
