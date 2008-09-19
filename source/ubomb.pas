Unit UBomb;

{$mode objfpc}{$H+}

Interface

Uses Classes, SysUtils, UGrid, UBlock, UUtils, UCore, UExplosion;

Type LPUpCount = procedure() of Object ;cdecl;
Type LPGetBomberman = function(aX,aY : integer):boolean;cdecl;
  
Type

{ CBomb }

CBomb = Class(CBlock)

     Protected
       bUpdateTime,
       bMoving,                                               // defini si la bombe est en cours de mouvement ou non
       bJumping,                                              // definit si la bombe est en cours de saut ...
       bMoveJump   : Boolean;                                 // definit si la bombe bouge en rebondissant ...
       uGrid       : CGrid;
       nPunch,                                                // nombre de cases restantes pour un mouvement dû à un punch
       nOriginX,
       nOriginY,
       nIndex,                                                // definit le joueur qui a pose la bombe
       nMoveDir,                                              // direction de mouvement de la bombe
       nBombSize : integer;                                   // portee de la flamme de la bombe
       fPosition : Vector;                                    // Coordonnees reelles de la bombe
       fExploseTime,                                          // temps avant explosion
       fJumpingTime : Single;                                 // temps en saut
       fLastTime    : Single;                                 // Dernier appel a checktimer
       fTimeCreated : Single;                                 // temps depuis lequel la bombe a ete creee
       pUpCount : LPUpcount;                                  // pointe sur la fonction du bomberman qui a pose la bombe pour lui augmenter son score
       pIsBomberman : LPGetBomberman;                         // pointe sur la fonction pour savoir s'il y a un bomberman en telle position

       procedure Move(dt : single);virtual;                           // fonction interne de mouvement classique
       procedure MoveJump(dt : Single);
       procedure Jump(dt : Single);

     Public
       nNetID : Integer;
       Constructor create(aX, aY : Single; aIndex, aBombSize : integer; aBombTime : Single; aGrid : CGrid; UpCount : LPUpCount; IsBomberman : LPGetBomberman; _nNetID : Integer);Virtual;     // permet de creer une bombe a partir de coordonnees et du bomberman qui la pose
       Destructor Destroy();Override;
       function UpdateBomb():boolean;virtual;                         // check le temps + mouvement
       procedure StartTime();
       procedure StopTime();
       Procedure Explose();Override;                          // fait exploser la bombe
       procedure MoveRight(dt : Single);
       procedure MoveDown(dt : Single);
       procedure MoveLeft(dt : Single);
       procedure MoveUp(dt : Single);
       procedure Punch(dir : integer; dt : Single);
       procedure DoMove(afX, afY : Single;aX,aY : integer);

       property CanExplose : boolean Read bExplosive;
       property Position : Vector Read fPosition Write fPosition;
       property Time : Single Read fTimeCreated;
       property ExploseTime : Single Read fExploseTime;
       property JumpMovement : boolean Read bMoveJump Write bMoveJump;
       property BIndex : integer Read nIndex Write nIndex;


end;





implementation
uses UItem, UListBomb, UGame, USetup, UMulti;




{                                                                               }
{                             CBomb                                             }
{                                                                               }

{*******************************************************************************}
{ Deplacement normal des bombes                                                 }
{*******************************************************************************}
procedure CBomb.DoMove(afX, afY : Single;aX,aY : integer);
begin
   uGrid.DelBlock(nX,nY);
   if nPunch>0 then
     if ((aX<>nX) or (aY<>nY)) then
       if (abs(afX-aX)<0.1) and (abs(afY-aY)<0.1) then nPunch -= 1;
   nX:=aX;
   nY:=aY;
   fPosition.x:=afX;
   fPosition.y:=afY;
   uGrid.AddBlock(nX,nY,Self);
