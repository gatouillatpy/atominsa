unit UBomberman;

{$mode objfpc}{$H+}

interface

uses UUtils,       //Nos constantes
     UGrid,        //Grille de jeu
     UBomb;        //Pour la creation de bombes

     

type

  { CBomberman }

  CBomberman = class
  private
    fCX, fCY : Single;       // coordonnées ciblées par l'intelligence artificielle
    fLX, fLY : Single;       // dernières coordonnées
    fDanger : Single;        // pourcentage de risque aux coordonnées courantes
    


    fPosition,
    fOrigin   : Vector;
    //fXOrigin,                //Position lors de la creation du bomberman
    //fYOrigin,
    //fX,
    //fY,                      //Position Graphique bomberman
    fSpeed,                  //Vitesse du bomberman
    fBombTime : Single;      //Temps avant explosion des bombes

    lastDir   : vectorN;     // memorise la derniere direction du bomberman

    sName     : string;       //nom du joueur

    nIndex,                   //numero du bomberman
    nTeam,                    //numero de team
    nKills,                   //nombre de bomberman tue
    nDeaths,                  //nombre de fois tue
    nScore,                   //Score
    nBombCount,               //Nombre de bombes dispo
    nFlameSize,               //Taille de la flamme
    nDirection  : integer;    //Derniere direction de mouvement du bomberman


    bSecondaryPressed,
    bCanGrabBomb,             // Peut il porter une bombe ... (le bonus)
    bEjectBomb,               //Si true = on oblige a lacher ses bombes
    bNoBomb  : Boolean;       //Permet de savoir si on peut poser une bombe ou pas indifferemment du nombre en stock (= maladie)
             //true = je suis malade => je peux pas poser
             //false = je suis pas malade => je peux poser si j'en ai assez en stock
    bReverse  : Boolean;       //touche inverse
    bAlive    : Boolean;      //Personnage en vie ou non
    bKick     : Boolean;      //Shoot dans une bombe possible ou non
    uGrid     : CGrid;        //Pointe sur la grille de jeu
    uGrabbedBomb : CBomb;      // pointe sur la bombe qu'on porte
    

    procedure Move(dx, dy : integer; dt : single);
    procedure UpBombCount(); cdecl;
    procedure CheckBonus();
    procedure DoMove(afX, afY : Single);
    procedure TestCase(aX,aY : integer;var bBomb : boolean;var bResult : boolean);
    procedure MoveBomb(_X,_Y,aX,aY,dX,dY : integer; dt : Single);
    procedure GrabBomb();
    procedure DropBomb(dt : Single);
    
    function TestBomb(aX,aY : integer):boolean;
    function TestBonus(aX,aY : integer):boolean;
    function TestGrid(aX,aY : integer):boolean;
    function ChangeCase(aX,aY : integer;afX, afY : Single):boolean;
  protected
    { protected declarations }
  public
    { public declarations }
  Constructor Create(aName : string; aTeam : integer; aIndex : Integer;
                           aGrid : CGrid; aX, aY : Single);
  procedure SecondaryKey(dt : single);cdecl;
  procedure MoveUp(dt : Single);cdecl;
  procedure MoveDown(dt : Single);cdecl;
  procedure MoveLeft(dt : Single);cdecl;
  procedure MoveRight(dt : Single);cdecl;
  procedure CreateBomb(dt : Single);cdecl;
  procedure Update(dt : Single);
  procedure UpKills();
  procedure DownKills();
  procedure Dead();
  procedure UpScore();
  procedure Restore();
  procedure ChangeReverse();
  procedure ChangeKick();
  procedure ChangeGrab();

  function CanBomb():boolean;

  property Position : Vector Read fPosition Write fPosition;
