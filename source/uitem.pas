Unit UItem;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UBlock, UBomberman;

Type

{ CItem }

CItem = Class (CBlock)

        Private
               bIsExplosed : Boolean;                                           // le bloc a deja explose (on voit le bonus) ou pas (on voit encore la caisse)
        
        Public
              Constructor Create (aX, aY : Integer);virtual;OverLoad;                   // constructeur
              Procedure Bonus ( nPlayer : CBomberman ) ; virtual; abstract;     // procedure abstraite qui definira l'action du bonus
              Procedure Explose () ; override;                                  // detruit le bloc si c'est possible (appele apres une explosion)
              Function IsExplosed () : Boolean ;                                // savoir si l'objet a deja explose une fois ou pas (caisse ou bonus)

End;



Implementation

{ CItem }

Procedure CItem.Explose () ;
Begin
     If (bIsExplosed) Then Self.Destroy                                         // detruit le bloc si il a deja explose (on voyait alors un bonus)
                      Else bIsExplosed := True;                                 // sinon il transforme la caisse en bonus
End;

Constructor CItem.Create ( aX, aY : Integer);
Begin
     Inherited Create(aX,aY,True);                                              // heritage du constructeur de UBlock
     bIsExplosed:=False;                                                        //au debut notre item est sous forme de caisse
  
End;

Function CItem.IsExplosed () : Boolean ;
Begin
     Result := bIsExplosed;                                                     // renvoie la valeur de bIsExplosed
End;





End.
