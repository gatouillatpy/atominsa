Unit UComputer;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils,
     UCore, UUtils, UBomberman, UForm, UFlame, UListBomb;

Type Table = Array [1..GRIDWIDTH,1..GRIDHEIGHT] Of Integer;

Procedure ProcessComputer ( pBomberman : CBomberman ; nSkill : Integer ) ;
Function CalculateFastDanger ( x : Integer ; y : Integer ; pState : Table ; iSkill : Integer ) : Integer ;
Function CalculateDanger ( x : Integer ; y : Integer ; xMin : Integer ; xMax : Integer ; yMin : Integer ;
                         yMax : Integer ; wState : Table ; wSkill : Integer ; canPush : Boolean ) : Integer ;
Function PutBomb( x : Integer ; y : Integer ; pState : Table; wSkill : Integer ) : Boolean ;



Implementation

Uses UGame, UBlock, UItem, UTriggerBomb, UDisease, USuperDisease;


Const SKILL_NOVICE         = 1;
Const SKILL_AVERAGE        = 2;
Const SKILL_MASTERFUL      = 3;
Const SKILL_GODLIKE        = 4;



Procedure ProcessComputer ( pBomberman : CBomberman ; nSkill : Integer ) ;

Var
    i, j, k : Integer;
    isBombermanFound,                                                // Le bomberman a-t-il déjà été comptabilisé dans le tableau
    continue,                                                        // La boucle while doit-elle être continuée
    canPush,                                                         // Le bomberman peut pousser la bombe (donc n'est pas sur la bombe)
    doExplosion : Boolean;                                           // Le bomberman doit-il faire exploser sa Trigger Bombe
    bLeft, bDown, bUp, bRight : Integer;                             // Limites pour les calculs dans le tableau
    dangerMin : Integer;                                             // Le danger minimal connu pour l'instant
    sum : Integer;                                                   // La somme des dangers sans tenir compte des blocks et des bords.
    pX, pY, cX, cY, lX, lY, bX, bY : Integer;                        // Renommage des coordonnées pour améliorer la lisibilité du code.
    aState : Array [1..GRIDWIDTH,1..GRIDHEIGHT] Of Integer ;         // tableau du contenu de chaque case, 0 pour vide, 1 pour flamme, 2 pour bombe et 4 pour autre bomberman.
Begin

Randomize;

// Initialisation des variables.
   pX := Trunc(pBomberman.Position.X + 0.5);
   pY := Trunc(pBomberman.Position.Y + 0.5);
   cX := Trunc(pBomberman.CX + 0.5);
   cY := Trunc(pBomberman.CY + 0.5);
   lX := Trunc(pBomberman.LX + 0.5);
   lY := Trunc(pBomberman.LY + 0.5);
   dangerMin := 10000;
   isBombermanFound := false;
   pBomberman.SumGetDelta := pBomberman.SumGetDelta + GetDelta;
   

// Mise à jour du tableau.
     
     // On met toutes les données à 0.
     For i := 1 To GRIDWIDTH Do Begin
         For j := 1 To GRIDHEIGHT Do Begin
             aState[i,j] := 0;
         End;
     End;

     // On ajoute 1 à chaque case qui contient une flamme.
     For k := 1 To GetFlameCount() Do Begin
         aState[GetFlameByCount(k).X, GetFlameByCount(k).Y] += 1;
     End;

     // On ajoute 2 à chaque case qui contient une bombe.
     For k := 1 To GetBombCount() Do Begin
         aState[Trunc(GetBombByCount(k).Position.X + 0.5), Trunc(GetBombByCount(k).Position.Y + 0.5)] += 2;
     End;
     
     // On ajoute 4 à chaque case qui contient un personnage autre que l'IA
     For k := 1 To GetBombermanCount() Do Begin
         If ( Trunc(GetBombermanByCount(k).Position.X + 0.5) <> pX )
         Or ( Trunc(GetBombermanByCount(k).Position.Y + 0.5) <> pY )
         Or ( isBombermanFound = true ) Then Begin
             aState[Trunc(GetBombermanByCount(k).Position.X + 0.5), Trunc(GetBombermanByCount(k).Position.Y + 0.5)] += 4;
         End
         Else isBombermanFound := true;
     End;
     
     // On ajoute 8 à chaque case qui contient un block et 16 à celles qui continennent un bonus.
     For i := 1 To GRIDWIDTH Do Begin
         For j := 1 To GRIDHEIGHT Do Begin
             If ( pGrid.GetBlock(i,j) Is CBlock ) And ( aState[i, j] mod 4 < 2 ) Then Begin
                If ( Not( pGrid.GetBlock(i,j) Is CItem ) ) Or ( (pGrid.GetBlock(i,j) As CItem).IsExplosed() = false ) Then
                   aState[i, j] += 8;
                If ( pGrid.GetBlock(i,j) is CItem ) And ( (pGrid.GetBlock(i,j) As CItem).IsExplosed() = true ) Then
                   aState[i, j] += 16;
             End;
         End;
     End;


        
// Mise à jour des dangers s'il ne vient pas de bouger
   If ( pBomberman.CanCalculate = true ) Or ( pBomberman.Position.X <> pBomberman.LX )
   Or ( pBomberman.Position.Y <> pBomberman.LY )Then Begin
      If ( pBomberman.Kick = true ) Or ( pBomberman.Punch = true ) Then
         canPush := true
      Else
          canPush := false;
      pBomberman.Danger := CalculateDanger(pX, pY, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, false);
      pBomberman.DangerLeft := CalculateDanger(pX - 1, pY, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush);
      pBomberman.DangerRight := CalculateDanger(pX + 1, pY, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush);
      pBomberman.DangerUp := CalculateDanger(pX, pY - 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush);
      pBomberman.DangerDown := CalculateDanger(pX, pY + 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush);
   End;



