Unit UGrid;

{$mode objfpc}{$H+}

Interface

Uses Classes, SysUtils, UBlock, UUtils, UScheme;
  

Type

{ CGrid }

CGrid = Class

        Private

               aBlock        : Array [1..GRIDWIDTH,1..GRIDHEIGHT] Of CBlock   ; // tableau stockant les items

               uScheme       : CScheme ;

               

        Public

              Constructor Create ( _uScheme : CScheme );                       // creer grille a partir d'un scheme
              Destructor Destroy () ;
              Procedure LoadScheme ( _uScheme : CScheme ) ;                    // méthode chargeant le scheme
	      procedure CreateFlame(aX,aY,aIndex : integer);
              Procedure AddBlock(aX,aY : integer;Block : CBlock);
              Function GetBlock(x, y : Integer ):CBlock; // obtenir l'item de la case (x,y)
              Procedure DelBlock ( x, y : Integer ) ; // supprimer l'item de la case (x,y)


     
End;


Implementation

Uses UExtraBomb, UFlameUp, uFlame, UDisease, USpeedUp, UKick, uGrab, uJelly,
     UPunch, USpoog, UGoldFLame, UTrigger, USuperDisease, URandomBonus;


{ CGrid }

Procedure CGrid.LoadScheme( _uScheme : CScheme ) ;
Var i, j, k : Integer;
    r : Integer;
    b : Boolean;
    qt : Array [1..POWERUPCOUNT] Of Integer;
    n : Integer;
    m : Integer;
Begin
     uScheme := _uScheme;
     
     n := 0;
     m := uScheme.BrickCount;
     For k := 1 To POWERUPCOUNT Do Begin
         qt[k] := uScheme.PowerUp(k).GameQuantity;
         n += qt[k];
     End;
         
     For j := 1 To GRIDHEIGHT Do Begin
          For i := 1 To GRIDWIDTH Do Begin
              aBlock[i,j] := NIL;
              Case uScheme.Block(i,j) Of // on lit le contenu de la case (i,j) de uScheme.aBlock et on crée l'item correspondant si nécessaire
                   BLOCK_SOLID :
                   Begin // creation d'un bloc solide
                        b := False; // donc non destructible
                        aBlock[i,j] := CBlock.Create(i,j,b);
                   End;
                   BLOCK_BRICK : // !!! la répartition des bonus est peut-être à revoir, on risque surement d'avoir
                   Begin // creation d'un bloc
                        b := True; // destructible
                        While (aBlock[i,j] = NIL) And (n > 0) Do // tant qu'il n'y a aucun bloc et qu'il reste des bonus à placer
                        Begin
                             r := Random( POWERUPCOUNT + 1 ) - 1; // on choisit un nombre aléatoire parmi les codes de bonus
                             If (r = POWERUP_NONE) And (m > n) Then aBlock[i,j] := CBlock.Create(i,j,b); // si aucun bonus n'est choisi et qu'il reste assez d'emplacements vides alors on en fait une brique standard
                              For k := 1 To POWERUPCOUNT Do Begin // on regarde à quoi cela correspond dans le tableau
                                 If (uScheme.PowerUp(k).Code = r) And (qt[k] > 0) Then Begin // ainsi que la quantité restante à placer
                                    Case r Of
                                         POWERUP_EXTRABOMB       : aBlock[i,j] := CExtraBomb.Create(i,j);
                                         POWERUP_FLAMEUP         : aBlock[i,j] := CFlameUp.Create(i,j);
                                         POWERUP_DISEASE         : aBlock[i,j] := CDisease.Create(i,j);
                                         POWERUP_KICK            : aBlock[i,j] := CKick.Create(i,j);
                                         POWERUP_SPEEDUP         : aBlock[i,j] := CSpeedUp.Create(i,j);
                                         POWERUP_PUNCH           : aBlock[i,j] := CPunch.Create(i,j);
                                         POWERUP_GRAB            : aBlock[i,j] := CGrab.Create(i,j);
                                         POWERUP_SPOOGER         : aBlock[i,j] := CSpoog.Create(i,j);
                                         POWERUP_GOLDFLAME       : aBlock[i,j] := CGoldFlame.Create(i,j);
                                         POWERUP_TRIGGERBOMB     : aBlock[i,j] := CTrigger.Create(i,j);
                                         POWERUP_JELLYBOMB       : aBlock[i,j] := CJelly.Create(i,j);
                                         POWERUP_SUPERDISEASE    : aBlock[i,j] := CSuperDisease.Create(i,j);
                                         POWERUP_RANDOM          : aBlock[i,j] := CRandomBonus.Create(i,j);
                                    End;
                                    qt[k] -= 1;
                                    n -= 1;
                                 End;
                             End;
                        End;
                        If aBlock[i,j] = NIL Then aBlock[i,j] := CBlock.Create(i,j,b); // cela signifie qu'il ne reste aucun bonus à placer
                        m -= 1;
                   End;
                   BLOCK_BLANK : // pour la forme...
                        aBlock[i,j] := NIL;
              End;
          End;
     End;
End;

Function CGrid.GetBlock ( x, y : Integer) : CBlock ;
Begin
  result := aBlock[x,y];
End;

Constructor CGrid.Create ( _uScheme : CScheme ) ;
Begin
     LoadScheme(_uScheme); // charger le scheme
End;

Destructor CGrid.Destroy () ;
Var i, j : Integer;
Begin
     For j := 1 To GRIDHEIGHT Do
         For i := 1 To GRIDWIDTH Do
             If ( aBlock[i,j] <> NIL ) then aBlock[i,j].Destroy(); //on scanne la grille et on detruit le contenu si necessaire
end;

procedure CGrid.CreateFlame(aX, aY, aIndex: integer);
begin
 AddFlame(aX,aY,aIndex);
end;

procedure CGrid.AddBlock(aX,aY : integer;Block : CBlock);
begin
  aBlock[aX,aY]:=Block;
end;

Procedure CGrid.DelBlock ( x, y : Integer ) ;
Begin
     aBlock[x,y] := Nil; //on vide la case (x,y) du tableau
End;



End.

