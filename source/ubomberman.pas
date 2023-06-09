unit UBomberman;

{$mode objfpc}{$H+}

interface

uses UUtils,       //Nos constantes
     UGrid,        //Grille de jeu
     UListBomb,
     UBomb,        //Pour les mouvements de bombes
     UTriggerBomb;

     

type

  { CBomberman }

  CBomberman = class
  public
    fCX, fCY,                    // coordonn�es cibl�es par l'intelligence artificielle
    fLX, fLY : Single;           // derni�res coordonn�es

    


    fPosition,                   // position graphique du personnage
    fOrigin   : Vector;          // position a la creation du personnage
    fIATime,                     // dernier temps pour l'IA
    fMoveTime,                   // temps de r�f�rence du dernier mouvement
    fSpeed,                      // vitesse du bomberman
    fBombTime : Single;          // temps avant explosion des bombes
    fSumDirGetDelta : Single;    // temps depuis lequel le bomberman n'a pas chang� de direction.
    fSumBombGetDelta : Single;   // temps depuis lequel le bomberman n'a pas pos� de bombes.
    fSumGrabGetDelta : Single;   // temps depuis lequel la bombe est port�e.
    fSumFixGetDelta : Single;
    fSumIgnitionGetDelta: Single;// temps depuis lequel la TriggerBomb a �t� pos�e.

    lastDir   : vectorN;         // memorise la derniere direction de mouvement du bomberman

    sName     : string;          // nom du joueur

    nDanger,                     // danger aux coordonn�es courantes
    nDangerLeft,                 // danger aux coordonn�es de la case � gauche du personnage
    nDangerRight,                // danger � droite du personnage
    nDangerUp,                   // danger au-dessus du personnage
    nDangerDown : Integer;       // danger au-dessous du personnage
    nDangerUL,
    nDangerUR,
    nDangerDL,
    nDangerDR : Integer;         // dangers en diagonales
    nAISkill,
    nTriggerBomb,                // stock le nombre de bombe TRIGGER qu'il peut encore poser
    nDisease,                    // stock le numero d'identification de la maladie
    nIndex,                      // numero du bomberman
    nTeam,                       // numero de team
    nKills,                      // nombre de bomberman tue
    nDeaths,                     // nombre de fois tue
    nScore,                      // score
    nBombCount,                  // nombre de bombes dispo
    nFlameSize,                  // taille de la flamme
    nDirection,                  // derniere direction de mouvement du bomberman
    nDirection2  : integer;      // deuxi�me direction pour que l'IA se d�place en diagonale



    bCanSpoog,
    bCanPunch,
    bJelly,
    bPrimaryPressed,
    bSecondaryPressed,
    bCanGrabBomb,                // peut il porter une bombe ... (le bonus)
    bEjectBomb,                  // si true = on oblige a lacher ses bombes
    bNoBomb,                     // permet de savoir si on peut poser une bombe ou pas indifferemment du nombre en stock (= maladie)
                                           //  true = je suis malade => je peux pas poser
                                           //  false = je suis pas malade => je peux poser si j'en ai assez en stock
    bReverse ,                   // touche inverse
    bAlive,                      // personnage en vie ou non
    bcanKick     : Boolean;      // shoot dans une bombe possible ou non

    bCanCalculate,               // les dangers doivent-ils �tre recalcul�s
    bCanGoToTheRight,
    bCanGoToTheLeft,
    bCanGoToTheUp,
    bCanGoToTheDown : Boolean;   // peut-il aller dans la direction indiqu�e
    
    bGrabbed : Boolean;          // le bomberman porte-t-il la bombe


    uTriggerBomb : LPBombItem;   // pointe sur les bombes a declenchement manuel
    uGrid        : CGrid;        // pointe sur la grille de jeu
    uGrabbedBomb : CBomb;        // pointe sur la bombe qu'on porte


    procedure Move(dx, dy : integer; dt : single);
    procedure UpBombCount(); cdecl;
    procedure CheckBonus();
    procedure DoMove(afX, afY : Single);
    procedure TestCase(aX,aY : integer;var bBomb : boolean;var bResult : boolean);
    procedure MoveBomb(_X,_Y,aX,aY,dX,dY : integer; dt : Single);
    function  GrabBomb():boolean;
    procedure GrabBombMulti( dX, dY : Integer );
    procedure DropBomb(dt : Single);
    procedure DropBombMulti(dt : Single);
    procedure ContaminateBomberman();
    procedure PunchBomb(dt : Single);
    procedure AddTriggerBomb();
    procedure DelTriggerBomb();
    procedure DelTriggerBombByNetId( nNetId : Integer );
    procedure TriggerToNormalBomb();
    procedure DoIgnition();

    
    function TestBomb(aX,aY : integer):boolean;
    function TestBonus(aX,aY : integer):boolean;
    function TestGrid(aX,aY : integer):boolean;
    function ChangeCase(aX,aY : integer;afX, afY : Single):boolean;
    function GetTargetTriggerBomb():CTriggerBomb;

    
  protected
    { protected declarations }
  public
    { public declarations }
  Constructor Create(aName : string; aTeam : integer; aIndex : Integer;
                           aAISkill : integer; aGrid : CGrid; aX, aY : Single);
  procedure PrimaryKeyDown(dt : Single);cdecl;
  procedure SecondaryKeyDown(dt : single);cdecl;
  procedure PrimaryKeyUp(dt : Single);cdecl;
  procedure SecondaryKeyUp(dt : Single);cdecl;
  procedure MoveUp(dt : Single);cdecl;
  procedure MoveDown(dt : Single);cdecl;
  procedure MoveLeft(dt : Single);cdecl;
  procedure MoveRight(dt : Single);cdecl;
  procedure CreateBomb(dt : Single; nNetID : Integer);cdecl;
  procedure CreateBombMulti(fX, fY : Single; nBombSize : Integer; fExploseTime : Single; _nNetID : Integer );
  procedure Update(dt : Single);
  procedure UpKills();
  procedure DownKills();
  procedure Dead();
  procedure UpScore();
  procedure Restore();
  procedure ChangeReverse();
  procedure ActiveKick();
  procedure DisableKick();
  procedure ActiveGrab();
  procedure ActiveJelly();
  procedure ActivePunch();
  procedure ActiveSpoog();
  procedure ActiveTrigger();

    function IsMoving():boolean;

  function CanBomb():boolean;

  property Position : Vector Read fPosition Write fPosition;
  property Direction : integer Read nDirection Write nDirection;
  property Direction2 : Integer Read nDirection2 Write nDirection2;
  property LastDirN : VectorN Read lastDir Write lastDir;

  Property LX : Single Read fLX Write fLX;
  Property LY : Single Read fLY Write fLY;
  Property CX : Single Read fCX Write fCX;
  Property CY : Single Read fCY Write fCY;

  Property Danger : Integer Read nDanger Write nDanger;
  Property DangerLeft : Integer Read nDangerLeft Write nDangerLeft;
  Property DangerRight : Integer Read nDangerRight Write nDangerRight;
  Property DangerUp : Integer Read nDangerUp Write nDangerUp;
  Property DangerDown : Integer Read nDangerDown Write nDangerDown;
  Property DangerUL : Integer Read nDangerUL Write nDangerUL;
  Property DangerUR : Integer Read nDangerUR Write nDangerUR;
  Property DangerDL : Integer Read nDangerDL Write nDangerDL;
  Property DangerDR : Integer Read nDangerDR Write nDangerDR;
  Property IATime : Single Read fIATime Write fIATime;
  Property SumDirGetDelta : Single Read fSumDirGetDelta Write fSumDirGetDelta;
  Property SumBombGetDelta : Single Read fSumBombGetDelta Write fSumBombGetDelta;
  Property SumGrabGetDelta : Single Read fSumGrabGetDelta Write fSumGrabGetDelta;
  Property SumFixGetDelta : Single Read fSumFixGetDelta Write fSumFixGetDelta;
  Property SumIgnitionGetDelta : Single Read fSumIgnitionGetDelta Write fSumIgnitionGetDelta;
  property ExploseBombTime : Single Read fBombTime Write fBombTime;

  property DiseaseNumber : integer Read nDisease Write nDisease;
  property BIndex : integer Read nIndex Write nIndex;
  property Name : string Read sName Write sName;
  property Team : integer Read nTeam Write nTeam;
  property Kills : integer Read nKills Write nKills;
  property Deaths : integer Read nDeaths Write nDeaths;
  property Score : integer Read nScore Write nScore;
  property AISkill : integer Read nAISkill;


  property BombCount : integer Read nBombCount Write nBombCount;
  property FlameSize : integer Read nFlameSize Write nFlameSize;
  property Speed : single Read fSpeed Write fSpeed;
  property Alive : boolean Read bAlive Write bAlive;
  property NoBomb : Boolean Read bNoBomb Write bNoBomb;
  property Kick : boolean Read bCanKick;
  property Punch : Boolean Read bCanPunch;
  property EjectBomb : boolean Read bEjectBomb Write bEjectBomb;
  property Reverse : Boolean Read bReverse Write bReverse;

  property CanCalculate : Boolean Read bCanCalculate Write bCanCalculate;
  property CanGoToTheRight : Boolean Read bCanGoToTheRight Write bCanGoToTheRight;
  property CanGoToTheLeft : Boolean Read bCanGoToTheLeft Write bCanGoToTheLeft;
  property CanGoToTheUp : Boolean Read bCanGoToTheUp Write bCanGoToTheUp;
  property CanGoToTheDown : Boolean Read bCanGoToTheDown Write bCanGoToTheDown;
  
  property TriggerBomb : LPBombItem Read uTriggerBomb;

  end;
  


