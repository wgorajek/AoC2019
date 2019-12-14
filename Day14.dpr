program Day14;

{$APPTYPE CONSOLE}

{$R *.res}

uses
    Spring.Collections
  , System.Generics.Collections
//  , Spring.Generics
  , System.Math
  , System.StrUtils
  , System.SysUtils
  , System.Types
  , WGUtils
  , System.RegularExpressions
  ;

type
  TIndegrient = record
    Number : Int64;
    Name : string;
    constructor Create(AName : string; ANumber : Int64);
  end;

  TReceip = class
    IndegrientList : IList<TIndegrient>;
    ReactionResult : TIndegrient;
    constructor Create;
  end;

var
  ReactionDictionary : IDictionary<string, TReceip>;
  SuppliesDictionary : IDictionary<string, Int64>;
  NeededSuppliesDictionary : IDictionary<string, Int64>;

function Ceil64(const X: Extended): Int64;
begin
  Result := Int64(Trunc(X));
  if Frac(X) > 0 then
    Inc(Result);
end;

procedure AddIndegrient(ADictionary : IDictionary<string, Int64>; AIndegrient : TIndegrient);
begin
  if ADictionary.ContainsKey(AIndegrient.Name) then
  begin
    ADictionary[AIndegrient.Name] := ADictionary[AIndegrient.Name] + AIndegrient.Number;
  end else
  begin
    ADictionary.Add(AIndegrient.Name, AIndegrient.Number);
  end;
end;

function TryRemoveIndegrient(ADictionary : IDictionary<string, Int64>; AIndegrient : TIndegrient) : Int64;
begin
  Result := 0;
  if ADictionary.ContainsKey(AIndegrient.Name) then
  begin
    if ADictionary[AIndegrient.Name] > AIndegrient.Number then
    begin
      ADictionary[AIndegrient.Name] := ADictionary[AIndegrient.Name] - AIndegrient.Number;
      Result := AIndegrient.Number;
    end else if ADictionary[AIndegrient.Name] = AIndegrient.Number then
    begin
      ADictionary.Remove(AIndegrient.Name);
      Result := AIndegrient.Number;
    end else if ADictionary[AIndegrient.Name] < AIndegrient.Number then
    begin
      Result := ADictionary[AIndegrient.Name];
      ADictionary.Remove(AIndegrient.Name);
    end;
  end;
end;

