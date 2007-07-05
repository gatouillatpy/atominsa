Unit UPowerUp;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils;

Type

{ UPowerUp }

CPowerUp = Class

           Private
                  nCode         : Integer       ;

                  nInitQuantity : Integer       ;

                  bGameOverride : Boolean       ;
                  nGameQuantity : Integer       ;
                  
                  bForbidden    : Boolean       ;

           Public
                 Constructor Create ( _nCode : Integer ;
                                      _nInitQuantity : Integer ;
                                      _bGameOverride  : Boolean ;
                                      _nGameQuantity : Integer ;
                                      _bForbidden : Boolean ) ; virtual;

                 Function Name : String ;
                 Property Code : Integer Read nCode ;
                 
                 Function InitQuantity : Integer ;
                 Function GameQuantity : Integer ;

                 Property Forbidden : Boolean Read bForbidden ;

End;



Implementation

{ CPowerUp }

Constructor CPowerUp.Create ( _nCode : Integer ;
                              _nInitQuantity : Integer ;
                              _bGameOverride  : Boolean ;
                              _nGameQuantity : Integer ;
                              _bForbidden : Boolean ) ;
Begin
     nCode := _nCode;

     nInitQuantity := _nInitQuantity;
     
     bGameOverride := _bGameOverride;
     If _nGameQuantity > 0 Then nGameQuantity := _nGameQuantity Else nGameQuantity := Random(-_nGameQuantity+1);
     
     bForbidden := _bForbidden;
End;

Function CPowerUp.Name : String ;
Begin
     Case nCode Of
          POWERUP_EXTRABOMB    : Result := 'an extra bomb';
          POWERUP_FLAMEUP      : Result := 'a flame upgrade';
          POWERUP_DISEASE      : Result := 'a disease';
          POWERUP_KICK         : Result := 'the ability to kick bombs';
          POWERUP_SPEEDUP      : Result := 'a speed upgrade';
          POWERUP_PUNCH        : Result := 'the ability to punch bombs';
          POWERUP_GRAB         : Result := 'the ability to grab bombs';
          POWERUP_SPOOGER      : Result := 'the spooger';
          POWERUP_GOLDFLAME    : Result := 'the goldflame';
          POWERUP_TRIGGERBOMB  : Result := 'some trigger bombs';
          POWERUP_JELLYBOMB    : Result := 'some jelly bombs';
          POWERUP_SUPERDISEASE : Result := 'a very bad disease';
          POWERUP_RANDOM       : Result := 'something';
     End;
End;

Function CPowerUp.InitQuantity : Integer ;
Begin
     If nInitQuantity > 0 Then
          Result := nInitQuantity
     Else Begin
          Case nCode Of
               POWERUP_EXTRABOMB    : Result := 1;
               POWERUP_FLAMEUP      : Result := 1;
               POWERUP_DISEASE      : Result := 0;
               POWERUP_KICK         : Result := 0;
               POWERUP_SPEEDUP      : Result := 1;
               POWERUP_PUNCH        : Result := 0;
               POWERUP_GRAB         : Result := 0;
               POWERUP_SPOOGER      : Result := 0;
               POWERUP_GOLDFLAME    : Result := 0;
               POWERUP_TRIGGERBOMB  : Result := 0;
               POWERUP_JELLYBOMB    : Result := 0;
               POWERUP_SUPERDISEASE : Result := 0;
               POWERUP_RANDOM       : Result := 0;
          End;
     End;
End;

Function CPowerUp.GameQuantity : Integer ;
Begin
     If bGameOverride Then
          Result := nGameQuantity
     Else Begin
          Case nCode Of
               POWERUP_EXTRABOMB    : Result := 20;
               POWERUP_FLAMEUP      : Result := 20;
               POWERUP_DISEASE      : Result := 10;
               POWERUP_KICK         : Result := 5;
               POWERUP_SPEEDUP      : Result := 20;
               POWERUP_PUNCH        : Result := 5;
               POWERUP_GRAB         : Result := 5;
               POWERUP_SPOOGER      : Result := 3;
               POWERUP_GOLDFLAME    : Result := 1;
               POWERUP_TRIGGERBOMB  : Result := 3;
               POWERUP_JELLYBOMB    : Result := 5;
               POWERUP_SUPERDISEASE : Result := 1;
               POWERUP_RANDOM       : Result := 3;
          End;
     End;

End;



End.
