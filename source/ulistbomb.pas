unit UListBomb;

{$mode objfpc}{$H+}

interface

uses UGrid, UBomb, UJellyBomb, UTriggerBomb, UUtils;

const NONE  = 0;
      UP    = 1;
      DOWN  = -1;
      RIGHT = 2;
      LEFT  = -2;

Type LPBombItem = ^BombItem;
     BombItem = record
              Count : integer;
              Bomb : CBomb;
              Next : LPBombItem;
              end;


    procedure AddBomb(aX, aY : Single; aIndex, aBombSize : integer; aBombTime : Single;aJelly : boolean; aTrigger : boolean; aGrid : CGrid; UpCount : LPUpCount; IsBomberman : LPGetBomberman; _nNetID : Integer);
    procedure RemoveBombByCount(i : integer);
    procedure RemoveBombByGridCoo(aX,aY : integer);
    procedure RemoveThisBomb(wBomb: CBomb);
    procedure FreeBomb();overload;
    procedure FreeBomb(pList : LPBombItem);overload;
    function GetBombCount():integer;
    function GetBombByCount(i : integer):CBomb;
    function GetBombByGridCoo(aX,aY : integer):CBomb;
    function GetBombByNetID(_nNetID : integer):CBomb;

implementation

Uses UGame, UCore, USetup, SysUtils;

{                                                                               }
{                           Liste Bombes                                        }
{                                                                               }
var pBombItem : LPBombItem = NIL;
    BombCount : integer = 0;                                                    // Contient notre liste de bombes



Procedure UpdateCountList();Forward;                                 // pour lui dire que la procedure existe plus loin



{*******************************************************************************}
{ Ajout / Suppression                                                           }
{*******************************************************************************}
// ajout
procedure AddBomb(aX, aY: Single; aIndex, aBombSize : integer; aBombTime : Single; aJelly : boolean; aTrigger : boolean; aGrid: CGrid; UpCount : LPUpCount; IsBomberman : LPGetBomberman; _nNetID : Integer);
var pTemp : LPBombItem;
    sData : String;
begin
 Inc(BombCount);
 if (pBombItem=Nil) then
 begin
   New(pBombItem);
   pBombItem^.Next:=Nil;
   if aJelly then pBombItem^.Bomb:=CJellyBomb.Create(aX,aY,aIndex,aBombSize,aBombTime,aGrid,UpCount,IsBomberman, _nNetID)
   else if aTrigger then pBombItem^.Bomb:=CTriggerBomb.Create(aX,aY,aIndex,aBombSize,aBombTime,aGrid,UpCount,IsBomberman, _nNetID)
   else pBombItem^.Bomb:=CBomb.Create(aX,aY,aIndex,aBombSize,aBombTime,aGrid,UpCount,IsBomberman, _nNetID);
   pBombItem^.Count:=BombCount;
 end
 else
 begin
   pTemp:=pBombItem;
   While (pTemp^.Next<>Nil) do
     pTemp:=pTemp^.Next;
   New(pTemp^.Next);
   pTemp:=pTemp^.Next;
   pTemp^.Count:=BombCount;
   pTemp^.Next:=Nil;
   if aJelly then pTemp^.Bomb:=CJellyBomb.Create(aX,aY,aIndex,aBombSize,aBombTime,aGrid,UpCount,IsBomberman, _nNetID)
   else if aTrigger then pTemp^.Bomb:=CTriggerBomb.Create(aX,aY,aIndex,aBombSize,aBombTime,aGrid,UpCount,IsBomberman, _nNetID)
   else pTemp^.Bomb:=CBomb.Create(aX,aY,aIndex,aBombSize,aBombTime,aGrid,UpCount,IsBomberman, _nNetID);
 end;
 
 If ( bMulti = true ) Then Begin
    sData := IntToStr(aIndex) + #31;
    sData := sData + IntToStr(_nNetID) + #31;
    sData := sData + FloatToStr(aX) + #31;
    sData := sData + FloatToStr(aY) + #31;
    sData := sData + IntToStr(aBombSize) + #31;
    sData := sData + FloatToStr(aBombTime) + #31;
    Send( nLocalIndex, HEADER_ACTION0, sData );
 End;
end;



// suppression par numero
procedure RemoveBombByCount(i: integer);
var pTemp,pPrev : LPBombItem;
    Find, Last : Boolean;
begin
pPrev:=Nil;
if ((i<=BombCount) AND (pBombItem<>Nil)) then
begin
  pTemp:=pBombItem;
  Find:=(pTemp^.Count=i);
  Last:=(pTemp^.Next=Nil);

  While Not(Find or Last) do
  begin
   pPrev:=pTemp;
   pTemp:=pTemp^.Next;
   Last:=(pTemp^.Next=Nil);
   Find:=(pTemp^.Count=i);
  end;

  if Find then
  begin
   if (pPrev<>Nil) then pPrev^.Next:=pTemp^.Next
   else pBombItem:=pTemp^.Next;
   pTemp^.Bomb.Free;
   Dec(BombCount);
   Dispose(pTemp);
   UpdateCountList();
  end;
