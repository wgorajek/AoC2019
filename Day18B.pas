unit Day18B;

interface


uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.Generics.Collections,
  System.Types,
  System.SysUtils;

type

  TStateOfGame = class
    KeysCollected : TList<ShortString>;
    PlayerPosition : TArray<TPoint>;
    PathLength : Integer;
    constructor Create(APosition : TArray<TPoint>; APathLength : Integer = 0; AKeysCollected : TList<ShortString> = nil);
    destructor Destroy; override;
    function IsEqual(AState : TStateOfGame):  Boolean;
  end;

  TDay18B = class //Delphi ide generate internal error from time to time when this is in *.dpr file
  public
    class function PartB(AData: string): string; static;
  end;

var
  Grid : Array of array of ShortString;
  PossibleStates : TList<TStateOfGame>;
  VisitedBestStates : TList<TStateOfGame>;
  AMiddlePoint : TPoint;


implementation

function GetPointIndex(APoint : TPoint): Integer;
begin
  If (APoint.X < AMiddlePoint.X) then
  begin
    If APoint.Y < AMiddlePoint.Y then
      Result := 0
    else
      Result := 3;
  end else
  begin
    If APoint.Y < AMiddlePoint.Y then
      Result := 1
    else
      Result := 2;
  end;
end;

function MoveVector(AInput : Integer) : TPoint;
begin
  if AInput = 1 then
  begin
    Result := TPoint.Create(0, -1);
  end else if AInput = 2 then
  begin
    Result := TPoint.Create(0, 1);
  end else if AInput = 3 then
  begin
    Result := TPoint.Create(-1, 0);
  end else if AInput = 4 then
  begin
    Result := TPoint.Create(1, 0);
  end;
end;

function AddOrSetBestState(AState : TStateOfGame) : Boolean;
begin
  Result := True;
  for var MyState in VisitedBestStates do
  begin
    if MyState.IsEqual(AState) then
    begin
      Result := False;
      if MyState.PathLength > AState.PathLength then
      begin
        MyState.PathLength := AState.PathLength;
        MyState.KeysCollected.Clear;
        for var MyKey in AState.KeysCollected do
        begin
          MyState.KeysCollected.Add(MyKey);
        end;

      end;
      break;
    end;
  end;
  if Result then
  begin
    VisitedBestStates.Add(AState);
  end;
end;

function ISPossibleToPass(AState : TStateOfGame; APoint : TPoint) : Boolean;
begin
  Result := (Grid[APoint.X][APoint.Y] = '.')
    or (AState.KeysCollected.Contains(shortstring(lowerCase(string(Grid[APoint.X][APoint.Y])))))
    or (AState.KeysCollected.Contains((Grid[APoint.X][APoint.Y])))
  ;
end;

function KeyFound(AString : ShortString): Boolean;
begin
  Result := 'abcdefghijklmnopqrstuvwxyz'.Contains(string(AString));
end;

function FindAllPossibleKeysToCollect(AState : TStateOfGame) : TList<TStateOfGame>;
var
  LPossiblePoints : TQueue<TPair<TPoint, Integer>>;
  LVisitedPoints : TList<TPoint>;
  LTmpPoint : TPoint;
  LPointPair : TPair<TPoint, Integer>;
  I : Integer;
begin
  Result := TList<TStateOfGame>.Create;
  LPossiblePoints :=  TQueue<TPair<TPoint, Integer>>.Create;
  LVisitedPoints := TList<TPoint>.Create;

  try
    for I := 0 to 3 do
    begin
      LPossiblePoints.Enqueue(TPair<TPoint, integer>.Create(AState.PlayerPosition[I], 0)); //!!!!![I]
      LVisitedPoints.Add(AState.PlayerPosition[I]);
    end;
    while (LPossiblePoints.Count > 0 ) do
    begin
      LPointPair := LPossiblePoints.Dequeue;
      for I := 1 to 4 do
      begin
        LTmpPoint := LPointPair.Key + MoveVector(I);
        If not LVisitedPoints.Contains(LTmpPoint) then
        begin
          if (KeyFound(Grid[LTmpPoint.X][LTmpPoint.Y])) and not (AState.KeysCollected.Contains(Grid[LTmpPoint.X][LTmpPoint.Y])) then
          begin
            var TmpI := Result.Add(TStateOfGame.Create(AState.PlayerPosition, LPointPair.Value+1+AState.PathLength, AState.KeysCollected));
            Result[TmpI].KeysCollected.Add(Grid[LTmpPoint.X][LTmpPoint.Y]);
