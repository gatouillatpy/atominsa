////////////////////////////////////////////////////////////////////////////////
// UFlame :  Fiche de gestion des flamùes                                     //
////////////////////////////////////////////////////////////////////////////////
Unit UFlame;

{$mode objfpc}{$H+}

Interface

Uses Classes, SysUtils, UBomberman, UUtils, UBomb, UCore;
  
Type

{******************************************************************************}
{         CFLAME                                                               }
{                                                                              }
{******************************************************************************}
CFlame = Class

         Protected // POURQUOI EN PROTECTED ???
                   bombPlayer : CBomberman;                        //Pointe sur le bomberman qui a cree la flame via la bombe
                   nX, nY : Integer;                                              //Coordonnees de la Flame
                   fTime : Single;                                  //temps depuis lequel la flame est cree (pour la faire disparaitre)

         Public
               Constructor Create( _nX, _nY, _nID : Integer );
               Function Update():boolean;         //Verifie s'il ne faut rien faire exploser ou s'il faut detruire la flame
     
               Function Itensity() : Single ;
               
               property X : integer Read nX;
               property Y : integer Read nY;
               
End;
    






{******************************************************************************}
{         GESTION DE LA LISTE DES FLAMES                                       }
{                                                                              }
{******************************************************************************}
Type LPFlameItem = ^FlameItem;
     FlameItem = record
            Count : integer;                               //numero de la flame
            Flame : CFlame;                                //pointe sur la flame
            Next : LPFlameItem;                            //pointe sur l element suivant de la liste
           end;
    
    function AddFlame(aX, aY, aIndex : integer):CFlame;    //Ajoute une flame a la liste
    Procedure FreeFlame();                                 //Supprime toutes les flames
    function GetFlameByCount(i : integer):CFlame;          //Recupere le poitneur d'une flame par son numero
    function GetFlameByCoo(aX,aY : integer):CFlame;        //Recupere une flame par ses coordonnees
    function GetFlameCount():integer;                      //Recupere le nombre total de flame dans la liste






implementation
var pFlameItem : LPFlameItem = Nil;                        //Notre liste
    FlameCount : integer = 0;                              //Nombre d'element dans la liste


//Permet de remettre en ordre les numeros de flame apres la suppression de l'une d'elles
Procedure UpdateCountList();
var Count : integer;
    pTemp : LPFlameItem;
begin
 Count:=1;
  pTemp:=pFlameItem;
  While (Count<=FlameCount) do
  begin
   pTemp^.Count:=Count;
   Inc(Count);
   pTemp:=pTemp^.Next;
  end;
end;




//Ajout d'un element a la liste
function AddFlame(aX, aY, aIndex : integer):CFlame;
var pTemp : LPFlameItem;
begin
 Inc(FlameCount);                                        //on incremente notre nombre d'element
 if (pFlameItem=Nil) then                                //Si c'est la premiere ...
 begin
   New(pFlameItem);
   pFlameItem^.Next:=Nil;
   pFlameItem^.Flame:=CFlame.Create(aX,aY,aIndex);
   pFlameItem^.Count:=FlameCount;
   result:=pFlameItem^.Flame;
 end
 else                                                     // ... Sinon
 begin
 pTemp:=pFlameItem;
 While (pTemp^.Next<>Nil) do                              // on cherche la derniere flame de la liste
   pTemp:=pTemp^.Next;
   
 New(pTemp^.Next);                                        //et on cree notre nouvel element ...
 pTemp:=pTemp^.Next;
 pTemp^.Count:=FlameCount;
 pTemp^.Next:=Nil;
 pTemp^.Flame:=CFlame.Create(aX,aY,aIndex);               //... avec une nouvelle flame
 result:=pTemp^.Flame;
 end;
end;



{procedure RemoveFlameByCount(i: integer);
var pTemp,pPrev : LPFlameItem;
    Find, Last : Boolean;
begin
pPrev:=Nil;
if ((i<=FlameCount) AND (pFlameItem<>Nil)) then
begin
  pTemp:=pFlameItem;
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
   else pFlameItem:=pTemp^.Next;
   pTemp^.Flame.Free;
   Dec(FlameCount);
   Dispose(pTemp);
   UpdateCountList(i);
  end;
end;
end;

procedure RemoveFlameByCoo(aX,aY : integer);
var pTemp,pPrev : LPFlameItem;
    Find, Last : Boolean;
    i : integer;
begin
pPrev:=Nil;
if ((pFlameItem<>Nil) AND CheckCoordinates(aX,aY)) then
begin
  pTemp:=pFlameItem;
  Find:=((pTemp^.Flame.X=aX) AND (pTemp^.Flame.Y=aY));
  Last:=(pTemp^.Next=Nil);

  While Not(Find or Last) do
  begin
   pPrev:=pTemp;
   pTemp:=pTemp^.Next;
   Last:=(pTemp^.Next=Nil);
   Find:=((pTemp^.Flame.X=aX) AND (pTemp^.Flame.Y=aY));
  end;

  if Find then
  begin
   if (pPrev<>Nil) then pPrev^.Next:=pTemp^.Next
   else pFlameItem:=pTemp^.Next;
   pTemp^.Flame.Free;
   i:=pTemp^.Count;
   Dec(FlameCount);
   Dispose(pTemp);
   UpdateCountList(i);
  end;
end;
end;
}




//Supprime un element en fonction de la flame
procedure RemoveThisFlame(aFlame: CFlame);
var Find : boolean;
    pTemp, pPrev : LPFlameItem;
