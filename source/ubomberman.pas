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
    //Visible uniquement dans cette unite
    { private declarations }
    fXOrigin,                //Position lors de la creation du bomberman
    fYOrigin,
    fX,
    fY,                      //Position Graphique bomberman
    fSpeed    : Single;      //Vitesse du bomberman



    sName     : string;       //nom du joueur

    nIndex,                   //numero du bomberman
    nTeam,                    //numero de team
    nKills,                   //nombre de bomberman tue
    nDeaths,                  //nombre de fois tue
    nScore,                   //Score
    nBombCount,               //Nombre de bombes dispo
    nFlameSize,               //Taille de la flamme
    nDirection  : integer;    //Derniere direction de mouvement du bomberman

    bNoBomb  : Boolean;       //Permet de savoir si on peut poser une bombe ou pas indifferemment du nombre en stock (= maladie)
             //true = je suis malade => je peux pas poser
             //false = je suis pas malade => je peux poser si j'en ai assez en stock
    bReverse : Boolean;       //touche inverse
    bAlive    : Boolean;      //Personnage en vie ou non
    bKick     : Boolean;      //Shoot dans une bombe possible ou non
    uGrid     : CGrid;        //Pointe sur la grille de jeu
    
    procedure ChangeScore();
    procedure Move(dx, dy : integer; dt : single);
    procedure UpBombCount(); cdecl;
    procedure CheckBonus();
  protected
    //Visible par les descendants
    { protected declarations }
  public
    { public declarations }
  Constructor Create(aName : string; aTeam : integer; aIndex : Integer;
                           aGrid : CGrid; aX, aY : Single);
  procedure MoveUp(dt : Single);cdecl;
  procedure MoveDown(dt : Single);cdecl;
  procedure MoveLeft(dt : Single);cdecl;
  procedure MoveRight(dt : Single);cdecl;
  procedure CreateBomb(dt : Single);cdecl;
  //procedure SpaceKey(dt : single);cdecl;
  procedure UpKills();
  procedure Dead();
  procedure Restore();
  procedure ChangeReverse();

  function CanBomb():boolean;

  property X : single Read fX Write fX;
  property Y : single Read fY Write fY;
  property Direction : integer Read nDirection;

  property BIndex : integer Read nIndex Write nIndex;
  property Name : string Read sName Write sName;
  property Team : integer Read nTeam Write nTeam;
  property Kills : integer Read nKills Write nKills;
  property Deaths : integer Read nDeaths Write nDeaths;
  property Score : integer Read nScore;
  
  property BombCount : integer Read nBombCount Write nBombCount;
  property FlameSize : integer Read nFlameSize Write nFlameSize;
  property Speed : single Read fSpeed Write fSpeed;
  property Alive : boolean Read bAlive;
  property NoBomb : Boolean Read bNoBomb Write bNoBomb;
  property Kick : boolean Read bKick Write bKick;

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
    Function CheckEndGame():boolean;

implementation

uses uItem;        //Classe Item


var pBombermanItem : LPBombermanItem = NIL; //Contient la liste de nos bombermans
    BombermanCount : integer = 0;

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
 Find:=((Trunc(pTemp^.Bomberman.X)=aX) AND (Trunc(pTemp^.Bomberman.Y)=aY));
 Last:=(pTemp^.Next=Nil);

 While Not(Find or Last) do
 begin
  pTemp:=pTemp^.Next;
  Find:=((Trunc(pTemp^.Bomberman.X)=aX) AND (Trunc(pTemp^.Bomberman.Y)=aY));
  Last:=(pTemp^.Next=Nil);
 end;

 if Find then result:=pTemp^.Bomberman;

end;
end;

function IsBombermanAtCoo(aX, aY: integer): boolean; cdecl;
var pTemp : LPBombermanItem;
begin
 result:=False;
 pTemp:=pBombermanItem;
 
 While Not(Result) And (pTemp<>Nil) do
 begin
  Result:=((Trunc(pTemp^.Bomberman.X)=aX) AND (Trunc(pTemp^.Bomberman.Y)=aY));
  pTemp:=pTemp^.Next;
 end;
end;

function CheckEndGame(): boolean;
var i : integer;
    Count : integer;
begin
 Count:=0;
 if (BombermanCount<>0) then
  begin
  For i:=1 to BombermanCount do
   if GetBombermanByCount(i).Alive then Inc(Count);
  end;
 result:=(Count<2);
end;

Function GetBombermanCount():Integer;
Begin
  result:=BombermanCount;
End;

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

{ CBomberman }

procedure CBomberman.ChangeScore();
begin
nScore:=nKills-nDeaths;
end;