end;
   
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
afX:=fPosition.x+dX*BOMBMOVESPEED*dt;
afY:=fPosition.y+dY*BOMBMOVESPEED*dt;
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
      //bMoving:=false;
      if ((nMoveDir=RIGHT) or (nMoveDir=DOWN)) then DoMove(_X,_Y,_X,_Y);
      bMoving:=False;
      nMoveDir:=NONE;
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
        //bMoving := false;
        if ((nMoveDir=RIGHT) or (nMoveDir=DOWN)) then DoMove(_X,_Y,_X,_Y);
        bMoving:=False;
      end;
    end;
  end;
end;
end;


procedure CBomb.MoveRight(dt : Single);
begin
  bMoving := True;
  nMoveDir := RIGHT;
  If ( bMoveJump ) And ( ( bMulti = false ) Or ( nLocalIndex = nClientIndex[0] ) ) Then
  begin
    bJumping:=true;
    Jump(dt);
  end
  else Move(dt);
end;

procedure CBomb.MoveDown(dt : Single);
begin
  bMoving := True;
  nMoveDir := DOWN;
  If ( bMoveJump ) And ( ( bMulti = false ) Or ( nLocalIndex = nClientIndex[0] ) ) Then
  begin
    bJumping:=true;
    Jump(dt);
  end
  else Move(dt);
end;

procedure CBomb.MoveLeft(dt : Single);
begin
  bMoving := True;
  nMoveDir := LEFT;
  If ( bMoveJump ) And ( ( bMulti = false ) Or ( nLocalIndex = nClientIndex[0] ) ) Then
  begin
    bJumping:=true;
    Jump(dt);
  end
  else Move(dt);
end;

procedure CBomb.MoveUp(dt : Single);
begin
  bMoving := True;
  nMoveDir := UP;
  If ( bMoveJump ) And ( ( bMulti = false ) Or ( nLocalIndex = nClientIndex[0] ) ) Then
  begin
    bJumping:=true;
    Jump(dt);
  end
  else Move(dt);
end;












{*******************************************************************************}
{ Deplacement par saut des bombes                                               }
{*******************************************************************************}
procedure CBomb.MoveJump(dt : single);
var r : integer;
begin
     If ( bMulti = False ) Or ( nLocalIndex = nClientIndex[0] ) Then Begin
         bJumping:=True;
         //Repeat
         r:=Random(4)+1;
         case r of
          1 : nMoveDir := UP;
          2 : nMoveDir := DOWN;
          3 : nMoveDir := RIGHT;
          4 : nMoveDir := LEFT;
         end;
         Jump(dt);
     End;
end;


