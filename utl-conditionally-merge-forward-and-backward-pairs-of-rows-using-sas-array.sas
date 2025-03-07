%let pgm=utl-conditionally-merge-forward-and-backward-pairs-of-rows-using-sas-array;

%stop_submission;

Conditionally merge forward and backward pairs of rows sas arrays r matrix

   TWO SOLUTIONS SAS AND R

       1 code comparison sas and r
       2 sas arrays
       2 r arrays

This type of problem is best solved with arrays because of non sequential
processing needed.

More than half this code is needed to handle the last two observartions.
There is way to reduce the lines of code by nesting the if statments,
but the resulting code would be harder to maintain?


My interpretation (Only the last two rows can have consecutive delays=1
and no three consecutive rows have delay=1)

First If delay =1 in next to last or last row
  merge rows and sum delay, invoice and payment.
else
If delay is not 1 in next to last or last row
   output two rows unchanged
else
If the delay is 1 in other row then merge rows and
  sum delay, invoive and payment;
else
  do nothing and output remaining rows


If the loan count is 1 then merge to the next row.
If last observation then merge with the previous
 row. Greatly appreciate your help in resolving this.

github
https://tinyurl.com/uh9e3sb8
https://github.com/rogerjdeangelis/utl-conditionally-merge-forward-and-backward-pairs-of-rows-using-sas-array

sas communities
https://tinyurl.com/2mxxumkb
https://communities.sas.com/t5/SAS-Programming/Merge-two-rows-into-one-if-the-count-of-one-row-is-1/m-p/953997#M372645