// Calcul des coordonnées cibles.
   If ( pBomberman.CanCalculate = true ) Or ( pBomberman.Position.X <> pBomberman.LX )
   Or ( pBomberman.Position.Y <> pBomberman.LY )Then Begin
               
   // Si les coordonnées ciblées sont atteintes ou obsolètes, alors on calcule de nouvelles coordonnées cibles.
      If ( ( cX = pX ) And ( cY = pY ) ) Or ( pBomberman.SumGetDelta >= 4 ) Then Begin
      // On fixe les limites du rectangle dans lequel on va calculer les dangers.
         If ( pX - 2 < 1 ) Then bLeft := 1 Else bLeft := pX - 2;
         If ( pX + 2 > GRIDWIDTH ) Then bRight := GRIDWIDTH Else bRight := pX + 2;
         If ( pY - 2 < 1 ) Then bUp := 1 Else bUp := pY - 2;
         If ( pY + 2 > GRIDHEIGHT ) Then bDown := GRIDHEIGHT Else bDown := pY + 2;
                  
      // Puis on calcule les dangers et sélectionne le minimum.
         For i := bLeft To bRight Do Begin
             For j := bUp To bDown Do Begin
                  If ( CalculateFastDanger( i, j, aState, nSkill ) < dangerMin )
                  Or ( ( CalculateFastDanger( i, j, aState, nSkill ) = dangerMin )
                  And ( Random < 0.5 ) ) Then Begin
                      cX := i;
                      cY := j;
                      dangerMin := CalculateFastDanger(i, j, aState, nSkill);
                  End;
             End;
         End;
         pBomberman.SumGetDelta := 0;
      End;


      // Prise en compte de la cible dans les dangers.
      If ( abs( pX - cX ) + abs( pY - cY ) <> 0 ) Then
         pBomberman.Danger := pBomberman.Danger - 16 div ( abs( pX - cX ) + abs( pY - cY ) )
      Else
          pBomberman.Danger := pBomberman.Danger - 32;
      If ( abs( pX - 1 - cX ) + abs( pY - cY ) <> 0 ) Then
         pBomberman.DangerLeft := pBomberman.DangerLeft - 16 div ( abs( pX - 1 - cX ) + abs( pY - cY ) )
      Else
          pBomberman.DangerLeft := pBomberman.DangerLeft - 32;
      If ( abs( pX + 1 - cX ) + abs( pY - cY ) <> 0 ) Then
         pBomberman.DangerRight := pBomberman.DangerRight - 16 div ( abs( pX + 1 - cX ) + abs( pY - cY ) )
      Else
          pBomberman.DangerRight := pBomberman.DangerRight - 32;
      If ( abs( pX - cX ) + abs( pY - 1 - cY ) <> 0 ) Then
         pBomberMan.DangerUp := pBomberman.DangerUp - 16 div ( abs( pX - cX ) + abs( pY - 1 - cY ) )
      Else
          pBomberman.DangerUp := pBomberman.DangerRight - 32;
      If ( abs( pX - cX ) + abs( pY + 1 - cY ) <> 0 )Then
         pBomberman.DangerDown := pBomberman.DangerDown - 16 div ( abs( pX - cX ) + abs( pY + 1 - cY ) )
      Else
          pBomberman.DangerDown := pBomberman.DangerDown - 32;
   End;



// Si les touches sont inversées et que le niveau et godlike, alors les préférences sont inversées.
   If ( nSkill = SKILL_GODLIKE ) And ( pBomberman.Reverse = true ) Then Begin
       dangerMin := pBomberman.DangerLeft;
       pBomberman.DangerLeft := pBomberman.DangerRight;
       pBomberman.DangerRight := dangerMin;
       dangerMin := pBomberman.DangerUp;
       pBomberman.DangerUp := pBomberman.DangerDown;
       pBomberman.DangerDown := dangerMin;
   End;



// Explosion des bombes pour le niveau godlike
   If ( nSkill = SKILL_GODLIKE ) And ( pBomberman.TriggerBomb <> nil ) Then Begin
      // Initialisation des données
      doExplosion := false;
      bX := Trunc(pBomberman.TriggerBomb^.Bomb.Position.X + 0.5);
      bY := Trunc(pBomberman.TriggerBomb^.Bomb.Position.Y + 0.5);
      If ( bX - pBomberman.FlameSize <= 1 ) Then bLeft := 1 Else bLeft := bX - pBomberman.FlameSize;
      If ( bX + pBomberman.FlameSize >= GRIDWIDTH ) Then bRight := GRIDWIDTH Else bRight := bX + pBomberman.FlameSize;
      If ( bY - pBomberman.FlameSize <= 1 ) Then bUp := 1 Else bUp := bY - pBomberman.FlameSize;
      If ( bY + pBomberman.FlameSize >= GRIDHEIGHT ) Then bDown := GRIDHEIGHT Else bDown := bY + pBomberman.FlameSize;

      // S'il y a quelqu'un sur la ligne/colonne de la bombe et qu'il n'y a pas de bloc ou de bonus entre alors on fait exploser la bombe
      // Gauche
      continue := true;
      i := bX - 1;
      While ( continue = true ) And ( i >= bLeft ) Do Begin
            If ( aState[i, bY] mod 8 >= 4 ) Then
               doExplosion := true;
            If ( aState[i, bY] >= 8 ) Then
               continue := false;
            i -= 1;
      End;
      // Droite
      continue := true;
      i := bX + 1;
      While ( continue = true ) And ( i <= bRight ) Do Begin
            If ( aState[i, bY] mod 8 >= 4 ) Then
               doExplosion := true;
            If ( aState[i, bY] >= 8 ) Then
               continue := false;
            i += 1;
      End;
      // Haut
      continue := true;
      j := bY - 1;
      While ( continue = true ) And ( j >= bUp ) Do Begin
            If ( aState[bX, j] mod 8 >= 4 ) Then
               doExplosion := true;
            If ( aState[bX, j] >= 8 ) Then
               continue := false;
            j -= 1;
      End;
      // Bas
      continue := true;
      j := bY + 1;
      While ( continue = true ) And ( j <= bDown ) Do Begin
            If ( aState[bX, j] mod 8 >= 4 ) Then
               doExplosion := true;
            If ( aState[bX, j] >= 8 ) Then
               continue := false;
            j += 1;
      End;

      // S'il le bomberman est sur la ligne/colonne de la bombe, alors on ne fait pas exploser la bombe
      // Gauche
      continue := true;
      i := bX - 1;
      While ( continue = true ) And ( i >= bLeft ) Do Begin
            If ( pX = i ) And ( pY = bY ) Then
               doExplosion := false;
            If ( aState[i, bY] >= 8 ) Then
               continue := false;
            i -= 1;
      End;
      // Droite
      continue := true;
      i := bX + 1;
      While ( continue = true ) And ( i <= bRight ) Do Begin
            If ( pX = i ) And ( pY = bY ) Then
               doExplosion := false;
            If ( aState[i, bY] >= 8 ) Then
               continue := false;
            i += 1;
      End;
      // Haut
      continue := true;
      j := bY - 1;
      While ( continue = true ) And ( j >= bUp ) Do Begin
            If ( pX = bX ) And ( pY = j ) Then
               doExplosion := false;
            If ( aState[bX, j] >= 8 ) Then
               continue := false;
            j -= 1;
      End;
      // Bas
      continue := true;
      j := bY + 1;
      While ( continue = true ) And ( j <= bDown ) Do Begin
            If ( pX = bX ) And ( pY = j ) Then
               doExplosion := false;
            If ( aState[bX, j] >= 8 ) Then
               continue := false;
            j += 1;
      End;

      // Explosion de la bombe si nécessaire
      If ( doExplosion = true ) Then
         pBomberman.DoIgnition();
   End;



