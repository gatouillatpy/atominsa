Unit UForm;

{$mode objfpc}{$H+}

Interface

Uses Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

Type

  { TWindow }

  TWindow = Class(TForm)
    Image : TImage ;
    Mask: TImage;
    Memo : TMemo ;
  Private
    { private declarations }
  Public
    { public declarations }
  End;

Var Window : TWindow ;

Procedure AddStringToConsole( s : String ) ;
Procedure AddLineToConsole( s : String ) ;

Implementation

Procedure AddStringToConsole( s : String ) ;
Begin
     Window.Memo.Lines.Strings[Window.Memo.Lines.Count-1] := Window.Memo.Lines.Strings[Window.Memo.Lines.Count-1] + s;
     Application.ProcessMessages;
End;

Procedure AddLineToConsole( s : String ) ;
Begin
     Window.Memo.Lines.Add( s );
     Window.Memo.SelStart:=Length(Window.Memo.Lines.Text);
     Application.ProcessMessages;
End;

Initialization
  {$I uform.lrs}

End.