procedure CBomberman.Move(dx, dy : integer; dt : single);
    //*********************BEGIN::SOUS FONCTION PRINC****************************//
      procedure TestMove(aX,aY : integer;var bBomb : boolean;var bResult : boolean);
      
       //*******************BEGIN::SOUS-SOUS FONCTIONS******************************//
         function ChangeCase(aX,aY : integer):boolean;
         {True = On change de case}
         begin
           result:= Not((aX=Trunc(fX+0.5)) AND (aY=Trunc(fY+0.5)));
         end;

         function TestGrid(aX,aY : integer):boolean;
         {True = je peux passer il n'y a rien}
         begin
           result:=(uGrid.GetBlock(aX,aY)=Nil);
         end;

         function TestBonus(aX,aY : integer):boolean;
         {True = c'est un bonus, je peux passer}
         begin
           result:=False;
           if (uGrid.GetBlock(aX,aY) is CItem) then
             result:=((uGrid.GetBlock(aX,aY) as CItem).IsExplosed());
         end;

         function TestBomb(aX,aY : integer):boolean;
         {True = c'est une bombe}
         begin
           result:=(uGrid.GetBlock(aX,aY) is CBomb);
         end;
      //*******************END::SOUS-SOUS FONCTIONS********************************//
      
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
        bCanMove:=TestGrid(aX,aY) or Not(ChangeCase(aX,aY));
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
          {Si deplacement vers la droite ou le bas, on force ce dernier}
          else
          begin
            bBomb:=False;
            bResult:=False;
          end;
        end;
      end;
      end;
      
      procedure DoMove(afX, afY : Single);
      begin
       fX:=afX;
       fY:=afY;
      end;
  //**************************END::SOUS FONCTIONS PRINC***********************//
  
var   aX, aY : integer;
     _X, _Y,_fX, _fY, delta : Single;
     _Bomb : CBomb;
     bBomb, bResult : boolean;
begin
{On modifie le vecteur orientation du bomberman}
nDirection:=-dX*90+90*dY*(dY-1);

{On repere d'abord dans quel case on est cence arriver}
delta := 0.8;
_fX:=fX + dx*fSpeed*dt;
_fY:=fY + dy*fSpeed*dt;
_X:=_fX;
_Y:=_fY;
if dY=1 then _Y:=_Y+delta
else if dX=1 then _X:=_X+delta;
aX:=Trunc(_X);
aY:=Trunc(_Y);


TestMove(aX,aY,bBomb,bResult);
if bResult then
begin
  {Si ca passe on on regarde si c'est pas grace au kick d'une bombe}
  if bBomb then
  {Auquel cas on ne la shoot que si au moins la moitie du bomberman est en face}
   begin
    if ((Trunc(_fX+0.5)=aX) or (Trunc(_fY+0.5)=aY)) then
    begin
     _Bomb:=GetBombByGridCoo(aX,aY);
     if dX=1 then _Bomb.MoveRight(dt)
     else if dX=-1 then _Bomb.MoveLeft(dt)
     else if dY=1 then _Bomb.MoveDown(dt)
     else if dY=-1 then _Bomb.MoveUp(dt);
    end;
  end
  else
  {Sinon bha on test l'autre extremite}
  begin
    aX:=Trunc(_X+abs(dY)*0.5);
    aY:=Trunc(_Y+abs(dX)*0.5);
    TestMove(aX,aY,bBomb,bResult);
    {Si elle passe aussi, rebelote}
    if bResult then
    begin
      if bBomb then
      begin
        if ((Trunc(_fX+abs(dY)*delta+0.5)=aX) or (Trunc(_fY+abs(dX)*delta+0.5)=aY)) then
        begin
         _Bomb:=GetBombByGridCoo(aX,aY);
         if dX=1 then _Bomb.MoveRight(dt)
         else if dX=-1 then _Bomb.MoveLeft(dt)
         else if dY=1 then _Bomb.MoveDown(dt)
         else if dY=-1 then _Bomb.MoveUp(dt);
        end;
      end
      else DoMove(_fX,_fY);
    end
  end;
  {Sinon on force un deplacement lateral en plus}
end;



{var aX, aY : Integer;
    _fX, _fY : single;
    _Bomb : CBomb;
begin
 _fX:=fX + dx*fSpeed*dt;
 _fY:=fY + dy*fSpeed*dt;
 aX := Trunc(_fX);
 aY := Trunc(_fY);
 if CheckCoordinates(aX,aY) then
 begin
 {S'il n'y a rien la ou on veut aller ou si on ne change pas de case}
   if ((uGrid.GetBlock(aX,aY) = nil) or ((aX=Trunc(fX)) AND (aY=Trunc(fY)))) then
   begin
     fX:=_fX;
     fY:=_fY;
   end
   
   else
   {S'il y a une caisse la ou on veut aller ... on avance que si elle est explosee (=bonus))}
   if (uGrid.GetBlock(aX,aY) is CItem) then
   begin
     if (uGrid.GetBlock(aX,aY) as CItem).IsExplosed() then
     begin
      fX:=_fX;
      fY:=_fY;
     end;
   end

   else
   
   begin
   {S'il y a une bombe qu'on ne vient pas nous même de poser peut-on la shooter}
      _Bomb:=GetBombByGridCoo(aX,aY);
     if (_Bomb<>Nil) then
     begin
       if bKick then
       begin
         if dX=1 then _Bomb.MoveRight(dt)
         else if dX=-1 then _Bomb.MoveLeft(dt)
         else if dY=1 then _Bomb.MoveDown(dt)
         else if dY=-1 then _Bomb.MoveUp(dt);

       end;
     end;
   end;
 end;}
end;

function CBomberman.CanBomb():boolean;
begin
 result := ((nBombCount<>0) And Not(NoBomb));
end;

procedure CBomberman.UpBombCount(); cdecl;
begin
  nBombCount +=1;
end;

procedure CBomberman.CheckBonus();
var oldX, oldY : integer;
begin
  if Not(uGrid.getBlock(Trunc(fX+0.5),Trunc(fY+0.5))=Nil) then
     if (uGrid.getBlock(Trunc(fX+0.5),Trunc(fY+0.5)) is CItem) then
      begin
         oldX:=Trunc(fX+0.5);        //a cause de la maladie SWITCH il faut se souvenir de ou il etait
         oldY:=Trunc(fY+0.5);        //avant de prendre le bonus
         CItem(uGrid.getBlock(oldX,oldY)).Bonus(Self);
         uGrid.DelBlock(oldX,oldY);
      end;
end;

constructor CBomberman.Create(aName: string; aTeam: integer; aIndex : Integer;
                               aGrid : CGrid; aX, aY : Single);
begin
  sName          := aName;
  nTeam          := aTeam;
  nIndex         := aIndex;
  fX             := aX;
  fY             := aY;
  fXOrigin       := aX;
  fYOrigin       := aY;
  uGrid          := aGrid;
  nKills         := 0;
  nDeaths        := 0;
  nScore         := 0;
  bNoBomb        := False;
  bReverse       := False;
  bKick          := True;
  bAlive         := True;
  nBombCount     := DEFAULTBOMBCOUNT;
  nFlameSize     := DEFAULTFLAMESIZE;
  fSpeed         := DEFAULTSPEED;
  nDirection     :=0;

end;


procedure CBomberman.MoveUp(dt : Single);cdecl;
begin
if Self.bAlive then
begin
 if Not(Self.bReverse) then Self.Move(0,-1,dt) //Haut
 else Self.Move(0,1,dt);                  //Bas
 
 Self.CheckBonus;
end;
end;

procedure CBomberman.MoveDown(dt : Single);cdecl;
begin
if Self.bAlive then
begin
 if Not(Self.bReverse) then Self.Move(0,1,dt)  //Bas
 else Self.Move(0,-1,dt);                 //Haut
 
 CheckBonus;
end;
end;

procedure CBomberman.MoveLeft(dt : Single);cdecl;
begin
if Self.bAlive then
begin
 if Not(Self.bReverse) then Self.Move(-1,0,dt) //left
 else Self.Move(1,0,dt);                   //right
 
 Self.CheckBonus;
end;
end;

procedure CBomberman.MoveRight(dt : Single);cdecl;
begin
if Self.bAlive then
begin
 if Not(bReverse) then Move(1,0,dt) //Right
 else Move(-1,0,dt);
 
 CheckBonus;
end;
end;

procedure CBomberman.CreateBomb(dt : Single); cdecl;
begin
if Self.bAlive then
begin
if Self.CanBomb  then
begin
if AddBomb(fX+0.5,fY+0.5,nIndex,nFlameSize,uGrid,@UpBombCount,@IsBombermanAtCoo) then
  Dec(nBombCount);
end;
end;
end;


procedure CBomberman.UpKills();
begin
  nKills += 1;
  ChangeScore;
end;

procedure CBomberman.Dead();
begin
if bAlive then
 begin
  bAlive:=False;
  Inc(nDeaths);
  ChangeScore;
 end;
end;

procedure CBomberman.Restore();
begin
  bAlive        := True;
  fX            := fXOrigin;
  fY            := fYOrigin;
  bNoBomb       := False;
  bReverse      := False;
  bKick         := True;
  nBombCount    := DEFAULTBOMBCOUNT;
  nFlameSize    := DEFAULTFLAMESIZE;
  fSpeed        := DEFAULTSPEED;
  nDirection    := 0;

end;

procedure CBomberman.ChangeReverse();
begin
  bReverse:=Not(bReverse);
end;

end.

