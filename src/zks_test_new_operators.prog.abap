*&---------------------------------------------------------------------*
*& Report zls_test_new_operators
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zks_test_new_operators.

TYPES: BEGIN OF myline,
         col1 TYPE i,
         col2 TYPE i,
         col3 TYPE char10,
         zahl TYPE i,
       END OF myline.

TYPES: tty_itab TYPE SORTED TABLE OF myline WITH UNIQUE KEY col1 col2.

DATA: itab       TYPE tty_itab,
      itab2      TYPE tty_itab,
      itab_delta TYPE tty_itab.

START-OF-SELECTION.

* Tabellen miteinander vergleichen - und nich gleiche Einträge merken
  itab = VALUE #( ( col1 = 1  col2 = 2 col3 =  'Susi'  zahl = 2 )
                  ( col1 = 2  col2 = 2 col3 =  'Peter' zahl = 3 )
                  ( col1 = 3  col2 = 4 col3 =  'Georg' zahl = 4 )
                ).

  itab2 = VALUE #( ( col1 = 1  col2 = 2 col3 =  'Susi'  zahl = 2 )
                   ( col1 = 2  col2 = 3 col3 =  'Peter' zahl = 3 )
              ).

  itab_delta =  FILTER #( itab EXCEPT IN itab2 WHERE col1 = col1 AND col2 = col2 ).
*  break-point.

* ALle Einträge einer Tablle mit einem bestimmten Wert übergeben
  CLEAR: itab_delta.
  itab_delta  = VALUE #( FOR wa IN itab WHERE ( col2 = 2 ) ( wa ) ).
*  break-point.

* ACHTUNG: das macht nicht dasgleiche
  CLEAR: itab_delta.
  itab_delta  = VALUE #( ( itab[ col2 = 2 ] ) ).
*  break-point.

* Tabelleneinträge summieren
  CLEAR: itab_delta.
  itab_delta = VALUE tty_itab(
                   FOR GROUPS cols2  OF  <col2> IN itab
                       GROUP BY ( col2 = <col2>-col2 )
                         LET wa = REDUCE myline(
                                        INIT line TYPE myline
                                         FOR r IN GROUP cols2
                                        NEXT line-zahl += r-zahl )
                         IN
                    ( col2 = cols2-col2
                      zahl = wa-zahl ) ).
  BREAK-POINT.

* Summe für eine Zeile
  CLEAR: itab_delta.
  itab_delta =  VALUE #( ( REDUCE myline(
                                        INIT line TYPE myline
                                         FOR r IN itab WHERE ( col2 = 2 )
                                        NEXT line-zahl += r-zahl
                                             line-col2 = r-col2 ) ) ).
  BREAK-POINT.
