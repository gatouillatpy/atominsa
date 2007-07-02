Unit UPractice;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils,
     UCore, UGame, UUtils, USetup;



Procedure InitPractice () ;
Procedure ProcessPractice () ;



Implementation



Procedure InitPractice () ;
Var k : Integer;
Begin
     // d�sactivation de la souris
     BindButton( BUTTON_LEFT, NIL );

     // d�sactivation du mode multi
     bMulti := False;

     // suppression de tous les joueurs externes
     For k := 1 To 8 Do
         If nPlayerType[k] = PLAYER_NET Then nPlayerType[k] := PLAYER_NIL;
         
     // initialisation du menu
     InitMenu();

     // mise � jour de la machine d'�tat
     nState := STATE_PRACTICE;
End;



Procedure ProcessPractice () ;
Begin
     Case nGame Of
          GAME_MENU : ProcessMenu();
          GAME_MENU_PLAYER : ProcessMenuPlayer();
          GAME_INIT : InitGame();
          GAME_ROUND : ProcessGame();
          GAME_WAIT : ProcessWait();
          GAME_SCORE : ProcessScore();
     End;
End;





























End.