end;
end;



// suppression par coordonnees
procedure RemoveBombByGridCoo(aX,aY : integer);
var pTemp,pPrev : LPBombItem;
    Find, Last : Boolean;
begin
pPrev:=Nil;
if ((pBombItem<>Nil) AND CheckCoordinates(aX,aY)) then
begin
  pTemp:=pBombItem;
  Find:=((pTemp^.Bomb.XGrid=aX) AND (pTemp^.Bomb.YGrid=aY));
  Last:=(pTemp^.Next=Nil);

  While Not(Find or Last) do
  begin
   pPrev:=pTemp;
   pTemp:=pTemp^.Next;
   Last:=(pTemp^.Next=Nil);
   Find:=((pTemp^.Bomb.XGrid=aX) AND (pTemp^.Bomb.YGrid=aY));
  end;

  if Find then
  begin
   if (pPrev<>Nil) then pPrev^.Next:=pTemp^.Next
   else pBombItem:=pTemp^.Next;
   pTemp^.Bomb.Free;
   Dec(BombCount);
   Dispose(pTemp);
   UpdateCountList();
  end;
end;
end;



// suppression par bombe
procedure RemoveThisBomb(wBomb: CBomb);
var Find : boolean;
    pTemp, pPrev : LPBombItem;
begin
Find:=False;
pPrev:=Nil;
  if pBombItem<>Nil then
  begin
    pTemp:=pBombItem;
    Find:=(pTemp^.Bomb=wBomb);

    While Not(Find) do
    begin
      pPrev:=pTemp;
      pTemp:=pTemp^.Next;
      // TODO
      // il y a un bug a corriger lorsqu'une trigger bombe est supprimée
      Find:=(pTemp <> Nil ) And (pTemp^.Bomb.XGrid=wBomb.XGrid)
      And (pTemp^.Bomb.YGrid=wBomb.YGrid);
    end;

    if pPrev<>nil then pPrev^.Next:=pTemp^.Next else pBombItem:=pTemp^.Next;
    Dispose(pTemp);
    Dec(BombCount);
    UpdateCountList();
  end;
end;



// vidage complet
procedure FreeBomb();
begin
 if pBombItem<>Nil then
 begin
  FreeBomb(pBombItem^.Next);
  pBombItem^.Bomb.Free;
  Dispose(pBombItem);
  pBombItem:=Nil;
 end;
 BombCount:=0;
end;

procedure FreeBomb(pList: LPBombItem);
begin
 if (pList<>Nil) then
 begin
  FreeBomb(pList^.Next);
  pList^.Bomb.Free;
  Dispose(pList);
  pList:=Nil;
 end;
end;














{*******************************************************************************}
{ Fonctions Get                                                                 }
{*******************************************************************************}
function GetBombByCount(i : integer):CBomb;
var pTemp : LPBombItem;
begin
result:=Nil;
pTemp:=pBombItem;
if ((i<=BombCount) AND (pBombItem<>Nil)) then
begin
 While (pTemp^.Count<>i) do
  pTemp:=pTemp^.Next;

 result:=pTemp^.Bomb;
end;
end;



function GetBombByNetID(_nNetID : integer):CBomb;
var pTemp : LPBombItem;
    Find, Last : Boolean;
begin
result:=Nil;
if (pBombItem<>Nil) then
begin
 pTemp:=pBombItem;
 Find:=(pTemp^.Bomb.nNetID=_nNetID);
 Last:=(pTemp^.Next=Nil);

 While Not(Find or Last) do
 begin
  pTemp:=pTemp^.Next;
  Find:=(pTemp^.Bomb.nNetID=_nNetID);
  Last:=(pTemp^.Next=Nil);
 end;

 if Find then result:=pTemp^.Bomb;

end;
end;



function GetBombByGridCoo(aX,aY : integer): CBomb;
var pTemp : LPBombItem;
    Find, Last : Boolean;
begin
result:=Nil;
if ((pBombItem<>Nil) AND (CheckCoordinates(aX,aY))) then
begin
 pTemp:=pBombItem;
 Find:=((pTemp^.Bomb.XGrid=aX) AND (pTemp^.Bomb.YGrid=aY));
 Last:=(pTemp^.Next=Nil);

 While Not(Find or Last) do
 begin
  pTemp:=pTemp^.Next;
  Find:=((pTemp^.Bomb.XGrid=aX) AND (pTemp^.Bomb.YGrid=aY));
  Last:=(pTemp^.Next=Nil);
 end;

 if Find then result:=pTemp^.Bomb;

end;
end;



function GetBombCount(): integer;
begin
  result:=BombCount;
end;








{*******************************************************************************}
{ Fonctions Diverses                                                            }
{*******************************************************************************}
Procedure UpdateCountList();
var i : integer;
    pTemp : LPBombItem;
begin
 if BombCount<>0 then
 begin
  pTemp:=pBombItem;
  for i:=1 to BombCount do
  begin
    pTemp^.Count:=i;
    pTemp:=pTemp^.Next;
  end;
 end;
end;
end.