type ArrayIndex = record
                   count : integer;
                   Tab   : array[1..8] of integer;
                  end;




type
    LPBombermanItem = ^BombermanItem;
    BombermanItem = Record
                   Count  : integer;
                   Bomberman : CBomberman;
                   Next : LPBombermanItem;
                 end;
    Function AddBomberman(aName : string; aTeam : integer; aIndex : Integer;
                           aAISkill : integer; aGrid : CGrid; aX, aY : Single):CBomberman;
    Function RemoveBombermanByIndex(i : Integer):Boolean;
    Function RemoveBombermanByCount(i : Integer):Boolean;
    Procedure FreeBomberman();overload;
    Procedure FreeBomberman(pList : LPBombermanItem);overload;
    Function GetBombermanCount():Integer;
    Function GetBombermanByCount(i : integer):Cbomberman;
    Function GetBombermanByIndex(i : integer):CBomberman;
    function GetBombermanIndexByCoo(aX, aY: integer): ArrayIndex;
    function IsBombermanAtCoo(aX,aY : integer):boolean;cdecl;
    Function CheckEndGame() : Integer;





implementation
uses uForm,uCore,uItem,uDisease,UGame,Classes,SysUtils,USetup,USuperDisease,UMulti,UBlock;





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
                           aAISkill : integer; aGrid : CGrid; aX, aY : Single):CBomberman;
