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
uses UListBomb, UUtils, UCore;

{ CJellyBomb }

procedure CJellyBomb.Move(dt: single);
begin
  inherited Move(dt);
  if Not(bMoving) and (nMoveDir<>NONE) then
  begin
    bMoving:=True;
    nMoveDir:=-nMoveDir;
    PlaySound( SOUND_BOUNCE( Random(2) + 1 ) );
  end;
end;


end.

