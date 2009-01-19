Unit UEditor;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils,
     UCore, UUtils, USetup, UForm;



Procedure InitEditor () ;
Procedure ProcessEditor () ;



Implementation



Const EDITOR_MENU         = 0;
Const EDITOR_STATICMESH   = 1;

Var nEditor  : Integer;



////////////////////////////////////////////////////////////////////////////////
// Import3DS : Charge un mesh au format 3DS.                                  //
////////////////////////////////////////////////////////////////////////////////
{Procedure Import3DS ( sFile : String ) ;

Const MAIN_CHUNK = 19789;
          EDITOR_CHUNK = 15677;
              OBJECT_BLOCK = 16384;
                  TRIANGULAR_MESH = 16640;
                      VERTICES_LIST = 16656;
                      FACES_DESCRIPTION = 16672;
                      MAPPING_COORDINATES_LIST = 16704;

Var ioChar : File Of Char ; sName : String ;
    ioWord : File Of Word ; nSize : Word ; nIndex : Word ; nData : Word ;
    ioDWord : File Of DWord ; nLength : DWord ;
    ioSingle : File Of Single ; fData : Single ;
    i, j : Integer ;
    pMesh : LPOGLMesh ;
    pDataItem : LPDataItem;

Begin
     j := 0;

     AddLineToConsole( 'Importing 3DS file ' + sFile + '...' );

     // création du pointeur vers le nouveau mesh
     New( pMesh );

     // lecture du nombre de polygones
     Assign( ioWord, sFile );
     Reset( ioWord, 1 );
     Seek( ioWord, j );

     While EOF(ioWord) = False Do Begin
          Read( ioWord, nIndex ); j += 2;
          Close( ioWord );
          Assign( ioDWord, sFile );
          Reset( ioDWord, 1 );
          Seek( ioDWord, j );
          Read( ioDWord, nLength ); j += 4;
          Close( ioDWord );
          Case nIndex Of
               MAIN_CHUNK : Begin
               End;
               EDITOR_CHUNK : Begin
               End;
               OBJECT_BLOCK : Begin
                   Assign( ioChar, sFile );
                   Reset( ioChar, 1 );
                   Seek( ioChar, j );
                   SetLength( sName, 256 );
                   For i := 1 To 256 Do Begin
                       //Seek( ioChunk, i + j - 1 );
                       Read( ioChar, sName[i] ); j += 1;
                       If sName[i] = #0 Then Break;
                   End;
                   Close( ioChar );
               End;
               TRIANGULAR_MESH : Begin
               End;
               VERTICES_LIST : Begin
                   Assign( ioWord, sFile );
                   Reset( ioWord, 1 );
                   Seek( ioWord, j );
                   Read( ioWord, nSize ); j += 2;
                   Close( ioWord );
                   pMesh^.VertexCount := nSize;
                   SetLength( pMesh^.VectorArray, nSize );
                   SetLength( pMesh^.NormalArray, nSize );
                   SetLength( pMesh^.ColorArray, nSize );
                   Assign( ioSingle, sFile );
                   Reset( ioSingle, 1 );
                   Seek( ioSingle, j );
                   For i := 0 To nSize - 1 Do Begin
                       Read( ioSingle, fData ); j += 4;
                       pMesh^.VectorArray[i].x := fData;
                       Read( ioSingle, fData ); j += 4;
                       pMesh^.VectorArray[i].y := fData;
                       Read( ioSingle, fData ); j += 4;
                       pMesh^.VectorArray[i].z := fData;
                   End;
                   Close( ioSingle );
               End;
               FACES_DESCRIPTION : Begin
                   Assign( ioWord, sFile );
                   Reset( ioWord, 1 );
                   Seek( ioWord, j );
                   Read( ioWord, nSize ); j += 2;
                   Close( ioWord );
                   pMesh^.PolygonCount := nSize;
                   SetLength( pMesh^.IndexArray, nSize );
                   Assign( ioWord, sFile );
                   Reset( ioWord, 1 );
                   Seek( ioWord, j );
                   For i := 0 To nSize - 1 Do Begin
                       Read( ioWord, nData ); j += 2;
                       pMesh^.IndexArray[i].id0 := nData;
                       Read( ioWord, nData ); j += 2;
                       pMesh^.IndexArray[i].id1 := nData;
                       Read( ioWord, nData ); j += 2;
                       pMesh^.IndexArray[i].id2 := nData;
                       Read( ioWord, nData ); j += 2;
                   End;
                   Close( ioWord );
               End;
               MAPPING_COORDINATES_LIST : Begin
                   Assign( ioWord, sFile );
                   Reset( ioWord, 1 );
                   Seek( ioWord, j );
                   Read( ioWord, nSize ); j += 2;
                   Close( ioWord );
                   SetLength( pMesh^.TextureArray, nSize );
                   Assign( ioSingle, sFile );
                   Reset( ioSingle, 1 );
                   Seek( ioSingle, j );
                   For i := 0 To nSize - 1 Do Begin
                       Read( ioSingle, fData ); j += 4;
                       pMesh^.TextureArray[i].u := fData;
                       Read( ioSingle, fData ); j += 4;
                       pMesh^.TextureArray[i].v := fData;
                   End;
                   Close( ioSingle );
               End;
               Else
                   j += nLength - 6;
          End;
          Assign( ioWord, sFile );
          Reset( ioWord, 1 );
          Seek( ioWord, j );
     End;

     Close( ioWord );

     // ajout du mesh à la pile de données
     AddItem( DATA_MESH, 9595, pMesh, sFile );

     AddStringToConsole( Format('OK. (%d bytes)', [j*4]) );
End;}