var pTemp : LPBombermanItem;
begin
Inc(BombermanCount);
if pBombermanItem=NIL then
 begin
    New(pBombermanItem);
    pBombermanItem^.Count:=1;
    pBombermanItem^.Bomberman:=CBomberman.Create(aName,aTeam,aIndex,aAISkill,aGrid,aX,aY);
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
    pTemp^.Bomberman:=CBomberman.Create(aName,aTeam,aIndex,aAISkill,aGrid,aX,aY);
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

function GetBombermanIndexByCoo(aX, aY: integer): ArrayIndex;
var pTemp : LPBombermanItem;
begin
  result.Count:=0;
  if ((pBombermanItem<>Nil) AND (CheckCoordinates(aX,aY))) then
  begin
   pTemp:=pBombermanItem;
   While Not(pTemp=Nil) do
   begin
     if ((Trunc(pTemp^.Bomberman.Position.X+0.5)=aX) AND (Trunc(pTemp^.Bomberman.Position.Y+0.5)=aY)) then
     begin
       inc(result.count);
       result.tab[result.count]:=pTemp^.Bomberman.Bindex;
     end;
     pTemp:=pTemp^.Next
   end;
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
result:=(GetBombermanIndexByCoo(aX,aY).Count<>0)
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
     If c > 1 Then Result :=  0; // on renvoie 0 si le jeu n'est pas termin�
     If c = 1 Then Result :=  k; // on renvoie l'index du joueur vainqueur
     If c = 0 Then Result := -1; // on renvoie -1 s'il y a �galit�
End;




















{                                                                               }
{                             CBomberman                                        }
{                                                                               }
{*******************************************************************************}
{ Toute la gestion du deplacement des bombermans                                }
{*******************************************************************************}

function CBomberman.IsMoving():boolean;
begin
     If (GetTime() - fMoveTime < 0.2) Then IsMoving := true Else IsMoving := false;
end;

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
     If CheckCoordinates( Trunc( afX + 0.5 ), Trunc( afY + 0.5 ) )
     And ( TestGrid( Trunc( afX + 0.5 ) , Trunc( afY + 0.5 ) )
     Or TestBomb( Trunc( afX + 0.5 ), Trunc( afY + 0.5 ) )
     Or TestBonus( Trunc( afX + 0.5 ), Trunc( afY + 0.5 ) ) ) Then Begin
        fPosition.x:=afX;
        fPosition.y:=afY;
     End;
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
    if (TestBomb(aX,aY) AND bCanKick) then
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
     sData : String;
begin
    fMoveTime := GetTime();

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

  If (bMulti = True) And (nLocalIndex <> nClientIndex[0]) Then Begin
     sData := IntToStr(nIndex) + #31;
     sData := sData + FormatFloat('0.000',fPosition.x) + #31;
     sData := sData + FormatFloat('0.000',fPosition.y) + #31;
     If dy = -1 Then Begin
        Send( nLocalIndex, HEADER_MOVEUP, sData );
     End Else If dy = 1 Then Begin
        Send( nLocalIndex, HEADER_MOVEDOWN, sData );
     End Else If dx = -1 Then Begin
        Send( nLocalIndex, HEADER_MOVELEFT, sData );
     End Else If dx = 1 Then Begin
        Send( nLocalIndex, HEADER_MOVERIGHT, sData );
     End;
  End;
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
  nScore := nScore + 1;
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
Var
   sData : String;
begin
if bAlive then
 begin
  If ( bMulti = false ) Or ( nLocalIndex = nClientIndex[0] ) Then Begin
     bAlive:=False;
     Inc(nDeaths);
     fPosition.x:=0;
     fPosition.y:=0;
     If ( bMulti = true ) Then Begin
        sData := IntToStr( nIndex ) + #31;
        Send( nLocalIndex, HEADER_DEAD, sData );
     End;
  End;
  PlaySound( SOUND_DIE( Random( 2 ) + 1 ) );
 end;
end;