// Si les dernières coordonnées ne sont pas les mêmes que les actuelles, alors déterminer pX et pY.
   If ( pBomberman.Position.X <> pBomberman.LX )
   Or ( pBomberman.Position.Y <> pBomberman.LY ) Then Begin
      // Mise à jour de lX et lY
      pBomberman.LX := pBomberman.Position.X;
      pBomberman.LY := pBomberman.Position.Y;

      // Comparaison des dangers.
      If ( pBomberman.DangerLeft < pBomberman.Danger ) And ( pBomberman.DangerLeft <= pBomberman.DangerRight )
      And ( pBomberman.DangerLeft <= pBomberman.DangerUp ) And ( pBomberman.DangerLeft <= pBomberman.DangerDown ) Then Begin
         pBomberman.MoveLeft( GetDelta );
         pBomberman.CanCalculate := false;
      End
      Else If ( pBomberman.DangerRight < pBomberman.Danger ) And ( pBomberman.DangerRight <= pBomberman.DangerUp )
      And ( pBomberman.DangerRight <= pBomberman.DangerDown ) Then Begin
         pBomberman.MoveRight( GetDelta );
         pBomberman.CanCalculate := false;
      End
      Else If ( pBomberman.DangerUp < pBomberman.Danger ) And ( pBomberman.DangerUp <= pBomberman.DangerDown ) Then Begin
           pBomberman.MoveUp( GetDelta );
           pBomberman.CanCalculate := false;
      End
      Else If ( pBomberman.DangerDown < pBomberman.Danger ) Then Begin
           pBomberman.MoveDown( GetDelta );
           pBomberman.CanCalculate := false;
      End
      Else
          pBomberman.CanCalculate := true;

      // Le bomberman se déplace donc on initialise les possibilités de déplacement.
      If ( pX <> lX ) Or ( pY <> lY ) Then Begin
          pBomberman.CanGoToTheLeft := true;
          pBomberman.CanGoToTheRight := true;
          pBomberman.CanGoToTheUp := true;
          pBomberman.CanGoToTheDown := true;
      End;
   End

// Si les dernières coordonnées sont les mêmes que les actuelles alors prendre le plus bas danger possible.
   Else Begin
      // Mise à jour de lX et lY
      pBomberman.LX := pBomberman.Position.X;
      pBomberman.LY := pBomberman.Position.Y;

      // Si le bomberman ne bouge pas, alors tout recommence.
      // Sinon, il y a des problèmes...
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
      // Sinon, la situation est a décoincée sans recalculer les dangers.
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

      // Si le bomberman n'a plus le droit de bouger, alors toutes les coordonnées redeviennent possibles.
      // Cela sert notamment quand la fonction ProcessComputer est lancée avant que les déplacements soient autorisées.
      If ( pBomberman.CanGoToTheRight = false ) And ( pBomberman.CanGoToTheLeft = false )
      And ( pBomberman.CanGoToTheDown = false ) And ( pBomberman.CanGoToTheUp = false ) Then Begin
          pBomberman.CanGoToTheRight := true;
          pBomberman.CanGoToTheLeft := true;
          pBomberman.CanGoToTheUp := true;
          pBomberman.CanGoToTheDown := true;
      End;
   End;



// Posage de bombes
   // On ajoute le danger à la somme sans tenir compte des murs.
   sum := pBomberman.Danger + pBomberman.DangerLeft + pBomberman.DangerRight + pBomberman.DangerUp
         + pBomberman.DangerDown;
   If ( pX = 1 ) Or ( aState[ pX - 1, pY ] mod 16 >= 8 ) Then sum := sum - 8192;      // On retire les dangers des bords et des blocs.
   If ( pX = 15 ) Or ( aState[ pX + 1, pY ] mod 16 >= 8 ) Then sum := sum - 8192;
   If ( pY = 1 ) Or ( aState[ pX, pY - 1 ] mod 16 >= 8 ) Then sum := sum - 8192;
   If ( pY = 11 ) Or ( aState[ pX, pY + 1 ] mod 16 >= 8 ) Then sum := sum - 8192;
   
   // Si le bomberman vient de bouger et qu'il n'y a pas trop de danger autour, alors il peut créer une bombe.
   // Si le bomberman est malade et que le niveau est godlike, alors il ne pose pas la bombe.
   If ( ( pBomberman.Position.X <> pBomberman.LX ) Or ( pBomberman.Position.Y <> pBomberman.LY ) )
   And ( sum < 1024 )
   And ( ( nSkill <> SKILL_GODLIKE ) Or ( pBomberman.ExploseBombTime >= 3 ) )
   And ( PutBomb( Trunc( pBomberman.Position.X + 0.5), Trunc( pBomberman.Position.Y + 0.5 ), aState, nSkill ) = true ) Then
       pBomberman.CreateBomb( GetDelta );


     
// Entrées des variables locales dans les variables du bomberman.
     pBomberman.CX := cX;
     pBomberman.CY := cY;

End;






Function CalculateFastDanger ( x : Integer ; y : Integer ; pState : Table ; iSkill : Integer ) : Integer ;
Var
   result1 : Integer;                            // résultat renvoyé
   cLeft, cRight, cUp, cDown : Integer;          // limites pour les calculs du tableau.
Begin
// Initialisation des variables
   result1 := 0;                                 // Le minimum est 0, le maximum est autour de 10000.
   If ( x - 3 < 1 ) Then cLeft := 1 Else cLeft := x - 3;
   If ( x + 3 > GRIDWIDTH ) Then cRight := GRIDWIDTH Else cRight := x + 3;
   If ( y - 3 < 1 ) Then cUp := 1 Else cUp := y - 3;
   If ( y + 3 > GRIDHEIGHT ) Then cDown := GRIDHEIGHT Else cDown := y + 3;

// Traitement des flammes, des bombes et des bombermans.
   result1 := CalculateDanger( x, y, cLeft, cRight, cUp, cDown, pState, iSkill, false );
// Pour que les coins ne soient pas favorisés.
   result1 := result1 * 49 div ( ( cRight - cLeft + 1 ) *  ( cDown - cUp + 1 ) );

CalculateFastDanger := result1;
End;




Function CalculateDanger ( x : Integer ; y : Integer ; xMin : Integer ; xMax : Integer ; yMin : Integer ;
                         yMax : Integer ; wState : Table ; wSkill : Integer ; canPush : Boolean ) : Integer ;
Var
   iBomb,                                        // Position de la bombe
   iExit,                                        // Position de la sortie
   nbrFreeCase,                                  // Numéro de la case libre (1:gauche,2:droite,3:haut,4:bas)
   sumFreeCases,                                 // Nombres de cases libres.
   result2 : Integer;                            // Résultat renvoyé
   i, j : Integer;
   continue,                                     // Vrai si on doit continuer la boucle while
   freeCase,                                     // Vrai si une case est libre
   upBomb, downBomb,                             // Vrai s'il y a une bombe sur la ligne/colonne supérieure (resp. inférieure)
   blocked : Boolean;                            // Vrai si le bomberman est coincé ( avec au maximum une case de liberté ).
Begin
// Initialisation des variables
   result2 := 0;                                 // Le minimum est 0, le maximum est autour de 10000.

