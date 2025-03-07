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































;;;;
%utl_rendx(resolve=N);


































































































































*works;                                                                      data want ;
%utl_rbeginx;
parmcards4;                                                                    array range[&_csn]
library(haven)                                                                   (%do_over(_cs,phrase=?,between=comma));
source("c:/oto/fn_tosas9x.R")                                                  /*---
  range<-c(25.,50.,75.,100.,125.                                               array range[11]
  ,150.,175.,200.,225.,250.,275.)                                                (25,50,75,100,125,150,175,200,225,250,275);
  num <- matrix (                                                              ---*/
   c(1.,  116294.,    7412.,
     12., 711046.,    43812.,                                                  array num %utl_numary(have,drop=upper lower);
     33., 2906308.,   186190.,                                                 /*---
     24., 2651113.,   144296.,                                                   Array num  [11,3]
     1.,  5807462.,   383168.,                                                     (1,  116294,    7412,
     59., 9304718.,   643080.,                                                      12, 711046,    43812,
     83., 15377836.,  984286.,                                                      33, 2906308,   186190,
     69., 14498236.,  889785.,                                                      24, 2651113,   144296,
     84., 19678015.,  1278485.,                                                     1,  5807462,   383168,
     76., 19644538.,  1156395.,                                                     59, 9304718,   643080,
     1.,  20128657., 1117135.)                                                      83, 15377836,  984286,
    ,nrow =11, ncol = 3,byrow=TRUE)                                                 69, 14498236,  889785,
result <- data.frame()                                                              84, 19678015,  1278485,
num_rows <- nrow(num)                                                               76, 19644538,  1156395,
num_rows                                                                            1,   20128657, 1117135)
result                                                                         ---*/
num_rows                                                                       do row=1 to dim(num,1) ;
row=0;
  for (rec in 1:num_rows) {                                                      select ;
    row=row+1
    #catrow ",row,"\n");                                                            * NEXT TO THE LAST ROW AND
                                                                                      DELAY=1 or DELAY=1 in LAST ROW ;

    if (row == num_rows - 1 &&      (row = dim(num,1)-1)                            when  (
         (num[row, 1] == 1 || num[row + 1, 1] == 1)) {                                and ((num[row,1]=1) or (num[row+1,1]=1))
      delay <- num[row, 1] + num[row + 1, 1]                                              ) do;
      invoice <- num[row, 2] + num[row + 1, 2]                                        delay    = num[row,1] + num[row+1,1] ;
      payment <- num[row, 3] + num[row + 1, 3]                                        invoice  = num[row,2] + num[row+1,2] ;
      lower <- range[row]                                                             payment  = num[row,3] + num[row+1,3] ;
      upper <- lower + 50                                                             lower    = range[row] ;
      result <- rbind(result,                                                         upper    = lower +50 ;
       data.frame(delay,invoice,payment,lower,upper))                                 output;
      #cat("1st","\n")                                                                stop;
      break                                                                         end;


    } else if ((row == num_rows-1)&&                                                when (
        ((num[row,1] != 1) && (num[row+1,1]!=1))){                                       (row = dim(num,1)-1) and (
      delay   <- num[row,1]                                                           num[row,1] ne 1) and (num[row+1,1] ne 1)
      invoice <- num[row,2]                                                              ) do;
      payment <- num[row,3]                                                           delay   = num[row,1] ;
      lower <- range[row]                                                             invoice = num[row,2] ;
      upper <- lower +25                                                              payment = num[row,3] ;
      result <- rbind(result,                                                         lower = range[row];
       data.frame(delay,invoice,payment,lower,upper))                                 upper = lower +25;
      delay   <- num[row+1,1]                                                         output;
      invoice <- num[row+1,2]                                                         delay   = num[row+1,1] ;
      payment <- num[row+1,3]                                                         invoice = num[row+1,2] ;
      lower <- range[row+1];                                                          payment = num[row+1,3] ;
      upper <- lower +25                                                              lower = range[row+1];
      result <- rbind(result,                                                         upper = lower +25;
       data.frame(delay,invoice,payment,lower,upper))                                 output;
      #cat("2nd","\n")                                                                stop;
      break                                                                         end;


    } else if (num[row,1]==1) {                                                     when (num[row,1]=1) do;
      delay   <- num[row,1] + num[row+1,1]                                            delay   = num[row,1] + num[row+1,1] ;
      invoice <- num[row,2] + num[row+1,2]                                            invoice = num[row,2] + num[row+1,2] ;
      payment <- num[row,3] + num[row+1,3]                                            payment = num[row,3] + num[row+1,3] ;
      lower <- range[row]                                                             lower = range[row];
      upper <- lower +50                                                              upper = lower +50;
      result <- rbind(result,                                                         row=row+1;
       data.frame(delay,invoice,payment,lower,upper))                                 output;
      cat("3rda",row,"\n")                                                          end;
      row<-row+1;
      cat("3rdb",row,"\n")

    } else {                                                                        otherwise do;
      delay <- num[row, 1]                                                            delay   = num[row,1];
      invoice <- num[row, 2]                                                          invoice = num[row,2];
      payment <- num[row, 3]                                                          payment = num[row,3];
      lower <- range[row]                                                             lower = range[row];
      upper <- lower + 25                                                             upper = lower +25;
      result <- rbind(result,                                                         output;
       data.frame(delay,invoice,payment,lower,upper))                               end;
      #cat("4th","\n")
    }                                                                            end;
   }
result                                                                       end;
;;;;                                                                         keep delay invoice payment lower upper;
%utl_rendx(resolve=N);                                                       run;quit;















































































































































            INPUT                                      PROCESS                                  OUTPUT
            =====

LOWER UPPER DELAY  INVOICE PAYMENT    OB LOWER UPPER DELAY INVOICE PAYMENT                      INPUT HAS DELAY=1 IN LAST OB

  25    50     1    116294    7412     1   25    50     1   116294    7412                      LOWER UPPER DELAY  INVOICE PAYMENT
  50    75    12    711046   43812     2   50    75    12   711046   43812
  75   100    33   2906308  186190                                                                25    75    13    827340   51224
 100   125    24   2651113  144296    RELPACE PAIR WITH SUM BECAUSE DELAY=1                       75   100    33   2906308  186190
 125   150     1   5807462  383168    -------------------------------------                      100   125    24   2651113  144296
 150   175    59   9304718  643080         25    75    13    827340   51224                      125   175    60  15112180 1026248
 175   200    83  15377836  984286                                                               175   200    83  15377836  984286
 200   225    69  14498236  889785     3   75   100    33   2906308  186190                      200   225    69  14498236  889785
 225   250    84  19678015 1278485     4  100   125    24   2651113  144296                      225   250    84  19678015 1278485
 250   275    76  19644538 1156395                                                               250   300    77  39773195 2273530
 275   300     1  20128657 1117135     5  125   150     1   5807462  383168
                                       6  150   175    59   9304718  643080                      INPUT HAS DELAY=0 IN LAST OB
data have;
  input lower upper delay             RELPACE PAIR WITH SUM BECAUSE DELAY=1                     LOWER UPPER DELAY  INVOICE PAYMENT
   invoice payment;                   -------------------------------------
cards4;                                   125   175    60  15112180 1026248                       25    75    13    827340   51224
25 50  1 116294 7412                                                                              75   100    33   2906308  186190
50 75  12 711046 43812                 7  175   200    83  15377836  984286                      100   125    24   2651113  144296
75 100 33 2906308 186190               8  200   225    69  14498236  889785                      125   175    60  15112180 1026248
100 125 24 2651113 144296              9  225   250    84  19678015 1278485                      175   200    83  15377836  984286
125 150 1 5807462 383168                                                                         200   225    69  14498236  889785
150 175 59 9304718 643080                                                                        225   250    84  19678015 1278485
175 200 83 15377836 984286            RELPACE PAIR WITH SUM BECAUSE DELAY=1
200 225 69 14498236 889785            -------------------------------------                      250   275    76  19644538  1156395
225 250 84 19678015 1278485           10  250   275    76  19644538 1156395                      275   300     0  20128657  1117135
250 275 76 19644538 1156395           11  275   300     1  20128657 1117135
275 300 1 20128657 1117135
;;;;
run;quit;


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
                                             1,   20128657, 1117135)
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



                                   _                                         _
  ___ ___  _ __ ___  _ __   __ _ _ __(_)___  ___  _ __    _ __   __ _ _ __   __| |  ___  __ _ ___
 / __/ _ \| `_ ` _ \| `_ \ / _` | `__| / __|/ _ \| `_ \  | `__| / _` | `_ \ / _` | / __|/ _` / __|
| (_| (_) | | | | | | |_) | (_| | |  | \__ \ (_) | | | | | |   | (_| | | | | (_| | \__ \ (_| \__ \
 \___\___/|_| |_| |_| .__/ \__,_|_|  |_|___/\___/|_| |_| |_|    \__,_|_| |_|\__,_| |___/\__,_|___/
                    |_|























*works;                                                                      data want ;
%utl_rbeginx;
parmcards4;                                                                    array range[&_csn]
library(haven)                                                                   (%do_over(_cs,phrase=?,between=comma));
source("c:/oto/fn_tosas9x.R")                                                  /*---
  range<-c(25.,50.,75.,100.,125.                                               array range[11]
  ,150.,175.,200.,225.,250.,275.)                                                (25,50,75,100,125,150,175,200,225,250,275);
  num <- matrix (                                                              ---*/
   c(1.,  116294.,    7412.,
     12., 711046.,    43812.,                                                  array num %utl_numary(have,drop=upper lower);
     33., 2906308.,   186190.,                                                 /*---
     24., 2651113.,   144296.,                                                   Array num  [11,3]
     1.,  5807462.,   383168.,                                                     (1,  116294,    7412,
     59., 9304718.,   643080.,                                                      12, 711046,    43812,
     83., 15377836.,  984286.,                                                      33, 2906308,   186190,
     69., 14498236.,  889785.,                                                      24, 2651113,   144296,
     84., 19678015.,  1278485.,                                                     1,  5807462,   383168,
     76., 19644538.,  1156395.,                                                     59, 9304718,   643080,
     1.,  20128657., 1117135.)                                                      83, 15377836,  984286,
    ,nrow =11, ncol = 3,byrow=TRUE)                                                 69, 14498236,  889785,
result <- data.frame()                                                              84, 19678015,  1278485,
num_rows <- nrow(num)                                                               76, 19644538,  1156395,
num_rows                                                                            1,   20128657, 1117135)
result                                                                         ---*/
num_rows                                                                       do row=1 to dim(num,1) ;
row=0;
  for (rec in 1:num_rows) {                                                      select ;
    row=row+1
    #catrow ",row,"\n");                                                            * NEXT TO THE LAST ROW AND
                                                                                      DELAY=1 or DELAY=1 in LAST ROW ;

    if (row == num_rows - 1 &&      (row = dim(num,1)-1)                            when  (
         (num[row, 1] == 1 || num[row + 1, 1] == 1)) {                                and ((num[row,1]=1) or (num[row+1,1]=1))
      delay <- num[row, 1] + num[row + 1, 1]                                              ) do;
      invoice <- num[row, 2] + num[row + 1, 2]                                        delay    = num[row,1] + num[row+1,1] ;
      payment <- num[row, 3] + num[row + 1, 3]                                        invoice  = num[row,2] + num[row+1,2] ;
      lower <- range[row]                                                             payment  = num[row,3] + num[row+1,3] ;
      upper <- lower + 50                                                             lower    = range[row] ;
      result <- rbind(result,                                                         upper    = lower +50 ;
       data.frame(delay,invoice,payment,lower,upper))                                 output;
      #cat("1st","\n")                                                                stop;
      break                                                                         end;


    } else if ((row == num_rows-1)&&                                                when (
        ((num[row,1] != 1) && (num[row+1,1]!=1))){                                       (row = dim(num,1)-1) and (
      delay   <- num[row,1]                                                           num[row,1] ne 1) and (num[row+1,1] ne 1)
      invoice <- num[row,2]                                                              ) do;
      payment <- num[row,3]                                                           delay   = num[row,1] ;
      lower <- range[row]                                                             invoice = num[row,2] ;
      upper <- lower +25                                                              payment = num[row,3] ;
      result <- rbind(result,                                                         lower = range[row];
       data.frame(delay,invoice,payment,lower,upper))                                 upper = lower +25;
      delay   <- num[row+1,1]                                                         output;
      invoice <- num[row+1,2]                                                         delay   = num[row+1,1] ;
      payment <- num[row+1,3]                                                         invoice = num[row+1,2] ;
      lower <- range[row+1];                                                          payment = num[row+1,3] ;
      upper <- lower +25                                                              lower = range[row+1];
      result <- rbind(result,                                                         upper = lower +25;
       data.frame(delay,invoice,payment,lower,upper))                                 output;
      #cat("2nd","\n")                                                                stop;
      break                                                                         end;


    } else if (num[row,1]==1) {                                                     when (num[row,1]=1) do;
      delay   <- num[row,1] + num[row+1,1]                                            delay   = num[row,1] + num[row+1,1] ;
      invoice <- num[row,2] + num[row+1,2]                                            invoice = num[row,2] + num[row+1,2] ;
      payment <- num[row,3] + num[row+1,3]                                            payment = num[row,3] + num[row+1,3] ;
      lower <- range[row]                                                             lower = range[row];
      upper <- lower +50                                                              upper = lower +50;
      result <- rbind(result,                                                         row=row+1;
       data.frame(delay,invoice,payment,lower,upper))                                 output;
      cat("3rda",row,"\n")                                                          end;
      row<-row+1;
      cat("3rdb",row,"\n")

    } else {                                                                        otherwise do;
      delay <- num[row, 1]                                                            delay   = num[row,1];
      invoice <- num[row, 2]                                                          invoice = num[row,2];
      payment <- num[row, 3]                                                          payment = num[row,3];
      lower <- range[row]                                                             lower = range[row];
      upper <- lower + 25                                                             upper = lower +25;
      result <- rbind(result,                                                         output;
       data.frame(delay,invoice,payment,lower,upper))                               end;
      #cat("4th","\n")
    }                                                                            end;
   }
result                                                                       end;
;;;;                                                                         keep delay invoice payment lower upper;
%utl_rendx(resolve=N);                                                       run;quit;



















*works;
%utl_rbeginx;
parmcards4;
library(haven)
source("c:/oto/fn_tosas9x.R")
  range<-c(25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.)
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
     1.,  20128657., 1117135.)
    ,nrow =11, ncol = 3,byrow=TRUE)
result <- data.frame()
num_rows <- nrow(num)
num_rows
result
num_rows
flg=0
  for (row in 1:num_rows) {
    row<-ifelse(flg==1,row+1,row)
    cat(flg," row ",row,"\n");
    if (row == num_rows - 1 && (num[row, 1] == 1 || num[row + 1, 1] == 1)) {
      delay <- num[row, 1] + num[row + 1, 1]
      invoice <- num[row, 2] + num[row + 1, 2]
      payment <- num[row, 3] + num[row + 1, 3]
      lower <- range[row]
      upper <- lower + 50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      #cat("1st","\n")
      break
    } else if ((row == num_rows-1) &&
        ((num[row,1] != 1) && (num[row+1,1] != 1))) {
      delay   = num[row,1]
      invoice = num[row,2]
      payment = num[row,3]
      lower = range[row]
      upper = lower +25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      delay   = num[row+1,1]
      invoice = num[row+1,2]
      payment = num[row+1,3]
      lower = range[row+1];
      upper = lower +25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      #cat("2nd","\n")
      break
    } else if (num[row,1]==1) {
      delay   = num[row,1] + num[row+1,1]
      invoice = num[row,2] + num[row+1,2]
      payment = num[row,3] + num[row+1,3]
      lower = range[row]
      upper = lower +50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      #cat("3rda",row,"\n")
      row=row+2
      flg=1;
      #cat("3rdb",row,"\n")
    } else {
      delay <- num[row, 1]
      invoice <- num[row, 2]
      payment <- num[row, 3]
      lower <- range[row]
      upper <- lower + 25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      #cat("4th","\n")
    }
   }
result
;;;;
%utl_rendx(resolve=N);



    } else
      If (row == numrows-1) &&
      ((num[row,1] != 1) && (num[row+1,1] != 1)) {
      delay   = num[row,1]
      invoice = num[row,2]
      payment = num[row,3]
      lower = range[row]
      upper = lower +25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      delay   = num[row+1,1]
      invoice = num[row+1,2]
      payment = num[row+1,3]
      lower = range[row+1];
      upper = lower +25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break




      If (row == numrows-1) &&
      ((num[row,1] != 1) && (num[row+1,1] != 1)) {

%utl_rbeginx;
parmcards4;
  for (i in 1:3) {
    if (i==2) {
        cat("inside ",i)
        next
        }
        cat("outside ",i)
   }
;;;;
%utl_rendx;
  num <- matrix (
   c(76., 19644538., 1156395.,
     0.,  20128657., 1117135.)
    ,nrow =2, ncol = 3,byrow=TRUE)
  num_rows <- nrow(num)
  row=1;
    if ((row = num_rows-1) &&
      ((num[row,1] != 1) && (num[row+1,1] != 1))) {
     cat("I AM HERE")
     }
  res;
;;;;
%utl_rendx;














*works;
%utl_rbeginx;
parmcards4;
library(haven)
source("c:/oto/fn_tosas9x.R")
  range<-c(25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.)
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
     1.,  20128657., 1117135.)
    ,nrow =11, ncol = 3,byrow=TRUE) # note;\
result <- data.frame()
num_rows <- nrow(num)
num_rows
result
num_rows
  for (row in 1:num_rows) {
    if (row == num_rows - 1 && (num[row, 1] == 1 || num[row + 1, 1] == 1)) {
      cat(" 1st am here ",row,num[row, 1])
      delay <- num[row, 1] + num[row + 1, 1]
      invoice <- num[row, 2] + num[row + 1, 2]
      payment <- num[row, 3] + num[row + 1, 3]
      lower <- range[row]
      upper <- lower + 50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
      }}
result
;;;;
%utl_rendx;


*works;
%utl_rbeginx;
parmcards4;
library(haven)
source("c:/oto/fn_tosas9x.R")
  range<-c(25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.)
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
     1.,  20128657., 1117135.)
    ,nrow =11, ncol = 3,byrow=TRUE) # note;\
result <- data.frame()
num_rows <- nrow(num)
num_rows
result
num_rows
  for (row in 1:num_rows) {
    if (row == num_rows - 1 && (num[row, 1] == 1 || num[row + 1, 1] == 1)) {
      cat(" 1st am here ",row,num[row, 1])
      delay <- num[row, 1] + num[row + 1, 1]
      invoice <- num[row, 2] + num[row + 1, 2]
      payment <- num[row, 3] + num[row + 1, 3]
      lower <- range[row]
      upper <- lower + 50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
    } else if (num[row,1]==1) {
      delay   = num[row,1] + num[row+1,1]
      invoice = num[row,2] + num[row+1,2]
      payment = num[row,3] + num[row+1,3]
      lower = range[row]
      upper = lower +50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
    } else {
      delay <- num[row, 1]
      invoice <- num[row, 2]
      payment <- num[row, 3]
      lower <- range[row]
      upper <- lower + 25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
    }
   }
result
;;;;
%utl_rendx;


*best;
%utl_rbeginx;
parmcards4;
library(haven)
source("c:/oto/fn_tosas9x.R")
  range<-c(25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.)
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
     1.,  20128657., 1117135.)
    ,nrow =11, ncol = 3,byrow=TRUE) # note;\
result <- data.frame()
num_rows <- nrow(num)
num_rows
result
num_rows
  for (row in 1:num_rows) {

    if (row == num_rows - 1 && (num[row, 1] == 1 || num[row + 1, 1] == 1)) {
      delay <- num[row, 1] + num[row + 1, 1]
      invoice <- num[row, 2] + num[row + 1, 2]
      payment <- num[row, 3] + num[row + 1, 3]
      lower <- range[row]
      upper <- lower + 50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
      }
    else {
      If (row = numrows-1) && (
      num[row,1] != 1) && (num[row+1,1] != 1) {
      delay   = num[row,1]
      invoice = num[row,2]
      payment = num[row,3]
      lower = range[row]
      upper = lower +25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      delay   = num[row+1,1]
      invoice = num[row+1,2]
      payment = num[row+1,3]
      lower = range[row+1];
      upper = lower +25;
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
      }
    }
    else { if (num[row,1]=1) {
      delay   = num[row,1] + num[row+1,1]
      invoice = num[row,2] + num[row+1,2]
      payment = num[row,3] + num[row+1,3]
      lower = range[row]
      upper = lower +50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      }
    }
    else {
      delay <- num[row, 1]
      invoice <- num[row, 2]
      payment <- num[row, 3]
      lower <- range[row]
      upper <- lower + 25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      }
  }
result
;;;;
%utl_rendx;

















libname etcx "c:/etcx";


# Assuming 'have' is your input data frame


proc datasets lib=sd1 nolist nodetails;
 delete want;
run;quit;

%put %utl_numary(have,drop=upper lower,reshape=%str([3,11]));

%utl_rbeginx;
parmcards4;
library(haven)
source("c:/oto/fn_tosas9x.R")
  range<-c(25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.)
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
     1.,  20128657., 1117135.)
    ,nrow =11, ncol = 3,byrow=TRUE)
result <- data.frame()
num_rows <- nrow(num)
num_rows
result
num_rows
  for (row in 1:num_rows) {
    cat(" Ist am here ")
    if (row == (num_rows - 1L )) {
      cat(" 2nd am here ",row,num[row, 1L])
      if (num[row+1L, 1L] == 1.0)  {
      cat(" 3rd am here ")
      delay <- num[row, 1] + num[row + 1L, 1]
      invoice <- num[row, 2] + num[row + 1L, 2]
      payment <- num[row, 3] + num[row + 1L, 3]
      lower <- range[row]
      upper <- lower + 50L
      cat(lower,upper)
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
      }}}
result
;;;;
%utl_rendx;

;;;;
%utl_rendx;

   c(1,116294,7412,12,711046,43812,33,2906308,186190,24,
   2651113,144296,1,5807462,383168,59,9304718,643080,
   83,15377836,984286,69,14498236,889785,84,19678015,
   1278485,76,19644538,1156395,1,20128657,1117135),












%utl_rbeginx;
parmcards4;
library(haven)
source("c:/oto/fn_tosas9x.R")
  range<-c(25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.)
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
     1.,  20128657., 1117135.)
    ,nrow =11, ncol = 3,byrow=TRUE) # note;\
result <- data.frame()
num_rows <- nrow(num)
num_rows
result
num_rows
  for (row in 1:num_rows) {
    if (row == num_rows - 1 && (num[row, 1] == 1 || num[row + 1, 1] == 1)) {
      cat(" 1st am here ",row,num[row, 1])
      delay <- num[row, 1] + num[row + 1, 1]
      invoice <- num[row, 2] + num[row + 1, 2]
      payment <- num[row, 3] + num[row + 1, 3]
      lower <- range[row]
      upper <- lower + 50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
      }}
result
;;;;
%utl_rendx;



*best;
%utl_rbeginx;
parmcards4;
library(haven)
source("c:/oto/fn_tosas9x.R")
  range<-c(25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.)
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
     1.,  20128657., 1117135.)
    ,nrow =11, ncol = 3,byrow=TRUE) # note;\
result <- data.frame()
num_rows <- nrow(num)
num_rows
result
num_rows
  for (row in 1:num_rows) {

    if (row == num_rows - 1 && (num[row, 1] == 1 || num[row + 1, 1] == 1)) {
      delay <- num[row, 1] + num[row + 1, 1]
      invoice <- num[row, 2] + num[row + 1, 2]
      payment <- num[row, 3] + num[row + 1, 3]
      lower <- range[row]
      upper <- lower + 50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
      }
    else {
      If (row = numrows-1) && (
      num[row,1] != 1) && (num[row+1,1] != 1) {
      delay   = num[row,1]
      invoice = num[row,2]
      payment = num[row,3]
      lower = range[row]
      upper = lower +25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      delay   = num[row+1,1]
      invoice = num[row+1,2]
      payment = num[row+1,3]
      lower = range[row+1];
      upper = lower +25;
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
      }
    }
    else { if (num[row,1]=1) {
      delay   = num[row,1] + num[row+1,1]
      invoice = num[row,2] + num[row+1,2]
      payment = num[row,3] + num[row+1,3]
      lower = range[row]
      upper = lower +50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      }
    }
    else {
      delay <- num[row, 1]
      invoice <- num[row, 2]
      payment <- num[row, 3]
      lower <- range[row]
      upper <- lower + 25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      }
  }
result
;;;;
%utl_rendx;


*best;
%utl_rbeginx;
parmcards4;
library(haven)
source("c:/oto/fn_tosas9x.R")
  range<-c(25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.)
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
     1.,  20128657., 1117135.)
    ,nrow =11, ncol = 3,byrow=TRUE) # note;\
result <- data.frame()
num_rows <- nrow(num)
num_rows
result
num_rows
  for (row in 1:num_rows) {

    if (row == num_rows - 1L && (num[row, 1] == 1. || num[row + 1, 1] == 1.)) {
      delay <- num[row, 1] + num[row + 1, 1]
      invoice <- num[row, 2] + num[row + 1, 2]
      payment <- num[row, 3] + num[row + 1, 3]
      lower <- range[row]
      upper <- lower + 50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
      }
    else { if (num[row,1]==1.) {
      delay   = num[row,1] + num[row+1,1]
      invoice = num[row,2] + num[row+1,2]
      payment = num[row,3] + num[row+1,3]
      lower   = range[row]
      upper   = lower +50
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      }
    }
    else {
      delay   <- num[row, 1]
      invoice <- num[row, 2]
      payment <- num[row, 3]
      lower   <- range[row]
      upper   <- lower + 25
      result  <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      }
  }
result
;;;;
%utl_rendx(resolve=N);

    else {
      If ( (row = numrows-1) && (
      num[row,1] != 1) && (num[row+1,1] != 1) ) {
      delay   = num[row,1]
      invoice = num[row,2]
      payment = num[row,3]
      lower = range[row]
      upper = lower +25
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      delay   = num[row+1,1]
      invoice = num[row+1,2]
      payment = num[row+1,3]
      lower = range[row+1];
      upper = lower +25;
      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
      }
    }

%macro utl_rendx(return=,resolve=Y)/des="utl_rbeginx uses parmcards and must end with utl_rendx macro";
run;quit;
* EXECUTE R PROGRAM;
data _null_;
  infile "c:/temp/r_pgm";
  input;
  file "c:/temp/r_pgmx";
  %if "&resolve"="Y" %then %do;_infile_=resolve(_infile_);%end;
  put _infile_;
run;quit;
options noxwait noxsync;
filename rut pipe "D:\r414\bin\r.exe --vanilla --quiet --no-save < c:/temp/r_pgmx";
run;quit;
data _null_;
  file print;
  infile rut;
  input;
  put _infile_;
  putlog _infile_;
run;quit;
data _null_;
  infile " c:/temp/r_pgm";
  input;
  putlog _infile_;
run;quit;
%if "&return" ne ""  %then %do;
  filename clp clipbrd ;
  data _null_;
   infile clp obs=1;
   input;
   putlog "xxxxxx  " _infile_;
   call symputx("&return.",_infile_,"G");
  run;quit;
  %end;
filename ft15f001 clear;
%mend utl_rendx;





;;;;%end;%mend;/*'*/ *);*};*];*/;/*"*/;run;quit;%end;end;run;endcomp;%utlfix;


























































else (
     (row = numrows-1) and (
  num[row,1]  1) and (num[row+1,1] ne 1)
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

* DEAY=1 NOT IN LAST TWO ROWS
  OUTPUT ONE ROW WITH SUMS;

when (num[row,1]=1) do;
  delay   = num[row,1] + num[row+1,1] ;
  invoice = num[row,2] + num[row+1,2] ;
  payment = num[row,3] + num[row+1,3] ;
  lower = range[row];
  upper = lower +50;
  row+1;
  output;
end;









     ;;;;%end;%mend;/*'*/ *);*};*];*/;/*"*/;run;quit;%end;end;run;endcomp;%utlfix;











proc print data=sd1.want;
run;quit;


 || num[row + 1, 1] == 1
fn_tosas9x(
      inp    = have
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )

     && (num[row, 1] == 1 || num[row + 1, 1] == 1)

%put %utl_numary(have,drop=upper lower,reshape=%str([3,11]));
(1,116294,7412,12,711046,43812,33,2906308,186190,24,
2651113,144296,1,5807462,383168,59,9304718,643080,
83,15377836,984286,69,14498236,889785,84,19678015,
1278485,76,19644538,1156395,1,20128657,1117135)












library(dplyr)

  range <- c(25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275)
  num   <- matrix(c(
    (1,116294,7412,12,711046,43812,33,2906308,186190,24,
    2651113,144296,1,5807462,383168,59,9304718,643080,
    83,15377836,984286,69,14498236,889785,84,19678015,
    1278485,76,19644538,1156395,1,20128657,1117135)

















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
     1,   20128657, 1117135))
     nrow =11, ncol = 3)

  result <- data.frame()
  num_rows <- nrow(have)

  for (row in 1:num_rows) {
    if (row == num_rows - 1 && (have[row, 1] == 1 || have[row + 1, 1] == 1)) {
      delay <- have[row, 1] + have[row + 1, 1]
      invoice <- have[row, 2] + have[row + 1, 2]
      payment <- have[row, 3] + have[row + 1, 3]
      lower <- range[row]
      upper <- lower + 50

      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
    } else {
      delay <- have[row, 1]
      invoice <- have[row, 2]
      payment <- have[row, 3]
      lower <- range[row]
      upper <- lower + 25

      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
    }
  }

  return(result)
}

# Assuming 'have' is your input data frame
want <- want(have)




















data want ;

  array range[11]
    (25,50,75,100,125,150,175,200,225,250,275);
  array num %utl_numary(have,drop=upper lower);
  do row=1 to dim(num,1) ;

    select ;

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

       otherwise do;                                -------------------------------------
         delay   = num[row,1];                          125   175    60  15112180 1026248
         invoice = num[row,2];
         payment = num[row,3];                       7  175   200    83  15377836  984286
         lower = range[row];                         8  200   225    69  14498236  889785
         upper = lower +25;                          9  225   250    84  19678015 1278485
         output;
       end;
                                                    RELPACE PAIR WITH SUM BECAUSE DELAY=1
    end;                                            -------------------------------------
                                                    10  250   275    76  19644538 1156395
  end;                                              11  275   300     1  20128657 1117135
  keep delay invoice payment lower upper;

 run;quit;                                          DO NOTHING NEXT TO LAST AND LAST
                                                    WHEN DELAY=1 IS NOT PRESENT

 250   275    76  19644538 1156395
 275   300     0  20128657 1117135

REPLACE WITH SUM IF DELAY+1
IN EITHER OF THE LAT TWO ROWS



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
       1,   20128657, 1117135)
  ---*/
  do row=1 to dim(num,1) ;

    select ;

       * NEXT TO THE LAST ROW AND
         DELAY=1 or DELAY=1 in LAST ROW ;
       when  (
                  (row = dim(num,1)-1)
              and ( (num[row,1]=1) or (num[row+1,1]=1) )
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
                  (row = dim(num,1)-1)
             and  (num[row,1] ne 1) and (num[row+1,1] ne 1)
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
         row+1;
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

 INPUT HAS DELAY=1 IN LAST OB

 LOWER UPPER DELAY  INVOICE PAYMENT

   25    75    13    827340   51224
   75   100    33   2906308  186190
  100   125    24   2651113  144296
  125   175    60  15112180 1026248
  175   200    83  15377836  984286
  200   225    69  14498236  889785
  225   250    84  19678015 1278485
  250   300    77  39773195 2273530

  INPUT HAS DELAY=0 IN LAST OB

  LOWER UPPER DELAY  INVOICE PAYMENT

    25    75    13    827340   51224
    75   100    33   2906308  186190
   100   125    24   2651113  144296
   125   175    60  15112180 1026248
   175   200    83  15377836  984286
   200   225    69  14498236  889785
   225   250    84  19678015 1278485

   250   275    76  19644538  1156395
   275   300     0  20128657  1117135



CHANGE DEL=1 to DELAY=99 IN LAST ROW AND RERUN

 DELAY     INVOICE    PAYMENT    LOWER    UPPER

   13       827340      51224      25       75
   33      2906308     186190      75      100
   24      2651113     144296     100      125
   60     15112180    1026248     125      175
   83     15377836     984286     175      200
   69     14498236     889785     200      225
   84     19678015    1278485     225      250

   NO REPLACED WIT THE SUM;
   76     19644538    1156395     250      275
    0     20128657    1117135     275      300








       when  ( (row = dim(num,1)-1) and (num[row,1] ne 1) ) do;
         delay    = num[row+1,1] ;
         invoice  = num[row+1,2] ;
         payment  = num[row+1,3] ;
         lower    = range[row] ;
         upper    = lower +50 ;
         output;
         stop;
       end;

 DELAY     INVOICE    PAYMENT    LOWER    UPPER

   13       827340      51224      25       75
   33      2906308     186190      75      100
   24      2651113     144296     100      125
   60     15112180    1026248     125      175
   83     15377836     984286     175      200
   69     14498236     889785     200      225
   84     19678015    1278485     225      250
   76     39773195    2273530     250      300


       when  (row = dim(num,1)-1 and num[row,1] ne 1)) do;
         delay    = num[row,1];
         invoice  = num[row,2];
         payment  = num[row,3];
         lower    = range[row] ;
         upper    = lower +25 ;
         output;
         stop;
       end;



filename ft15f001 "%sysfunc(pathname(work))/temp.txt";
parmcards4;
1 1 25
2 8 50
3 0 75
4 0 100
1 8 125
6 1 150
7 0 175
8 0 200
9 0 225
0 1 250
1 8 275
;;;;
run;quit;

data have ;
   retain precnt precost prelower pre 0;
   infile "%sysfunc(pathname(work))/temp.txt" eof=fix;
   input cnt1 cost1 lower1;
   if cnt1=1 then do;;
      input cnt2 cost2 lower2;
      cnt=cnt1+cnt2;
      cost=cost1+cost2;
      lower=lower1;
      upper=lower+50;
      output;
      goto skip;
   end;
   else do;
     cnt=cnt1;
     cost=cost1;
     lower=lower1;
     upper=lower+25;
     output;
  end;
  precnt=cnt;
  precost=cost;
  prelower=lower;

  keep cnt cost lower upper;
;;;;
run;quit;

      fix:
        put _n_ "1 am here";
        input cnt1 cost1 lower1;
        cnt=precnt +cnt1;
        cost=precost + cost1;
        lower=prelower;
        upper=lower+50;
        output;
        stop;
        skip:
         put "skipped over fix";












# Assuming 'have' is your input data frame
library(dplyr)

want <- function(have) {
  range <- c(25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275)
  have <- matrix(c(1, 2, 3, 4, 5, 6),


nrow =11, ncol = 3)

  result <- data.frame()
  num_rows <- nrow(have)

  for (row in 1:num_rows) {
    if (row == num_rows - 1 && (have[row, 1] == 1 || have[row + 1, 1] == 1)) {
      delay <- have[row, 1] + have[row + 1, 1]
      invoice <- have[row, 2] + have[row + 1, 2]
      payment <- have[row, 3] + have[row + 1, 3]
      lower <- range[row]
      upper <- lower + 50

      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
      break
    } else {
      delay <- have[row, 1]
      invoice <- have[row, 2]
      payment <- have[row, 3]
      lower <- range[row]
      upper <- lower + 25

      result <- rbind(result, data.frame(delay, invoice, payment, lower, upper))
    }
  }

  return(result)
}

# Assuming 'have' is your input data frame
want <- want(have)












































data x ;
 infile cards4 n=10 flowover eof=fix;
 input #2 num1;
 input #1 num2;
 return;
 fix:
   if _infile_="" then put "Iam here";
   stop;
cards4;
1
2
3
4
5
;;;;
run;quit;



             run;quit;   ;;;;%end;%mend;/*'*/ *);*};*];*/;/*"*/;run;quit;%end;end;run;endcomp;%utlfix;

MISSOVER: This option sets all empty variables to missing when reading a short line. It prevents SAS from moving to the next line to look for additional values13.

TRUNCOVER: Similar to MISSOVER, but it also reads partial values to fill the first unfilled variable. This is often considered superior to MISSOVER as it can capture more information14.

FLOWOVER: This is the default option in SAS. When the INPUT statement reaches the end of non-blank characters without filling all variables, it moves to the next line to continue reading4.

STOPOVER: This option causes the DATA step to stop processing if an INPUT statement reaches the end of the current record without finding values for all variables9.

SCANOVER: This option positions the pointer to a search condition in the file and then continues reading as normal9.














         otherwise do ;
           * if next to last row and last observation has delay=1;
           if (row=(dim(num,1)-1) and num[dim(num,1),1]=1) then do;
              flg=1;
           end;

           else do;
              flg=0;
              delay   = num[row,1];
              invoice = num[row,2];
              payment = num[row,3];
              lower = range[row];
              upper = lower + 25;
           end;
           if flg ne 1 then output;

         end;
      end;
  end;
  keep delay invoice payment lower upper;
run;quit;




 ORIGINALBALANCE      CURRBALANCE    CONTRIBIOBALANCE    LOANCOUNT

(25,000-75,000]       827,340.00        51,224.00          13       13       827340      51224      25       75
(75,000-100,000]      2906308.00       186,190.00          33       33      2906308     186190      75      100
(100,000-125,000]     2651113.00       144,296.00          24       24      2651113     144296     100      125
(125,000-175,000]    15112180.00       1026248.00          60       60     15112180    1026248     125      175
(175,000-200,000]    15377836.00       984,286.00          83       83     15377836     984286     175      200
(200,000-225,000]    14498236.00       889,785.00          69       69     14498236     889785     200      225
(225,000-250,000]    19678015.00       1278485.00          84       84     19678015    1278485     225      250
(250,000-300,000]    39773195.00       2273530.00          77       77     39773195    2273530     250      300


























data want;

  retain flg 0;

  array range[&_csn] (%do_over(_cs,phrase=?,between=comma));
  array num %utl_numary(have,drop=upper lower);

  do row=1 to dim(num,1) ;

      select;

         when (row=dim(num,1) and num[dim(num,1),1]=1) do;
           delay   = num[row-1,1] + num[row,1] ;
           invoice = num[row-1,2] + num[row,2] ;
           payment = num[row-1,3] + num[row,3] ;
           lower   = range[row-1];
           upper   = lower +50;
           flg=0;
           output;
         end;

         when (num[row,1]=1) do;
           delay   = num[row,1] + num[row+1,1] ;
           invoice = num[row,2] + num[row+1,2] ;
           payment = num[row,3] + num[row+1,3] ;
           lower = range[row];
           upper = lower +50;
           row+1;
           output;
         end;

         otherwise do ;
           * if next to last row and last observation has delay=1;
           if not (row=(dim(num,1)-1) and num[dim(num,1),1]=1) then do;
              output;
              flg=1;
           end;

           else do;
              flg=0;
              delay   = num[row,1];
              invoice = num[row,2];
              payment = num[row,3];
              lower = range[row];
              upper = lower + 25;
           end;


         end;
      end;
  end;
  keep delay invoice payment lower upper;
run;quit;

































data want;

  retain flg 0;

  array range[&_csn] (%do_over(_cs,phrase=?,between=comma));
  array num %utl_numary(have,drop=upper lower);

  do row=1 to dim(num,1) ;

      select;

         when (row=dim(num,1) and num[dim(num,1),1]=1) do;
           delay   = num[row-1,1] + num[row,1] ;
           invoice = num[row-1,2] + num[row,2] ;
           payment = num[row-1,3] + num[row,3] ;
           lower   = range[row-1];
           upper   = lower +50;
           flg=0;
           output;
         end;

         when (num[row,1]=1) do;
           delay   = num[row,1] + num[row+1,1] ;
           invoice = num[row,2] + num[row+1,2] ;
           payment = num[row,3] + num[row+1,3] ;
           lower = range[row];
           upper = lower +50;
           row+1;
           output;
         end;

         otherwise do ;
           * if next to last row and last observation has delay=1;
           if not (row=(dim(num,1)-1) and num[dim(num,1),1]=1) then do;
              output;
           end;
           else do;
              delay   = num[row,1];
              invoice = num[row,2];
              payment = num[row,3];
              lower = range[row];
              upper = lower + 25;
           end;
         end;
      end;
  end;

  keep delay invoice payment lower upper;
run;quit;


data want;

  retain flg 0;

  array range[&_csn] (%do_over(_cs,phrase=?,between=comma));
  array num %utl_numary(have,drop=upper lower);

  do row=1 to dim(num,1) ;

      select;

         when (row=dim(num,1) and num[dim(num,1),1]=1) do;
           cnt  = num[row-1,1] + num[row,1] ;
           cost = num[row-1,2] + num[row,2] ;
           lrange = range[row-1];
           hrange = lrange +50;
           flg=0;
           output;
         end;

         when (num[row,1]=1) do;
           cnt = num[row,1] + num[row+1,1] ;
           cost= num[row,2] + num[row+1,2] ;
           lrange = range[row];
           hrange = lrange +50;
           row+1;
           output;
         end;

         otherwise do ;
           * if next to last observation and last observation cnt=1 - already taken care pf in first when clause;;
           if (row=(dim(num,1)-1) and num[dim(num,1),1]=1) then do;
              flg=1;
           end;
           else do;
              flg=0;
              cnt = num[row,1];
              cost= num[row,2];
              lrange = range[row];
              hrange = lrange + 25;
           end;
           if flg ne 1 then output;
         end;
      end;
  end;
  keep lrange hrange cnt cost flg;
run;quit;


 CNT    COST    LRANGE    HRANGE

  3       9        25        75
  3       0        75       100
  4       0       100       125
  7       9       125       175
  7       0       175       200
  8       0       200       225
  9       0       225       250
  1       9       250       300


data have;
infile cards dlm="|";
input OriginalBalance :32. LoanCount CurrBalance :comma12. ContribIOBalance :comma12.;

OB2 = scan(OriginalBalance,2,'[( -)]');
format CurrBalance ContribIOBalance dollar12.2;
cards;
(25,000 - 50,000]|1|116,294|7,412|0.0|4.47|317
(50,000 - 75,000]|12|711,046|43,812|0.2|4.52|337
(75,000 - 100,000]|33|2,906,308|186,190|0.8|4.49|331
(100,000 - 125,000]|24|2,651,113|144,296|0.6|4.48|332
(125,000 - 150,000]|1|5,807,462|383,168|1.7|4.51|331
(150,000 - 175,000]|59|9,304,718|643,080|2.9|4.52|329
(175,000 - 200,000]|83|15,377,836|984,286|4.4|4.50|342
(200,000 - 225,000]|69|14,498,236|889,785|4.0|4.50|340
(225,000 - 250,000]|84|19,678,015|1,278,485|5.7|4.50|340
(250,000 - 275,000]|76|19,644,538|1,156,395|5.2|4.50|339
(275,000 - 300,000]|0|20,128,657|1,117,135|5.0|4.50|343
;
run;
proc print;
run;











data have2;
do n=1 by 1 until(LoanCount>1 or _E_);
  set have end=_E_;
  grp++(1=n);
  grp+-(_E_=LoanCount);
  output;
end;
run;
proc print;
run;

data want;

  length OriginalBalance2 $ 32;
  call missing(OriginalBalance2, n, cumB, cumIOB, cumLC);
  do until(last.grp);
    set have2 end=_E_;
    by grp;
    if first.grp then OB1 = scan(OriginalBalance,1,'[( -)]');;
    cumB+CurrBalance;
    cumIOB+ContribIOBalance;
    cumLC+LoanCount;
  end;

  OB2 = scan(OriginalBalance,2,'[( -)]');
  OriginalBalance2 = cats("(",OB1,"-",OB2,"]");

  drop CurrBalance ContribIOBalance LoanCount OriginalBalance OB1 OB2 n grp;
  rename
    cumB=CurrBalance
    cumIOB=ContribIOBalance
    cumLC=LoanCount
    OriginalBalance2=OriginalBalance
  ;
  format cumB cumIOB dollar12.2;
run;
proc print;
run;






























































data want;
  retain flg 0;
  array range[&_csn] (%do_over(_cs,phrase=?,between=comma));
  array num %utl_numary(have,drop=range);

  do row=1 to dim(num,1) ;

      select;

         when (row=dim(num,1) and num[dim(num,1),1]=1) do;
           cnt  = num[row-1,1] + num[row,1] ;
           cost = num[row-1,2] + num[row,2] ;
           lrange = range[row-1];
           hrange = lrange +50;
           flg=0;
           output;
         end;

         when (num[row,1]=1) do;
           cnt = num[row,1] + num[row+1,1] ;
           cost= num[row,2] + num[row+1,2] ;
           lrange = range[row];
           hrange = lrange +50;
           row+1;
           output;
         end;

         otherwise do ;
           if (row=(dim(num,1)-1) and num[dim(num,1),1]=1) then do;
              flg=1;
           end;
           else do;
              flg=0;
              cnt = num[row,1];
              cost= num[row,2];
           lrange = range[row];
           hrange = lrange + 25;
           end;
           if flg ne 1 then output;
         end;
      end;
  end;
  keep lrange hrange cnt cost flg;
run;quit;