//  property X : single Read fX Write fX;
//  property Y : single Read fY Write fY;
  property Direction : integer Read nDirection;

  Property LX : Single Read fLX Write fLX;
  Property LY : Single Read fLY Write fLY;
  Property CX : Single Read fCX Write fCX;
  Property CY : Single Read fCY Write fCY;
  Property Danger : Single Read fDanger Write fDanger;

  property BIndex : integer Read nIndex Write nIndex;
  property Name : string Read sName Write sName;
  property Team : integer Read nTeam Write nTeam;
  property Kills : integer Read nKills;
  property Deaths : integer Read nDeaths;
  property Score : integer Read nScore;
  property ExploseBombTime : Single Read fBombTime Write fBombTime;
  
  property BombCount : integer Read nBombCount Write nBombCount;
  property FlameSize : integer Read nFlameSize Write nFlameSize;
  property Speed : single Read fSpeed Write fSpeed;
  property Alive : boolean Read bAlive;
  property NoBomb : Boolean Read bNoBomb Write bNoBomb;
  property Kick : boolean Read bKick;
  property EjectBomb : boolean Read bEjectBomb Write bEjectBomb;

  end;
  


type
    LPBombermanItem = ^BombermanItem;
    BombermanItem = Record
                   Count  : integer;
                   Bomberman : CBomberman;
                   Next : LPBombermanItem;
                 end;
    Function AddBomberman(aName : string; aTeam : integer; aIndex : Integer;
                           aGrid : CGrid; aX, aY : Single):CBomberman;
    Function RemoveBombermanByIndex(i : Integer):Boolean;
    Function RemoveBombermanByCount(i : Integer):Boolean;
    Procedure FreeBomberman();overload;
    Procedure FreeBomberman(pList : LPBombermanItem);overload;
    Function GetBombermanCount():Integer;
    Function GetBombermanByCount(i : integer):Cbomberman;
    Function GetBombermanByIndex(i : integer):CBomberman;
    function GetBombermanByCoo(aX, aY: integer): CBomberman;
    function IsBombermanAtCoo(aX,aY : integer):boolean;cdecl;
    Function CheckEndGame() : Integer;





implementation
uses uItem,        //Classe Item
     uForm;




{                                                                               }
{                           Liste Bomberman                                     }
{                                                                               }



var pBombermanItem : LPBombermanItem = NIL;                                     //Contient la liste de nos bombermans
    BombermanCount : integer = 0;
    
Procedure UpdateCountList(i : integer);Forward;
    
{*******************************************************************************}
{ Ajout / Suppression                                                           }
{*******************************************************************************}
Function AddBomberman(aName : string; aTeam : integer; aIndex : Integer;
                           aGrid : CGrid; aX, aY : Single):CBomberman;
var pTemp : LPBombermanItem;
begin
Inc(BombermanCount);
if pBombermanItem=NIL then
 begin
    New(pBombermanItem);
    pBombermanItem^.Count:=1;
    pBombermanItem^.Bomberman:=CBomberman.Create(aName,aTeam,aIndex,aGrid,aX,aY);
    pBombermanItem^.Next:=NIL;
    result:=pBombermanItem^.Bomberman;
 end
 else
 begin
    pTemp:=pBombermanItem;
    While (pTemp^.Next<>Nil) do
      pTemp:=pTemp^.Next;
    New(pTemp^.Next);
    pTemp:=pTemp^.Next;
    pTemp^.Count:=BombermanCount;
    pTemp^.Bomberman:=CBomberman.Create(aName,aTeam,aIndex,aGrid,aX,aY);
    pTemp^.Next:=NIL;
    result:=pTemp^.Bomberman;
 end;
end;

Function RemoveBombermanByIndex(i : Integer):Boolean;
var pPrev, pTemp : LPBombermanItem;
    Find, Last : boolean;
    Count : integer;
Begin
Find:=False;
if (pBombermanItem<>Nil) then
begin
pPrev:=NIL;
pTemp:=pBombermanItem;
Find:=(pTemp^.Bomberman.BIndex=i);
Last:=(pTemp^.Next=Nil);

While Not(Find Or Last) do
begin
pPrev:=pTemp;
pTemp:=pTemp^.Next;
Find:=(pTemp^.Bomberman.BIndex=i);
Last:=(pTemp^.Next=Nil);
end;

if Find then
begin
 if (pPrev<>NIL) then  pPrev^.Next:=pTemp^.Next
 else pBombermanItem:=pBombermanItem^.Next;
  pTemp^.Bomberman.Free;
  Count:=pTemp^.Count;
  Dispose(pTemp);
  Dec(BombermanCount);
      //si il a supprimer un bomberman on fait un decalage du count de toute la liste
  UpdateCountList(Count);
