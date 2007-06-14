Unit UBomb;

{$mode objfpc}{$H+}

Interface

Uses Classes, SysUtils, UGrid, UBlock, UUtils, uCore;

Type LPUpCount = procedure() of Object ;cdecl;
Type LPGetBomberman = function(aX,aY : integer):boolean;cdecl;
  
Type

{ CBomb }

CBomb = Class(CBlock)
     Private
       bMoving : Boolean;           //defini si la bombe est en cours de mouvement ou non
       uGrid       : CGrid;
       nIndex,                      // definit le joueur qui a pose la bombe
       nMoveDir,                    // direction de mouvement de la bombe
       nBombSize : integer;         // portee de la flamme de la bombe
       fX,                          // Coordonnees reelles de la bombe
       fY,
       ftime : Single;
       pUpCount : LPUpcount;        //pointe sur la fonction du bomberman qui a pose la bombe pour lui augmenter son score
       pIsBomberman : LPGetBomberman;  //pointe sur la fonction pour savoir s'il y a un bomberman en tel position

       procedure Move(dt : single);

     Public
       Constructor create(aX, aY : Single; aIndex, aBombSize : integer; aGrid : CGrid; UpCount : LPUpCount; IsBomberman : LPGetBomberman);Overload;     // permet de creer une bombe a partir de coordonnees et du bomberman qui la pose
       Destructor Destroy();Override;
       function UpdateBomb(dt : Single):boolean;
       Procedure Explose();Override;                                 // fait exploser la bombe
       procedure MoveRight(dt : Single);
       procedure MoveDown(dt : Single);
       procedure MoveLeft(dt : Single);
       procedure MoveUp(dt : Single);

       property CanExplose : boolean Read bExplosive;
       property X : Single Read fX;
       property Y : Single Read fY;
       property Time : Single Read fTime;

end;


Type LPBombItem = ^BombItem;
     BombItem = record
              Count : integer;
              Bomb : CBomb;
              Next : LPBombItem;
              end;

    
    function AddBomb(aX, aY : Single; aIndex, aBombSize : integer; aGrid : CGrid; UpCount : LPUpCount; IsBomberman : LPGetBomberman):Boolean;
    procedure RemoveBombByCount(i : integer);
    procedure RemoveBombByGridCoo(aX,aY : integer);
    procedure FreeBomb();overload;
    procedure FreeBomb(pList : LPBombItem);overload;
    function GetBombCount():integer;
    function GetBombByCount(i : integer):CBomb;
    function GetBombByGridCoo(aX,aY : integer):CBomb;


implementation
uses UItem;

var pBombItem : LPBombItem = NIL;
    BombCount : integer = 0;

Procedure UpdateCountList(i : integer);
var Count : integer;
    pTemp : LPBombItem;
begin
 Count:=1;
  pTemp:=pBombItem;
  While (Count<=BombCount) do
  begin
   if (Count>=i) then pTemp^.Count:=Count;
   Inc(Count);
   pTemp:=pTemp^.Next;
  end;
end;

function AddBomb(aX, aY: Single; aIndex, aBombSize : integer; aGrid: CGrid; UpCount : LPUpCount; IsBomberman : LPGetBomberman): boolean;
var pTemp : LPBombItem;
begin
result:=false;
if (aGrid.GetBlock(Trunc(aX),Trunc(aY))=Nil) then
begin
 Inc(BombCount);
 if (pBombItem=Nil) then
 begin
   New(pBombItem);
   pBombItem^.Next:=Nil;
   pBombItem^.Bomb:=CBomb.Create(aX,aY,aIndex,aBombSize,aGrid,UpCount,IsBomberman);
   pBombItem^.Count:=BombCount;
   result:=true;
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
 pTemp^.Bomb:=CBomb.Create(aX,aY,aIndex,aBombSize,aGrid,UpCount,IsBomberman);
 result:=true;
end;
end;
end;

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
   UpdateCountList(i);
  end;
end;
end;

procedure RemoveBombByGridCoo(aX,aY : integer);
var pTemp,pPrev : LPBombItem;
    Find, Last : Boolean;
    i : integer;
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
   i:=pTemp^.Count;
   Dec(BombCount);
   Dispose(pTemp);
   UpdateCountList(i);
  end;
end;
end;

procedure RemoveThisBomb(bomb: CBomb);
var Find : boolean;
    pTemp, pPrev : LPBombItem;
    Count : integer;