{*******************************************************************************}
{ Liens avec les bombes                                                         }
{*******************************************************************************}
procedure CBomberman.AddTriggerBomb();
var pPrev, pTemp : LPBombItem;
begin
  pPrev := nil;
  pTemp := uTriggerBomb;
  while pTemp<>nil do
  begin
    pPrev := pTemp;
    pTemp := pTemp^.Next;
  end;

  New(pTemp);
  if pPrev<>Nil then pPrev^.Next:=pTemp else uTriggerBomb := pTemp;
  pTemp^.Bomb:=GetBombByCount(GetBombCount());
  pTemp^.Count:=nIndex;
  pTemp^.Next:=Nil;
end;





procedure CBomberman.DelTriggerBomb();
var pTemp : LPBombItem;
begin
  pTemp:=uTriggerBomb;
  uTriggerBomb:=uTriggerBomb^.Next;
  Dispose(pTemp);
end;



procedure CBomberman.DelTriggerBombByNetID( nNetID : Integer );
var pTemp, pPrev : LPBombItem;
    bFound : Boolean;
begin
    bFound := False;
    pPrev := Nil;
    pTemp := uTriggerBomb;
    While ( pTemp <> Nil ) And ( bFound = False ) Do Begin
          If ( pTemp^.Bomb.nNetId = nNetId ) Then Begin
             If ( pPrev = Nil ) Then Begin
                  uTriggerBomb:=uTriggerBomb^.Next;
             End
             Else Begin
                  pPrev^.Next := pTemp^.Next;
             End;
             Dispose(pTemp);
             bFound := True;
          End;
          pPrev := pTemp;
          pTemp := pTemp^.Next;
    End;
end;




function CBomberman.GetTargetTriggerBomb(): CTriggerBomb;
begin
     if (uTriggerBomb = nil) then
        result := nil
     else
        result:=(uTriggerBomb^.Bomb as CTriggerBomb);
end;



procedure CBomberman.DoIgnition();
var sData : String;
begin
     if GetTargetTriggerBomb <> nil then begin
        If ( bMulti = true ) And ( nPlayerClient[nIndex] = nLocalIndex ) Then Begin
           sData := IntToStr( nIndex ) + #31;
           Send( nLocalIndex, HEADER_ACTION1, sData );
        End;
        If ( bMulti = False ) Or ( nLocalIndex = nClientIndex[0] ) Then Begin
           GetTargetTriggerBomb.Ignition();
           DelTriggerBomb();
        End;
     end;
end;

procedure CBomberman.TriggerToNormalBomb();
var aX, aY, _nNetID : integer;
begin
  if uTriggerBomb<>nil then
  begin
    while uTriggerBomb<>nil do
    begin
      aX := uTriggerBomb^.Bomb.XGrid;
      aY := uTriggerBomb^.Bomb.YGrid;
      _nNetID := uTriggerBomb^.Bomb.nNetID;
      uGrid.DelBlock(aX,aY);                                                    // pas necessaire mais plus propre
      RemoveThisBomb(uTriggerBomb^.Bomb);
      uTriggerBomb^.Bomb.Destroy();

      AddBomb(aX,aY,nIndex,nFlameSize,fBombTime,false,false,uGrid,@UpBombCount,@IsBombermanAtCoo, _nNetID, True);
      DelTriggerBomb();
    end;//while
  end;//if uTriggerBomb
end;





function CBomberman.CanBomb():boolean;
begin
 result := ((nBombCount<>0) And Not(NoBomb));
end;



procedure CBomberman.UpBombCount(); cdecl;
begin
  nBombCount +=1;
end;







procedure CBomberman.CreateBomb(dt : Single; nNetID : Integer); cdecl;
var aX, aY, dX, dY : integer;
    bTrigger, Stop : boolean;
begin
  if bAlive then
  begin
    if CanBomb  then
    begin
      if uGrid.GetBlock(Trunc(fPosition.x+0.5),Trunc(fPosition.y+0.5))=Nil then
      begin
        PlaySound( SOUND_DROP( Random(3) + 1 ) );
        bTrigger := nTriggerBomb>0;
        AddBomb(fPosition.x+0.5,fPosition.y+0.5,nIndex,nFlameSize,fBombTime,bJelly,bTrigger,uGrid,@UpBombCount,@IsBombermanAtCoo, nNetID, False);
        Dec(nBombCount);
        if bTrigger then
        begin
          AddTriggerBomb();
          Dec(nTriggerBomb);
        end;
      end
      else if bCanSpoog then
      begin
          PlaySound( SOUND_DROP( Random(3) + 1 ) );
          //creation en ligne de bombes
          dX := 0;
          dY := 0;
          aX := Trunc(fPosition.x+0.5);
          aY := Trunc(fPosition.y+0.5);
          Stop := false;
          case nDirection of
              0    : begin  //bas
                       dY := 1;
                     end;
              90   : begin  //gauche
                       dX := -1;
                     end;
              180 : begin  //haut
                       dY := -1;
                     end;
              -90  : begin  //droite
                       dX := 1;
                     end;
          end;
          While (nBombCount<>0) and Not(Stop) do begin
            aX := aX + dX;
            aY := aY + dY;
            if Not(CheckCoordinates(aX,aY)) then
            begin
              Stop := True;
            end
            else
            begin
              if Not(uGrid.GetBlock(aX,aY)=nil) or IsBombermanAtCoo(aX,aY) then
              begin
                stop := true;
              end
              else
              begin
                  bTrigger := nTriggerBomb>0;
                  AddBomb(aX,aY,nIndex,nFlameSize,fBombTime,bJelly,bTrigger,uGrid,@UpBombCount,@IsBombermanAtCoo, Random(1000000), False);
                  Dec(nBombCount);
                  if bTrigger then
                  begin
                    AddTriggerBomb();
                    Dec(nTriggerBomb);
                  end;
              end;
            end;
          end;
      end;
    end;
  end;
