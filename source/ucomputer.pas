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
Var t : Single;
    i, j, k : Integer;
    bLeft, bDown, bUp, bRight : Integer;                             // Limites pour les calculs dans le tableau
    dangerMin : Integer;                                             // Le danger minimal connu pour l'instant
    pX, pY, cX, cY, lX, lY : Integer;                                // Renommage des coordonnées pour améliorer la lecture du code.
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
   

// Mise à jour du tableau.
     
     // On met tous les données à 0.
     For i := 1 To GRIDWIDTH Do Begin
         For j := 1 To GRIDHEIGHT Do Begin
             aState[i,j] := 0;
         End;
     End;

     // On ajoute 1 à chaque case qui contient une flamme.
     For k := 1 To GetFlameCount() Do Begin
         aState[GetFlameByCount(k).X, GetFlameByCount(k).Y ] += 1;
     End;

     // On ajoute 2 à chaque case qui contient une bombe.
     For k := 1 To GetBombCount() Do Begin
         aState[Trunc(GetBombByCount(k).Position.X + 0.5), Trunc(GetBombByCount(k).Position.Y + 0.5)] += 2;
     End;
     
     // On ajoute 4 à chaque case qui contient un personnage autre que l'IA
     For k := 1 To GetBombermanCount() Do Begin
         If (GetBombermanByCount(k) <> pBomberman) Then              // Comparaison à vérifier.
            aState[Trunc(GetBombermanByCount(k).Position.X + 0.5), Trunc(GetBombermanByCount(k).Position.Y + 0.5)] += 4;
     End;
     
// Mise à jour des dangers.
   pBomberman.Danger := CalculateSlowDanger(pX, pY, aState);
   pBomberman.DangerLeft := CalculateSlowDanger(pX - 1, pY, aState);
   pBomberman.DangerRight := CalculateSlowDanger(pX + 1, pY, aState);
   pBomberman.DangerUp := CalculateSlowDanger(pX, pY - 1, aState);
   pBomberman.DangerDown := CalculateSlowDanger(pX, pY + 1, aState);