begin
Find:=False;
pPrev:=Nil;
  if pFlameItem<>Nil then                        //Uniquement possible si notre liste n'est pas vide
  begin
    pTemp:=pFlameItem;
    Find:=(pTemp^.Flame=aFlame);

    While Not(Find) do                           //On cherche notre Flame
    begin
      pPrev:=pTemp;
      pTemp:=pTemp^.Next;
      Find:=(pTemp^.Flame=aFlame);
    end;

    if pPrev<>nil then pPrev^.Next:=pTemp^.Next  //si ce n'est pas la premiere on fait pointer l'element precedent sur le suivant
       else pFlameItem:=pTemp^.Next;             //sinon si c'est la premiere notre debut de liste commence au suivant
    Dispose(pTemp);                              //On supprime l'element
    Dec(FlameCount);                             //On decrement le nombre d'element en stock
    UpdateCountList();                           //On met a jour les numeros de notre liste
  end;
end;




//FonctionSSSS de vidage complet de la liste
procedure FreeFlameP(pList: LPFlameItem);
begin
 if (pList<>Nil) then                            //Si on est toujours dans la liste
 begin
  FreeFlameP(pList^.Next);                       //On rappelle la fonction
  pList^.Flame.Free;                             //Ensuite on detruit la Flame
  Dispose(pList);                                //Et on supprime l'element
  pList:=Nil;                                    //qui pointe alors sur NIL
 end;
end;
procedure FreeFlame();
begin
 if pFlameItem<>Nil then
 begin
  FreeFlameP(pFlameItem^.Next);                  //cf juste au dessus
  pFlameItem^.Flame.Free;
  Dispose(pFlameItem);
  pFlameItem:=Nil;
 end;
 FlameCount:=0;
end;




//Recupere une FLAME par sa position dans la liste
function GetFlameByCount(i : integer):CFlame;
var pTemp : LPFlameItem;
begin
result:=Nil;
pTemp:=pFlameItem;
if ((i<=FlameCount) AND (pTemp<>Nil)) then    //si le numero recherche est inferieur au nombre de flame
begin                                         //en stock et que notre liste n'est pas vide
 While (pTemp^.Count<>i) do
  pTemp:=pTemp^.Next;                         //et bien tant que tu n'as pas la bonne ... tu passes a l'element suivant

 result:=pTemp^.Flame;
end;
end;



//Recupere une Flame par ses coordonnees dans la grid
function GetFlameByCoo(aX,aY : integer): CFlame;
var pTemp : LPFlameItem;
    Find, Last : Boolean;
begin
result:=Nil;
if ((pFlameItem<>Nil) AND (CheckCoordinates(aX,aY))) then
begin
 pTemp:=pFlameItem;
 Find:=((pTemp^.Flame.X=aX) AND (pTemp^.Flame.Y=aY));
 Last:=(pTemp^.Next=Nil);
 
 While Not(Find or Last) do                                        //Idem a au dessus
 begin
  pTemp:=pTemp^.Next;
  Find:=((pTemp^.Flame.X=aX) AND (pTemp^.Flame.Y=aY));
  Last:=(pTemp^.Next=Nil);
 end;
 
 if Find then result:=pTemp^.Flame;
 
end;
end;



//Renvoi le nombre d'element dans la liste (= nombre de flame en stock)
function GetFlameCount(): integer;
begin
  result:=FlameCount;
end;





{******************************************************************************}
{         CFLAME                                                               }
{                                                                              }
{******************************************************************************}
//Constructeur
constructor CFlame.Create( _nX, _nY, _nID : Integer );
begin
  nX := _nX;
  nY := _nY;
  fTime := GetTime() + FLAMETIME;
  bombPlayer := GetBombermanByIndex(_nID);                  //On recupere le bomberman a partir de son numero
  Update();                                             //Un update a sa creation pour effectuer un premier test
end;





//Verifie si une bombe ou un bomberman se trouve sur la flame
function CFlame.Update():boolean;
var PlayerKilled : CBomberman;
begin
  result:=False;
  if (GetBombByGridCoo(Self.X,Self.Y)<>nil) then                      //cherche les bombes en fait
   GetBombByGridCoo(Self.X,Self.Y).Explose();
   
   
  PlayerKilled:=GetBombermanByCoo(Self.X,Self.Y);
  if (PlayerKilled<>nil) then                                     //cherche si y'a un bomberman dans le coin
  begin
  if PlayerKilled.Alive then
   begin
   PlayerKilled.Dead();                                           //fait tomber de 1 le score ...
   if (PlayerKilled<>bombPlayer) then bombPlayer.UpKills;         //on incremente le score du joueur qui a
  end;                                                            //cree la flame que si il s'est pas tue tout seul
  end;



  if GetTime() >= fTime then                                       //Si le temps depuis lequel la flame a ete cree
  begin                                                           //et superieur au temps de duree d'une flame
   RemoveThisFlame(Self);                                         //alors elle est supprimee de la liste et detruite
   result:=True;
   Destroy;
  end;

end;



Function CFlame.Itensity() : Single ;
Var f : Single;
Begin
     //Result := Pow(1.0 - Abs(2.0 * (fTime - GetTime()) / FLAMETIME - 1.0), 2.0);
     f := 1.0 + (GetTime() - fTime) / FLAMETIME;
     If (f >= 0.0) And (f <= 0.2) Then Result := f * 5.0;
     If (f >= 0.2) And (f <= 0.6) Then Result := 1.0;
     If (f >= 0.6) And (f <= 1.0) Then Result := (1.0 - f) * 2.5;
End;



end.