end;


procedure CBomberman.CreateBombMulti(fX, fY : Single; nBombSize : Integer; fExploseTime : Single; _nNetID : Integer );
Var bTrigger : Boolean;
Begin
     bTrigger := nTriggerBomb > 0;
     AddBombMulti(fX,fY,nIndex,nBombSize,fExploseTime,bJelly,bTrigger,uGrid,@UpBombCount,@IsBombermanAtCoo,_nNetID,True);
     Dec(nBombCount);
     if bTrigger then
     begin
          AddTriggerBomb();
          Dec(nTriggerBomb);
     end;
     PlaySound( SOUND_DROP( Random(3) + 1 ) );
End;






procedure CBomberman.MoveBomb(_X,_Y,aX,aY,dX,dY : integer; dt : Single);
var _Bomb : CBomb;
    sData : String;
begin
  if ((_X=aX) or (_Y=aY)) then
  begin
    If ( (bMulti = false) Or (nLocalIndex = nClientIndex[0]) ) Then Begin
       _Bomb:=GetBombByGridCoo(aX,aY);
       If Not( _Bomb = nil ) Then Begin
          If dX = 1 Then _Bomb.MoveRight(dt)
          Else If dX = -1 Then _Bomb.MoveLeft(dt)
          Else If dY = 1 Then _Bomb.MoveDown(dt)
          Else If dY = -1 Then _Bomb.MoveUp(dt);
          PlaySound( SOUND_KICK( Random(4) + 1 ) );
          If bMulti = True Then Send( nLocalIndex, HEADER_PUNCH, '' );
       End;
    End
    Else Begin
       sData := IntToStr( nIndex ) + #31;
       sData := sData + IntToStr( aX ) + #31;
       sData := sData + IntToStr( aY ) + #31;
       sData := sData + IntToStr( dX ) + #31;
       sData := sData + IntToStr( dY ) + #31;
       sData := sData + FormatFloat('0.0000', dt ) + #31;
       Send( nLocalIndex, HEADER_MOVEBOMB, sData );
    End;
  End;
end;









function CBomberman.GrabBomb():boolean;
var dX, dY : integer;
    sData : String;
    bResult : Boolean;
begin
    bResult := ( uGrabbedBomb = Nil );
    dX := Trunc(fPosition.x+0.5);
    dY := Trunc(fPosition.y+0.5);
    if CheckCoordinates(dX,dY) then Begin
        if ((uGrid.GetBlock(dX,dY)<>nil) AND (uGrid.GetBlock(dX,dY) is CBomb)) then
        begin
             bResult := False;
             If ( bMulti = False ) Or ( nLocalIndex = nClientIndex[0] ) Then Begin
                GrabBombMulti( dX, dY );
                bResult := ( uGrabbedBomb = Nil );
                If ( bMulti = True ) Then Begin
                   sData := IntToStr( nIndex ) + #31;
                   sData := sData + IntToStr( dX ) + #31;
                   sData := sData + IntToStr( dY ) + #31;
                   Send( nLocalIndex, HEADER_GRAB_CLIENT, sData );
                End;
             End;
             If ( bMulti = True ) And ( nLocalIndex <> nClientIndex[0] ) Then Begin
                  bGrabbed := True;
                  sData := IntToStr( nIndex ) + #31;
                  sData := sData + IntToStr( dX ) + #31;
                  sData := sData + IntToStr( dY ) + #31;
                  Send( nLocalIndex, HEADER_GRAB_SERVER, sData );
             End;
        end;
    End;
    result := bResult;
end;


procedure CBomberman.GrabBombMulti( dX, dY : Integer );
Begin
     uGrabbedBomb:=CBomb(uGrid.GetBlock(dX,dY));
     uGrid.DelBlock(dX,dY);
     uGrabbedBomb.StopTime();
     uGrabbedBomb.Position.z:=0.85;
     PlaySound( SOUND_GRAB( Random(2) + 1 ) );
End;