procedure CBomb.Jump(dt : Single);
var dX, dY : integer;
begin
  dX := 0;
  dY := 0;

  case nMoveDir of
    RIGHT : dX := 1;
    LEFT  : dX := -1;
    UP    : dY := -1;
    DOWN  : dY := 1
  end;

  fPosition.x:=fPosition.x+dX*BOMBMOVESPEED*dt;
  fPosition.y:=fPosition.y+dY*BOMBMOVESPEED*dt;

  if Not(CheckCoordinates(Trunc(fPosition.x),Trunc(fPosition.y))) then
  begin
    case nMoveDir of
      RIGHT : fPosition.x := 1;
      LEFT  : fPosition.x := GRIDWIDTH;
      UP    : fPosition.y := GRIDHEIGHT;
      DOWN  : fPosition.y := 1;
    end;
  end;
  
  case nMoveDir of
    RIGHT, LEFT : begin
                    fPosition.z:=sin(PI*(fPosition.x-Trunc(fPosition.x)));
                    if (((fPosition.x-Trunc(fPosition.x))<0.1) and ( (nOriginX<>Trunc(fPosition.x)) or (nOriginY<>fPosition.y)) )then
                    begin
                      if (uGrid.GetBlock(Trunc(fPosition.x),Trunc(fPosition.y))=nil) and Not(pIsBomberman(Trunc(fPosition.x),Trunc(fPosition.y))) then
                      begin
                        fPosition.z  := 0;
                        nX           := Trunc(fPosition.x);
                        nY           := Trunc(fPosition.y);
                        nOriginX     := nX;
                        nOriginY     := nY;
                        fPosition.y  := nY;
                        fPosition.x  := nX;
                        uGrid.AddBlock(nX,nY,Self);
                        bJumping     := false;
                        bMoveJump    := false;
                        bMoving      := false;
                      end
                      else bJumping:=false;
                    end;
                  end;
    UP, DOWN    : begin
                    fPosition.z:=sin(PI*(fPosition.y-Trunc(fPosition.y)));
                      if (((fPosition.y-Trunc(fPosition.y))<0.1) and ( (nOriginX<>Trunc(fPosition.x)) or (nOriginY<>fPosition.y)) )then
                      begin
                        if (uGrid.GetBlock(Trunc(fPosition.x),Trunc(fPosition.y))=nil)  and Not(pIsBomberman(Trunc(fPosition.x),Trunc(fPosition.y))) then
                        begin
                        fPosition.z  := 0;
                        nX           := Trunc(fPosition.x);
                        nY           := Trunc(fPosition.y);
                        fPosition.y  := nY;
                        fPosition.x  := nX;
                        nOriginX     := nX;
                        nOriginY     := nY;
                        uGrid.AddBlock(nX,nY,Self);
                        bJumping     := false;
                        bMoveJump    := false;
                        bMoving      := false;
                        end
                        else bJumping:=false;
                      end;
                  end;
  end;


end;