Procedure InitMenu () ;
Begin
     SetString( STRING_EDITOR_MENU(2), 'f2 : static mesh', 0.0, 1.0, 60 );
     SetString( STRING_EDITOR_MENU(3), 'f3 : skeletal mesh', 0.5, 1.0, 60 );
     SetString( STRING_EDITOR_MENU(4), 'f4 : animation', 1.0, 1.0, 60 );
     SetString( STRING_EDITOR_MENU(5), 'f5 : character', 1.5, 1.0, 60 );
     SetString( STRING_EDITOR_MENU(6), 'f6 : map', 2.0, 1.0, 60 );
     SetString( STRING_EDITOR_MENU(7), 'f7 : scheme', 2.5, 1.0, 60 );
     SetString( STRING_EDITOR_MENU(8), 'f8 : voice', 3.0, 1.0, 60 );
End;



Procedure ProcessMenu () ;
Var w, h : Single;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();
     
     DrawString( STRING_SCORE_TABLE(2), -w / h * 0.5,  0.6, -1, 0.024 * w / h, 0.032, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     DrawString( STRING_SCORE_TABLE(3), -w / h * 0.5,  0.4, -1, 0.024 * w / h, 0.032, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     DrawString( STRING_SCORE_TABLE(4), -w / h * 0.5,  0.2, -1, 0.024 * w / h, 0.032, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     DrawString( STRING_SCORE_TABLE(5), -w / h * 0.5,  0.0, -1, 0.024 * w / h, 0.032, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     DrawString( STRING_SCORE_TABLE(6), -w / h * 0.5, -0.2, -1, 0.024 * w / h, 0.032, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     DrawString( STRING_SCORE_TABLE(7), -w / h * 0.5, -0.4, -1, 0.024 * w / h, 0.032, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     DrawString( STRING_SCORE_TABLE(8), -w / h * 0.5, -0.6, -1, 0.024 * w / h, 0.032, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     
     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nState := PHASE_MENU;
        ClearInput();
     End;
End;


Procedure InitEditor () ;
Begin
     InitMenu();

     // initialisation de l'éditeur
     nEditor := EDITOR_MENU;

     // mise à jour de la machine d'état
     nState := STATE_EDITOR;
End;



Procedure ProcessEditor () ;
Begin
     Case nEditor Of
          EDITOR_MENU : ProcessMenu();
     End;
End;



End.