end;
End; //du If de depart
Result:=Find;
End;

Function RemoveBombermanByCount(i : Integer):Boolean;
var Find, Last : Boolean;
    pTemp, pPrev : LPBombermanItem;
Begin
Find:=False;
if (pBombermanItem<>Nil) then
begin
  pPrev:=Nil;
  pTemp:=pBombermanItem;
  Find:=(pTemp^.Count=i);
  Last:=(pTemp^.Next=Nil);

  While Not(Find or Last) do
  begin
   pPrev:=pTemp;
   pTemp:=pTemp^.Next;
   Find:=(pTemp^.Count=i);
   Last:=(pTemp^.Next=Nil);
  end;

  if Find then
  begin
   if (pPrev<>Nil) then pPrev^.Next:=pTemp^.Next
   else pBombermanItem:=pBombermanItem^.Next;       //Si pPrev vaut nil ca veut dire que je supprime le premier element de la liste pBombermanItem
   pTemp^.Bomberman.Free;
   Dispose(pTemp);
   Dec(BombermanCount);
   UpdateCountList(i);
  end;
Result:=Find;
end;
end;


Procedure FreeBomberman(pList : LPBombermanItem);
begin
 if (pList<>Nil) then
 begin
   FreeBomberman(pList^.Next);
   pList^.Bomberman.Free;
   Dispose(pList);
   pList:=Nil;
   Dec(BombermanCount);
 end;
end;

Procedure FreeBomberman();
Begin
  if (pBombermanItem<>Nil) then
  begin
     FreeBomberman(pBombermanItem^.Next);
     pBombermanItem^.Bomberman.Free;
     Dispose(pBombermanItem);
     pBombermanItem:=Nil;
     Dec(BombermanCount);
  end;
end;










{*******************************************************************************}
{ Fonctions Get                                                                 }
{*******************************************************************************}
Function GetBombermanByCount(i : integer):Cbomberman;
var pTemp : LPBombermanItem;
Begin
result:=Nil;
if ((pBombermanItem<>NIL) AND (i<=BombermanCount)) then
begin
 pTemp:=pBombermanItem;
 While Not(pTemp^.Count=i) do
   pTemp:=pTemp^.Next;

 result:=pTemp^.Bomberman;
end;
End;

Function GetBombermanByIndex(i : integer):Cbomberman;
var pTemp : LPBombermanItem;
    Find, Last : Boolean;
Begin
Result:=Nil;
pTemp:=Nil;
Find:=False;
if (pBombermanItem<>NIL) then
begin
 pTemp:=pBombermanItem;
 Find:=(pTemp^.Bomberman.BIndex=i);
 Last:=(pTemp^.Next=Nil);
 While Not(Find or Last) do
   begin
    pTemp:=pTemp^.Next;
    Find:=(pTemp^.Bomberman.BIndex=i);
    Last:=(pTemp^.Next=Nil);
   end;
end;
if Find then result:=pTemp^.Bomberman;
End;

function GetBombermanByCoo(aX, aY: integer): CBomberman;
var pTemp : LPBombermanItem;
    Find, Last : Boolean;
begin
result:=Nil;
if ((pBombermanItem<>Nil) AND (CheckCoordinates(aX,aY))) then
begin
 pTemp:=pBombermanItem;
 Find:=((Trunc(pTemp^.Bomberman.Position.X+0.5)=aX) AND (Trunc(pTemp^.Bomberman.Position.Y+0.5)=aY));
 Last:=(pTemp^.Next=Nil);

 While Not(Find or Last) do
 begin
  pTemp:=pTemp^.Next;
  Find:=((Trunc(pTemp^.Bomberman.Position.X+0.5)=aX) AND (Trunc(pTemp^.Bomberman.Position.Y+0.5)=aY));
  Last:=(pTemp^.Next=Nil);
 end;

 if Find then result:=pTemp^.Bomberman;

end;
end;

Function GetBombermanCount():Integer;
Begin
  result:=BombermanCount;
End;












