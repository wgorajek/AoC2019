program Day6;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.StrUtils,
  WGUtils,
  System.Generics.Collections,
  System.SysUtils;

type
  TSpaceObject = class
  public
    Root : TSpaceObject;
    OrbitList : TList<TSpaceObject>;
    OrbitsNumber : Integer;
    Name : string;
    constructor Create(AName : string); reintroduce;
    destructor Destroy; override;
  end;

var
  SpaceObjectsDictionary : TDictionary<string, TSpaceObject>;

procedure FillSpace(AFirstObjectName, ASecondObjectName : String);
begin
  if not SpaceObjectsDictionary.ContainsKey(ASecondObjectName) then begin
    SpaceObjectsDictionary.Add(ASecondObjectName, TSpaceObject.Create(ASecondObjectName));
  end;

  if not SpaceObjectsDictionary.ContainsKey(AFirstObjectName) then begin
    SpaceObjectsDictionary.Add(AFirstObjectName, TSpaceObject.Create(AFirstObjectName));
  end;
  var LFirst := SpaceObjectsDictionary[AFirstObjectName];
  var LSecond := SpaceObjectsDictionary[ASecondObjectName];

  LFirst.OrbitList.add(LSecond);
  LSecond.Root := LFirst;
end;

procedure CalculateOrbits(ASpaceObject : TSpaceObject);
begin
  if ASpaceObject.Root <> nil then
  begin
    ASpaceObject.OrbitsNumber := ASpaceObject.Root.OrbitsNumber + 1;
  end;
  for var MyElem in ASpaceObject.OrbitList do
  begin
    CalculateOrbits(MyElem);
  end;
end;

function PartAB(AData : string; IsPartB : Boolean = False): string;
var
  DataArray : TArray<string>;
  I: Integer;
  LFirstObjectName, LSecondObjectName : string;
  TotalOrbits : Integer;
  RoadFromYouToRoot : TDictionary<string, integer>;
begin
  DataArray := AData.Split([#13#10]);
  SpaceObjectsDictionary := TDictionary<string, TSpaceObject>.Create;
  try
    for I := 0 to Length(DataArray) - 1 do
    begin
      LFirstObjectName := Trim(DataArray[I].Remove(DataArray[I].IndexOf(')')));
      LSecondObjectName := Trim(DataArray[I].Substring(DataArray[I].IndexOf(')')+1));
      FillSpace(LFirstObjectName, LSecondObjectName);
    end;

    CalculateOrbits(SpaceObjectsDictionary['COM']);

    if not IsPartB then begin
      TotalOrbits := 0;
      for var MyElem in SpaceObjectsDictionary.Values do
      begin
        Inc(TotalOrbits, MyElem.OrbitsNumber);
      end;
      Result := TotalOrbits.ToString;
    end else
    begin
      RoadFromYouToRoot := TDictionary<string, integer>.Create;
      try
        var TmpSpaceObject : TSpaceObject;
        TmpSpaceObject := SpaceObjectsDictionary['YOU'];
        I := 0;
        while TmpSpaceObject.Root <> nil do
        begin
          TmpSpaceObject := TmpSpaceObject.Root;
          RoadFromYouToRoot.Add(TmpSpaceObject.Name, I);
          Inc(I);
        end;

        TmpSpaceObject := SpaceObjectsDictionary['SAN'];
        I := 0;
        while TmpSpaceObject.Root <> nil do
        begin
          TmpSpaceObject := TmpSpaceObject.Root;
          If RoadFromYouToRoot.ContainsKey(TmpSpaceObject.Name) then begin
            Result := (I + RoadFromYouToRoot[TmpSpaceObject.Name]).ToString;
            Break;
          end;
          Inc(I);
        end;
      finally
        RoadFromYouToRoot.Free;
      end;
    end;


  finally
    SpaceObjectsDictionary.Free;
  end;
end;

constructor TSpaceObject.Create(AName : string);
begin
  inherited Create;
  Root := nil;
  OrbitList := TList<TSpaceObject>.Create;
  OrbitsNumber := 0;
  Name := AName;
end;

destructor TSpaceObject.Destroy;
begin
  OrbitList.Free;
  inherited;
end;

begin
  try
    writeln(PartAB(T_WGUtils.OpenFile('..\..\day6.txt')));
    writeln(PartAB(T_WGUtils.OpenFile('..\..\day6Test.txt'), True));
    writeln(PartAB(T_WGUtils.OpenFile('..\..\day6.txt'), True));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
