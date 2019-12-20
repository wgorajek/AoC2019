unit Day20B;

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

  TDay20B = class //Delphi ide generate internal error from time to time when this is in *.dpr file
  public
    class function PartB(AData: string): string; static;
  end;

  TMazePoint = record
    Position : TPoint;
    PathLength : Integer;
    MazeDepth : Integer;
    constructor Create(APosition : TPoint; APathLength : Integer; AMazeDepth : Integer);
  end;

var
  Grid : Array of array of ShortString;
  Portals : TDictionary<TPoint, TPoint>;
  PortalsEntry : TDictionary<shortstring, TPoint>;
  PortalsExit : TDictionary<shortstring, TPoint>;
  StartPoint : TPoint;
  EndPoint : TPoint;
  InnerMazeStart : TPoint;
  InnerMazeEnd : TPoint;

implementation

function IsInnerMaze(APoint : TPoint) : Boolean;
begin
  Result := (APoint.X >= InnerMazeStart.X) and (APoint.Y >= InnerMazeStart.Y);
  Result := Result and (APoint.X <= InnerMazeEnd.X) and (APoint.Y <= InnerMazeEnd.Y);
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

function Teleport(const APoint : TPoint; out AMazeDepth : Integer) : TPoint;
begin
  if Portals.ContainsKey(APoint) then
  begin
    Result := Portals[APoint];
    if not IsInnerMaze(Result) then
    begin
      Dec(AMazeDepth);
    end else if AMazeDepth = 0 then
    begin
      Result := APoint;
    end else
    begin
      Inc(AMazeDepth);
    end;
  end else
  begin
    Result := APoint;
  end;

end;

function FindExitPoint(APosition : TPoint) : Integer;
var
  LPossiblePoints : TQueue<TMazePoint>;
  LVisitedPoints : TList<TPair<TPoint, Integer>>;
  LTmpPoint : TPoint;
  LFound : Boolean;
  LMazePoint : TMazePoint;
  I : Integer;
  LDepth : Integer;
begin
  Result := -1;
  LFound := False;
  LPossiblePoints :=  TQueue<TMazePoint>.Create;
  LVisitedPoints := TList<TPair<TPoint, Integer>>.Create;
  try
    LPossiblePoints.Enqueue(TMazePoint.Create(APosition, 0, 0));
    LVisitedPoints.Add(TPair<TPoint, Integer>.Create(APosition, 0));

    while (LPossiblePoints.Count > 0 ) and not LFound do
    begin
      LMazePoint := LPossiblePoints.Dequeue;
      for I := 1 to 4 do
      begin
        LDepth := LMazePoint.MazeDepth;
        LTmpPoint := Teleport(LMazePoint.Position + MoveVector(I), LDepth);
        If not LVisitedPoints.Contains(TPair<TPoint, Integer>.Create(LTmpPoint, LDepth)) then
        begin
          if (LTmpPoint = EndPoint) and (LDepth=0) then
          begin
            LFound := True;
            Result := LMazePoint.PathLength;
            Break;
          end else if Grid[LTmpPoint.X][LTmpPoint.Y] = '.' then
          begin
            if Abs(LDepth) < (Portals.Count+2) then
              LPossiblePoints.Enqueue(TMazePoint.Create(LTmpPoint, LMazePoint.PathLength+1, LDepth));
//            LPossiblePoints.Enqueue(TMazePoint.Create(LTmpPoint, LMazePoint.PathLength+1, 0));
            LVisitedPoints.Add(TPair<TPoint, Integer>.Create(LTmpPoint, LDepth));
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

class function TDay20B.PartB(AData : string): string;
var
  DataArray : TArray<string>;
  I, J: Integer;
//  LPosition : TPoint;
//  LMoveVector : TPoint;
//  LOutput : Int64;
begin
  DataArray := AData.Split([sLineBreak]);
  SetLength(Grid, Length(DataArray) + 3, Length(DataArray) + 3);
//  InnerMazeStart := TPoint.Create(9,9);
//  InnerMazeEnd := TPoint.Create(29,37);
  InnerMazeStart := TPoint.Create(37,37);
  InnerMazeEnd := TPoint.Create(97,97);
  for J := 1 to Length(DataArray) do
  begin
    for I := 1 to Length(DataArray[J-1]) do
    begin
      Grid[J][I] := shortString(DataArray[J-1][I]);
    end;
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


{ TMazePoint }

constructor TMazePoint.Create(APosition: TPoint; APathLength, AMazeDepth: Integer);
begin
  Position := APosition;
  PathLength := APathLength;
  MazeDepth := AMazeDepth;
end;

end.