// Traitement des objets.
   For i := xMin To xMax Do Begin
       For j := yMin To yMax Do Begin
       // Traitement des objets qui sont sur des cases différentes.
           If (i <> x) Or ( j <> y )Then Begin
           // Traitement des flammes
              If ( wState[i, j] mod 2 = 1 ) Then
                 result2 := result2 + 128 div ( abs(x - i) + abs(y - j) );
           // Traitement des bombes
              If ( wState[i, j] mod 4 >= 2 ) Then Begin
              // Si le bomberman est dans le champ de tir de la bombe et qu'il n'y a pas de bombe entre, alors le danger est très grand.
                 continue := false;
                 If ( x = i ) Then Begin
                    continue := true;
                    If ( y > j ) Then iBomb := j + 1 Else iBomb := j - 1;
                    While ( continue = true ) And ( iBomb <> y ) Do Begin
                          If ( wState[i, iBomb] mod 16 >= 8 ) Then
                             continue := false;
                          If ( y > iBomb ) Then iBomb := iBomb + 1 Else iBomb := iBomb - 1;
                    End;
                    If ( continue = true ) Then
                       If ( abs(y -  j) <= 2 ) Then result2 := result2 + 1024 Else result2 := result2 + 2048 div abs(y - j);
                 End;
                 If ( y = j ) Then Begin
                    continue := true;
                    If ( x > i ) Then iBomb := i + 1 Else iBomb := i - 1;
                    While ( continue = true ) And ( iBomb <> x ) Do Begin
                          If ( wState[iBomb, j] mod 16 >= 8 ) Then
                             continue := false;
                          If ( x > iBomb ) Then iBomb := iBomb + 1 Else iBomb := iBomb - 1;
                    End;
                    If ( continue = true ) Then
                       If ( abs(x - i) <= 2 ) Then result2 := result2 + 1024 Else result2 := result2 + 2048 div abs(x - i);
                 End;
              // Sinon le danger est relativement faible.
                 If ( ( x <> i ) And ( y <> j ) ) Or ( continue = false ) Then
                     result2 := result2 + 128 div ( abs(x - i) + abs(y - j) );
              End;
           // Traitement des bombermans si le bomberman n'est pas sur la même case.
              If ( wState[i, j] mod 8 >= 4 ) Then Begin
                 If ( ( abs(x - i) + abs(y - j) ) <= 4 ) Then
                    result2 := result2 + 32;
                 If ( ( abs(x - i) + abs(y - j) ) >= 6 ) Then
                    result2 := result2 - 16;
              End;
           // Traitement des bonus pour le niveau godlike.
              If ( wSkill = SKILL_GODLIKE ) And ( wState[i, j] >= 16 ) Then Begin
                 If ( (pGrid.GetBlock(i,j) As CItem) is CDisease )
                 Or ( (pGrid.GetBlock(i,j) As CItem) is CSuperDisease ) Then
                    result2 := result2 + 16 div ( abs(x - i) + abs(y - j) )
                 Else
                     result2 := result2 - 16 div ( abs(x - i) + abs(y - j) );
              End;

           End

       // Traitement des objets situés sur la même case.
           Else Begin
           // Traitement des flammes.
              If ( wState[i, j] mod 2 = 1 ) Then
                 result2 := result2 + 4096;
           // Traitement des bombes.
              // Si le niveau est godlike est que le bomberman peut pousser la bombe, alors elle ne représente pas un danger.
              If ( wState[i, j] mod 4 >= 2 ) And ( ( wSkill <> SKILL_GODLIKE ) Or ( canPush = false ) ) Then
                 result2 := result2 + 2048;
           // Traitement des bombermans situés sur le même case.
              If ( wState[i, j] mod 8 >= 4 ) Then
                 result2 := result2 + 64;
           // Traitement des blocks.
              If ( wState[i, j] mod 16 >= 8 ) Then
                 result2 := result2 + 8192;
           // Traitement des bonus pour le niveau godlike.
              If ( wSkill = SKILL_GODLIKE ) And ( wState[i, j] >= 16 ) Then Begin
                 If ( (pGrid.GetBlock(i,j) As CItem) is CDisease )
                 And ( (pGrid.GetBlock(i,j) As CItem) is CSuperDisease ) Then
                    result2 := result2 + 32
                 Else
                     result2 := result2 - 32;
              End;

           End;
       End;
   End;
   
   // Traitement des cases hors plateau.
   If ( x < 1 ) Or ( x > GRIDWIDTH ) Or ( y < 1 ) Or ( y > GRIDHEIGHT ) Then
      result2 := result2 + 8192;
      
      
      
// Traitement des cases sans issues pour les niveaux average, masterful et godlike.
   // Si pour chaque côté, il n'y a pas de case de sortie après celle du côté
   // et qu'un bomberman est proche, alors il y a danger.
   // Ca sert à ne pas se faire coincer dans un coin.
   If ( wSkill <> SKILL_NOVICE ) Then Begin
      // S'il n'y a pas de bomberman à moins de 4 cases, alors il n'y a pas de danger.
      blocked := false;
      freeCase := false;
      sumFreeCases := 0;                // répresente le nombre de cases libres.
      If ( x < 4 ) Then xMin := 1 Else xMin := x - 3;
      If ( x > GRIDWIDTH - 3 ) Then xMax := GRIDWIDTH Else xMax := x + 3;
      If ( y < 4 ) Then yMin := 1 Else yMin := y - 3;
      If ( x > GRIDHEIGHT - 3 ) Then yMax := GRIDHEIGHT Else yMax := y + 3;

      For i := xMin To xMax Do Begin
          For j := yMin To yMax Do Begin
              If ( wState[i, j] mod 8 >= 4 ) Then
                 blocked := true;
          End;
      End;
      
      // Pour la case de gauche, s'il y a deux cases libres de suite alors, il n'y a pas de danger.
      If ( x > 1 ) And ( ( wState[x - 1, y] = 0 ) Or ( wState[x - 1, y] = 4 ) ) Then Begin
         sumFreeCases := sumFreeCases + 1;
         If ( ( ( x > 2 ) And ( ( wState[x - 2, y] = 0 ) Or ( wState[x - 2, y] = 4 ) ) )
         Or ( ( y > 1 ) And ( ( wState[x - 1, y - 1] = 0 ) Or ( wState[x - 1, y - 1] = 4 ) ) )
         Or ( ( y < GRIDHEIGHT ) And ( ( wState[x - 1, y + 1] = 0 ) Or ( wState[x - 1, y + 1] = 4 ) ) ) ) Then Begin
            freeCase := true;
            sumFreeCases := sumFreeCases + 1;
         End;
      End;
      // Droite.
      If ( x < GRIDWIDTH ) And ( ( wState[x + 1, y] = 0 ) Or ( wState[x + 1, y] = 4 ) ) Then Begin
         sumFreeCases := sumFreeCases + 1;
         If ( ( ( x < GRIDWIDTH - 1 ) And ( ( wState[x + 2, y] = 0 ) Or ( wState[x + 2, y] = 4 ) ) )
         Or ( ( y > 1 ) And ( ( wState[x + 1, y - 1] = 0 ) Or ( wState[x + 1, y - 1] = 4 ) ) )
         Or ( ( y < GRIDHEIGHT ) And ( ( wState[x + 1, y + 1] = 0 ) Or ( wState[x + 1, y + 1] = 4 ) ) ) ) Then Begin
            If ( freeCase = true ) Then blocked := false Else freeCase := true;
            sumFreeCases := sumFreeCases + 1;
         End;
      End;
      // Haut
      If ( y > 1 ) And ( ( wState[x, y - 1] = 0 ) Or ( wState[x, y - 1] = 4 ) ) Then Begin
         sumFreeCases := sumFreeCases + 1;
         If ( ( ( y > 2 ) And ( ( wState[x, y - 2] = 0 ) Or ( wState[x, y - 2] = 4 ) ) )
         Or ( ( x > 1 ) And ( ( wState[x - 1, y - 1] = 0 ) Or ( wState[x - 1, y - 1] = 4 ) ) )
         Or ( ( x < GRIDWIDTH ) And ( ( wState[x + 1, y - 1] = 0 ) Or ( wState[x + 1, y - 1] = 4 ) ) ) ) Then Begin
            If ( freeCase = true ) Then blocked := false Else freeCase := true;
            sumFreeCases := sumFreeCases + 1;
         End;
      End;
      // Bas
      If  ( y < GRIDHEIGHT ) And ( ( wState[x, y + 1] = 0 ) Or ( wState[x, y + 1] = 4 ) ) Then Begin
          sumFreeCases := sumFreeCases + 1;
          If ( ( ( y < GRIDHEIGHT - 1 ) And ( ( wState[x, y + 2] = 0 ) Or ( wState[x, y + 2] = 4 ) ) )
          Or ( ( x > 1 ) And ( ( wState[x - 1, y + 1] = 0 ) Or ( wState[x - 1, y + 1] = 4 ) ) )
          Or ( ( x < GRIDWIDTH ) And ( ( wState[x + 1, y + 1] = 0 ) Or ( wState[x + 1, y + 1] = 4 ) ) ) ) Then Begin
             If ( freeCase = true ) Then blocked := false Else freeCase := true;
             sumFreeCases := sumFreeCases + 1;
          End;
      End;

      // Plus le nombre de cases libres est grand, plus le danger est faible. Si ce coefficient est trop faible, alors il
      // se coince car il a peur des bombermans. Si ce coefficient est trop fort, alors il ne fait plus attention aux bombes.
      If ( blocked = true ) Then
         result2 := result2 + 512 div ( 8 + sumFreeCases );



