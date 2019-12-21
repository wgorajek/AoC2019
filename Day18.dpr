program Day18;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WGUtils,
  System.Types,
  System.SysUtils,
  Day18AB in 'Day18AB.pas',
  Day18B in 'Day18B.pas';

begin
  try
    writeln(TDay18.PartA(T_WGUtils.OpenFile('..\..\day18Test.txt')));
//    writeln(TDay18.PartA(T_WGUtils.OpenFile('..\..\day18.txt')));
    writeln(TDay18B.PartB(T_WGUtils.OpenFile('..\..\day18B.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
