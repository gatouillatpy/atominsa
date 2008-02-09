Unit UComputer;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils,
     UCore, UUtils, UBomberman, UForm, UFlame, UBomb, UListBomb;

Type Table = Array [1..GRIDWIDTH,1..GRIDHEIGHT] Of Integer;

Procedure ProcessComputer ( pBomberman : CBomberman ; nSkill : Integer ) ;
Function CalculateFastDanger ( x : integer ; y : integer ; pState : Table ) : integer ;
Function CalculateSlowDanger ( x : integer ; y : integer ; pState : Table ) : integer ;



Implementation



Const SKILL_NOVICE         = 1;
Const SKILL_AVERAGE        = 2;
Const SKILL_MASTERFUL      = 3;
Const SKILL_GODLIKE        = 4;



Procedure ProcessComputer ( pBomberman : CBomberman ; nSkill : Integer ) ;
Function lm : Single; Begin If Random < 0.5 Then lm := -1.0 Else lm := 1.0 End;
Var t, rand : Single;
    i, j, k : Integer;
    bLeft, bDown, bUp, bRight : Integer;                             // Limites pour les calculs dans le tableau
    dangerMin : Integer;                                             // Le danger minimal connu pour l'instant
    pX, pY, cX, cY, lX, lY : Integer;                                // Renommage des coordonn�es pour am�liorer la lecture du code.
    aState : Array [1..GRIDWIDTH,1..GRIDHEIGHT] Of integer ;         // tableau du contenu de chaque case, 0 pour vide, 1 pour flamme, 2 pour bombe et 4 pour autre bomberman.
Begin

// Initialisation des variables.
   pX := Trunc(pBomberman.Position.X + 0.5);
   pY := Trunc(pBomberman.Position.Y + 0.5);
   cX := Trunc(pBomberman.CX + 0.5);
   cY := Trunc(pBomberman.CY + 0.5);
   lX := Trunc(pBomberman.LX + 0.5);
   lY := Trunc(pBomberman.LY + 0.5);
   dangerMin := 10000;
   pBomberman.SumGetDelta := pBomberman.SumGetDelta + GetDelta;
   

// Mise � jour du tableau.
     
     // On met toutes les donn�es � 0.
     For i := 1 To GRIDWIDTH Do Begin
         For j := 1 To GRIDHEIGHT Do Begin
             aState[i,j] := 0;
         End;
     End;

     // On ajoute 1 � chaque case qui contient une flamme.
     For k := 1 To GetFlameCount() Do Begin
         aState[GetFlameByCount(k).X, GetFlameByCount(k).Y] += 1;
     End;

     // On ajoute 2 � chaque case qui contient une bombe.
     For k := 1 To GetBombCount() Do Begin
         aState[Trunc(GetBombByCount(k).Position.X + 0.5), Trunc(GetBombByCount(k).Position.Y + 0.5)] += 2;
     End;
     
     // On ajoute 4 � chaque case qui contient un personnage autre que l'IA
     For k := 1 To GetBombermanCount() Do Begin
         If ( ( Trunc(GetBombermanByCount(k).Position.X + 0.5) <> pX )
         Or ( Trunc(GetBombermanByCount(k).Position.Y + 0.5) <> pY ) ) Then
            aState[Trunc(GetBombermanByCount(k).Position.X + 0.5), Trunc(GetBombermanByCount(k).Position.Y + 0.5)] += 4;
     End;
     
// Mise � jour des dangers s'il ne vient pas de bouger
   If ( pBomberman.CanCalculate = true ) Or ( pX <> lX ) Or ( pY <> lY )Then Begin
      pBomberman.Danger := CalculateSlowDanger(pX, pY, aState);
      pBomberman.DangerLeft := CalculateSlowDanger(pX - 1, pY, aState);
      pBomberman.DangerRight := CalculateSlowDanger(pX + 1, pY, aState);
      pBomberman.DangerUp := CalculateSlowDanger(pX, pY - 1, aState);
      pBomberman.DangerDown := CalculateSlowDanger(pX, pY + 1, aState);
   End;