// Traitement des bombes pour les niveaux average, masterful et godlike.
   // Ca sert à ne pas se coincer dans un coin juste après avoir poser une bombe et en sortir si c'est possible.
      // Si le bomberman ne peut se déplacer que dans le sens dans la bombe qui est proche, alors il le fait.
      blocked := false;
      // Bombe à gauche : si pour le haut, la droite et le bas, il y a le bord, un obstacle ou qu'il y a une bombe
      // qui menace la case, et qu'il y a une bombe à gauche du bomberman, alors il est bloqué.
      If ( ( y = 1 ) Or ( ( wState[x, y - 1] <> 0 ) And ( wState[x, y - 1] <> 4 ) ) Or ( ( x > 1 )
      And ( wState[x - 1, y - 1] mod 4 >= 2 ) ) Or ( ( x > 2 ) And ( wState[x - 2, y - 1] mod 4 >= 2 ) ) )
      And ( ( x = GRIDWIDTH ) Or ( (  wState[x + 1, y] <> 0 ) And ( wState[x + 1, y] <> 4 ) ) )
      And ( ( y = GRIDHEIGHT ) Or ( ( wState[x, y + 1] <> 0 ) And ( wState[x, y + 1] <> 4 ) ) Or ( ( x > 1 )
      And ( wState[x - 1, y + 1] mod 4 >= 2 ) ) Or ( ( x > 2 ) And ( wState[x - 2, y + 1] mod 4 >= 2 ) ) )
      And ( ( ( x > 1 ) And ( wState[x - 1, y] mod 4 >= 2 ) )
      Or ( ( x > 2 ) And ( wState[x - 2, y] mod 4 >= 2 ) ) ) Then
         blocked := true;
      // Bombe en haut
      If ( ( x = 1 ) Or ( ( wState[x - 1, y] <> 0 ) And ( wState[x - 1, y] <> 4 ) ) Or ( ( y > 1 )
      And ( wState[x - 1, y - 1] mod 4 >= 2 ) ) Or ( ( y > 2 ) And ( wState[x - 1, y - 2] mod 4 >= 2 ) ) )
      And ( ( x = GRIDWIDTH ) Or ( ( wState[x + 1, y] <> 0 ) And ( wState[x + 1, y] <> 4 ) ) Or ( ( y > 1 )
      And ( wState[x + 1, y - 1] mod 4 >= 2 ) ) Or ( ( y > 2 ) And ( wState[x + 1, y - 2] mod 4 >= 2 ) ) )
      And ( ( y = GRIDHEIGHT ) Or ( ( wState[x, y + 1] <> 0 ) And ( wState[x, y + 1] <> 4 ) ) )
      And ( ( ( y > 1 ) And ( wState[x, y - 1] mod 4 >= 2 ) )
      Or ( ( y > 2 ) And ( wState[x, y - 2] mod 4 >= 2 ) ) ) Then
         blocked := true;
      // Bombe à droite.
      If ( ( x = 1 ) Or ( ( wState[x - 1, y] <> 0 ) And ( wState[x - 1, y] <> 4 ) ) )
      And ( ( y = 1 ) Or ( ( wState[x, y - 1] <> 0 ) And ( wState[x, y - 1] <> 4 ) ) Or ( ( x < GRIDWIDTH )
      And ( wState[x + 1, y - 1] mod 4 >= 2 ) ) Or ( ( x < GRIDWIDTH - 1 ) And ( wState[x + 2, y - 1] mod 4 >= 2 ) ) )
      And ( ( y = GRIDHEIGHT ) Or ( ( wState[x, y + 1] <> 0 ) And ( wState[x, y + 1] <> 4 ) ) Or ( ( x < GRIDWIDTH )
      And ( wState[x + 1, y + 1] mod 4 >= 2 ) ) Or ( ( x < GRIDWIDTH - 1 ) And ( wState[x + 2, y + 1] mod 4 >= 2 ) ) )
      And ( ( ( x < GRIDWIDTH ) And ( wState[x + 1, y] mod 4 >= 2 ) )
      Or ( ( x < GRIDWIDTH - 1 ) And ( wState[x + 2, y] mod 4 >= 2 ) ) ) Then
         blocked := true;
      // Bombe en bas.
      If ( ( x = 1 ) Or ( ( wState[x - 1, y ] <> 0 ) And ( wState[x - 1, y] <> 4 ) ) Or ( ( y < GRIDHEIGHT )
      And ( wState[x - 1, y + 1] mod 4 >= 2 ) ) Or ( ( y < GRIDHEIGHT - 1 ) And ( wState[x - 1, y + 2] mod 4 >= 2 ) ) )
      And ( ( y = 1 ) Or ( ( wState[x, y - 1] <> 0 ) And ( wState[x, y - 1] <> 4 ) ) )
      And ( ( x = GRIDWIDTH ) Or ( ( wState[x + 1, y] <> 0 ) And ( wState[x + 1, y] <> 4 ) ) Or ( ( y < GRIDHEIGHT )
      And ( wState[x + 1, y + 2] mod 4 >= 2 ) ) Or ( ( y < GRIDHEIGHT - 1 ) And ( wState[x + 1, y + 2] mod 4 >= 2 ) ) )
      And ( ( ( y < GRIDHEIGHT ) And ( wState[x, y + 1] mod 4 >= 2 ) )
      Or ( ( y < GRIDHEIGHT - 1 ) And ( wState[x, y + 2] mod 4 >= 2 ) ) ) Then
         blocked := true;

      // Si le bomberman est bloqué, alors il est en danger. 1024 est-il trop fort?
      If ( blocked = true ) Then
        result2 := result2 + 1024;
   End;
   
   
   