/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/************************************************************************************************************************************/
/*                                     |                                                    |                                       */
/*             INPUT                   |                   PROCESS                          |           OUTPUT                      */
/*             =====                   | If the delay is 1 then merge to the next row.      |                                       */
/*                                     | If last observations and delay = 1 then merge      |                                       */
/*                                     |                                                    |                                       */
/*                                     |                                                    |                                       */
/* LOWER UPPER DELAY  INVOICE PAYMENT  |  OB LOWER UPPER DELAY INVOICE PAYMENT              | CASE 1                                */
/*                                     |                                                    |                                       */
/*   25    50     1    116294    7412  |   1   25    50     1   116294    7412  * DELETE    | INPUT HAS DELAY=1 IN LAST OB          */
/*   50    75    12    711046   43812  |   2   50    75    12   711046   43812  * DELETE    |                                       */
/*   75   100    33   2906308  186190  |                                                    | LOWER UPPER DELAY  INVOICE PAYMENT    */
/*  100   125    24   2651113  144296  |  RELPACE PAIR WITH SUM BECAUSE DELAY=1             |                                       */
/*  125   150     1   5807462  383168  |  -------------------------------------             |   25    75    13    827340   51224    */
/*  150   175    59   9304718  643080  |       25    75    13    827340   51224 * MERGED    |   75   100    33   2906308  186190    */
/*  175   200    83  15377836  984286  |                                                    |  100   125    24   2651113  144296    */
/*  200   225    69  14498236  889785  |   3   75   100    33   2906308  186190             |  125   175    60  15112180 1026248    */
/*  225   250    84  19678015 1278485  |   4  100   125    24   2651113  144296             |  175   200    83  15377836  984286    */
/*  250   275    76  19644538 1156395  |                                                    |  200   225    69  14498236  889785    */
/*  275   300     1  20128657 1117135  |   5  125   150     1   5807462  383168 * DELETE    |  225   250    84  19678015 1278485    */
/*                                     |   6  150   175    59   9304718  643080 * DELETE    |  250   300    77  39773195 2273530    */
/* data have;                          |                                                    |                                       */
/*   input lower upper delay           |  RELPACE PAIR WITH SUM BECAUSE DELAY=1             |                                       */
/*    invoice payment;                 |  -------------------------------------             |                                       */
/* cards4;                             |      125   175    60  15112180 1026248 * MERGED    |                                       */
/* 25 50  1 116294 7412                |                                                    |                                       */
/* 50 75  12 711046 43812              |   7  175   200    83  15377836  984286             |                                       */
/* 75 100 33 2906308 186190            |   8  200   225    69  14498236  889785             |                                       */
/* 100 125 24 2651113 144296           |   9  225   250    84  19678015 1278485             |                                       */
/* 125 150 1 5807462 383168            |                                                    |                                       */
/* 150 175 59 9304718 643080           |  -------------------------------------             |                                       */
/* 175 200 83 15377836 984286          |  10  250   275    76  19644538 1156395 * DELETE    |                                       */
/* 200 225 69 14498236 889785          |  11  275   300     1  20128657 1117135 * DELETE    |                                       */
/* 225 250 84 19678015 1278485         |                                                    |                                       */
/* 250 275 76 19644538 1156395         |  RELPACE PAIR WITH SUM BECAUSE DELAY=1             |                                       */
/* 275 300 1 20128657 1117135          |  -------------------------------------             |                                       */
/* ;;;;                                |     250    300    77  39773195 2273530 * MERGED    |                                       */
/* run;quit;                           |                                                    |                                       */
/*                                     |                                                    |                                       */
/* -------------------------------------                                                    |---------------------------------------*/
/*                                     |                                                    |                                       */
/* CASE 2 (DELAY NOT=1 IN LAST 2 ROWS) |  WORKS FOR BOTH CASES                              | CASE 2                                */
/*                                     |                                                    |                                       */
/*                                     |                                                    |                                       */
/*  data have;                         |  %array(_cs,data=have,var=lower);                  | DELAY NOT=1 IN LAST 2 ROWS            */
/*    input lower upper delay          |  %put _user_;                                      |                                       */
/*     invoice payment;                |                                                    | LOWER UPPER DELAY  INVOICE PAYMENT    */
/*  cards4;                            |  /*                                                |                                       */
/*  25 50  1 116294 7412               |  GLOBAL _CS1 25                                    |   25    75    13    827340   51224    */
/*  50 75  12 711046 43812             |  GLOBAL _CS2 50                                    |   75   100    33   2906308  186190    */
/*  75 100 33 2906308 186190           |  GLOBAL _CS3 75                                    |  100   125    24   2651113  144296    */
/*  100 125 24 2651113 144296          |  GLOBAL _CS4 100                                   |  125   175    60  15112180 1026248    */
/*  125 150 1 5807462 383168           |  GLOBAL _CS5 125                                   |  175   200    83  15377836  984286    */
/*  150 175 59 9304718 643080          |  GLOBAL _CS6 150                                   |  200   225    69  14498236  889785    */
/*  175 200 83 15377836 984286         |  GLOBAL _CS7 175                                   |  225   250    84  19678015 1278485    */
/*  200 225 69 14498236 889785         |  GLOBAL _CS8 200                                   |  250   275    76  19644538 1156395    */
/*  225 250 84 19678015 1278485        |  GLOBAL _CS9 225                                   |  275   300     0  20128657 1117135    */
/*  250 275 76 19644538 1156395        |  GLOBAL _CS10 250                                  |                                       */
/*  275 300 0 20128657 1117135         |  GLOBAL _CS11 275                                  |                                       */
/*  ;;;;                               |                                                    |                                       */
/*  run;quit;                          |  GLOBAL _CSN 11                                    |                                       */
/*                                     |  */                                                |                                       */
/*                                     |                                                    |                                       */
/*                                     |  data want ;                                       |                                       */
/*                                     |                                                    |                                       */
/*                                     |    array range[&_csn]                              |                                       */
/*                                     |      (%do_over(_cs,phrase=?,between=comma));       |                                       */
/*                                     |    /*---                                           |                                       */
/*                                     |    array range[11]                                 |                                       */
/*                                     |      (25,50,75,100,125,150,175,200,225,250,275);   |                                       */
/*                                     |    ---*/                                           |                                       */
/*                                     |                                                    |                                       */
/*                                     |    array num %utl_numary(have,drop=upper lower);   |                                       */
/*                                     |    /*---                                           |                                       */
/*                                     |      Array num  [11,3]                             |                                       */
/*                                     |        (1,  116294,    7412,                       |                                       */
/*                                     |         12, 711046,    43812,                      |                                       */
/*                                     |         33, 2906308,   186190,                     |                                       */
/*                                     |         24, 2651113,   144296,                     |                                       */
/*                                     |         1,  5807462,   383168,                     |                                       */
/*                                     |         59, 9304718,   643080,                     |                                       */
/*                                     |         83, 15377836,  984286,                     |                                       */
/*                                     |         69, 14498236,  889785,                     |                                       */
/*                                     |         84, 19678015,  1278485,                    |                                       */
/*                                     |         76, 19644538,  1156395,                    |                                       */
/*                                     |         1,   20128657, 1117135)                    |                                       */
/*                                     |    ---*/                                           |                                       */
/*                                     |    do row=1 to dim(num,1) ;                        |                                       */
/*                                     |                                                    |                                       */
/*                                     |      select ;                                      |                                       */
/*                                     |                                                    |                                       */
/*                                     |         * NEXT TO THE LAST ROW AND                 |                                       */
/*                                     |           DELAY=1 or DELAY=1 in LAST ROW ;         |                                       */
/*                                     |         when  (                                    |                                       */
/*                                     |               (row = dim(num,1)-1)                 |                                       */
/*                                     |           and ((num[row,1]=1) or (num[row+1,1]=1)) |                                       */
/*                                     |               ) do;                                |                                       */
/*                                     |           delay    = num[row,1] + num[row+1,1] ;   |                                       */
/*                                     |           invoice  = num[row,2] + num[row+1,2] ;   |                                       */
/*                                     |           payment  = num[row,3] + num[row+1,3] ;   |                                       */
/*                                     |           lower    = range[row] ;                  |                                       */
/*                                     |           upper    = lower +50 ;                   |                                       */
/*                                     |           output;                                  |                                       */
/*                                     |           stop;                                    |                                       */
/*                                     |         end;                                       |                                       */
/*                                     |                                                    |                                       */
/*                                     |         * NEXT TO THE LAST ROW AND                 |                                       */
/*                                     |           DELAY DOES NOT =1 IN NEXT                |                                       */
/*                                     |           TO LAST ROW OR LAST ROW                  |                                       */
/*                                     |           OUTPUT BOTH ROWS;                        |                                       */
/*                                     |         when (                                     |                                       */
/*                                     |              (row = dim(num,1)-1) and (            |                                       */
/*                                     |           num[row,1] ne 1) and (num[row+1,1] ne 1) |                                       */
/*                                     |              ) do;                                 |                                       */
/*                                     |           delay   = num[row,1] ;                   |                                       */
/*                                     |           invoice = num[row,2] ;                   |                                       */
/*                                     |           payment = num[row,3] ;                   |                                       */
/*                                     |           lower = range[row];                      |                                       */
/*                                     |           upper = lower +25;                       |                                       */
/*                                     |           output;                                  |                                       */
/*                                     |           delay   = num[row+1,1] ;                 |                                       */
/*                                     |           invoice = num[row+1,2] ;                 |                                       */
/*                                     |           payment = num[row+1,3] ;                 |                                       */
/*                                     |           lower = range[row+1];                    |                                       */
/*                                     |           upper = lower +25;                       |                                       */
/*                                     |           output;                                  |                                       */
/*                                     |           stop;                                    |                                       */
/*                                     |         end;                                       |                                       */
/*                                     |                                                    |                                       */
/*                                     |         * DELAY=1 NOT IN LAST TWO ROWS             |                                       */
/*                                     |           OUTPUT ONE ROW WITH SUMS;                |                                       */
/*                                     |                                                    |                                       */
/*                                     |         when (num[row,1]=1) do;                    |                                       */
/*                                     |           delay   = num[row,1] + num[row+1,1] ;    |                                       */
/*                                     |           invoice = num[row,2] + num[row+1,2] ;    |                                       */
/*                                     |           payment = num[row,3] + num[row+1,3] ;    |                                       */
/*                                     |           lower = range[row];                      |                                       */
/*                                     |           upper = lower +50;                       |                                       */
/*                                     |           row=row+1;                               |                                       */
/*                                     |           output;                                  |                                       */
/*                                     |         end;                                       |                                       */
/*                                     |                                                    |                                       */
/*                                     |         * NO CHANGE;                               |                                       */
/*                                     |         otherwise do;                              |                                       */
/*                                     |           delay   = num[row,1];                    |                                       */
/*                                     |           invoice = num[row,2];                    |                                       */
/*                                     |           payment = num[row,3];                    |                                       */
/*                                     |           lower = range[row];                      |                                       */
/*                                     |           upper = lower +25;                       |                                       */
/*                                     |           output;                                  |                                       */
/*                                     |         end;                                       |                                       */
/*                                     |                                                    |                                       */
/*                                     |      end;                                          |                                       */
/*                                     |                                                    |                                       */
/*                                     |    end;                                            |                                       */
/*                                     |    keep delay invoice payment lower upper;         |                                       */
/*                                     |                                                    |                                       */
/*                                     |   run;quit;                                        |                                       */
/*                                     |                                                    |                                       */
/************************************************************************************************************************************/