// Niveau Novice

     Case nSkill Of
          SKILL_NOVICE :
          Begin
          {
               // Si les coordonn�es cibl�es sont atteintes ou obsol�tes, alors on calcule de nouvelles coordonn�es cibles.
               If ( ( cX = pX ) And ( cY = pY ) ) Or ( pBomberman.SumGetDelta >= 8 ) Then Begin
                  // On fixe les limites du rectangle dans lequel on va calculer les dangers.
                  If ( pX - 2 < 1 ) Then bLeft := 1 Else bLeft := pX - 2;
                  If ( pX + 2 > GRIDWIDTH ) Then bRight := GRIDWIDTH Else bRight := pX + 2;
                  If ( pY - 2 < 1 ) Then bUp := 1 Else bUp := pY - 2;
                  If ( pY + 2 > 1 ) Then bDown := GRIDHEIGHT Else bDown := pY + 2;
                  
                  // Puis on calcule les dangers et s�lectionne le minimum.
                  For i := bLeft To bRight Do Begin
                      For j := bUp To bDown Do Begin
                          If CalculateFastDanger( i, j, aState ) <= dangerMin Then Begin
                             cX := i;
                             cY := j;
                             dangerMin := CalculateFastDanger( i, j, aState);  // cX et cY � remettre dans pBomberman plus tard.
                          End;
                      End;
                  End;
                  pBomberman.SumGetDelta := 0;
               End;
               

               // Prise en compte de la cible dans les dangers.
               If ( abs( pX - cX ) + abs( pY - cY ) <> 0 ) Then
                  pBomberman.Danger := pBomberman.Danger - 128 div ( abs( pX - cX ) + abs( pY - cY ) )
               Else
                  pBomberman.Danger := pBomberman.Danger - 256;
               If ( abs( pX - 1 - cX ) + abs( pY - cY ) <> 0 ) Then
                  pBomberman.DangerLeft := pBomberman.DangerLeft - 128 div ( abs( pX - 1 - cX ) + abs( pY - cY ) )
               Else
                  pBomberman.DangerLeft := pBomberman.DangerLeft - 256;
               If ( abs( pX + 1 - cX ) + abs( pY - cY ) <> 0 ) Then
                  pBomberman.DangerRight := pBomberman.DangerRight - 128 div ( abs( pX + 1 - cX ) + abs( pY - cY ) )
               Else
                  pBomberman.DangerRight := pBomberman.DangerRight - 256;
               If ( abs( pX - cX ) + abs( pY - 1 - cY ) <> 0 ) Then
                  pBomberMan.DangerUp := pBomberman.DangerUp - 128 div ( abs( pX - cX ) + abs( pY - 1 - cY ) )
               Else
                  pBomberman.DangerUp := pBomberman.DangerRight - 256;
               If ( abs( pX - cX ) + abs( pY + 1 - cY ) <> 0 )Then
                  pBomberman.DangerDown := pBomberman.DangerDown - 128 div ( abs( pX - cX ) + abs( pY + 1 - cY ) )
               Else
                  pBomberman.DangerDown := pBomberman.DangerDown - 256;
                }
                

               // Si les derni�res coordonn�es ne sont pas les m�mes que les actuelles, alors d�terminer pX et pY.
               If ( pX <> lX ) Or ( pY <> lY ) Then Begin
                  // Comparaison des dangers.
                  If ( pBomberman.DangerLeft <= pBomberman.Danger ) And ( pBomberman.DangerLeft <= pBomberman.DangerRight )
                  And ( pBomberman.DangerLeft <= pBomberman.DangerUp ) And ( pBomberman.DangerLeft <= pBomberman.DangerDown ) Then Begin
                     pBomberman.MoveLeft( GetDelta );
                     pBomberman.CanCalculate := false;
                  End
                  Else If ( pBomberman.DangerRight <= pBomberman.Danger ) And ( pBomberman.DangerRight <= pBomberman.DangerUp )
                  And ( pBomberman.DangerRight <= pBomberman.DangerDown ) Then Begin
                     pBomberman.MoveRight( GetDelta );
                     pBomberman.CanCalculate := false;
                  End
                  Else If ( pBomberman.DangerUp <= pBomberman.Danger ) And ( pBomberman.DangerUp <= pBomberman.DangerDown ) Then Begin
                       pBomberman.MoveUp( GetDelta );
                       pBomberman.CanCalculate := false;
                  End
                  Else If ( pBomberman.DangerDown <= pBomberman.Danger ) Then Begin
                       pBomberman.MoveDown( GetDelta );
                       pBomberman.CanCalculate := false;
                  End
                  Else
                      pBomberman.CanCalculate := true;

                  // Le bomberman se d�place donc on initialise les possibilit�s de d�placement.
                  pBomberman.CanGoToTheLeft := true;
                  pBomberman.CanGoToTheRight := true;
                  pBomberman.CanGoToTheUp := true;
                  pBomberman.CanGoToTheDown := true;
               End
               
               // Si les derni�res coordonn�es sont les m�mes que les actuelles alors prendre le plus bas danger possible.
               Else Begin
                  // Si le bomberman ne bouge pas, alors tout recommence.
                  If  ( ( pBomberman.Danger <= pBomberman.DangerLeft ) Or ( pBomberman.CanGoToTheLeft = false ) )
                  And ( ( pBomberman.Danger <= pBomberman.DangerRight ) Or ( pBomberman.CanGoToTheRight = false ) )
                  And ( ( pBomberman.Danger <= pBomberman.DangerUp ) Or ( pBomberman.CanGoToTheUp = false ) )
                  And ( ( pBomberman.Danger <= pBomberman.DangerDown ) Or ( pBomberman.CanGoToTheDown = false ) ) Then Begin
                      pBomberman.CanGoToTheLeft := true;
                      pBomberman.CanGoToTheRight := true;
                      pBomberman.CanGoToTheDown := true;
                      pBomberman.CanGoToTheUp := true;
                      pBomberman.CanCalculate := true;
                  End
                  Else Begin
                  // Sinon, la situation est a d�coinc�e sans recalculer les dangers.
                       pBomberman.CanCalculate := false;
                       
                       If ( ( pBomberman.DangerLeft <= pBomberman.DangerRight ) Or ( pBomberman.CanGoToTheRight = false ) )
                       And ( ( pBomberman.DangerLeft <= pBomberman.DangerUp ) Or ( pBomberman.CanGoToTheUp = false ) )
                       And ( ( pBomberman.DangerLeft <= pBomberman.DangerDown ) Or ( pBomberman.CanGoToTheDown = false ) )
                       And ( pBomberman.CanGoToTheLeft = true ) Then Begin
                           pBomberman.MoveLeft( GetDelta );
                           pBomberman.CanGoToTheLeft := false;
                       End
                       Else If ( ( pBomberman.DangerRight <= pBomberman.DangerUp ) Or ( pBomberman.CanGoToTheUp = false ) )
                       And ( ( pBomberman.DangerRight <= pBomberman.DangerDown ) Or ( pBomberman.CanGoToTheDown = false ) )
                       And ( pBomberman.CanGoToTheRight = true ) Then Begin
                           pBomberman.MoveRight( GetDelta );
                           pBomberman.CanGoToTheRight := false;
                       End
                       Else If ( ( pBomberman.DangerUp <= pBomberman.DangerDown ) Or ( pBomberman.CanGoToTheDown = false ) )
                       And ( pBomberman.CanGoToTheUp = true ) Then Begin
                           pBomberman.MoveUp( GetDelta );
                           pBomberman.CanGoToTheUp := false;
                       End
                       Else Begin
                            pBomberman.MoveDown( GetDelta );
                            pBomberman.CanGoToTheDown := false;
                       End;
                  End;
                  
                  // Si le bomberman n'a plus le droit de bouger, alors toutes les coordonn�es redeviennent possibles.
                  // Cela sert notamment quand la fonction ProcessComputer est lanc�e avant que les d�placements soient autoris�es.
                  If ( pBomberman.CanGoToTheRight = false ) And ( pBomberman.CanGoToTheLeft = false )
                  And ( pBomberman.CanGoToTheDown = false ) And ( pBomberman.CanGoToTheUp = false ) Then Begin
                      pBomberman.CanGoToTheRight := true;
                      pBomberman.CanGoToTheLeft := true;
                      pBomberman.CanGoToTheUp := true;
                      pBomberman.CanGoToTheDown := true;
                  End;
               End;

          End; // Fin de Novice
     End; // Fin du Case Of
     
     // Entr�es des variables locales dans les variables du bomberman.
     pBomberman.CX := cX;
     pBomberman.CY := cY;
     pBomberman.LX := pX;
     pBomberman.LY := pY;
     

     



    { Case nSkill Of
          SKILL_NOVICE :
          Begin
               // si les coordonn�es cibl�es sont toutes deux diff�rentes aux coordonn�es courantes alors
               // on attribue de nouvelles coordonn�es cibles. �a arrive en d�but de partie ou en cas de t�l�portation
               If (pBomberman.CX <> pBomberman.Position.X) And (pBomberman.CY <> pBomberman.Position.Y) Then Begin
                  If Random < 0.5 Then Begin
                     pBomberman.CX := pBomberman.Position.X + (2.0 + Random * 6.0) - 4.0;
                     pBomberman.CY := pBomberman.Position.Y;
                  End Else Begin
                     pBomberman.CX := pBomberman.Position.X;
                     pBomberman.CY := pBomberman.Position.Y + (2.0 + Random * 4.0) - 3.0;
                  End;
               End;
               // si les coordonn�es cibl�es ont �t� atteintes alors on attribue de nouvelles coordonn�es cibles.
               // on a 80% de chances de repartir dans une direction perpendiculaire.
               If (pBomberman.CX = pBomberman.Position.X)  And (Abs(pBomberman.CY - pBomberman.Position.Y) < 0.5) Then Begin
                  If Random < 0.8 Then Begin
                     pBomberman.CX := pBomberman.Position.X + lm * (2.0 + Random * 4.0);
                     pBomberman.CY := pBomberman.Position.Y;
                  End Else If pBomberman.LY > pBomberman.Position.Y Then Begin
                     pBomberman.CX := pBomberman.Position.X;
                     pBomberman.CY := pBomberman.Position.Y + 1.5 + Random * 3.0;
                  End Else If pBomberman.LY < pBomberman.Position.Y Then Begin
                     pBomberman.CX := pBomberman.Position.X;
                     pBomberman.CY := pBomberman.Position.Y - 1.5 + Random * 3.0;
                  End;
               End Else If (pBomberman.CY = pBomberman.Position.Y)  And (Abs(pBomberman.CX - pBomberman.Position.X) < 0.5) Then Begin
                  If Random < 0.8 Then Begin
                     pBomberman.CX := pBomberman.Position.X;
                     pBomberman.CY := pBomberman.Position.Y + lm * (2.0 + Random * 4.0);
                  End Else If pBomberman.LX > pBomberman.Position.X Then Begin
                     pBomberman.CX := pBomberman.Position.X + 1.5 + Random * 3.0;
                     pBomberman.CY := pBomberman.Position.Y;
                  End Else If pBomberman.LX < pBomberman.Position.X Then Begin
                     pBomberman.CX := pBomberman.Position.X - 1.5 + Random * 3.0;
                     pBomberman.CY := pBomberman.Position.Y;
                  End;
               End;
               // si on fait face � un obstacle (coordonn�es courantes �gales aux derni�res) alors on attribue
               // de nouvelles coordonn�es cibles. on a 80% de chances de repartir dans la direction oppos�e.
               If (pBomberman.LX = pBomberman.Position.X) And (pBomberman.LY = pBomberman.Position.Y) Then Begin
                  If pBomberman.CX > pBomberman.Position.X Then Begin
                      If Random < 0.8 Then Begin
                         pBomberman.CX := pBomberman.Position.X - 2.0 + Random * 4.0;
                         pBomberman.CY := pBomberman.Position.Y;
                      End Else Begin
                         pBomberman.CX := pBomberman.Position.X;
                         pBomberman.CY := pBomberman.Position.Y + lm * (1.5 + Random * 3.0);
                      End;
                  End Else If pBomberman.CX < pBomberman.Position.X Then Begin
                      If Random < 0.8 Then Begin
                         pBomberman.CX := pBomberman.Position.X + 2.0 + Random * 4.0;
                         pBomberman.CY := pBomberman.Position.Y;
                      End Else Begin
                         pBomberman.CX := pBomberman.Position.X;
                         pBomberman.CY := pBomberman.Position.Y + lm * (1.5 + Random * 3.0);
                      End;
                  End Else If pBomberman.CY > pBomberman.Position.Y Then Begin
                      If Random < 0.8 Then Begin
                         pBomberman.CX := pBomberman.Position.X;
                         pBomberman.CY := pBomberman.Position.Y - 1.5 + Random * 3.0;
                      End Else Begin
                         pBomberman.CX := pBomberman.Position.X + lm * (2.0 + Random * 4.0);
                         pBomberman.CY := pBomberman.Position.Y;
                      End;
                  End Else If pBomberman.CY < pBomberman.Position.Y Then Begin
                      If Random < 0.8 Then Begin
                         pBomberman.CX := pBomberman.Position.X;
                         pBomberman.CY := pBomberman.Position.Y + 1.5 + Random * 3.0;
                      End Else Begin
                         pBomberman.CX := pBomberman.Position.X + lm * (2.0 + Random * 4.0);
                         pBomberman.CY := pBomberman.Position.Y;
                      End;
                  End;
               End;
               // on remplace les derni�res coordonn�es par les coordonn�es courantes.
               pBomberman.LX := pBomberman.Position.X;
               pBomberman.LY := pBomberman.Position.Y;
               // on g�re le d�placement en fonction des coordonn�es cibl�es.
               If pBomberman.CX > pBomberman.Position.X Then pBomberman.MoveRight( GetDelta );
               If pBomberman.CX < pBomberman.Position.X Then pBomberman.MoveLeft( GetDelta );
               If pBomberman.CY > pBomberman.Position.Y Then pBomberman.MoveDown( GetDelta );
               If pBomberman.CY < pBomberman.Position.Y Then pBomberman.MoveUp( GetDelta );

               t := 0.0;
               // on �value le risque de se prendre une flamme avec les nouvelles coordonn�es. comme on est
               // novice on avoir 80% de chances de crever en passant dans des flammes.
               k := 1;
               While ( k <= GetFlameCount() ) Do Begin
                   If (Trunc(pBomberman.Position.X + 0.5) = GetFlameByCount(k).X) And (Trunc(pBomberman.Position.Y + 0.5) = GetFlameByCount(k).Y) Then t += 0.8;
                   k += 1;
               End;
               // on ajoute � cela le risque de crever en �tant sur la trajectoire d'une bombe. de m�me
               // en novice on �value ce risque � 20%.
               k := 1;
               While ( k <= GetBombCount() ) Do Begin
                   If (Trunc(pBomberman.Position.X + 0.5) = Trunc(GetBombByCount(k).Position.X + 0.5)) Or (Trunc(pBomberman.Position.Y + 0.5) = Trunc(GetBombByCount(k).Position.Y + 0.5)) Then t += 0.2;
                   k += 1;
               End;
               // s'il y a un risque sup�rieur aux nouvelles coordonn�es alors on r�attribue les anciennes.
               If (Random < t) And (pBomberman.Danger < t) Then Begin
                  pBomberman.Position.X := pBomberman.LX;
                  pBomberman.Position.Y := pBomberman.LY;
               End;
               pBomberman.Danger := t;
               
               // � chaque mise � jour on a 3% de chances de poser une bombe.
               If Random < 0.5 * GetDelta Then pBomberman.CreateBomb( GetDelta );
          End;
     End;  }
