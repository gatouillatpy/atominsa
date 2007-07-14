Unit UComputer;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils,
     UCore, UUtils, UBomberman, UForm, UFlame, UBomb, UListBomb;


Function lm : Single;
Procedure ProcessComputer ( pBomberman : CBomberman ; nSkill : Integer ) ;
Procedure MoveIA ( pBomberman : CBomberman ; nSkill : Integer ; fBomb, fFlame : Single ) ;


Implementation



Const SKILL_NOVICE         = 1;
Const SKILL_AVERAGE        = 2;
Const SKILL_MASTERFUL      = 3;
Const SKILL_GODLIKE        = 4;

 // pourcentage de crever en passant sur des flammes
Const NOVICE_FLAME         = 0.1;
Const AVERAGE_FLAME        = 0.06;
Const MASTERFUL_FLAME      = 0.04;
Const GODLIKE_FLAME        = 0.02;

 // pourcentage de crever en étant sur la trajectoire d'une bombe
Const NOVICE_BOMB          = 0.1;
Const AVERAGE_BOMB         = 0.06;
Const MASTERFUL_BOMB       = 0.04;
Const GODLIKE_BOMB         = 0.02;



Function lm : Single; Begin If Random < 0.5 Then lm := -1.0 Else lm := 1.0 End;

Procedure ProcessComputer ( pBomberman : CBomberman ; nSkill : Integer ) ;
Begin
     Case nSkill Of
          SKILL_NOVICE :
            Begin
              MoveIA(pBomberman,SKILL_NOVICE, NOVICE_BOMB, NOVICE_FLAME);
              If Random < 0.5 * GetDelta Then pBomberman.CreateBomb( GetDelta );
            End;
          SKILL_AVERAGE :
            Begin
              MoveIA(pBomberman, SKILL_AVERAGE, AVERAGE_BOMB, AVERAGE_FLAME);
              If Random < 0.5 * GetDelta Then pBomberman.CreateBomb( GetDelta );
            End;
     End;
End;


Procedure MoveIA ( pBomberman : CBomberman ; nSkill : Integer ; fBomb,fFlame : Single ) ;
Var t : Single;
    k : Integer;
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

// on évalue le risque de se prendre une flamme avec les nouvelles coordonnées.
k := 1;
While ( k <= GetFlameCount() ) Do Begin
     If (Trunc(pBomberman.Position.X + 0.5) = GetFlameByCount(k).X) And (Trunc(pBomberman.Position.Y + 0.5) = GetFlameByCount(k).Y) Then t += fFlame;
     k += 1;
End;

// on ajoute à cela le risque de crever en étant sur la trajectoire d'une bombe.
k := 1;
While ( k <= GetBombCount() ) Do Begin
     If (Trunc(pBomberman.Position.X + 0.5) = Trunc(GetBombByCount(k).Position.X + 0.5)) Or (Trunc(pBomberman.Position.Y + 0.5) = Trunc(GetBombByCount(k).Position.Y + 0.5)) Then t += fBomb;
     k += 1;
End;

// s'il y a un risque supérieur aux nouvelles coordonnées alors on réattribue les anciennes.
If (Random < t) And (pBomberman.Danger < t) Then Begin
   pBomberman.Position.X := pBomberman.LX;
   pBomberman.Position.Y := pBomberman.LY;
End;

pBomberman.Danger := t;

End;

End.
