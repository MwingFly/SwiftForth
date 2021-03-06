\ Solution of cubic equation with real coefficients
\ ANS compatible version of 10/6/1994

\ Forth Scientific Library Algorithm #6


\ Environmental dependencies:
\       Separate floating point stack
\       FLOAT, FLOAT EXT wordsets
\       default precision (tests carried out with 32-bit precision)

\ Additional words (if not present):
\      %  (IMMEDIATE) -- converts the next text to fp literal
\       : %   BL WORD  COUNT  >FLOAT  NOT ABORT" Not a fp#"
\             STATE @  IF POSTPONE FLITERAL  THEN  ; IMMEDIATE
\       : S>F     S>D  D>F  ;
\       : ZDUP    FOVER  FOVER  ;
\       : FTUCK  ( F: x y -- y x y)     FSWAP FOVER ;
\       : E.   FE. ;
\       : F0>  % 0.0 FSWAP F< ;
\       % 3.1415926536 FCONSTANT F=PI

\ Source of algorithms:
\ Complex roots: Abramowitz & Stegun, p. 17 3.8.2
\ Real roots:    Press, et al., "Numerical Recipes" (1st ed.) p. 146

\       0 = x^3 + ax^2 + bx + c
\       q = b / 3 - a^2 / 9
\       r = ( b a/3 - c) / 2 - ( a / 3 )^3

\       D = q^3 + r^2

\       If D > 0, 1 real and a pair of cc roots;
\          D = 0, all roots real, at least 2 equal;
\          D < 0, all roots real

\ Case I: D > 0
\
\       s1 = [ r + sqrt(D) ]^1/3
\       s2 = [ r - sqrt(D) ]^1/3
\
\       x1 = s1 + s2 - a / 3
\       Re(x2) = - (s1 + s2) / 2  - a / 3
\       Im(x2) = sqrt(3) * (s1 - s2) / 2
\
\       x3 = conjg(x2)


\ Case II: D < 0
\
\       K = -2 * sqrt(-q)
\       phi = acos( -r / sqrt(-q^3) )
\
\       x1 = K * cos(phi / 3) - a / 3
\       x2 = K * cos( (phi + 2*pi) / 3) - a / 3
\       x3 = K * cos( (phi + 4*pi) / 3) - a / 3

\     (c) Copyright 1994  Julian V. Noble.     Permission is granted
\     by the author to use this software for any application provided
\     the copyright notice is preserved.

\ Cube root by Newton's method

3 S>F  FCONSTANT F=3

: X'    ( F: N x -- x')
\       F" X' = ( N / X / X + 2 * X ) / 3 "
        FTUCK   F**2  F/  FSWAP  F2*  F+  F=3  F/  ;

: FCBRT    ( F: N -- N^1/3)   FDUP  F0<  FABS
           FDUP  FSQRT                ( F: -- N x)
           BEGIN   ZDUP  X'           ( F: -- N x x')
                   FTUCK    F-  FOVER   F/  FABS
           % 1.E-8  F<  UNTIL
           X'  IF  FNEGATE  THEN  ;

\ Solve cubic
\ Data structures
FVARIABLE A     FVARIABLE B     FVARIABLE C     \ coeffs
FVARIABLE Q     FVARIABLE R                     \ derived stuff
FVARIABLE S1    FVARIABLE S2

: F**3    FDUP  FDUP  F* F*  ;

: INITIALIZE    ( F: a b c -- D )
        C SF!    B SF!    A F=3 F/  SF!
\       F" Q = B / 3 - A*A "
            B SF@  F=3 F/  A SF@ F**2 F-  Q SF!
\       F" R = ( A*B - C ) / 2 - A*A*A "
            A SF@ B SF@  F*  C SF@ F-  F2/  A SF@ F**3  F-  R SF!
\       F" D = Q*Q*Q + R*R "
            Q SF@  F**3    R SF@ F**2  F+    ;

: 1REAL     ( F: D --)  CR  ." 1 real, 2 complex conjugate roots"
\       F" s1 = [ r + sqrt(D) ]^1/3 "
            FSQRT   R SF@  FOVER  F+  FCBRT S1 SF!    ( F: sqrt[D] )
\       F" s2 = [ r - sqrt(D) ]^1/3 "
            FNEGATE  R SF@  F+        FCBRT S2 SF!    ( F: -- )
\       F" x1 = s1 + s2 - a / 3 + i * 0 "
            S1 SF@ S2 SF@  F+  FDUP   A SF@  F-        ( F: s1+s2 x1)
            CR   E.                             \ real root