/*                 _                                            _
/ |   ___ ___   __| | ___   ___ ___  _ __ ___  _ __   __ _ _ __(_)___  ___  _ __
| |  / __/ _ \ / _` |/ _ \ / __/ _ \| `_ ` _ \| `_ \ / _` | `__| / __|/ _ \| `_ \
| | | (_| (_) | (_| |  __/| (_| (_) | | | | | | |_) | (_| | |  | \__ \ (_) | | | |
|_|  \___\___/ \__,_|\___| \___\___/|_| |_| |_| .__/ \__,_|_|  |_|___/\___/|_| |_|
                                              |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/* *works;                                                          data want ;                                           */
/* %utl_rbeginx;                                                                                                          */
/* parmcards4;                                                        array range[&_csn]                                  */
/* library(haven)                                                       (%do_over(_cs,phrase=?,between=comma));           */
/* source("c:/oto/fn_tosas9x.R")                                      /*---                                               */
/*   range<-c(25.,50.,75.,100.,125.                                   array range[11]                                     */
/*   ,150.,175.,200.,225.,250.,275.)                                    (25,50,75,100,125,150,175,200,225,250,275);       */
/*   num <- matrix (                                                  ---*/                                               */
/*    c(1.,  116294.,    7412.,                                                                                           */
/*      12., 711046.,    43812.,                                      array num %utl_numary(have,drop=upper lower);       */
/*      33., 2906308.,   186190.,                                     /*---                                               */
/*      24., 2651113.,   144296.,                                       Array num  [11,3]                                 */
/*      1.,  5807462.,   383168.,                                         (1,  116294,    7412,                           */
/*      59., 9304718.,   643080.,                                          12, 711046,    43812,                          */
/*      83., 15377836.,  984286.,                                          33, 2906308,   186190,                         */
/*      69., 14498236.,  889785.,                                          24, 2651113,   144296,                         */
/*      84., 19678015.,  1278485.,                                         1,  5807462,   383168,                         */
/*      76., 19644538.,  1156395.,                                         59, 9304718,   643080,                         */
/*      1.,  20128657., 1117135.)                                          83, 15377836,  984286,                         */
/*     ,nrow =11, ncol = 3,byrow=TRUE)                                     69, 14498236,  889785,                         */
/* result <- data.frame()                                                  84, 19678015,  1278485,                        */
/* num_rows <- nrow(num)                                                   76, 19644538,  1156395,                        */
/* num_rows                                                                1,   20128657, 1117135)                        */
/* result                                                             ---*/                                               */
/* num_rows                                                           do row=1 to dim(num,1) ;                            */
/* row=0;                                                                                                                 */
/*   for (rec in 1:num_rows) {                                          select ;                                          */
/*     row=row+1                                                                                                          */
/*     #catrow ",row,"\n");                                                * NEXT TO THE LAST ROW AND                     */
/*                                                                           DELAY=1 or DELAY=1 in LAST ROW ;             */
/*                                                                                                                        */
/*     if (row == num_rows - 1 &&                                          when  (                                        */
/*          (num[row, 1] == 1 || num[row + 1, 1] == 1)) {                    and ((num[row,1]=1) or (num[row+1,1]=1))     */
/*       delay <- num[row, 1] + num[row + 1, 1]                                  ) do;                                    */
/*       invoice <- num[row, 2] + num[row + 1, 2]                            delay    = num[row,1] + num[row+1,1] ;       */
/*       payment <- num[row, 3] + num[row + 1, 3]                            invoice  = num[row,2] + num[row+1,2] ;       */
/*       lower <- range[row]                                                 payment  = num[row,3] + num[row+1,3] ;       */
/*       upper <- lower + 50                                                 lower    = range[row] ;                      */
/*       result <- rbind(result,                                             upper    = lower +50 ;                       */
/*        data.frame(delay,invoice,payment,lower,upper))                     output;                                      */
/*       #cat("1st","\n")                                                    stop;                                        */
/*       break                                                             end;                                           */
/*                                                                                                                        */
/*                                                                                                                        */
/*     } else if ((row == num_rows-1)&&                                    when (                                         */
/*         ((num[row,1] != 1) && (num[row+1,1]!=1))){                           (row = dim(num,1)-1) and (                */
/*       delay   <- num[row,1]                                               num[row,1] ne 1) and (num[row+1,1] ne 1)     */
/*       invoice <- num[row,2]                                                  ) do;                                     */
/*       payment <- num[row,3]                                               delay   = num[row,1] ;                       */
/*       lower <- range[row]                                                 invoice = num[row,2] ;                       */
/*       upper <- lower +25                                                  payment = num[row,3] ;                       */
/*       result <- rbind(result,                                             lower = range[row];                          */
/*        data.frame(delay,invoice,payment,lower,upper))                     upper = lower +25;                           */
/*       delay   <- num[row+1,1]                                             output;                                      */
/*       invoice <- num[row+1,2]                                             delay   = num[row+1,1] ;                     */
/*       payment <- num[row+1,3]                                             invoice = num[row+1,2] ;                     */
/*       lower <- range[row+1];                                              payment = num[row+1,3] ;                     */
/*       upper <- lower +25                                                  lower = range[row+1];                        */
/*       result <- rbind(result,                                             upper = lower +25;                           */
/*        data.frame(delay,invoice,payment,lower,upper))                     output;                                      */
/*       #cat("2nd","\n")                                                    stop;                                        */
/*       break                                                             end;                                           */
/*                                                                                                                        */
/*                                                                                                                        */
/*     } else if (num[row,1]==1) {                                         when (num[row,1]=1) do;                        */
/*       delay   <- num[row,1] + num[row+1,1]                                delay   = num[row,1] + num[row+1,1] ;        */
/*       invoice <- num[row,2] + num[row+1,2]                                invoice = num[row,2] + num[row+1,2] ;        */
/*       payment <- num[row,3] + num[row+1,3]                                payment = num[row,3] + num[row+1,3] ;        */
/*       lower <- range[row]                                                 lower = range[row];                          */
/*       upper <- lower +50                                                  upper = lower +50;                           */
/*       result <- rbind(result,                                             row=row+1;                                   */
/*        data.frame(delay,invoice,payment,lower,upper))                     output;                                      */
/*       cat("3rda",row,"\n")                                              end;                                           */
/*       row<-row+1;                                                                                                      */
/*       cat("3rdb",row,"\n")                                                                                             */
/*                                                                                                                        */
/*     } else {                                                            otherwise do;                                  */
/*       delay <- num[row, 1]                                                delay   = num[row,1];                        */
/*       invoice <- num[row, 2]                                              invoice = num[row,2];                        */
/*       payment <- num[row, 3]                                              payment = num[row,3];                        */
/*       lower <- range[row]                                                 lower = range[row];                          */
/*       upper <- lower + 25                                                 upper = lower +25;                           */
/*       result <- rbind(result,                                             output;                                      */
/*        data.frame(delay,invoice,payment,lower,upper))                   end;                                           */
/*       #cat("4th","\n")                                                                                                 */
/*     }                                                                end;                                              */
/*    }                                                                                                                   */
/* result                                                           end;                                                  */
/* ;;;;                                                             keep delay invoice payment lower upper;               */
/* %utl_rendx(resolve=N);                                           run;quit;                                             */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