End;

Function CalculateFastDanger ( x : integer ; y : integer ; pState : Table ) : integer ;
Var
   result1 : integer;                            // r�sultat renvoy�
   i, j : integer;
   cLeft, cRight, cUp, cDown : integer;          // limites pour les calculs du tableau.
Begin
// Initialisation des variables
   result1 := 0;                                 // Le minimum est 0, le maximum est autour de 10000.
   If ( x - 3 < 1 ) Then cLeft := 1 Else cLeft := x - 3;
   If ( x + 3 > GRIDWIDTH ) Then cRight := GRIDWIDTH Else cRight := x + 3;
   If ( y - 3 < 1 ) Then cUp := 1 Else cUp := y - 3;
   If ( y + 3 > GRIDHEIGHT ) Then cDown := GRIDHEIGHT Else cDown := y + 3;

// Traitement des flammes et des bombes.
   For i :=  cLeft To cRight Do Begin
       For j := cUp To cDown Do Begin
           If (i <> x) Or ( j <> y )Then Begin   // Pour Ariane V...
           // Traitement des flammes
              If ( pState[i, j] mod 2 = 1 ) Then
                 result1 := result1 + 2048 div ( abs(x - i) + abs(y - j) );
           // Traitement des bombes
              If ( pState[i, j] mod 4 >= 2 ) Then Begin
                 // Si le bomberman est dans le champ de tir de la bombe, alors le danger est tr�s grand.
                 If ( x = i ) Or ( y = j ) Then
                    result1 := result1 + 1024 div( abs(x - i) + abs(y - j) )
                 // Sinon le danger est relativement faible.
                 Else
                     result1 := result1 + 128 div ( abs(x - i) + abs(y - j) );
              End;
           End;
       End;
   End;