// Niveaux masterful et godlike
   // Traitement des cases sans planques pour les niveaux masterful et godlike
   // Ca sert à ne pas aller dans une impasse quand on est suivi.
   If ( wSkill = SKILL_MASTERFUL ) Or ( wSkill = SKILL_GODLIKE ) Then Begin
      // S'il n'y a pas de bomberman à moins de 7 cases, alors il n'y a pas de danger.
      blocked := false;
      nbrFreeCase := 0;
      If ( x < 7 ) Then xMin := 1 Else xMin := x - 6;
      If ( x > GRIDWIDTH - 6 ) Then xMax := GRIDWIDTH Else xMax := x + 6;
      If ( y < 7 ) Then yMin := 1 Else yMin := y - 6;
      If ( x > GRIDHEIGHT - 6 ) Then yMax := GRIDHEIGHT Else yMax := y + 6;

      For i := xMin To xMax Do Begin
          For j := yMin To yMax Do Begin
              If ( wState[i, j] mod 8 >= 4 ) And ( abs(x - i) + abs(y - j) <= 7 ) Then
                 blocked := true;
          End;
      End;
      
      // S'il y a une case de sortie ou un bomberman sur une autre ligne à gauche, alors gauche est une sortie.
      continue := true;
      i := x - 1;
      While ( continue = true ) And ( i >= 1 ) Do Begin
            If ( wState[i, y] <> 0 ) And ( wState[i, y] <> 4 ) Then
               continue := false
            Else If ( ( y > 1 ) And ( ( wState[i, y - 1] = 0 ) Or ( wState[i, y - 1] = 4 ) ) )
            Or ( ( y < GRIDHEIGHT ) And ( ( wState[i, y + 1] = 0 ) Or ( wState[i, y + 1] = 4 ) ) ) Then Begin
               nbrFreeCase := 1;
               iExit := i;
               continue := false;
            End;
            i := i - 1;
      End;
      // Sortie à droite.
      continue := true;
      i := x + 1;
      While ( continue = true ) And ( i <= GRIDWIDTH ) Do Begin
            If ( wState[i, y] <> 0 ) And ( wState[i, y] <> 4 )Then
               continue := false
            Else If ( ( y > 1 ) And ( ( wState[i, y - 1] = 0 ) Or ( wState[i, y - 1] = 4 ) ) )
            Or ( ( y < GRIDHEIGHT ) And ( ( wState[i, y + 1] = 0 ) Or ( wState[i, y + 1] = 4 ) ) ) Then Begin
               If ( nbrFreeCase <> 0 ) Then blocked := false
               Else Begin
                    nbrFreeCase := 2;
                    iExit := i;
               End;
               continue := false;
            End;
            i := i + 1;
      End;
      // Sortie en haut.
      continue := true;
      j := y - 1;
      While ( continue = true ) And ( j >= 1 ) Do Begin
            If ( wState[x, j] <> 0 ) And ( wState[x, j] <> 4 )Then
               continue := false
            Else If ( ( x > 1 ) And ( ( wState[x - 1, j] = 0 ) Or ( wState[x - 1, j] = 4 ) ) )
            Or ( ( x < GRIDWIDTH ) And ( ( wState[x + 1, j] = 0 ) Or ( wState[x + 1, j] = 4 ) ) ) Then Begin
               If ( nbrFreeCase <> 0 ) Then blocked := false
               Else Begin
                    nbrFreeCase := 3;
                    iExit := j;
               End;
               continue := false;
            End;
            j := j - 1;
      End;
      // Sortie en bas.
      continue := true;
      j := y + 1;
      While ( continue = true ) And ( j <= GRIDHEIGHT ) Do Begin
            If ( wState[x, j] <> 0 ) And ( wState[x, j] <> 4 ) Then
               continue := false
            Else If ( ( x > 1 ) And ( ( wState[x - 1, j] = 0 ) Or ( wState[x - 1, j] = 4 ) ) )
            Or ( ( x < GRIDWIDTH ) And ( ( wState[x + 1, j] = 0 ) Or ( wState[x + 1, j] = 4 ) ) ) Then Begin
               If ( nbrFreeCase <> 0 ) Then blocked := false
               Else Begin
                    nbrFreeCase := 4;
                    iExit := j;
               End;
               continue := false;
            End;
            j := j + 1;
      End;

      // Si la case est bloquée, alors le danger est proportionnelle à la distance de la case de sortie.
      If ( blocked = true ) Then Begin
         If ( nbrFreeCase = 1 ) Or ( nbrFreeCase = 2 ) Then
            result2 := result2 + 16 * ( 8 + abs(iExit - x) );
         If ( nbrFreeCase = 3 ) Or ( nbrFreeCase = 3 ) Then
            result2 := result2 + 16 * ( 8 + abs(iExit - y) ) ;
      End;
            

              
