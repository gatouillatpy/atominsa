unit UTriggerBomb;

{$mode objfpc}{$H+}

interface

Uses UBomb, UGrid;

type

{CTriggerBomb}

        CTriggerBomb = class(CBomb)
        public
          bIgnition : boolean;
          Constructor create(aX, aY : Single; aIndex, aBombSize : integer; aBombTime : Single ;aGrid : CGrid; UpCount : LPUpCount; IsBomberman : LPGetBomberman; _nNetID : Integer; wIsChecked : Boolean);OverRide;
          function UpdateBomb():boolean;override;
          procedure Ignition();
        end;
implementation
uses UListBomb;

{ CTriggerBomb }

constructor CTriggerBomb.create(aX, aY: Single; aIndex, aBombSize: integer;
  aBombTime: Single; aGrid: CGrid; UpCount: LPUpCount;
  IsBomberman: LPGetBomberman; _nNetID : Integer; wIsChecked : Boolean);
begin
  inherited create(aX, aY, aIndex, aBombSize, aBombTime, aGrid, UpCount,
    IsBomberman, _nNetID, wIsChecked);
  bIgnition    := false;
  bUpdateTime  := bIgnition;
  fExploseTime := 0.01;
end;

function CTriggerBomb.UpdateBomb():boolean;
begin
  bUpdateTime:=bIgnition;
  result:= inherited UpdateBomb();
end;

procedure CTriggerBomb.Ignition();
begin
  bIgnition := true;
end;

end.