// Niveau Novice

     Case nSkill Of
          SKILL_NOVICE :
          Begin
               // si les coordonnées ciblées sont atteintes, alors on calcule de nouvelles coordonnées cibles.
               If ( pX - 2 < 0 ) Then bLeft := 0 Else bLeft := pX - 2;
               If ( pX + 2 > GRIDWIDTH ) Then bRight := GRIDWIDTH Else bRight := pX + 2;
               If ( pY - 2 < 0 ) Then bUp := 0 Else bUp := pY - 2;
               If ( pY + 2 > 0 ) Then bDown := GRIDHEIGHT Else bDown := pY + 2;
               
               If (cX = pX) And (cY = pY) Then Begin
                  For i := bLeft To bRight Do Begin
                      For j := bUp To bDown Do Begin
                          If CalculateFastDanger(i,j, aState) <= dangerMin Then Begin
                             cX := i;
                             cY := j;                                // cX et cY à remettre dans pBomberman plus tard.
                          End;
                      End;
                  End;
               End;
               

          End;
     End;



    { Case nSkill Of
          SKILL_NOVICE :
          Begin
               // si les coordonnées ciblées sont toutes deux différentes aux coordonnées courantes alors
               // on attribue de nouvelles coordonnées cibles. ça arrive en début de partie ou en cas de téléportation
               If (pBomberman.CX <> pBomberman.Position.X) And (pBomberman.CY <> pBomberman.Position.Y) Then Begin
                  If Random < 0.5 Then Begin
                     pBomberman.CX := pBomberman.Position.X + (2.0 + Random * 6.0) - 4.0;
                     pBomberman.CY := pBomberman.Position.Y;
                  End Else Begin
                     pBomberman.CX := pBomberman.Position.X;
                     pBomberman.CY := pBomberman.Position.Y + (2.0 + Random * 4.0) - 3.0;
                  End;
               End;
               // si les coordonnées ciblées ont été atteintes alors on attribue de nouvelles coordonnées cibles.
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
               // si on fait face à un obstacle (coordonnées courantes égales aux dernières) alors on attribue
               // de nouvelles coordonnées cibles. on a 80% de chances de repartir dans la direction opposée.
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
               // on remplace les dernières coordonnées par les coordonnées courantes.
               pBomberman.LX := pBomberman.Position.X;
               pBomberman.LY := pBomberman.Position.Y;
               // on gère le déplacement en fonction des coordonnées ciblées.
               If pBomberman.CX > pBomberman.Position.X Then pBomberman.MoveRight( GetDelta );
               If pBomberman.CX < pBomberman.Position.X Then pBomberman.MoveLeft( GetDelta );
               If pBomberman.CY > pBomberman.Position.Y Then pBomberman.MoveDown( GetDelta );
               If pBomberman.CY < pBomberman.Position.Y Then pBomberman.MoveUp( GetDelta );

               t := 0.0;
               // on évalue le risque de se prendre une flamme avec les nouvelles coordonnées. comme on est
               // novice on avoir 80% de chances de crever en passant dans des flammes.
               k := 1;
               While ( k <= GetFlameCount() ) Do Begin
                   If (Trunc(pBomberman.Position.X + 0.5) = GetFlameByCount(k).X) And (Trunc(pBomberman.Position.Y + 0.5) = GetFlameByCount(k).Y) Then t += 0.8;
                   k += 1;
               End;
               // on ajoute à cela le risque de crever en étant sur la trajectoire d'une bombe. de même
               // en novice on évalue ce risque à 20%.
               k := 1;
               While ( k <= GetBombCount() ) Do Begin
                   If (Trunc(pBomberman.Position.X + 0.5) = Trunc(GetBombByCount(k).Position.X + 0.5)) Or (Trunc(pBomberman.Position.Y + 0.5) = Trunc(GetBombByCount(k).Position.Y + 0.5)) Then t += 0.2;
                   k += 1;
               End;
               // s'il y a un risque supérieur aux nouvelles coordonnées alors on réattribue les anciennes.
               If (Random < t) And (pBomberman.Danger < t) Then Begin
                  pBomberman.Position.X := pBomberman.LX;
                  pBomberman.Position.Y := pBomberman.LY;
               End;
               pBomberman.Danger := t;
               
               // à chaque mise à jour on a 3% de chances de poser une bombe.
               If Random < 0.5 * GetDelta Then pBomberman.CreateBomb( GetDelta );
          End;
     End;  }
End;

Function CalculateFastDanger ( x : integer ; y : integer ; pState : Table ) : integer ;
Var
   result1 : integer;                            // résultat renvoyé
   i, j : integer;
   cLeft, cRight, cUp, cDown : integer;          // limites pour les calculs du tableau.
Begin
// Initialisation des variables
   result1 := 0;                                 // Le minimum est 0, le maximum est autour de 10000.
   If ( x - 3 < 0 ) Then cLeft := 0 Else cLeft := x - 3;
   If ( x + 3 > GRIDWIDTH ) Then cRight := GRIDWIDTH Else cRight := x + 3;
   If ( y - 3 < 0 ) Then cUp := 0 Else cUp := y - 3;
   If ( y + 3 > 0 ) Then cDown := GRIDHEIGHT Else cDown := y + 3;

// Traitement des flammes et des bombes.
   For i :=  cLeft To cRight Do Begin
       For j := cUp To cDown Do Begin
           If (i <> x) Or ( j <> y )Then Begin   // Pour éviter les divisions par 0 et sauver Ariane V...
           // Traitement des flammes
              If ( pState[i, j] mod 2 = 1 ) Then
                 result1 := 1000 div ( abs(x - i) + abs(y - j) );
           // Traitement des bombes
              If ( pState[i, j] mod 4 >= 2 ) Then
                 result1 := 500 div ( abs(x - i) + abs(y - j) );
           End;
       End;
   End;

CalculateFastDanger := result1;
End;

Function CalculateSlowDanger ( x : integer ; y : integer ; pState :  Table ) : integer ;   // A faire
Var
   result2 : integer;
Begin
     result2 := 1;
CalculateSlowDanger := result2;
End;



End.
