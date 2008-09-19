Unit UItem;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UBlock, UBomberman;

Type

{ CItem }

CItem = Class (CBlock)

        Public
               bIsExplosed : Boolean;                                           // le bloc a deja explose (on voit le bonus) ou pas (on voit encore la caisse)

        

              bIsExplosedMulti : Boolean;                                       // le package HEADER_ISEXPLOSED_ITEM a été reçu.
              Constructor Create (aX, aY : Integer);virtual;OverLoad;           // constructeur
              Procedure Bonus ( nPlayer : CBomberman ) ; virtual; abstract;     // procedure abstraite qui definira l'action du bonus
              Procedure Explose () ; override;                                  // detruit le bloc si c'est possible (appele apres une explosion)
              Procedure ExploseMulti(); override;
              Function IsExplosed () : Boolean ;                                // savoir si l'objet a deja explose une fois ou pas (caisse ou bonus)

End;



Implementation

Uses UGame, UMulti, USetup, UCore;

{ CItem }

Procedure CItem.Explose ();
Var sData : String;
Begin
     If (bIsExplosedMulti = False) And ((bMulti = False) Or (nLocalIndex = nClientIndex[0]))  Then Begin
         If (bIsExplosed) Then Begin
            Self.Destroy;                                         // detruit le bloc si il a deja explose (on voyait alors un bonus)
            If (bMulti = True) And (nLocalIndex = nClientIndex[0]) Then Begin
               sData := IntToStr( nX ) + #31;
               sData := sData + IntToStr( nY ) + #31;
               Send( nLocalIndex, HEADER_EXPLOSE_BLOCK, sData );
            End;
         End
         Else Begin
              bIsExplosed := true;                                  // sinon on voit le bonus
              If (bMulti = True) And (nLocalIndex = nClientIndex[0]) Then Begin
                 sData := IntToStr( nX ) + #31;
                 sData := sData + IntToStr( nY ) + #31;
                 Send( nLocalIndex, HEADER_ISEXPLOSED_ITEM, sData );
              End;
         End;
     End;
     If (bIsExplosedMulti = True) Then Begin
        bIsExplosedMulti := False;
     End;
End;

Procedure CItem.ExploseMulti();
Begin
     Self.Destroy;
End;

Constructor CItem.Create ( aX, aY : Integer);
Begin
     Inherited Create(aX,aY,True);                                              // heritage du constructeur de UBlock
     bIsExplosed:=False;                                                        //au debut notre item est sous forme de caisse
     bIsExplosedMulti := False;
  
End;

Function CItem.IsExplosed () : Boolean ;
Begin
     Result := bIsExplosed;                                                     // renvoie la valeur de bIsExplosed
End;





End.