\       F" x2 = -(s1 + s2) / 2 - a / 3 + i * SQRT(3) * (s1 - s2) / 2 "
            FNEGATE  F2/  A SF@ F-   FDUP  CR E. \ Re(x2)
            S1 SF@  S2 SF@  F-  F2/  F=3  FSQRT  F*   FTUCK
            ."   + i " E.                       \ Im(x2)
            CR E.  ."   - i " E.   ;            \ x3 = conjg(x2)

: .ROOT     ( F: K angle -- x)
            F=3 F/  FCOS   FOVER  F*  A SF@  F-    CR E.  ;

: 3REAL     CR  ." 3 real roots"
\       F" K = SQRT( ABS(Q) ) "
            Q SF@  FABS  FSQRT                   ( F: K )
\       F" phi = ACOS( -r / K^3 ) "
            R SF@  FNEGATE                       ( F: K  -r )
            FOVER   F**3  F/   FACOS            ( F: K phi )
\       F" K = -2*K "
            FSWAP   F2*   FNEGATE               ( F: -- phi K )
            FOVER                       .ROOT   \ x1
            FOVER   F=PI  F2*       F+  .ROOT   \ x2
            FSWAP   F=PI  F2* F2*   F+  .ROOT   \ x3
            FDROP   ;


: +?    FDUP F0> IF ." + "  ELSE  ." - "  FABS  THEN  ;

: .EQU'N   CR  ." x^3 "
           A SF@  F=3 F*   +?  E.  ."  x^2 "
           B SF@  +?  E.  ." x "  C SF@  +?  E.  ."  = 0"  ;

: >ROOTS     ( F: a b c --)
        INITIALIZE                          ( F: -- D )
        CR  .EQU'N
        FDUP  F0>                           \ test discriminant
        IF      1REAL
        ELSE    FDROP  3REAL
        THEN  CR  ;

: RESIDUAL   ( F: x y --)   S2 SF!  S1 SF!  CR
\       F" x * ( x*x - 3*y*y) + A*( x*x - y*y) + x*B + C "  E.
           S1 SF@ F**2   S2 SF@ F**2  F=3 F*   F-  B SF@  F+
           S1 SF@ F*
           A SF@ F=3 F*
           S1 SF@ F**2   S2 SF@ F**2 F-   F*  F+
           C SF@  F+  E.
\       F" y * ( 3*x*x - y*y + 2*x*A + B ) "    ."   + i " E.
           F=3  S1 SF@  F**2 F*   S2 SF@  F**2   F-
           S1 SF@ F2*   A SF@  F*  F=3 F*   F+
           B  SF@ F+    S2 SF@ F*    ."  + i " E.  ;
\ Use to test quality of solution


\ Examples

\ % -2 % 1 % -2 >ROOTS

\ x^3 - 2.000000e0 x^2 + 9.999999e-1x - 1.999999e0 = 0
\ 1 real, 2 complex conjugate roots
\ 2.000000e0
\ 2.607703e-8  + i 9.999999e-1
\ 2.607703e-8  - i 9.999999e-1 ok
\ The exact solutions of x^3 - 2x^2 + x - 2 = 0 are  2, i, -i

\ % -2 % -1 % 2 >ROOTS

\ x^3 + 1.999999e0 x^2 - 0.999999e0x - 1.999999e0 = 0
\ 3 real roots
\ -1.000001e0
\ 2.000000e0
\ 9.999999e-1 ok
\ The exact solutions of x^3 - 2x^2 - x - 2 = 0 are  2, 1, -1

\ % -4 % -1 % 22 >ROOTS

\ x^3 - 4.000000e0 x^2 - 0.999999e0x + 2.199999e1 = 0
\ 1 real, 2 complex conjugate roots
\ -2.000001e0
\ 3.000000e0  + i 1.414213e0
\ 3.000000e0  - i 1.414213e0 ok
\ The exact solutions of x^3 - 4x^2 - x + 22 = 0 are  -2, 3+i*sqrt(2), 3-i*sqrt(2)

\ % -2 % 0 RESIDUAL
\ -2.384186e-6 + i 0.0 ok
\ % 3 % 2 FSQRT RESIDUAL
\ -14.458536e-7 + i -4.286459e-6 ok
\ % 3 % 2 FSQRT FNEGATE RESIDUAL
\ -3.131728e-6 + i 4.763296e-6 ok