begin
Find:=False;
pPrev:=Nil;
  if pBombItem<>Nil then
  begin
    pTemp:=pBombItem;
    Find:=(pTemp^.Bomb=Bomb);

    While Not(Find) do
    begin
      pPrev:=pTemp;
      pTemp:=pTemp^.Next;
      Find:=(pTemp^.Bomb=Bomb);
    end;
    
    if pPrev<>nil then pPrev^.Next:=pTemp^.Next else pBombItem:=pTemp^.Next;
    Count:=pTemp^.Count;
    Dispose(pTemp);
    Dec(BombCount);
    UpdateCountList(Count);
  end;
end;

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

{ CBomb }
const NONE  = 0;
      UP    = 1;
      DOWN  = 2;
      RIGHT = 3;
      LEFT  = 4;

procedure CBomb.Move(dt : single);

   function ChangeCase(aX,aY : integer):boolean;
   {True = je change de case}
   begin
     result:=Not((aX=nX) AND (aY=nY));
   end;
   
   function TestGrid(aX,aY : integer):boolean;
   {True = je peux passer, il n'y a rien}
   begin
     result:=uGrid.GetBlock(aX,aY)=Nil;
   end;
   
   function TestBomberman(aX,aY : integer):boolean;
   {True = il y a un bomberman}
   begin
     result:=pIsBomberman(aX,aY);
   end;
   
   function TestBonus(aX,aY : integer):boolean;
   {True = je peux passer c'est un bonus}
   begin
     result:=False;
     if (uGrid.GetBlock(aX,aY) is CItem) then
      result:=((uGrid.GetBlock(aX,aY) as CItem).IsExplosed());
   end;

   procedure DoMove(afX, afY : Single;aX,aY : integer);
   begin
     uGrid.DelBlock(nX,nY);
     nX:=aX;
     nY:=aY;
     fX:=afX;
     fY:=afY;
     uGrid.AddBlock(nX,nY,Self);
   end;

var
   afX, afY : Single;
   dX, dY : Integer;
   aX, aY : integer;
   _X, _Y : integer;
   bCanMove : Boolean;
begin
{On détermine d'abord la direction du mouvement}
dX:=0;
dY:=0;
case nMoveDir of
   UP : dY:=-1;
   DOWN : dY:=1;
   RIGHT : dX:=1;
   LEFT :  dX:=-1;
end;

{On repere ensuite les coordonnees ou doit aller la bombe}
afX:=fX+dX*BOMBMOVESPEED*dt;
afY:=fY+dY*BOMBMOVESPEED*dt;
_X:=Trunc(afX);
_Y:=Trunc(afY);
aX:=_X;
aY:=_Y;

  if nMoveDir=RIGHT then aX:=aX+1
  else if nMoveDir=DOWN then aY:=aY+1;
{On verifie avant tout qu'on est toujours dans la grille,}
{en commencant par traiter le cas ou on est dehors }
if Not(CheckCoordinates(aX,aY)) then
begin
  {Si on sort c'est que c'est fini ca sert a rien de vouloir bouger}
  bMoving:=False;
 { Par Contre si on bougeait vers la droite ou vers le bas, il faut forcer le dernier deplacement         }
 { En effet avec un deplacement dans ces directions, mes reperes se font avec le bord inferieur droit,    }
 { ainsi que tous les tests. Donc si on est dehors, la relle coordonne (haut a gauche) ne l'est pas       }
 { On force donc son dernier mouvement                                                                    }
  if ((nMoveDir=RIGHT) or (nMoveDir=DOWN)) then DoMove(_X,_Y,_X,_Y);

end
else
begin

  bCanMove:=(TestGrid(aX,aY) or Not(ChangeCase(aX,aY)) ) AND Not(TestBomberman(aX,aY));
  
  {Si on peut se deplacer on fait le deplacement sans chercher a comprendre}
  if bCanMove then
  begin
   DoMove(afX,afY,_X,_Y);
  end
  
  {Sinon il faut voir si ce qui nous bloque ne peut pas etre franchi}
  else
  begin
   {Si c'est un bomberman, on s'arrete}
   {Par contre meme remarque que tout a l'heure si mouvement a droite ou gauche}
    if TestBomberman(aX,aY) then
    begin
      bMoving:=False;
      if ((nMoveDir=RIGHT) or (nMoveDir=DOWN)) then DoMove(_X,_Y,_X,_Y);
    end
   {Sinon c'est que c'est un objet sur la grille qui nous bloque}
    else
    begin
     {Premier cas : un bonus on peut passer dessus apres l'avoir detruit}
      if TestBonus(aX,aY) then
      begin
        uGrid.GetBlock(aX,aY).Explose();
        uGrid.DelBlock(aX,aY);
        DoMove(afX,afY,_X,_Y);
      end
     {Deuxieme Cas : Bombe ou mur : on s'arrete}
      else
      begin
        bMoving:=False;
        if ((nMoveDir=RIGHT) or (nMoveDir=DOWN)) then DoMove(_X,_Y,_X,_Y);
      end;
    end;
  end;
end;
end;

constructor CBomb.create(aX, aY : Single; aIndex,aBombSize : integer; aGrid : CGrid; UpCount : LPUpCount; IsBomberman : LPGetBomberman);
begin
   pUpCount:=UpCount;
   pIsBomberman:=IsBomberman;
   bExplosive := true;          //une bombe peut exploser
   bMoving:=False;
   nMoveDir:=NONE;
   uGrid := aGrid;
   nIndex := aIndex;
   nBombSize := aBombSize;                     // la taille des flammes de la bombe est celle de la portee des flammes du joueur qui la cree
   nX := Trunc(aX);                            // abscisse de la bombe dans la grille
   nY := Trunc(aY);                            // ordonnee de la bombe dans la grille
   fX:=nX;                                    //abscisse ordonnee reelles
   fY:=nY;
   ftime:=0;
   uGrid.AddBlock(nX,nY,Self);                 //avec ca on peut prevoir un mouvement de la bombe (shoot)
end;

Procedure CBomb.Explose();
           Procedure CreateFlame(dx, dy : integer);
           var Stop : boolean;
               Size : integer;
               tempBlock : CBlock;
           begin
             Size := 1;
             Stop := False;
             While (Not(Stop) And (Size<nBombSize)) do
             begin
             if CheckCoordinates(nX+Size*dx,nY+Size*dy) then
             begin
                 tempBlock:=uGrid.GetBlock(nX+Size*dx,nY+Size*dy);
               if tempBlock<>nil then //si y'a quelque chose ... on le detruit
               begin
                 Stop:=True;
                 if (tempBlock is CBomb) then
                          begin
                           if (CBomb(tempBlock).CanExplose) then  CBomb(tempBlock).Explose;      //si c'est une bombe on la fait exploser
                          end
                 else if (tempBlock is CItem) then
                          begin
                          if CItem(tempBlock).IsExplosed()then uGrid.delBlock(nX+Size*dx,nY+Size*dy);
                           CItem(tempBlock).Explose;                                    //si c'est un bonus on fait exploser
                          end
                 else if (tempBlock is CBlock) then
                          begin
                           if (tempBlock.IsExplosive()) then
                            begin
                             (tempBlock.Explose());
                             uGrid.DelBlock(nX+Size*dx,nY+Size*dy);
                            end;
                  end;                                       //Sinon c'est que c'est un mur ... ca pete pas ...
               end
               else    //Sinon on cree une nouvelle flame a la bonne place ...
               begin
                 uGrid.CreateFlame(nX+Size*dx,nY+Size*dy,nIndex);
                 Size +=1;
               end;
             end
             else Stop:=True;// si les coordonnees ne sont pas bonnes => Stop
             end;   //fin de la boucle while
           end;
var k : integer;
begin
  k := Round(Random(2));
  PlaySound( SOUND_BOMB(k) );
  RemoveThisBomb(Self);  //On supprime la bombe de la liste
  bExplosive:=False;    //elle pete elle peut plus exploser ... pour eviter qu'une bombe fasse sauter une bombe et celle ci fasse resaute la meme qu au debut ...
  CreateFlame(1,0);     //gauche
  CreateFlame(-1,0);    //droite
  CreateFlame(0,1);     //haut
  CreateFlame(0,-1);    //bas
  pUpCount;
  uGrid.DelBlock(nX,nY);     //mise a nil de la case 
  uGrid.CreateFlame(nX,nY,nIndex);   //histoire de remplacer la bombe par une flame
  Destroy;
end;

destructor CBomb.Destroy();
begin
  inherited;
end;

function CBomb.UpdateBomb(dt : Single):boolean;
begin
ftime += dt;
if bMoving then Move(dt);   // fait bouger la bombe si elle le doit
result:=(ftime >= BOMBTIME);
if result then Explose;
end;

procedure CBomb.MoveRight(dt : Single);
begin
bMoving:=True;
nMoveDir:=RIGHT;
Move(dt);
end;

procedure CBomb.MoveDown(dt : Single);
begin
bMoving:=True;
nMoveDir:=DOWN;
Move(dt);
end;

procedure CBomb.MoveLeft(dt : Single);
begin
bMoving:=True;
nMoveDir:=LEFT;
Move(dt);
end;

procedure CBomb.MoveUp(dt : Single);
begin
bMoving:=True;
nMoveDir:=UP;
Move(dt);
end;

end.

