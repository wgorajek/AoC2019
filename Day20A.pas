unit Day20A;

interface


uses
    System.Generics.Collections
  , System.Math
  , System.RegularExpressions
  , System.StrUtils
  , System.SysUtils
  , System.Types
  , WGUtils
  ;

type

  TDay20 = class //Delphi ide generate internal error from time to time when this is in *.dpr file
  public
    class function PartA(AData: string): string; static;
  end;

var
  Grid : Array of array of ShortString;
  Portals : TDictionary<TPoint, TPoint>;
  PortalsEntry : TDictionary<shortstring, TPoint>;
  PortalsExit : TDictionary<shortstring, TPoint>;
  StartPoint : TPoint;
  EndPoint : TPoint;

implementation

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

function Teleport(APoint:TPoint) : TPoint;
begin
  if Portals.ContainsKey(APoint) then
  begin
    Result := Portals[APoint];
  end else
  begin
    Result := APoint; 
  end;
  
end;

function FindExitPoint(APosition : TPoint) : Integer;
var
  LPossiblePoints : TQueue<TPair<TPoint, Integer>>;
  LVisitedPoints : TList<TPoint>;
  LTmpPoint : TPoint;
  LFound : Boolean;
  LPointPair : TPair<TPoint, Integer>;
  I : Integer;
begin
  Result := -1;
  LFound := False;
  LPossiblePoints :=  TQueue<TPair<TPoint, Integer>>.Create;
  LVisitedPoints := TList<TPoint>.Create;

  LPossiblePoints.Enqueue(TPair<TPoint, integer>.Create(APosition, 0));
  LVisitedPoints.Add(APosition);

  try
    while (LPossiblePoints.Count > 0 ) and not LFound do
    begin
      LPointPair := LPossiblePoints.Dequeue;
      for I := 1 to 4 do
      begin
        LTmpPoint := Teleport(LPointPair.Key + MoveVector(I));
        If not LVisitedPoints.Contains(LTmpPoint) then
        begin
          if LTmpPoint = EndPoint then
          begin
            LFound := True;
            Result := LPointPair.Value;
            Break;
          end else if Grid[LTmpPoint.X][LTmpPoint.Y] = '.' then
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

procedure AddPortal(APortalName: ShortString; APointEntry, APointExit : TPoint);
begin
  If PortalsEntry.ContainsKey(APortalName) then
  begin
    Portals.Add(PortalsEntry.ExtractPair(APortalName).Value, APointExit);
    Portals.Add(APointEntry, PortalsExit.ExtractPair(APortalName).Value);
  end else begin
    PortalsEntry.Add(APortalName, APointEntry);
    PortalsExit.Add(APortalName, APointExit);
  end;
end;

procedure CompressPortal(APoint : TPoint);
var
  SecondPortalPart : TPoint;
  PortalName : ShortString;
begin
  for var I := 1 to 4 do
  begin
    var TmpPoint := APoint + MoveVector(I);
    If TRegEx.IsMatch(String(Grid[TmpPoint.X][TmpPoint.Y]), '[A-Z]') then begin
      SecondPortalPart := TmpPoint;
      if Grid[SecondPortalPart.X][SecondPortalPart.Y] < Grid[APoint.X][APoint.Y] then
        PortalName := Grid[SecondPortalPart.X][SecondPortalPart.Y] + Grid[APoint.X][APoint.Y]
      else
        PortalName := Grid[APoint.X][APoint.Y]+Grid[SecondPortalPart.X][SecondPortalPart.Y];

      TmpPoint := APoint + MoveVector(I) + MoveVector(I);
      if Grid[TmpPoint.X][TmpPoint.Y] <> '.' then
      begin
        Grid[APoint.X][APoint.Y] := PortalName;
        Grid[SecondPortalPart.X][SecondPortalPart.Y] := ' ';
        AddPortal(PortalName, APoint, APoint - MoveVector(I));
      end else
      begin
        Grid[SecondPortalPart.X][SecondPortalPart.Y] := PortalName;
        Grid[APoint.X][APoint.Y] := ' ';
        AddPortal(PortalName, SecondPortalPart, TmpPoint);
      end;
      If PortalName = 'ZZ' then
      begin
        EndPoint := PortalsEntry[PortalName];
      end;
      if PortalName = 'AA' then
      begin
        StartPoint := PortalsEntry[PortalName];
      end;
    end;
  end;

end;

class function TDay20.PartA(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Int64;
begin
  DataArray := AData.Split([sLineBreak]);
  SetLength(Grid, Length(DataArray) + 3, Length(DataArray) + 3);

  for J := 1 to Length(DataArray) do
  begin
    for I := 1 to Length(DataArray[J-1]) do
    begin
      Grid[J][I] := shortString(DataArray[J-1][I]);
    end;
  end;

  for I := 1 to Length(Grid) - 1 do
  begin
    for J := 1 to Length(Grid) - 1 do
    begin
      Write(Grid[I][J]);
    end;
    Writeln;
  end;
  Portals := TDictionary<TPoint, TPoint>.Create;
  try
    PortalsEntry := TDictionary<shortstring, TPoint>.Create;
    PortalsExit := TDictionary<shortstring, TPoint>.Create;
    try
      for I := 0 to Length(Grid)-1 do
        begin
          for J := 0 to Length(Grid[I])-1 do
          begin
            If TRegEx.IsMatch(String(Grid[I][J]), '[A-Z]') then begin
              CompressPortal(TPoint.Create(I,J));
            end;
          end;
        end;     
    finally
      PortalsEntry.Free;
      PortalsExit.Free;
    end;

    Result := (FindExitPoint(StartPoint) - 1).ToString;
  finally
    Portals.Free;
  end;
end;


end.
