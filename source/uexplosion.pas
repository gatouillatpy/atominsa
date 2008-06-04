Unit UExplosion;

{$mode objfpc}{$H+}

Interface

Uses Classes, SysUtils, UCore;

Const EXPLOSION_DURATION : Single = 1.6;

Type LPExplosion = ^Explosion;
     Explosion = Record
                       X : Single;
                       Y : Single;
                       T : Single;
                       N : LPExplosion;
                 End;

Procedure AddExplosion( _X : Single ; _Y : Single );
Procedure UpdateExplosion();
Function GetExplosionCount() : Integer;
Function GetExplosion( i : Integer ) : LPExplosion;

Implementation

Var pExplosion : LPExplosion = NIL;
    nCount : Integer = 0;

Procedure AddExplosion( _X : Single ; _Y : Single );
Var pTemp : LPExplosion;
Begin
     Inc(nCount);
     New(pTemp);
     pTemp^.X := _X;
     pTemp^.Y := _Y;
     pTemp^.T := GetTime();
     pTemp^.N := pExplosion;
     pExplosion := pTemp;
End;

Procedure UpdateExplosion();
Var pTemp, t, d : LPExplosion;
Begin
     pTemp := pExplosion;
     While pTemp <> NIL Do Begin
           t := pTemp;
           
           pTemp := pTemp^.N;
           
           If GetTime() > t^.T + EXPLOSION_DURATION * 2.0 Then Begin
               If t = pExplosion Then Begin
                  pExplosion := t^.N;
               End Else Begin
                  d := pExplosion;
                  While d^.N <> t Do
                        d := d^.N;
                  d^.N := t^.N;
               End;
               Dec(nCount);
               Dispose(t);
           End;
     End;
End;

Function GetExplosionCount() : Integer;
Begin
     GetExplosionCount := nCount;
End;

Function GetExplosion( i : Integer ) : LPExplosion;
Var k : Integer;
Var pTemp : LPExplosion;
Begin
     k := 1;
     pTemp := pExplosion;
     While (pTemp <> NIL) Do Begin
           If k = i Then Break;
           k := k + 1;
           pTemp := pTemp^.N;
     End;
     GetExplosion := pTemp;
End;

End.