procedure CBomberman.DropBomb(dt : Single);
Var sData : String;
begin
  if (uGrabbedBomb<>nil) Or (bGrabbed = True) then
  begin
       If ( bMulti = false ) Or ( nLocalIndex = nClientIndex[0] ) Then Begin
          DropBombMulti( dt );
          If ( bMulti = True ) Then Begin
             sData := IntToStr( nIndex ) + #31;
             sData := sData + FormatFloat( '0.000', fPosition.x ) + #31;
             sData := sData + FormatFloat( '0.0000', fPosition.y )+ #31;
             Send( nLocalIndex, HEADER_DROP_CLIENT, sData );
          End;
       End
       Else Begin
            bGrabbed := False;
            sData := IntToStr( nIndex ) + #31;
            sData := sData + FormatFloat( '0.0000', dt ) + #31;
            Send( nLocalIndex, HEADER_DROP_SERVER, sData );
       End;
  end;
end;



procedure CBomberman.DropBombMulti(dt : Single);
begin
  if uGrabbedBomb<>nil then
  begin
       uGrabbedBomb.Position.x:=fPosition.x;
       uGrabbedBomb.Position.y:=fPosition.y;
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
       PlaySound( SOUND_THROW( Random(4) + 1 ) );
  end;
end;







procedure CBomberman.PunchBomb(dt: Single);
var dX, dY : integer;
    delta : single;
    sData : String;
begin
  delta := 0.5;
  dX := Trunc(fPosition.x);
  dY := Trunc(fPosition.y);

  case nDirection of
    0    : begin  //bas
             dY := Trunc(fPosition.y)+1;
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
       If ( (bMulti = false) Or (nLocalIndex = nClientIndex[0]) ) Then Begin
          case nDirection of
            0    :  CBomb(uGrid.GetBlock(dX,dY)).Punch(DOWN,dt);
            90   :  CBomb(uGrid.GetBlock(dX,dY)).Punch(LEFT,dt);
            180  :  CBomb(uGrid.GetBlock(dX,dY)).Punch(UP,dt);
            -90  :  CBomb(uGrid.GetBlock(dX,dY)).Punch(RIGHT,dt);
          end;
          PlaySound( SOUND_KICK( Random(4) + 1 ) );
          If bMulti = True Then Send( nLocalIndex, HEADER_PUNCH, '' );
       End
       Else Begin
             sData := sData + IntToStr( nIndex ) + #31;
             sData := sData + IntToStr( nDirection ) + #31;
             sData := sData + IntToStr( dX ) + #31;
             sData := sData + IntToStr( dY ) + #31;
             sData := sData + FormatFloat('0.0000', dt ) + #31;
             Send( nLocalIndex, HEADER_PUNCH, sData );
       End;
  end;
end;





















{*******************************************************************************}
{ Creation et restauration                                                      }
{*******************************************************************************}
constructor CBomberman.Create(aName: string; aTeam: integer; aIndex : Integer;
                               aAISkill : integer; aGrid : CGrid; aX, aY : Single);
begin
  sName              := aName;
  nAISkill           := aAISkill;
  nTeam              := aTeam;
  nIndex             := aIndex;
  fOrigin.x          := aX;
  fOrigin.y          := aY;
  fOrigin.z          := 0;
  uGrid              := aGrid;
  nKills             := 0;
  nDeaths            := 0;
  nScore             := 0;
  lastDir.z          := 0;
  bGrabbed           := False;
  fCX                := aX;
  fCY                := aY;
  fSumDirGetDelta    := 0.125;
  fSumBombGetDelta   := 2 + Random * 2;
  fSumIgnitionGetDelta:=0;
  uGrabbedBomb       := Nil;
end;






procedure CBomberman.Restore();
begin
  bAlive             := True;
  fPosition          := fOrigin;
  bCanSpoog          := False;
  bCanPunch          := False;
  bJelly             := False;
  bCanGrabBomb       := False;
  bCanKick           := False;
  bPrimaryPressed    := False;
  bSecondaryPressed  := False;
  bEjectBomb         := False;
  bNoBomb            := False;
  bReverse           := False;
  bGrabbed           := False;
  nDisease           := DISEASE_NONE;
  nTriggerBomb       := 0;
  nBombCount         := DEFAULTBOMBCOUNT;
  fBombTime          := BOMBTIME;
  nFlameSize         := DEFAULTFLAMESIZE;
  fSpeed             := DEFAULTSPEED;
  nDirection         := 0;
  lastDir.x          := 0;
  lastDir.y          := 0;
  fSumDirGetDelta    := 0.125;
  fSumBombGetDelta   := 2 + Random * 2;
  fSumGrabGetDelta   := 0;
  fSumFixGetDelta    := 0;
  fSumIgnitionGetDelta:=0;
  uTriggerBomb       := nil;
  uGrabbedBomb       := nil;
end;















