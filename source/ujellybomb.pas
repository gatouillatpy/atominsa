unit UJellyBomb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UBomb;


type

{CJellyBomb}

        CJellyBomb = class(CBomb)
        protected
        procedure Move(dt : single);override;
        
        end;
implementation
uses UListBomb;

{ CJellyBomb }

procedure CJellyBomb.Move(dt: single);
begin
  inherited Move(dt);
  if Not(bMoving) then
  begin
    bMoving:=True;
    nMoveDir:=-nMoveDir;
  end;
end;


end.