CalculateFastDanger := result1;
End;

Function CalculateSlowDanger ( x : integer ; y : integer ; pState :  Table ) : integer ; // A faire
Var
   result2 : integer;                            // r�sultat renvoy�
   i, j : integer;
Begin
// Initialisation des variables
   result2 := 0;                                 // Le minimum est 0, le maximum est autour de 10000.

// Traitement des flammes et des bombes.
   For i := 1 To GRIDWIDTH Do Begin
       For j := 1 To GRIDHEIGHT Do Begin
           If (i <> x) Or ( j <> y )Then Begin   // Pour Ariane V...
           // Traitement des flammes
              If ( pState[i, j] mod 2 = 1 ) Then
                 result2 := result2 + 2048 div ( abs(x - i) + abs(y - j) );
           // Traitement des bombes
              If ( pState[i, j] mod 4 >= 2 ) Then Begin
              // Si le bomberman est dans le champ de tir de la bombe, alors le danger est tr�s grand.
                 If ( x = i ) Or ( y = j ) Then
                    result2 := result2 + 1024 div ( abs(x - i) + abs(y - j) )
              // Sinon le danger est relativement faible.
                 Else
                     result2 := result2 + 256 div ( abs(x - i) + abs(y - j) );
              End;
           // Traitement des bombermans ( pas trop pr�t ni trop loin )
              If ( pState[i, j] >= 4 ) Then Begin
                 If ( ( abs(x - i) + abs(y - j) ) <= 2 ) Then
                    result2 := result2 + 64 div ( abs(x - i) + abs(y - j) );
                 If ( ( abs(x - i) + abs(y - j) ) >= 8 ) Then
                    result2 := result2 - 64 div ( abs(x - i) + abs(y - j) );
              End;
           End;
       End;
   End;

CalculateSlowDanger := result2;
End;

End.