{*******************************************************************************}
{ Update                                                                        }
{*******************************************************************************}
procedure CBomberman.Update(dt : Single);
begin
  CheckBonus;
  if nDisease<>0 then begin
     ContaminateBomberman();
     If ( GetTime > fDiseaseTime ) Then Begin
        PlaySound( SOUND_DISEASE( Random( 8 ) + 1 ) );
        fDiseaseTime := GetTime + 1 + Random( 200 ) / 100;
     End;
  end;
  If ( GetTime > fSpeechTime ) Then Begin
    PlaySound( SOUND_SPEECH( Random( 87 ) + 1 ) );
    fSpeechTime := GetTime + 2 + Random( 500 ) / 100;
  End;
  if (bEjectBomb) And ((bMulti = False) Or (nLocalIndex = nClientIndex[0])) then
     CreateBomb(dt, Random(1000000000));
  if (uGrabbedBomb<>nil) then
  begin
    uGrabbedBomb.Position.x:=fPosition.x-0.1;
    uGrabbedBomb.Position.y:=fPosition.y-0.1;
  end;

  If (bMulti = True) And (nLocalIndex <> nClientIndex[0])
  And (nPlayerClient[nIndex] <> nLocalIndex)  And ((GetTime - fInterpolationTime) < 0.5) Then Begin
     fMoveTime := GetTime();
     Case nDirection Of
            0:DoMove(fPosition.x, fPosition.y + fSpeed*dt);
           90:DoMove(fPosition.x - fSpeed*dt, fPosition.y);
          180:DoMove(fPosition.x, fPosition.y - fSpeed*dt);
          -90:DoMove(fPosition.x + fSpeed*dt, fPosition.y);
     End;
  End;
end;













{*******************************************************************************}
{ Gestion des bonus                                                             }
{*******************************************************************************}
procedure CBomberman.CheckBonus();
var oldX, oldY : integer;
    mDirection, k : Integer;
    aDisease : CDisease;
    sData : String;
    pBomberman : CBomberman;
begin
  if (Trunc(fPosition.x+0.5) in [1..GRIDWIDTH]) And (Trunc(fPosition.y+0.5) in [1..GRIDHEIGHT])
  And Not(uGrid.getBlock(Trunc(fPosition.x+0.5),Trunc(fPosition.y+0.5))=Nil) then
    if (uGrid.getBlock(Trunc(fPosition.x+0.5),Trunc(fPosition.y+0.5)) is CItem) then
      begin
         PlaySound( SOUND_BONUS( Random(4) + 1 ) );
         oldX:=Trunc(fPosition.x+0.5);                                                   //a cause de la maladie SWITCH il faut se souvenir de ou il etait
         oldY:=Trunc(fPosition.y+0.5);
         If ( bMulti = True ) And ( nLocalIndex = nClientIndex[0] ) Then Begin
            sData := '';
            For k := 1 To 8 Do Begin
              pBomberman := GetBombermanByIndex( k );
              If pBomberman <> Nil Then Begin
                 sData := sData + FormatFloat('0.000',pBomberman.Position.x) + #31;
                 sData := sData + FormatFloat('0.000',pBomberman.Position.y) + #31;
                 //sData := sData + IntToStr(pBomberman.LastDirN.x) + #31;
                 //sData := sData + IntToStr(pBomberman.LastDirN.y) + #31;
                 If (pBomberman.Direction = 0) Then nDirection := 0
                 Else If (pBomberman.Direction = 90) Then nDirection := 1
                 Else If (pBomberman.Direction = 180) Then nDirection := 2
                 Else If (pBomberman.Direction = -90) Then nDirection := 3
                 Else nDirection := 4;
                 If pBomberman.IsMoving() Then nDirection += 5;
                 sData := sData + IntToStr(nDirection) + #31;
              End;
            End;
            Send( nLocalIndex, HEADER_BOMBERMAN, sData );
         End;
         If ( bMulti = True ) And ( nLocalIndex <> nClientIndex[0] )
         And ( nPlayerClient[ nIndex ] = nLocalIndex ) Then Begin
            sData := IntToStr( nIndex ) + #31;
            sData := sData + FormatFloat('0.000',Position.x) + #31;
            sData := sData + FormatFloat('0.000',Position.y) + #31;
            sData := sData + IntToStr(LastDirN.x) + #31;
            sData := sData + IntToStr(LastDirN.y) + #31;
            If (Direction = 0) Then mDirection := 0
            Else If (Direction = 90) Then mDirection := 1
            Else If (Direction = 180) Then mDirection := 2
            Else If (Direction = -90) Then mDirection := 3
            Else mDirection := -1;
            sData := sData + IntToStr(mDirection) + #31;
            Send( nLocalIndex, HEADER_CHECK_BONUS, sData );
         End;
         If ( bMulti = false ) Or Not ( ( uGrid.GetBlock(oldX,oldY) is CDisease )
         Or ( uGrid.GetBlock(oldX, oldY ) is CSuperDisease ) ) Then
            CItem(uGrid.getBlock(oldX,oldY)).Bonus(Self)
         Else Begin
              If ( uGrid.GetBlock(oldX,oldY) is CDisease ) Then Begin
                 SetString( STRING_NOTIFICATION, Name + ' has picked up a disease.', 0.0, 0.2, 5 );
                 If ( DiseaseNumber = 0 )
                 Or ( numDisease[Trunc(Position.X + 0.5), Trunc(Position.Y + 0.5)] = DISEASE_SWITCH ) Then Begin
                      aDisease := CDisease.Create(0,0);
                      aDisease.BonusForced(Self,numDisease[Trunc(Position.X + 0.5), Trunc(Position.Y + 0.5)]);
                 End;
              End;
              If ( uGrid.GetBlock(oldX,oldY) is CSuperDisease ) Then Begin
                 SetString( STRING_NOTIFICATION, Name + ' has picked up a super disease.', 0.0, 0.2, 5 );
                 aDisease := CDisease.Create(0,0);
                 aDisease.BonusForced(Self,numDisease[Trunc(Position.X + 0.5), Trunc(Position.Y + 0.5)] mod 100);
                 aDisease := CDisease.Create(0,0);
                 aDisease.BonusForced(Self,( numDisease[Trunc(Position.X + 0.5), Trunc(Position.Y + 0.5)] mod 10000 ) div 100);
                 aDisease := CDisease.Create(0,0);
                 aDisease.BonusForced(Self,numDisease[Trunc(Position.X + 0.5), Trunc(Position.Y + 0.5)] div 10000);
              End;
         End;
         uGrid.DelBlock(oldX,oldY);
      end;
