\ pcylfun     Parabolic Cylinder Functions U and V,
\             plus related confluent hypergeometric functions

\ Forth Scientific Library Algorithm #20

\ Evaluates the Parabolic Cylinder functions,
\     Upcf              U(nu,x)
\ and 
\     Vpcf              V(nu,x)
\ In addition the following related functions are provided,
\ U()        U(a,b,x)      Hypergeometric function U for real args
\ M()        M(a,b,x)      Hypergeometric function M for real args
\ Wwhit      W(k,mu,z)     Whittaker function W for real args
\ Mwhit      M(k,mu,z)     Whittaker function M for real args


\ This code conforms with ANS requiring:
\      1. The Floating-Point word set
\      2. The immediate word '%' which takes the next token
\         and converts it to a floating-point literal
\      3. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      4. Uses the word 'GAMMA' to evaluate the gamma function
\      5. The FCONSTANT PI (3.1415926536...)
\      6. The compilation of the test code is controlled by VALUE ?TEST-CODE
\         and the conditional compilation words in the Programming-Tools wordset.

\ There is a bit of stack gymnastics in this code particularly in U() and M()
\ but that seems to be in the nature of the algorithm.

\ Baker, L., 1992; C Mathematical Function Handbook, McGraw-Hill,
\ New York, 757 pages,  ISBN 0-07-911158-0