// Traitement des bombes qui sont sur la même rangée.
   // Ca sert à sortir de l'impasse s'il y a sortie et qu'il y a de l'espoir.
   // Si une bombe est à plus de 3 cases de la sortie ou que la sortie est à moins de 6 cases du bomberman, alors il va vers la sortie.
   // Si une bombe est sur la ligne/colonne d'à côté, on considère qu'il n'y a pas de sortie de ce côté.
      // Gauche : on ne continue que s'il y a une bombe à gauche et qu'il n'y a pas de sortie à droite.
      continue := false;
      downBomb := false;
      upBomb := false;
      For i := 1 To x - 1 Do Begin
          If ( wState[i, y] mod 4 >= 2 ) Then Begin
             continue := true;
             iBomb := i;
          End;
          // S'il y a une bombe à la ligne du dessous et qu'il n'y a pas de bloc entre, alors il n'y a pas de sortie en dessous.
          If ( y > 1 ) And ( wState[i, y - 1] mod 4 >= 2 ) And ( downBomb = false ) Then Begin
             downBomb := true;
             j := i + 1;
             While ( downBomb = true ) And ( j < x ) Do Begin
                   If ( wState[j, y - 1] mod 16 >= 8 ) Then
                      downBomb := false;
                   j := j + 1;
             End;
          End;
          If ( y < GRIDHEIGHT ) And ( wState[i, y + 1] mod 4 >= 2 ) And ( upBomb = false ) Then Begin
             upBomb := true;
             j := i + 1;
             While ( upBomb = true ) And ( j < x ) Do Begin
                   If ( wState[j, y + 1] mod 16 >= 8 ) Then
                      upBomb := false;
                   j := j + 1;
             End;
          End;
      End;
      For i := x To GRIDWIDTH Do
          If ( ( y > 1 ) And ( downBomb = false ) And ( ( wState[i, y - 1] = 0 ) Or ( wState[i, y - 1] = 4 ) ) )
          Or ( ( y < GRIDHEIGHT ) And ( upBomb = false ) And ( ( wState[i, y + 1] = 0 ) Or ( wState[i, y + 1] = 4 ) ) ) Then
             continue := false;
      // S'il y a une sortie à gauche et que la sortie est à moins de 3 cases de la bombe ou à moins de 6 cases du bomberman,
      // alors le danger est proportionnel à la distance de la sortie.
      If ( continue = true ) Then
         For i := iBomb + 1 To x - 1 Do
             If ( ( ( y > 1 ) And ( downBomb = false ) And ( ( wState[i, y - 1] = 0 ) Or ( wState[i, y - 1] = 4 ) ) )
             Or ( ( y < GRIDHEIGHT ) And ( upBomb = false ) And ( ( wState[i, y + 1] = 0 ) Or ( wState[i, y + 1] = 4 ) ) ) )
             And ( ( i - iBomb >= 3 ) Or ( x - i <= 5 ) ) Then
                 result2 := result2 + 512 * abs( x - i );
      // Droite
      continue := false;
      downBomb := false;
      upBomb := false;
      For i := x + 1 To GRIDWIDTH Do Begin
          If ( wState[i, y] mod 4 >= 2 ) Then Begin
             continue := true;
             iBomb := i;
          End;
          If ( y > 1 ) And ( wState[i, y - 1] mod 4 >= 2 ) And ( downBomb = false ) Then Begin
             downBomb := true;
             j := i - 1;
             While ( downBomb = true ) And ( j > x ) Do Begin
                   If ( wState[j, y - 1] mod 16 >= 8 ) Then
                      downBomb := false;
                   j := j - 1;
             End;
          End;
          If ( y < GRIDHEIGHT ) And ( wState[i, y + 1] mod 4 >= 2 ) And ( upBomb = false ) Then Begin
             upBomb := true;
             j := i - 1;
             While ( upBomb = true ) And ( j > x ) Do Begin
                   If ( wState[j, y + 1] mod 16 >= 8 ) Then
                      upBomb := false;
                   j := j - 1;
             End;
          End;
      End;
      For i := 1 To x Do
          If ( ( y > 1 ) And ( downBomb = false ) And ( ( wState[i, y - 1] = 0 ) Or ( wState[i, y - 1] = 4 ) ) )
          Or ( ( y < GRIDHEIGHT ) And ( upBomb = false ) And ( ( wState[i, y + 1] = 0 ) Or ( wState[i, y + 1] = 4 ) ) ) Then
             continue := false;
      If ( continue = true ) Then
         For i := x + 1 To iBomb - 1 Do
             If ( ( ( y > 1 ) And ( downBomb = false ) And ( ( wState[i, y - 1] = 0 ) Or ( wState[i, y - 1] = 4 ) ) )
             Or ( ( y < GRIDHEIGHT ) And ( downBomb = false ) And ( ( wState[i, y + 1] = 0 ) Or ( wState[i, y + 1] = 4 ) ) ) )
             And ( ( iBomb - i >= 3 ) Or ( i - x <= 5 ) ) Then
                 result2 := result2 + 512 * abs( x - i );
      // Haut
      continue := false;
      downBomb := false;
      upBomb := false;
      For j := 1 To y - 1 Do Begin
          If ( wState[x, j] mod 4 >= 2 ) Then Begin
             continue := true;
             iBomb := j;
          End;
          If ( x > 1 ) And ( wState[x - 1, j] mod 4 >= 2 ) And ( downBomb = false ) Then Begin
             downBomb := true;
             i := j + 1;
             While ( downBomb = true ) And ( i < y ) Do Begin
                   If ( wState[x - 1, i] mod 16 >= 8 ) Then
                      downBomb := false;
                   i := i + 1;
             End;
          End;
          If ( x < GRIDWIDTH ) And ( wState[x + 1, j] mod 4 >= 2 ) And ( upBomb = true ) Then Begin
             upBomb := true;
             i := j + 1;
             While ( upBomb = true ) And ( i < y ) Do Begin
                   If ( wState[x + 1, i] mod 16 >= 8 ) Then
                      upBomb := false;
                   i := i + 1;
             End;
          End;
      End;
      For j := y To GRIDHEIGHT Do
          If ( ( x > 1 ) And ( downBomb = false ) And ( ( wState[x - 1, j] = 0 ) Or ( wState[x - 1, j] = 4 ) ) )
          Or ( ( x < GRIDWIDTH ) And ( downBomb = false ) And ( ( wState[x + 1, j] = 0 ) Or ( wState[x + 1, j] = 4 ) ) ) Then
             continue := false;
      If ( continue = true ) Then
         For j := iBomb + 1 To y - 1 Do
             If ( ( ( x > 1 ) And ( downBomb = false ) And ( ( wState[x - 1, j] = 0 ) Or ( wState[x - 1, j] = 4 ) ) )
             Or ( ( x < GRIDWIDTH ) And ( downBomb = false ) And ( ( wState[x + 1, j] = 0 ) Or ( wState[x + 1, j] = 4 ) ) ) )
             And ( ( j - iBomb >= 3 ) Or ( y - j <= 5 ) ) Then
                 result2 := result2 + 512 * abs( y - i );
      // Bas
      continue := false;
      downBomb := false;
      upBomb := false;
      For j := y + 1 To GRIDHEIGHT Do Begin
          If ( wState[x, j] mod 4 >= 2 ) Then Begin
             continue := true;
             iBomb := j;
          End;
          If ( x > 1 ) And ( wState[x - 1, j] mod 4 >= 2 ) And ( downBomb = false ) Then Begin
             downBomb := true;
             i := j - 1;
             While ( downBomb = true ) And ( i > y ) Do Begin
                   If ( wState[x - 1, i] mod 16 >= 8 ) Then
                      downBomb := false;
                   i := i - 1;
             End;
          End;
          If ( x < GRIDWIDTH ) And ( wState[x + 1, j] mod 4 >= 2 ) And ( upBomb = false ) Then Begin
             upBomb := true;
             i := j - 1;
             While ( upBomb = true ) And ( i > y ) Do Begin
                   If ( wState[x + 1, i] mod 16 >= 8 ) Then
                      upBomb := false;
                   i := i - 1;
             End;
          End;
      End;
      For j := 1 To y Do
          If ( ( x > 1 ) And ( downBomb = false ) And ( ( wState[x - 1, j] = 0 ) Or ( wState[x - 1, j] = 4 ) ) )
          Or ( ( x < GRIDWIDTH ) And ( upBomb = false ) And ( ( wState[x + 1, j] = 0 ) Or ( wState[x + 1, j] = 4 ) ) ) Then
             continue := false;
      If ( continue = true ) Then
         For j := y + 1 To iBomb - 1 Do
             If ( ( ( x > 1 ) And ( downBomb = false ) And ( ( wState[x - 1, j] = 0 ) Or ( wState[x - 1, j ] = 4 ) ) )
             Or ( ( x < GRIDWIDTH ) And ( upBomb = false ) And ( ( wState[x + 1, j] = 0 ) Or ( wState[x + 1, j] = 4 ) ) ) )
             And ( ( iBomb - j >= 3 ) Or ( j - y <= 5 ) ) Then
                 result2 := result2 + 512 * abs( y - i );
   End;