{*******************************************************************************}
{ Lancement d'une bombe par le punch                                            }
{*******************************************************************************}
procedure CBomb.Punch(dir: integer; dt: Single);
begin
 nMoveDir  := dir;
 nPunch    := PUNCHNUMBERCASE;
 bMoving   := true;
 Move(dt);
end;



















{*******************************************************************************}
{ Creation / destruction                                                        }
{*******************************************************************************}
constructor CBomb.create(aX, aY : Single; aIndex,aBombSize : integer; aBombTime : Single; aGrid : CGrid; UpCount : LPUpCount; IsBomberman : LPGetBomberman; _nNetID : Integer);
begin
   if (aBombTime=BOMBTIME) and (bMulti = false) and ((random(100)+1)<=10)then
      aBombtime := (random(200)+1)*BOMBTIME/100;
   //play sound moisi !!!

   pUpCount        := UpCount;
   nNetID          := _nNetID;
   pIsBomberman    := IsBomberman;
   bUpdateTime     := true;
   bExplosive      := true;                                                     //une bombe peut exploser
   bMoving         := False;
   bMoveJump       := False;
   bJumping        := false;
   nMoveDir        := NONE;
   uGrid           := aGrid;
   nPunch          := -1;
   nIndex          := aIndex;
   nBombSize       := aBombSize;                                                // la taille des flammes de la bombe est celle de la portee des flammes du joueur qui la cree
   nX              := Trunc(aX);                                                // abscisse de la bombe dans la grille
   nY              := Trunc(aY);                                                // ordonnee de la bombe dans la grille
   nOriginX        := nX;
   nOriginY        := nY;
   fPosition.x     := nX;                                                       //abscisse ordonnee reelles
   fPosition.y     := nY;
   fTimeCreated    := 0;
   fJumpingTime    := 0;
   fLastTime       := GetTime();
   fExploseTime    := aBombTime;                                                // temps au bout duquel al bombe doit exploser
   uGrid.AddBlock(nX,nY,Self);                                                  //avec ca on peut prevoir un mouvement de la bombe (shoot)
end;


destructor CBomb.Destroy();
begin
  inherited;
end;

















{*******************************************************************************}
{ Gestion de l'explosion                                                        }
{*******************************************************************************}
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
               if tempBlock<>nil then                                           // si y'a quelque chose ... on le detruit
               begin
                 Stop:=True;
                 if (tempBlock is CBomb) then
                          begin
                           if (CBomb(tempBlock).CanExplose) then
                                 CBomb(tempBlock).Explose;                      // si c'est une bombe on la fait exploser
                          end
                 else if (tempBlock is CItem) then
                          begin
                          if CItem(tempBlock).IsExplosed() And (CItem(tempBlock).bIsExplosedMulti = False) then
                             uGrid.delBlock(nX+Size*dx,nY+Size*dy);
                           CItem(tempBlock).Explose;                            // si c'est un bonus on fait exploser
                          end
                 else if (tempBlock is CBlock) then
                          begin
                           if (tempBlock.IsExplosive()) then
                            begin
                             (tempBlock.Explose());
                             uGrid.DelBlock(nX+Size*dx,nY+Size*dy);
                            end;
                  end;                                                          // sinon c'est que c'est un mur ... ca pete pas ...
               end
               else                                                             // sinon on cree une nouvelle flame a la bonne place ...
               begin
                 uGrid.CreateFlame(nX+Size*dx,nY+Size*dy,nIndex);
                 Size +=1;
               end;
             end
             else Stop:=True;                                                   // si les coordonnees ne sont pas bonnes => Stop
             end;                                                               // fin de la boucle while
           end;
           
           
var k : integer;
    sData : String;
begin
  k := (Random(3) + 1) * 10;
  PlaySound( SOUND_BOMB(k + nIndex) );
  RemoveThisBomb(Self);                                                         //On supprime la bombe de la liste
  bExplosive:=False;                                                            //elle pete elle peut plus exploser ... pour eviter qu'une bombe fasse sauter une bombe et celle ci fasse resaute la meme qu au debut ...
  AddExplosion(fPosition.x, fPosition.y);
  CreateFlame(1,0);                                                             //gauche
  CreateFlame(-1,0);                                                            //droite
  CreateFlame(0,1);                                                             //haut
  CreateFlame(0,-1);                                                            //bas
  pUpCount;
  uGrid.DelBlock(nX,nY);                                                        //mise a nil de la case 
  uGrid.CreateFlame(nX,nY,nIndex);                                              //histoire de remplacer la bombe par une flame
  Destroy;                                                                      // bye-bye ...
  If ((bMulti = True) And (nLocalIndex = nClientIndex[0])) Then Begin
     sData := IntToStr( nNetID ) + #31;
     Send( nLocalIndex, HEADER_EXPLOSE_BOMB, sData );
  End;
end;


















{*******************************************************************************}
{ Update                                                                        }
{*******************************************************************************}
function CBomb.UpdateBomb():boolean;
var dt : Single;
    aLastTime : Single;
begin
  aLastTime:=GetTime();
  dt:=aLastTime - fLastTime;
  fLastTime:=aLastTime;
  if (Not(bMoveJump) and bUpdateTime) then fTimeCreated += dt;
  if Not(bUpdateTime and bMoveJump) then
  begin
    nX:=Trunc(fPosition.x);
    nY:=Trunc(fPosition.y);
  end;
  if bMoving then
  begin
     If ( bMoveJump ) And ( ( bMulti = false ) Or ( nLocalIndex = nClientIndex[0] ) ) Then
    begin
      if bJumping then begin Jump(dt); end  else MoveJump(dt);
    end
    else Move(dt);
  end;

  if (nPunch=0) AND bMoving then
  begin
    bMoving := false;
    nPunch  := -1;
  end;
  result := (fPosition.x-Trunc(fPosition.x))<0.2;
  result := result and ((fPosition.y-Trunc(fPosition.y))<0.2);
  result := result and (fTimeCreated >= fExploseTime);
  if result then Explose;
end;

procedure CBomb.StartTime();
begin
  bUpdateTime := true;
end;

procedure CBomb.StopTime();
begin
  bUpdateTime := false;
end;



end.