{*******************************************************************************}
{ Fonctions Diverses                                                            }
{*******************************************************************************}
Procedure UpdateCountList(i : integer);
var Count : integer;
    pTemp : LPBombermanItem;
begin
 Count:=1;
  pTemp:=pBombermanItem;
  While (Count<=BombermanCount) do
  begin
   if (Count>=i) then pTemp^.Count:=Count;
   Inc(Count);
   pTemp:=pTemp^.Next;
  end;
end;



function IsBombermanAtCoo(aX, aY: integer): boolean; cdecl;
{True = il y a au moins un bomberman}
begin
result:=(GetBombermanByCoo(aX,aY)<>Nil)
end;



Function CheckEndGame() : Integer;
Var i : Integer;
    c : Integer;
    k : Integer;
Begin
     c := 0;
     If BombermanCount <> 0 Then Begin
        For i := 1 To BombermanCount Do Begin
            If GetBombermanByCount(i).Alive Then Begin
               k := GetBombermanByCount(i).BIndex;
               c += 1;
            End;
        End;
     End;
     If c > 1 Then Result :=  0; // on renvoie 0 si le jeu n'est pas terminé
     If c = 1 Then Result :=  k; // on renvoie l'index du joueur vainqueur
     If c = 0 Then Result := -1; // on renvoie -1 s'il y a égalité
End;










{                                                                               }
{                             CBomberman                                        }
{                                                                               }


{*******************************************************************************}
{ Toute la gestion du deplacement des bombermans                                }
{*******************************************************************************}

