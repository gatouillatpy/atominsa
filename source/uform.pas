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
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  Private
    { private declarations }
  Public
    { public declarations }
  End;

Var Window : TWindow ;

Var FORCE_QUIT : Boolean;

Procedure AddStringToConsole( s : String ) ;
Procedure AddLineToConsole( s : String ) ;

Implementation

Uses USetup;

Procedure AddStringToConsole( s : String ) ;
Begin
     Window.Memo.Lines.Strings[Window.Memo.Lines.Count-1] := Window.Memo.Lines.Strings[Window.Memo.Lines.Count-1] + s;
     Application.ProcessMessages;

End;

Procedure AddLineToConsole( s : String ) ;
Begin
     Window.Memo.Lines.Add( s );
     //Window.Memo.SelStart := Length(Window.Memo.Lines.Text);
     Application.ProcessMessages;
End;

{ TWindow }              

procedure TWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     FORCE_QUIT := True;
end;

Initialization
  {$I uform.lrs}

End.

