program Day20;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WGUtils,
  System.Types,
  System.SysUtils,
  Day20A in 'Day20A.pas',
  Day20B in 'Day20B.pas';

begin
  try
//    writeln(TDay20.PartA(T_WGUtils.OpenFile('..\..\day20test.txt')));
//    writeln(TDay20.PartA(T_WGUtils.OpenFile('..\..\day20.txt')));
//    writeln(TDay20B.PartB(T_WGUtils.OpenFile('..\..\day20test.txt')));
    writeln(TDay20B.PartB(T_WGUtils.OpenFile('..\..\day20.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