CalculateDanger := result2;
End;




Function PutBomb( x : Integer ; y : Integer ; pState : Table; wSkill : Integer ) : Boolean ;
Var
   CanPut, continue : Boolean;
   FreeDirections : Integer;                // Nombres de directions sans danger.
   i, j, cLeft, cRight, cUp, cDown : Integer;
Begin
// Initialisation des variables
   CanPut := false;
   If ( x - 4 ) < 1 Then cLeft := 1 Else cLeft := x - 4;
   If ( x + 4 ) > GRIDWIDTH Then cRight := GRIDWIDTH Else cRight := x + 4;
   If ( y - 4 ) < 1 Then cUp := 1 Else cUp := y - 4;
   If ( y + 4 ) > GRIDHEIGHT Then cDown := GRIDHEIGHT Else cDown := y + 4;

         
// Si un bomberman est proche, alors on peut poser une bombe.
   For i := cLeft To cRight Do
       If ( pState[ i, y ] mod 8 >= 4 ) Then
          CanPut := true;
   For i := cUp To cDown Do
       If ( pState[ x, i ] mod 8 >= 4 ) Then
          CanPut := true;


// Si le niveau est au moins average et que le bomberman se coince avec sa bombe, alors il ne la pose pas.
   If ( wSkill <> SKILL_NOVICE) Then Begin
      // On initialise le nombre de directions libres à 0.
      FreeDirections := 0;
      
      // Pour la case de gauche, s'il y a deux cases libres de suite alors, il n'y a pas de danger.
      If ( x > 1 ) And ( pState[x - 1, y] = 0 )
      And ( ( ( x > 2 ) And ( pState[x - 2, y] = 0 ) )
      Or ( ( y > 1 ) And ( pState[x - 1, y - 1] = 0 ) )
      Or ( ( y < GRIDHEIGHT ) And ( pState[x - 1, y + 1] = 0 ) ) ) Then
         FreeDirections := FreeDirections + 1;
      // Droite.
      If ( x < GRIDWIDTH ) And ( pState[x + 1, y] = 0 )
      And ( ( ( x < GRIDWIDTH - 1 ) And ( pState[x + 2, y] = 0 ) )
      Or ( ( y > 1 ) And ( pState[x + 1, y - 1] = 0 ) )
      Or ( ( y < GRIDHEIGHT ) And ( pState[x + 1, y + 1] = 0 ) ) ) Then
         FreeDirections := FreeDirections + 1;
      // Haut
      If ( y > 1 ) And ( pState[x, y - 1] = 0 )
      And ( ( ( y > 2 ) And ( pState[x, y - 2] = 0 ) )
      Or ( ( x > 1 ) And ( pState[x - 1, y - 1] = 0 ) )
      Or ( ( x < GRIDWIDTH ) And ( pState[x + 1, y - 1] = 0 ) ) ) Then
         FreeDirections := FreeDirections + 1;
      // Bas
      If  ( y < GRIDHEIGHT ) And ( pState[x, y + 1] = 0 )
      And ( ( ( y < GRIDHEIGHT - 1 ) And  ( pState[x, y + 2] = 0 ) )
      Or ( ( x > 1 ) And ( pState[x - 1, y + 1] = 0 ) )
      Or ( ( x < GRIDWIDTH ) And ( pState[x + 1, y + 1] = 0 ) ) ) Then
         FreeDirections := FreeDirections + 1;
      
      // S'il n'y pas plus de deux directions libres, alors on ne pose pas la bombe.
      If ( FreeDirections < 2 ) Then
         CanPut := false;
   End;
   
   
// Si le bomberman est dans une impasse, et que le niveau est au moins masterful alors il ne pose pas de bombe.
   If ( wSkill = SKILL_MASTERFUL ) Or ( wSkill = SKILL_GODLIKE ) Then Begin
      FreeDirections := 0;

      // S'il y a une case de sortie ou un bomberman sur une autre ligne à gauche, alors gauche est une sortie.
      continue := true;
      i := x - 1;
      While ( continue = true ) And ( i >= 1 ) Do Begin
            If ( pState[i, y] <> 0 ) Then
               continue := false
            Else If ( ( y > 1 ) And ( pState[i, y - 1] = 0 ) )
            Or ( ( y < GRIDHEIGHT ) And ( pState[i, y + 1] = 0 ) ) Then Begin
               FreeDirections := FreeDirections + 1;
               continue := false;
            End;
            i := i - 1;
      End;
      // Sortie à droite.
      continue := true;
      i := x + 1;
      While ( continue = true ) And ( i <= GRIDWIDTH ) Do Begin
            If ( pState[i, y] <> 0 ) Then
               continue := false
            Else If ( ( y > 1 ) And ( pState[i, y - 1] = 0 ) )
            Or ( ( y < GRIDHEIGHT ) And ( pState[i, y + 1] = 0 ) ) Then Begin
               FreeDirections := FreeDirections + 1;
               continue := false;
            End;
            i := i + 1;
      End;
      // Sortie en haut.
      continue := true;
      j := y - 1;
      While ( continue = true ) And ( j >= 1 ) Do Begin
            If ( pState[x, j] <> 0 ) Then
               continue := false
            Else If ( ( x > 1 ) And ( pState[x - 1, j] = 0 ) )
            Or ( ( x < GRIDWIDTH ) And ( pState[x + 1, j] = 0 ) ) Then Begin
               FreeDirections := FreeDirections + 1;
               continue := false;
            End;
            j := j - 1;
      End;
      // Sortie en bas.
      continue := true;
      j := y + 1;
      While ( continue = true ) And ( j <= GRIDHEIGHT ) Do Begin
            If ( pState[x, j] <> 0 ) Then
               continue := false
            Else If ( ( x > 1 ) And ( pState[x - 1, j] = 0 ) )
            Or ( ( x < GRIDWIDTH ) And ( pState[x + 1, j] = 0 ) ) Then Begin
               FreeDirections := FreeDirections + 1;
               continue := false;
            End;
            j := j + 1;
      End;
      
   // S'il n'y pas plus de deux directions libres, alors on ne pose pas la bombe.
      If ( FreeDirections < 2 ) Then
         CanPut := false;
   End;
   
      

// On renvoye la variable.
   PutBomb := CanPut;
End;





End.