data have;
  input lower upper delay
   invoice payment;
cards4;
25 50  1 116294 7412
50 75  12 711046 43812
75 100 33 2906308 186190
100 125 24 2651113 144296
125 150 1 5807462 383168
150 175 59 9304718 643080
175 200 83 15377836 984286
200 225 69 14498236 889785
225 250 84 19678015 1278485
250 275 76 19644538 1156395
275 300 1 20128657 1117135
;;;;
run;quit;


 data have;
   input lower upper delay
    invoice payment;
 cards4;
 25 50  1 116294 7412
 50 75  12 711046 43812
 75 100 33 2906308 186190
 100 125 24 2651113 144296
 125 150 1 5807462 383168
 150 175 59 9304718 643080
 175 200 83 15377836 984286
 200 225 69 14498236 889785
 225 250 84 19678015 1278485
 250 275 76 19644538 1156395
 275 300 0 20128657 1117135
 ;;;;
 run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* CASE 1 (DELAY=1 IN ONE OR MORE OF LAST 2 OBSEVATIONS)                                                                  */
/*                                                                                                                        */
/*   LOWER    UPPER    DELAY     INVOICE    PAYMENT                                                                       */
/*                                                                                                                        */
/*     25       50        1       116294       7412                                                                       */
/*     50       75       12       711046      43812                                                                       */
/*     75      100       33      2906308     186190                                                                       */
/*    100      125       24      2651113     144296                                                                       */
/*    125      150        1      5807462     383168                                                                       */
/*    150      175       59      9304718     643080                                                                       */
/*    175      200       83     15377836     984286                                                                       */
/*    200      225       69     14498236     889785                                                                       */
/*    225      250       84     19678015    1278485                                                                       */
/*    250      275       76     19644538    1156395                                                                       */
/*    275      300        1**   20128657    1117135                                                                       */
/*                                                                                                                        */
/*   CASE 1 (                                                                                                             */
/*                                                                                                                        */
/* CASE 2 (DELAY NOT=1 IN LAST 2 ROWS)                                                                                    */
/*                                                                                                                        */
/*                                                                                                                        */
/*   LOWER    UPPER    DELAY     INVOICE    PAYMENT                                                                       */
/*                                                                                                                        */
/*     25       50        1       116294       7412                                                                       */
/*     50       75       12       711046      43812                                                                       */
/*     75      100       33      2906308     186190                                                                       */
/*    100      125       24      2651113     144296                                                                       */
/*    125      150        1      5807462     383168                                                                       */
/*    150      175       59      9304718     643080                                                                       */
/*    175      200       83     15377836     984286                                                                       */
/*    200      225       69     14498236     889785                                                                       */
/*    225      250       84     19678015    1278485                                                                       */
/*    250      275       76     19644538    1156395                                                                       */
/*    275      300        0     20128657    1117135                                                                       */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___
|___ \   ___  __ _ ___    __ _ _ __ _ __ __ _ _   _ ___
  __) | / __|/ _` / __|  / _` | `__| `__/ _` | | | / __|
 / __/  \__ \ (_| \__ \ | (_| | |  | | | (_| | |_| \__ \
|_____| |___/\__,_|___/  \__,_|_|  |_|  \__,_|\__, |___/
                                              |___/
*/

* CASE 1;
data have;
  input lower upper delay
   invoice payment;
cards4;
25 50  1 116294 7412
50 75  12 711046 43812
75 100 33 2906308 186190
100 125 24 2651113 144296
125 150 1 5807462 383168
150 175 59 9304718 643080
175 200 83 15377836 984286
200 225 69 14498236 889785
225 250 84 19678015 1278485
250 275 76 19644538 1156395
275 300 1 20128657 1117135
;;;;
run;quit;

* CASE 2;
data have;
  input lower upper delay
   invoice payment;
cards4;
25 50  1 116294 7412
50 75  12 711046 43812
75 100 33 2906308 186190
100 125 24 2651113 144296
125 150 1 5807462 383168
150 175 59 9304718 643080
175 200 83 15377836 984286
200 225 69 14498236 889785
225 250 84 19678015 1278485
250 275 76 19644538 1156395
275 300 0 20128657 1117135
;;;;
run;quit;

proc datasets lib=work nodetails nolist;
 delete want;
run;quit;

%arraydelete(_cs);

%array(_cs,data=have,var=lower);
%put _user_;

/*
GLOBAL _CS1 25
GLOBAL _CS2 50
GLOBAL _CS3 75
GLOBAL _CS4 100
GLOBAL _CS5 125
GLOBAL _CS6 150
GLOBAL _CS7 175
GLOBAL _CS8 200
GLOBAL _CS9 225
GLOBAL _CS10 250
GLOBAL _CS11 275

GLOBAL _CSN 11
*/

data want ;

  array range[&_csn]
    (%do_over(_cs,phrase=?,between=comma));
  /*---
  array range[11]
    (25,50,75,100,125,150,175,200,225,250,275);
  ---*/

  array num %utl_numary(have,drop=upper lower);
  /*---
    Array num  [11,3]
      (1,  116294,    7412,
       12, 711046,    43812,
       33, 2906308,   186190,
       24, 2651113,   144296,
       1,  5807462,   383168,
       59, 9304718,   643080,
       83, 15377836,  984286,
       69, 14498236,  889785,
       84, 19678015,  1278485,
       76, 19644538,  1156395,
       *** 1 or 0 ***,20128657, 1117135)
  ---*/
  do row=1 to dim(num,1) ;

    select ;

       * NEXT TO THE LAST ROW AND
         DELAY=1 or DELAY=1 in LAST ROW ;
       when  (
             (row = dim(num,1)-1)
         and ((num[row,1]=1) or (num[row+1,1]=1))
             ) do;
         delay    = num[row,1] + num[row+1,1] ;
         invoice  = num[row,2] + num[row+1,2] ;
         payment  = num[row,3] + num[row+1,3] ;
         lower    = range[row] ;
         upper    = lower +50 ;
         output;
         stop;
       end;

       * NEXT TO THE LAST ROW AND
         DELAY DOES NOT =1 IN NEXT
         TO LAST ROW OR LAST ROW
         OUTPUT BOTH ROWS;
       when (
            (row = dim(num,1)-1) and (
         num[row,1] ne 1) and (num[row+1,1] ne 1)
            ) do;
         delay   = num[row,1] ;
         invoice = num[row,2] ;
         payment = num[row,3] ;
         lower = range[row];
         upper = lower +25;
         output;
         delay   = num[row+1,1] ;
         invoice = num[row+1,2] ;
         payment = num[row+1,3] ;
         lower = range[row+1];
         upper = lower +25;
         output;
         stop;
       end;

       * DELAY=1 NOT IN LAST TWO ROWS
         OUTPUT ONE ROW WITH SUMS;

       when (num[row,1]=1) do;
         delay   = num[row,1] + num[row+1,1] ;
         invoice = num[row,2] + num[row+1,2] ;
         payment = num[row,3] + num[row+1,3] ;
         lower = range[row];
         upper = lower +50;
         row=row+1;
         output;
       end;

       * NO CHANGE;
       otherwise do;
         delay   = num[row,1];
         invoice = num[row,2];
         payment = num[row,3];
         lower = range[row];
         upper = lower +25;
         output;
       end;

    end;

  end;
  keep delay invoice payment lower upper;

 run;quit;

%arraydelete(_cs);

proc print data=want;
run;quit;

/**************************************************************************************************************************/
/*                                                         |                                                              */
/*  CASE 1 (DELAY=1 IN ONE OR MORE OF LAST 2 OBSEVATIONS)  | CASE 2 (DELAY=1 IN ONE OR MORE OF LAST 2 OBSEVATIONS         */
/*  =====================================================  | ====================================================         */
/*                                                         |                                                              */
/*  DELAY     INVOICE    PAYMENT    LOWER    UPPER         | DELAY     INVOICE    PAYMENT    LOWER    UPPER               */
/*                                                         |                                                              */
/*    13       827340      51224      25       75          |   13       827340      51224      25       75                */
/*    33      2906308     186190      75      100          |   33      2906308     186190      75      100                */
/*    24      2651113     144296     100      125          |   24      2651113     144296     100      125                */
/*    60     15112180    1026248     125      175          |   60     15112180    1026248     125      175                */
/*    83     15377836     984286     175      200          |   83     15377836     984286     175      200                */
/*    69     14498236     889785     200      225          |   69     14498236     889785     200      225                */
/*    84     19678015    1278485     225      250          |   84     19678015    1278485     225      250                */
/*                                                         |                                                              */
/*                                                         |   76     19644538    1156395     250      275                */
/*                                                         |    0     20128657    1117135     275      300                */
/*                                                         |                                                              */
/**************************************************************************************************************************/

/*____
|___ /   _ __    __ _ _ __ _ __ __ _ _   _ ___
  |_ \  | `__|  / _` | `__| `__/ _` | | | / __|
 ___) | | |    | (_| | |  | | | (_| | |_| \__ \
|____/  |_|     \__,_|_|  |_|  \__,_|\__, |___/
                                     |___/
*/

proc datasets lib=work nodetails nolist;
 delete want;
run;quit;

*works;
%utl_rbeginx;
parmcards4;
library(haven)
source("c:/oto/fn_tosas9x.R")
  range<-c(25.,50.,75.,100.,125.
  ,150.,175.,200.,225.,250.,275.)
  num <- matrix (
   c(1.,  116294.,    7412.,
     12., 711046.,    43812.,
     33., 2906308.,   186190.,
     24., 2651113.,   144296.,
     1.,  5807462.,   383168.,
     59., 9304718.,   643080.,
     83., 15377836.,  984286.,
     69., 14498236.,  889785.,
     84., 19678015.,  1278485.,
     76., 19644538.,  1156395.,
     0.,  20128657., 1117135.)
    ,nrow =11, ncol = 3,byrow=TRUE)
result <- data.frame()
num_rows <- nrow(num)
num_rows
result
num_rows
row=0;
  for (rec in 1:num_rows) {
    row=row+1
    #catrow ",row,"\n");


    if (row == num_rows - 1 &&
         (num[row, 1] == 1 || num[row + 1, 1] == 1)) {
      delay <- num[row, 1] + num[row + 1, 1]
      invoice <- num[row, 2] + num[row + 1, 2]
      payment <- num[row, 3] + num[row + 1, 3]
      lower <- range[row]
      upper <- lower + 50
      result <- rbind(result,
       data.frame(delay,invoice,payment,lower,upper))
      #cat("1st","\n")
      break


    } else if ((row == num_rows-1)&&
        ((num[row,1] != 1) && (num[row+1,1]!=1))){
      delay   <- num[row,1]
      invoice <- num[row,2]
      payment <- num[row,3]
      lower <- range[row]
      upper <- lower +25
      result <- rbind(result,
       data.frame(delay,invoice,payment,lower,upper))
      delay   <- num[row+1,1]
      invoice <- num[row+1,2]
      payment <- num[row+1,3]
      lower <- range[row+1];
      upper <- lower +25
      result <- rbind(result,
       data.frame(delay,invoice,payment,lower,upper))
      #cat("2nd","\n")
      break


    } else if (num[row,1]==1) {
      delay   <- num[row,1] + num[row+1,1]
      invoice <- num[row,2] + num[row+1,2]
      payment <- num[row,3] + num[row+1,3]
      lower <- range[row]
      upper <- lower +50
      result <- rbind(result,
       data.frame(delay,invoice,payment,lower,upper))
      cat("3rda",row,"\n")
      row<-row+1;
      cat("3rdb",row,"\n")

    } else {
      delay <- num[row, 1]
      invoice <- num[row, 2]
      payment <- num[row, 3]
      lower <- range[row]
      upper <- lower + 25
      result <- rbind(result,
       data.frame(delay,invoice,payment,lower,upper))
      #cat("4th","\n")
    }
   }
result
fn_tosas9x(
      inp    = result
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

proc print data=sd1.want;
run;quit;

/**************************************************************************************************************************/
/*                                      |                                                                                 */
/* R                                    |  SAS                                                                            */
/*                                      |                                                                                 */
/* CASE 1                               |  CASE 1                                                                         */
/*                                      |                                                                                 */
/* delay  invoice payment lower upper   |  ROWNAMES DELAY  INVOICE PAYMENT LOWER UPPER                                    */
/*                                      |                                                                                 */
/*    13   827340   51224    25    75   |      1      13    827340   51224   25    75                                     */
/*    33  2906308  186190    75   100   |      2      33   2906308  186190   75   100                                     */
/*    24  2651113  144296   100   125   |      3      24   2651113  144296  100   125                                     */
/*    60 15112180 1026248   125   175   |      4      60  15112180 1026248  125   175                                     */
/*    83 15377836  984286   175   200   |      5      83  15377836  984286  175   200                                     */
/*    69 14498236  889785   200   225   |      6      69  14498236  889785  200   225                                     */
/*    84 19678015 1278485   225   250   |      7      84  19678015 1278485  225   250                                     */
/*    77 39773195 2273530   250   300   |      8      77  39773195 2273530  250   300                                     */
/*                                      |                                                                                 */
/* CASE 2                               |  CASE 2                                                                         */
/*                                      |                                                                                 */
/* delay  invoice payment lower upper   |  ROWNAMES DELAY  INVOICE PAYMENT LOWER UPPER                                    */
/*                                      |                                                                                 */
/*    13   827340   51224    25    75   |      1      13    827340   51224   25    75                                     */
/*    33  2906308  186190    75   100   |      2      33   2906308  186190   75   100                                     */
/*    24  2651113  144296   100   125   |      3      24   2651113  144296  100   125                                     */
/*    60 15112180 1026248   125   175   |      4      60  15112180 1026248  125   175                                     */
/*    83 15377836  984286   175   200   |      5      83  15377836  984286  175   200                                     */
/*    69 14498236  889785   200   225   |      6      69  14498236  889785  200   225                                     */
/*    84 19678015 1278485   225   250   |      7      84  19678015 1278485  225   250                                     */
/*    76 19644538 1156395   250   275   |      8      76  19644538 1156395  250   275                                     */
/*     0 20128657 1117135   275   300   |      9       0  20128657 1117135  275   300                                     */
/*                                      |                                                                                 */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/