function PartA(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
  LReceip : TReceip;
  TmpIndegrient : TIndegrient;
  OreNeeded : Int64;
begin
  OreNeeded := 0;
  ReactionDictionary := TCollections.CreateDictionary<string, TReceip>;
  SuppliesDictionary := TCollections.CreateDictionary<string, Int64>;
  NeededSuppliesDictionary := TCollections.CreateDictionary<string, Int64>;

  DataArray := AData.Split([#13#10]);

  for I := 0 to Length(DataArray) - 1 do
  begin
    LReceip := TReceip.Create;
    var FirstStr := DataArray[I].Remove(TRegEx.Match(DataArray[I], '=>').Index-1);
    for var AMatch in TRegEx.Matches(FirstStr, '(\d*) (\S*?)(, | )') do
    begin
      TmpIndegrient.Name := Trim(AMatch.Groups[2].Value);
      TmpIndegrient.Number := StrToInt(Trim(AMatch.Groups[1].Value));
      LReceip.IndegrientList.Add(TmpIndegrient);
    end;
    FirstStr := DataArray[I].Substring(TRegEx.Match(DataArray[I], '=>').Index+2);
    for var AMatch in TRegEx.Matches(FirstStr, '(\d*) (\S*)') do
    begin
      LReceip.ReactionResult.Name := Trim(AMatch.Groups[2].Value);
      LReceip.ReactionResult.Number := StrToInt(Trim(AMatch.Groups[1].Value));
    end;
    ReactionDictionary.Add(LReceip.ReactionResult.Name, LReceip);
  end;
  TmpIndegrient.Name := 'FUEL';
  TmpIndegrient.Number := 1;
  AddIndegrient(NeededSuppliesDictionary, TmpIndegrient);

  while not NeededSuppliesDictionary.IsEmpty do begin
    var LTmpName := NeededSuppliesDictionary.First.Key;
    var LTmpNumber := NeededSuppliesDictionary.First.Value;
    TmpIndegrient.Number := LTmpNumber;
    TmpIndegrient.Name := LTmpName;
    LTmpNumber := TmpIndegrient.Number - TryRemoveIndegrient(SuppliesDictionary, TmpIndegrient);
    NeededSuppliesDictionary.Remove(NeededSuppliesDictionary.First.Key);
    if LTmpNumber > 0 then
    begin
      if LTmpName = 'ORE' then
      begin
        Inc(OreNeeded, LTmpNumber);
      end else
      begin
        var LReaction := ReactionDictionary[LTmpName];
        var LReactionNumber := Ceil64(LTmpNumber/LReaction.ReactionResult.Number);
        var ExcessProduced := LReactionNumber * LReaction.ReactionResult.Number - LTmpNumber;
        if ExcessProduced > 0 then
        begin
          AddIndegrient(SuppliesDictionary, TIndegrient.Create(LTmpName, ExcessProduced));
        end;

          for TmpIndegrient in LReaction.IndegrientList do
          begin
            var TmpInt := TmpIndegrient.Number*LReactionNumber - TryRemoveIndegrient(SuppliesDictionary, TIndegrient.Create(TmpIndegrient.Name, TmpIndegrient.Number*LReactionNumber));
            if TmpInt > 0 then
            begin
              AddIndegrient(NeededSuppliesDictionary, TIndegrient.Create(TmpIndegrient.Name, TmpInt));
            end;
          end;
      end;
    end;
  end;


  Result := OreNeeded.ToString;
end;



function PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
  LReceip : TReceip;
  TmpIndegrient : TIndegrient;
  FuelProduced : Int64;
  OreStorage : Int64;
begin
  FuelProduced := 0;
  ReactionDictionary := TCollections.CreateDictionary<string, TReceip>;
  SuppliesDictionary := TCollections.CreateDictionary<string, Int64>;
  NeededSuppliesDictionary := TCollections.CreateDictionary<string, Int64>;

  DataArray := AData.Split([#13#10]);

  for I := 0 to Length(DataArray) - 1 do
  begin
    LReceip := TReceip.Create;
    var FirstStr := DataArray[I].Remove(TRegEx.Match(DataArray[I], '=>').Index-1);
    for var AMatch in TRegEx.Matches(FirstStr, '(\d*) (\S*?)(, | )') do
    begin
      TmpIndegrient.Name := Trim(AMatch.Groups[2].Value);
      TmpIndegrient.Number := StrToInt(Trim(AMatch.Groups[1].Value));
      LReceip.IndegrientList.Add(TmpIndegrient);
    end;
    FirstStr := DataArray[I].Substring(TRegEx.Match(DataArray[I], '=>').Index+2);
    for var AMatch in TRegEx.Matches(FirstStr, '(\d*) (\S*)') do
    begin
      LReceip.ReactionResult.Name := Trim(AMatch.Groups[2].Value);
      LReceip.ReactionResult.Number := StrToInt(Trim(AMatch.Groups[1].Value));
    end;
    ReactionDictionary.Add(LReceip.ReactionResult.Name, LReceip);
  end;

  OreStorage := 1000000000000;
  J := 30;

  FuelProduced := 0;
  J := 0;
  while (OreStorage > 0) and (J < 10000) do begin


    TmpIndegrient.Name := 'FUEL';
      TmpIndegrient.Number := Round(OreStorage/Int64(100000000))+1;
    var FuelToProduce := TmpIndegrient.Number;
//    Writeln(OreStorage.ToString + ' ' + TmpIndegrient.Number.ToString);
    AddIndegrient(NeededSuppliesDictionary, TmpIndegrient);

    while not NeededSuppliesDictionary.IsEmpty do begin
      var LTmpName := NeededSuppliesDictionary.First.Key;
      var LTmpNumber := NeededSuppliesDictionary.First.Value;
      TmpIndegrient.Number := LTmpNumber;
      TmpIndegrient.Name := LTmpName;
      LTmpNumber := TmpIndegrient.Number - TryRemoveIndegrient(SuppliesDictionary, TmpIndegrient);
      NeededSuppliesDictionary.Remove(NeededSuppliesDictionary.First.Key);
      if LTmpNumber > 0 then
      begin
        if LTmpName = 'ORE' then
        begin
          Dec(OreStorage, LTmpNumber);
        end else
        begin
          var LReaction := ReactionDictionary[LTmpName];
          var LReactionNumber := Ceil64(LTmpNumber/LReaction.ReactionResult.Number);
          var ExcessProduced := LReactionNumber * LReaction.ReactionResult.Number - LTmpNumber;
          if ExcessProduced > 0 then
          begin
            AddIndegrient(SuppliesDictionary, TIndegrient.Create(LTmpName, ExcessProduced));
          end;

          for TmpIndegrient in LReaction.IndegrientList do
          begin
            var TmpInt := TmpIndegrient.Number*LReactionNumber - TryRemoveIndegrient(SuppliesDictionary, TIndegrient.Create(TmpIndegrient.Name, TmpIndegrient.Number*LReactionNumber));
            if TmpInt > 0 then
            begin
              AddIndegrient(NeededSuppliesDictionary, TIndegrient.Create(TmpIndegrient.Name, TmpInt));
            end;
          end;
        end;
      end;
    end;
      if OreStorage > 0 then
        FuelProduced := FuelProduced + FuelToProduce;
    Inc(J);
  end;

//  Writeln('ore ' + OreStorage.ToString);
  Result := FuelProduced.ToString;
end;
{ TReceip }

constructor TReceip.Create;
begin
  inherited;
  IndegrientList := TCollections.CreateList<TIndegrient>;
end;

{ TIndegrient }

constructor TIndegrient.Create(AName: string; ANumber: Int64);
begin
  Name := AName;
  Number := ANumber;
end;

begin
  try
//    writeln(PartA(T_WGUtils.OpenFile('..\..\day14Test.txt')));
    writeln(PartA(T_WGUtils.OpenFile('..\..\day14.txt')));
//    writeln(PartB(T_WGUtils.OpenFile('..\..\day14Test.txt')));
    writeln(PartB(T_WGUtils.OpenFile('..\..\day14.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