function CBomberman.TestBomb(aX,aY : integer):boolean;
{True = c'est une bombe}
begin
 result:=(uGrid.GetBlock(aX,aY) is CBomb);
end;


function CBomberman.TestBonus(aX,aY : integer):boolean;
{True = c'est un bonus, je peux passer}
begin
 result:=False;
 if (uGrid.GetBlock(aX,aY) is CItem) then
   result:=((uGrid.GetBlock(aX,aY) as CItem).IsExplosed());
end;

function CBomberman.TestGrid(aX,aY : integer):boolean;
{True = je peux passer il n'y a rien}
begin
 result:=(uGrid.GetBlock(aX,aY)=Nil);
end;

function CBomberman.ChangeCase(aX,aY : integer;afX, afY : Single):boolean;
{True = On change de case}
begin
 result:= Not((aX=Trunc(afX+0.5)) AND (aY=Trunc(afY+0.5)));
end;

procedure CBomberman.DoMove(afX, afY : Single);
begin
 fPosition.x:=afX;
 fPosition.y:=afY;
end;


procedure CBomberman.TestCase(aX,aY : integer;var bBomb : boolean;var bResult : boolean);
var   bCanMove : boolean;
begin
{On verifie avant tout qu'on est toujours dans la grille de jeu}
if Not(CheckCoordinates(aX,aY)) then
begin
  bBomb:=False;
  bResult:=False;
end
else
begin
  bCanMove:=TestGrid(aX,aY) or Not(ChangeCase(aX,aY,fPosition.x,fPosition.y));
  {Si on peut se deplacer on le fait sans chercher quoi que ce soit}
  if bCanMove then
  begin
    bResult:=True;
    bBomb:=False;
  end
  {Si on peut pas, il faut voir si ce qui nous bloque ne peut etre franchit}
  else
  begin
    {Si c'est un bonus, on passe}
    if TestBonus(aX,aY) then
    begin
      bResult:=True;
      bBomb:=False;
    end
    {Sinon c'est que c'est soit un mur / caisse soit une bombe}
    else
    {Si c'est une bombe on regarde si on peut la shooter}
    if (TestBomb(aX,aY) AND bKick) then
    begin
      bBomb:=True;
      bResult:=True;
    end
    {Sinon c'est que c'est un mur ou caisse ... On ne passe pas}
    else
    begin
      bBomb:=False;
      bResult:=False;
    end;
  end;
end;
end;

procedure CBomberman.Move(dx, dy : integer; dt : single);
var  aX1, aX2, aY1, aY2 : integer;
     _X, _Y,_fX, _fY, delta : Single;
     bExtrem1, bExtrem2, bBomb1, bBomb2 : boolean;
begin
  {On modifie l'orientation du bomberman}
  nDirection:=-dX*90+90*dY*(dY-1);

  {On repere d'abord dans quel case on est cence arriver}
  delta := 1;
  _fX:=fPosition.x + dx*fSpeed*dt;
  _fY:=fPosition.y + dy*fSpeed*dt;
  _X:=_fX;
  _Y:=_fY;
  if dY=1 then _Y:=_Y+delta;                                                    // mouvement vers le bas
  if dX=1 then _X:=_X+delta;                                                    // mouvement vers la droite
  aX1:=Trunc(_X);
  aY1:=Trunc(_Y);
  aX2:=Trunc(_X+abs(dY)*0.5);
  aY2:=Trunc(_Y+abs(dX)*0.5);

  {Test des mouvements des deux extremites}
  TestCase(aX1,aY1,bBomb1,bExtrem1);
  TestCase(aX2,aY2,bBomb2,bExtrem2);

  if bExtrem1 and bExtrem2 then
  begin
    if bBomb1 then MoveBomb(Trunc(fPosition.x+0.5),Trunc(fPosition.y+0.5),aX1,aY1,dX,dY,dt)
    else if bBomb2 then MoveBomb(Trunc(fPosition.x+0.5),Trunc(fPosition.y+0.5),aX2,aY2,dX,dY,dt)
    else
    begin
      DoMove(_fX,_fY);
      lastDir.x:=dX;
      lastDir.y:=dY;
    end;
  end
  else
  begin
    if bExtrem1 then
    begin
      if bBomb1 then MoveBomb(Trunc(fPosition.x+0.5),Trunc(fPosition.y+0.5),aX1,aY1,dX,dY,dt)
      else
      begin
        if dX<>0 then
        begin
          if lastDir.y<>1 then
          begin
            DoMove(fPosition.x - abs(dy)*fSpeed*dt,fPosition.y - abs(dx)*fSpeed*dt);
            lastDir.x:=dX;
            lastDir.y:=dY;
          end
          else
          begin
            lastDir.x:=0;
            lastDir.y:=0;
          end;
        end
        else if dY<> 0 then
        begin
          if lastDir.x<>1 then
          begin
            DoMove(fPosition.x - abs(dy)*fSpeed*dt,fPosition.y - abs(dx)*fSpeed*dt);
            lastDir.x:=dX;
            lastDir.y:=dY;
          end
          else
          begin
            lastDir.x:=0;
            lastDir.y:=0;
          end;
        end;
      end;
    end
    else if bExtrem2 then
    begin
      if bBomb2 then MoveBomb(Trunc(fPosition.x+0.5),Trunc(fPosition.y+0.5),aX2,aY2,dX,dY,dt)
      else
      begin
        if dX<>0 then
        begin
          if lastDir.y<>-1 then
          begin
            DoMove(fPosition.x + abs(dy)*fSpeed*dt,fPosition.y + abs(dx)*fSpeed*dt);
            lastDir.x:=dX;
            lastDir.y:=dY;
          end
          else
          begin
            lastDir.x:=0;
            lastDir.y:=0;
          end;
        end
        else if dY<> 0 then
        begin
          if lastDir.x<>-1 then
          begin
            DoMove(fPosition.x + abs(dy)*fSpeed*dt,fPosition.y + abs(dx)*fSpeed*dt);
            lastDir.x:=dX;
            lastDir.y:=dY;
          end
          else
          begin
            lastDir.x:=0;
            lastDir.y:=0;
          end;
        end;
      end;
    end
    else
    begin
      lastDir.x:=0;
      lastDir.y:=0;
    end;
  end;
  if (((dX=1) or (dY=1)) AND (Not(bExtrem1 or bExtrem2))) then
  begin
    if dX=1 then begin if (_fX-Trunc(_fX))<0.4 then DoMove(_fX,Position.y); end
    else if (_fY-Trunc(_fY))<0.4 then DoMove(Position.x,_fY);
  end;
end;

procedure CBomberman.MoveUp(dt : Single);cdecl;
begin
if bAlive then
begin
 if Not(bReverse) then Move(0,-1,dt) //Haut
 else Move(0,1,dt);                  //Bas
end;
end;

procedure CBomberman.MoveDown(dt : Single);cdecl;
begin
if bAlive then
begin
 if Not(bReverse) then Move(0,1,dt)  //Bas
 else Move(0,-1,dt);                 //Haut
end;
end;

procedure CBomberman.MoveLeft(dt : Single);cdecl;
begin
if bAlive then
begin
 if Not(bReverse) then Move(-1,0,dt) //left
 else Move(1,0,dt);                   //right
end;
end;

procedure CBomberman.MoveRight(dt : Single);cdecl;
begin
if bAlive then
begin
 if Not(bReverse) then Move(1,0,dt) //Right
 else Move(-1,0,dt);
end;
end;














{*******************************************************************************}
{ Gestion des Scores                                                            }
{*******************************************************************************}
procedure CBomberman.UpScore();
begin
Inc(nScore);
end;

procedure CBomberman.UpKills();
begin
  nKills += 1;
end;

procedure CBomberman.DownKills();
begin
  nKills -= 1;
end;

procedure CBomberman.Dead();
begin
if bAlive then
 begin
  bAlive:=False;
  Inc(nDeaths);
  fPosition.x:=0;
  fPosition.y:=0;
 end;
end;







{*******************************************************************************}
{ Liens avec les bombes                                                         }
{*******************************************************************************}
function CBomberman.CanBomb():boolean;
begin
 result := ((nBombCount<>0) And Not(NoBomb));
end;



procedure CBomberman.UpBombCount(); cdecl;
begin
  nBombCount +=1;
end;



procedure CBomberman.CreateBomb(dt : Single); cdecl;
begin
  if bAlive then
  begin
    if CanBomb  then
    begin
      if AddBomb(fPosition.x+0.5,fPosition.y+0.5,nIndex,nFlameSize,fBombTime,uGrid,@UpBombCount,@IsBombermanAtCoo) then
        Dec(nBombCount);
    end;
  end;
end;



procedure CBomberman.MoveBomb(_X,_Y,aX,aY,dX,dY : integer; dt : Single);
var _Bomb : CBomb;
begin
  if ((_X=aX) or (_Y=aY)) then
  begin
   _Bomb:=GetBombByGridCoo(aX,aY);
   if dX=1 then _Bomb.MoveRight(dt)
   else if dX=-1 then _Bomb.MoveLeft(dt)
   else if dY=1 then _Bomb.MoveDown(dt)
   else if dY=-1 then _Bomb.MoveUp(dt);
  end;
end;



procedure CBomberman.GrabBomb();
var dX, dY : integer;
    delta : single;
begin
  delta := 0.5;
  dX := Trunc(fPosition.x);
  dY := Trunc(fPosition.y);

  case nDirection of
    0    : begin  //bas
             dY := Trunc(fPosition.y)+1;;
           end;
    90   : begin  //gauche
             dX := Trunc(fPosition.x-delta);
           end;
    180 : begin  //haut
             dY := Trunc(fPosition.y-delta);
           end;
    -90  : begin  //droite
             dX := Trunc(fPosition.x)+1;
           end;
  end;

 if CheckCoordinates(dX,dY) then
  if ((uGrid.GetBlock(dX,dY)<>nil) AND (uGrid.GetBlock(dX,dY) is CBomb)) then
  begin
    uGrabbedBomb:=CBomb(uGrid.GetBlock(dX,dY));
    uGrid.DelBlock(dX,dY);
    uGrabbedBomb.StopTime();
    uGrabbedBomb.Position.z:=1;
  end;
end;



procedure CBomberman.DropBomb(dt : Single);
begin
  if uGrabbedBomb<>nil then
  begin
    uGrabbedBomb.StartTime();
    uGrabbedBomb.Position.Z:=0;
    uGrabbedBomb.JumpMovement:=True;
    case nDirection of
      0    : uGrabbedBomb.MoveDown(dt);
      90   : uGrabbedBomb.MoveLeft(dt);
      180  : uGrabbedBomb.MoveUp(dt);
      -90  : uGrabbedBomb.MoveRight(dt);
    end;
    uGrabbedBomb:=nil;
  end;
end;










{*******************************************************************************}
{ Creation et restauration                                                      }
{*******************************************************************************}
constructor CBomberman.Create(aName: string; aTeam: integer; aIndex : Integer;
                               aGrid : CGrid; aX, aY : Single);
begin
  sName           := aName;
  nTeam           := aTeam;
  nIndex          := aIndex;
  fPosition.x     := aX;
  fPosition.y     := aY;
  fPosition.z     := 0;
  fOrigin         := fPosition;
  uGrid           := aGrid;
  uGrabbedBomb    := nil;
  nKills          := 0;
  nDeaths         := 0;
  nScore          := 0;
  bSecondaryPressed := false;
  bCanGrabBomb       := true;///////////////////////////////////////////////////////////////
  bEjectBomb      := false;
  bNoBomb         := False;
  bReverse        := False;
  bKick           := false;
  bAlive          := True;
  nBombCount      := DEFAULTBOMBCOUNT;
  fBombTime       := BOMBTIME;
  nFlameSize      := DEFAULTFLAMESIZE;
  fSpeed          := DEFAULTSPEED;
  nDirection      := 0;
  lastDir.x       := 0;
  lastDir.y       := 0;
  lastDir.z       := 0;
end;




procedure CBomberman.Restore();
begin
  bAlive          := True;
  fPosition       := fOrigin;
  bSecondaryPressed := false;
  bCanGrabBomb       := True; ////////////////////////////////////////////////////////////
  bEjectBomb      := false;
  bNoBomb         := False;
  bReverse        := False;
  bKick           := false;
  nBombCount      := DEFAULTBOMBCOUNT;
  fBombTime       := BOMBTIME;
  nFlameSize      := DEFAULTFLAMESIZE;
  fSpeed          := DEFAULTSPEED;
  nDirection      := 0;
  lastDir.x       := 0;
  lastDir.y       := 0;
  uGrabbedBomb    := nil;
end;









{*******************************************************************************}
{ Update                                                                        }
{*******************************************************************************}
procedure CBomberman.Update(dt : Single);
begin
  CheckBonus;
  if bEjectBomb then CreateBomb(dt);
  if (uGrabbedBomb<>nil) then
  begin
    uGrabbedBomb.Position.x:=fPosition.x;
    uGrabbedBomb.Position.y:=fPosition.y;
    if Not(bSecondaryPressed) then DropBomb(dt);                  // si on appuie plus mais qu'on a une bombe on la jete
  end;
  bSecondaryPressed := false;
end;






{*******************************************************************************}
{ Gestion des bonus                                                             }
{*******************************************************************************}
procedure CBomberman.CheckBonus();
var oldX, oldY : integer;
begin
  if Not(uGrid.getBlock(Trunc(fPosition.x+0.5),Trunc(fPosition.y+0.5))=Nil) then
     if (uGrid.getBlock(Trunc(fPosition.x+0.5),Trunc(fPosition.y+0.5)) is CItem) then
      begin
         oldX:=Trunc(fPosition.x+0.5);                                                   //a cause de la maladie SWITCH il faut se souvenir de ou il etait
         oldY:=Trunc(fPosition.y+0.5);                                                   //avant de prendre le bonus
         CItem(uGrid.getBlock(oldX,oldY)).Bonus(Self);
         uGrid.DelBlock(oldX,oldY);
      end;
end;



procedure CBomberman.ChangeReverse();
begin
  bReverse:=Not(bReverse);
end;



procedure CBomberman.ChangeKick();
begin
  bKick := Not(bKick);
  //if bGrab reapparition de la caisse ?
  bCanGrabBomb := false;
end;

procedure CBomberman.ChangeGrab();
begin
  bCanGrabBomb := Not(bCanGrabBomb);
  //if bKick reapparition de la caisse ?
  bKick := false;
end;







{*******************************************************************************}
{ Gestion de la seconde touche d'action                                         }
{*******************************************************************************}
procedure CBomberman.SecondaryKey(dt: single); cdecl;
begin
 bSecondaryPressed := true;
 if (bCanGrabBomb and (uGrabbedBomb=nil)) then GrabBomb();
end;


end.