\ (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.

cr .( PCYLFUN      V1.1                 3 October 1994   EFC )

Private:

FVARIABLE SUM
FVARIABLE TERM
FVARIABLE OLD-TERM

\ scratch space for stack conservation
FVARIABLE XX-TMP
FVARIABLE A-TMP
FVARIABLE B-TMP
FVARIABLE C-TMP
FVARIABLE D-TMP
FVARIABLE U-TMP

FVARIABLE AV-TMP
FVARIABLE BV-TMP
FVARIABLE CV-TMP
FVARIABLE XV-TMP
FVARIABLE NV-TMP
FVARIABLE XU-TMP
FVARIABLE NU-TMP
FVARIABLE AU-TMP
FVARIABLE BU-TMP

: FRAC ( -- , f: x -- fractional_part_of_x )
         FDUP F>S S>F F-
;

: FAC ( -- , f: x -- z )
          % 1.0 F+ GAMMA
;


: ?big-x ( -- t/f , f: nu x -- nu x )
        FOVER FOVER
        % 4.0 F> FABS % 4.0 F* FOVER FSWAP F> AND
;

: asymptotic-u ( -- , f: nu x -- U[nu,x] )

                 % 0.5 FOVER FDUP F* F/
                 A-TMP F!

                 FDUP FDUP F* % -0.25 F*
                 FEXP D-TMP F!

                 FOVER % 0.5 F+ F** D-TMP F@ FSWAP F/
                 D-TMP F!
                                                   
                 FDUP FDUP
                 % 3.5 F+ FSWAP % 2.5 F+ F* A-TMP F@ F* % 0.5 F* % 1.0 F-
                 A-TMP F@ F*
                 FOVER % 0.5 F+ F*
                 FSWAP % 1.5 F+ F*
                 % 1.0 F+

                 D-TMP F@ F*

;

: simple-u ( -- , f: b a -- z )
           FSWAP FDROP XX-TMP F@ FSWAP F**
           SUM F@ FSWAP F/
;


: asymptotic-v ( -- , f: nu x -- V[nu,x] )

                 % 0.5 FOVER FDUP F* F/
                 A-TMP F!

                 FDUP FDUP F* % 0.25 F*
                 FEXP D-TMP F!

                 FOVER % 0.5 F- F** D-TMP F@ F*

                 % 2.0 PI F/ FSQRT F*
                 D-TMP F!
                                                   
                 FDUP FDUP
                 % 3.5 F- FSWAP % 2.5 F- F* A-TMP F@ F* % 0.5 F* % 1.0 F+
                 A-TMP F@ F*
                 FOVER % 0.5 F- F*
                 FSWAP % 1.5 F- F*
                 % 1.0 F+

                 D-TMP F@ F*

;

: ?bad-M-parameters ( -- t/f , f: a b -- a b )
           FDUP F0<
           FOVER FOVER FSWAP F< AND
           FOVER FRAC F0= AND
           FDUP FRAC F0= AND
;

Public:

: M()  ( -- , f: a b x --- u )

       XX-TMP F!

       ?bad-M-parameters abort" M() bad parameters "

       XX-TMP F@ F0= IF
                     FDROP FDROP % 1.0
                ELSE
                     % 1.0 TERM F!     % 1.0 SUM F!

                     XX-TMP F@ % 10.0 F>

                                   IF
                                      1.0e30 OLD-TERM F!

                                      40 0 DO
                                             FOVER FOVER FOVER F- I S>F F+
                                             FSWAP I 1+ S>F FSWAP F- F*
                                             I 1+ S>F XX-TMP F@ F* F/
                                             TERM F@ F* FDUP TERM F!
                                              
                                             FABS OLD-TERM F@ F> IF LEAVE THEN
                                             TERM F@ FDUP FABS OLD-TERM F!
                                             SUM F@ F+ SUM F!

                                             OLD-TERM F@ FDUP 1.0e-6 F<
                                             SUM F@ FABS  1.0e-6 F* F<
                                             OR IF LEAVE THEN
                                             
                                      LOOP

                                      FOVER FOVER F- XX-TMP F@ FSWAP F**
                                      XX-TMP F@ FEXP F* SUM F@ F*
                                      FSWAP GAMMA F*
                                      FSWAP GAMMA F/

                                   ELSE

                                       40 0 DO
                                              FOVER I S>F F+ XX-TMP F@ F*

                                              FOVER I S>F F+
                                              I 1+ S>F F* F/

                                              TERM F@ F* FDUP TERM F!

                                              FABS
                                              SUM F@ FABS  1.0e-6 F*
                                              F< IF LEAVE THEN
                                              SUM F@ TERM F@ F+ SUM F! 

                                       LOOP

                                       FDROP FDROP SUM F@

                                    THEN


                THEN

;

Private:

: u-small-x ( -- , f: a b  -- u )
            \ wont work if b is an integer, so tweak it slightly if it is
            FDUP FRAC F0= IF 1.0e-6 F+ THEN

            BU-TMP F!  AU-TMP F!

            XX-TMP F@ % 0.0 F> IF    \ 0 > x > 5

                                           
                                 PI BU-TMP F@ PI F* FSIN F/
                                 


                                 AU-TMP F@ BU-TMP F@ F- % 1.0 F+ GAMMA
                                 BU-TMP F@ GAMMA F* U-TMP F!

                                 AU-TMP F@ BU-TMP F@ XX-TMP F@ M() U-TMP F@ F/
                                 U-TMP F!

                                 BU-TMP F@ FNEGATE FDUP BU-TMP F!    \ b is now -b
                                 % 1.0 F+ FAC

                                 AU-TMP F@ GAMMA F*
                                 XX-TMP F@ BU-TMP F@ % 1.0 F+ F**
                                 FSWAP F/

                                 AU-TMP F@ BU-TMP F@ F+ % 1.0 F+
                                 % 2.0 BU-TMP F@ F+
                                 XX-TMP F@     M()

                                 F* FNEGATE

                                 U-TMP F@ F+ F*


                              ELSE    \ -5 < x < 0

                                  PI BU-TMP F@ PI F* FSIN F/

                                  XX-TMP F@ FEXP F*

                                  BU-TMP F@ AU-TMP F@ F-
                                  BU-TMP F@
                                  XX-TMP F@ FNEGATE M()
                                  U-TMP F!

                                  \ NOTE: side effect recovery !!!!
                                  \ M() stores last parameter in XX-TMP
                                  \ which is now the original XX-TMP
                                  \ with it sign changed, so we have
                                  \ to fix it here,
                                  XX-TMP F@ FNEGATE XX-TMP F!

                                  AU-TMP F@ BU-TMP F@ F- % 1.0 F+ GAMMA
                                  BU-TMP F@ GAMMA F* U-TMP F@ FSWAP F/
                                  U-TMP F!

                                  BU-TMP F@ FNEGATE FDUP BU-TMP F!    \ b is now -b
                                  
                                  % 2.0 F+ GAMMA AU-TMP F@ GAMMA F*


                                  BU-TMP F@ % 1.0 F+ PI F* FCOS FSWAP F/

                                  XX-TMP F@ FNEGATE
                                  BU-TMP F@ % 1.0 F+  F** F*


                                  % 1.0 AU-TMP F@ F-
                                  BU-TMP F@ % 2.0 F+
                                  XX-TMP F@    M()

                                           
                                  F* FNEGATE

                                  U-TMP F@ F+ F*

            THEN
;

Public:

: U()  ( -- , f: a b x --- u )

       FDUP XX-TMP F!
       FABS % 5.0 F< IF
                         u-small-x
                     ELSE
                         % 1.0 TERM F!   % 1.0 SUM F!
                         FSWAP
                         40 0 DO
                                FOVER FOVER FSWAP F- I 1+ S>F F+
                                FOVER I S>F F+ F*
                                I 1+ S>F XX-TMP F@ F* F/ FNEGATE

                                FDUP FABS % 1.0 F> IF

                                              TERM F@ SUM F@ F/ FABS 1.0e-3 F<
                                              IF   FDROP simple-u
                                              ELSE

                                                   FDROP FSWAP u-small-x
                                              THEN

                                              LEAVE

                                ELSE
                                              TERM F@ F* FDUP TERM F!
                                              SUM F@ F+ SUM F!

                                              TERM F@ SUM F@ F/ FABS 1.0e-6 F<
                                              IF   simple-u
                                                   LEAVE
                                              THEN

                                THEN
                         LOOP


                     THEN

;


: Upcf ( -- , f: nu x  -- U[nu,x] ) 

        ?big-x IF
                   asymptotic-u
               ELSE

                  FSWAP % 0.5 F* FSWAP         \ nu is now 0.5*nu

                  FDUP FDUP F* % -0.25 F* FEXP A-TMP F!
                  FOVER % 0.25 F+ % 2.0 FSWAP F**
                  A-TMP F@ FSWAP F/  A-TMP F!

                  FDUP % 0.0 F> IF

                              FDUP F* % 0.5 F*
                              FSWAP % 0.25 F+ FSWAP
                              % 0.5 FSWAP

                              U()

                           ELSE                \ x <= 0

                              PI FSQRT A-TMP F@ F* A-TMP F!

                              \ saving params in TMPs to conserve stack space
                              XU-TMP F!    FDUP NU-TMP F!

                              % 0.75 F+ GAMMA           B-TMP F!
                              NU-TMP F@ % 0.25 F+ GAMMA C-TMP F!

                              NU-TMP F@ % 0.25 F+ 
                              % 0.5
                              XU-TMP F@ FDUP F* % 0.5 F*

                              M() B-TMP F@ F/ B-TMP F!

                              NU-TMP F@ % 0.75 F+
                              % 1.5
                              XU-TMP F@ FDUP F* % 0.5 F*

                              M() C-TMP F@ F/ % 2.0 FSQRT F* XU-TMP F@ F* FNEGATE

                              B-TMP F@ F+

                           THEN
                           
 
                            A-TMP F@ F*
               THEN

;

: Vpcf ( -- , f: nu x -- V[nu,x] )
        
        ?big-x IF
                   asymptotic-v
               ELSE
                   \ saving params in TMPs to conserve stack space
                   XV-TMP F!    FDUP NV-TMP F!

                   % 0.5 F+ GAMMA PI F/        AV-TMP F!
                   NV-TMP F@ PI F* FSIN        BV-TMP F!

                   NV-TMP F@ XV-TMP F@
                               Upcf            CV-TMP F!
                   NV-TMP F@ XV-TMP F@ FNEGATE
                               Upcf            D-TMP F!

                   BV-TMP F@ CV-TMP F@ F* D-TMP F@ F+ AV-TMP F@ F*
               THEN

;

: Mwhit (  -- , f: k mu z -- M[k,mu,z] )
         FOVER FOVER FSWAP % 0.5 F+ FSWAP F**
         FOVER % -0.5 F* FEXP F*
         D-TMP F!

         FROT FNEGATE % 0.5 F+
         FROT FSWAP FOVER F+

         FSWAP % 2.0 F* % 1.0 F+
         FROT     M()
         D-TMP F@ F*
;

: Wwhit ( -- , f: k mu z -- W[k,mu,z] )
         FOVER FOVER FSWAP % 0.5 F+ FSWAP F**
         FOVER % -0.5 F* FEXP F*
         D-TMP F!

         FROT FNEGATE % 0.5 F+
         FROT FSWAP FOVER F+

         FSWAP % 2.0 F* % 1.0 F+
         FROT     U()
         D-TMP F@ F*
;

Reset_Search_Order

?TEST-CODE [IF]     \ Test Code =============================================

\ compares against test values given in Baker, 1992

: pcf-test ( -- )

     CR

     ."   nu   x     Upcf-actual Vpcf-actual    Upcf     Vpcf " CR

     ."  -2.0  0.0   -0.6081402  -0.4574753   "
     % -2.0 % 0.0 Upcf F.   % -2.0 % 0.0 Vpcf F. CR

     ."   2.0  0.0    0.8108537   0.3431063    "
     % 2.0 % 0.0 Upcf F.   % 2.0 % 0.0 Vpcf F. CR

     ."  -2.0  1.0    0.5156671  -0.5417693    "
     % -2.0 % 1.0 Upcf F.   % -2.0 % 1.0 Vpcf F. CR

     ."   2.0  1.0    0.1832067   1.439015     "
     % 2.0 % 1.0 Upcf F.   % 2.0 % 1.0 Vpcf F. CR

;

[THEN]