//            var tmpP := TPoint.Create(LTmpPoint.X,LTmpPoint.Y);
            Result[TmpI].PlayerPosition[GetPointIndex(LTmpPoint)] := LTmpPoint;
            Break;
          end else
          if ISPossibleToPass(AState, LTmpPoint) then
          begin
            LPossiblePoints.Enqueue(TPair<TPoint, integer>.Create(LTmpPoint, LPointPair.Value+1));
            LVisitedPoints.Add(LTmpPoint);
          end;
        end;
      end;
    end;
  finally
    LPossiblePoints.Free;
    LVisitedPoints.Free;
  end;
end;

procedure AddNewPossibleStates(AState : TStateOfGame);
var
  NewPossibleStates : TList<TStateOfGame>;
begin
  NewPossibleStates := FindAllPossibleKeysToCollect(AState);
  try
    for var MyState in NewPossibleStates do begin
      if AddOrSetBestState(MyState) then
      begin
        PossibleStates.Add(MyState);
      end;
    end;
  finally
    NewPossibleStates.Free;
  end;
end;

class function TDay18B.PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
  LPosition : TArray<TPoint>;
  LState : TStateOfGame;
begin
  SetLength(Grid, 100, 100);
  for I := 0 to 99 do
  begin
    for J := 0 to 99 do
    begin
      Grid[I][J] := ' ';
    end;
  end;
  AMiddlePoint := TPoint.Create(41,41);
  DataArray := AData.Split([sLineBreak]);
  SetLength(LPosition, 4);
  for J := 1 to Length(DataArray) do
  begin
    for I := 1 to Length(DataArray[J-1]) do
    begin
      Grid[I][J] := shortString(DataArray[J-1][I]);
      If Grid[I][J] = '@' then
      begin
        Grid[I][J] := '.';
        LPosition[GetPointIndex(TPoint.Create(I, J))] := TPoint.Create(I, J);
      end;
    end;
  end;
  PossibleStates := TList<TStateOfGame>.Create;
  VisitedBestStates := TList<TStateOfGame>.Create;
  LState := TStateOfGame.Create(LPosition, 0);
  try
    PossibleStates.Add(LState);

    while (PossibleStates.Count > 0) do
    begin
      LState := PossibleStates.ExtractAt(0);
      AddNewPossibleStates(LState);
      AddOrSetBestState(LState);
    end;

    var MaxKeysCollected := 0;
    var ShortestWay := 0;
    for var Tmp in VisitedBestStates do
    begin
      if Tmp.KeysCollected.Count > MaxKeysCollected then
      begin
        MaxKeysCollected := Tmp.KeysCollected.Count;
        ShortestWay := Tmp.PathLength;
      end else if Tmp.KeysCollected.Count = MaxKeysCollected then
      begin
        ShortestWay := Min(ShortestWay, Tmp.PathLength);
      end;
    end;
    Result := ShortestWay.Tostring;

  finally
    PossibleStates.Free;
    VisitedBestStates.Free;
  end;

end;

{ TStateOfGame }

constructor TStateOfGame.Create(APosition : TArray<TPoint>; APathLength : Integer = 0; AKeysCollected : TList<ShortString> = nil);
begin
  KeysCollected := TList<ShortString>.Create;
  if Assigned(AKeysCollected) then
  begin
    for var AKey in AKeysCollected do
    begin
      KeysCollected.Add(AKey);
    end;
  end;
  PathLength := APathLength;
  SetLength(PlayerPosition, 4);
  for var I := 0 to 3 do
  begin
    PlayerPosition[I] := TPoint.Create(APosition[I]);
  end;
end;

destructor TStateOfGame.Destroy;
begin
  KeysCollected.Destroy;
  inherited;
end;

function TStateOfGame.IsEqual(AState: TStateOfGame): Boolean;
begin
  Result := False;
  var EqualPosition := True;
  for var I := 0 to 3 do
  begin
    EqualPosition := EqualPosition and (AState.PlayerPosition[I] = PlayerPosition[I]);
  end;
  if EqualPosition then
  begin
    Result := True;
    if AState.KeysCollected.Count = KeysCollected.Count then
    begin
      for var I := 0 to KeysCollected.Count-1 do
      begin
        Result := Result and AState.KeysCollected.Contains(KeysCollected[I]);
      end;
    end
    else
      Result := False;
  end;
end;

end.