end;





procedure CBomberman.ContaminateBomberman();
var aArrayVictim : ArrayIndex;
    aVictim : CBomberman;
    aDisease : CDisease;
    index : integer;
    sData : String;
begin
     If ( bMulti = False ) Or ( nLocalIndex = nClientIndex[0] ) Then Begin
         aArrayVictim := GetBombermanIndexByCoo(Trunc(fPosition.x+0.5),Trunc(fPosition.y+0.5));
         if Not(aArrayVictim.Count<=1) then
         for index:=Low(aArrayVictim.tab) to aArrayVictim.Count do
         if aArrayVictim.tab[index]<>nIndex then
         begin
           aVictim:=GetBombermanByIndex(aArrayVictim.Tab[index]);
           if (aVictim.DiseaseNumber=0) then
           begin
             SetString( STRING_NOTIFICATION, aVictim.Name + ' has been stephaned by ' + sName, 0.0, 0.2, 5 );
             aDisease:=CDisease.Create(1,1);
             aDisease.BonusForced(aVictim,nDisease);
             If ( bMulti = True )  Then Begin
                 sData := IntToStr( nIndex ) + #31;
                 sData := sData + IntToStr( aVictim.nIndex ) + #31;
                 Send( nLocalIndex, HEADER_CONTAMINATE, sData );
             End;
           end;
         end;
     End;
end;








procedure CBomberman.ChangeReverse();
begin
  bReverse:=Not(bReverse);
end;




procedure CBomberman.ActiveKick();
begin
  bCanKick := true;
  //if bCanPunch reapparition de la caisse ?
  bCanPunch       := false;
end;

procedure CBomberman.DisableKick();
begin
  bCanKick := false;
end;

procedure CBomberman.ActiveGrab();
begin
  bCanGrabBomb := true;
  //if bCanSpoog reapparition de la caisse ?
  bCanSpoog := false;
end;

procedure CBomberman.ActiveJelly();
begin
  bJelly := true;
  nTriggerBomb := 0;
  TriggerToNormalBomb();
end;

procedure CBomberman.ActivePunch();
begin
  bCanPunch := true;
  bCanKick := false;
  TriggerToNormalBomb();
end;

procedure CBomberman.ActiveSpoog();
begin
  bCanSpoog := true;
  if Not(uGrabbedBomb=nil) then DropBomb(0);
  bCanGrabBomb := false;
end;

procedure CBomberman.ActiveTrigger();
begin
  bJelly := false;
  bCanPunch := false;
  nTriggerBomb += 3;
end;














{*******************************************************************************}
{ Gestion des touches d'actions                                                 }
{*******************************************************************************}
procedure CBomberman.PrimaryKeyDown(dt: Single); cdecl;
begin
 if bAlive then
 begin
  if (uGrabbedBomb=Nil) and Not(bGrabbed) and Not(bPrimaryPressed) then
  begin
    If bCanGrabBomb Then Begin
       If GrabBomb() Then Begin
          CreateBomb(dt, Random(1000000000));
       End;
    End
    Else Begin
         If (uGrabbedBomb=Nil) and Not(bGrabbed) Then Begin
            CreateBomb(dt, Random(1000000000));
         End;
    End;
  end;
  
  bPrimaryPressed := true;
 end;
end;

procedure CBomberman.SecondaryKeyDown(dt: single); cdecl;
begin
  if bAlive then
  begin
    if Not(bSecondaryPressed) then
    begin
      if bCanPunch then PunchBomb(dt);
      if uTriggerBomb<>nil then DoIgnition();
    end;
    bSecondaryPressed := true;
  end;
end;

procedure CBomberman.PrimaryKeyUp(dt: Single); cdecl;
begin
  if bAlive then
  begin
    bPrimaryPressed := false;
    if (uGrabbedBomb<>Nil) Or (bGrabbed = True) then DropBomb(dt);                  // si on appuie plus mais qu'on a une bombe on la jete
  end;
end;

procedure CBomberman.SecondaryKeyUp(dt: Single); cdecl;
begin
  if bAlive then
  begin
    bSecondaryPressed := false;
  end;
end;


end.
