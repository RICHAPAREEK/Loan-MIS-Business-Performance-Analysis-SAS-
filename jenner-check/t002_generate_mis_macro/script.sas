/* Source data (real loan-MIS rows) read inline so the bundle is self-contained.
   In the repo this came from PROC IMPORT of loan_mis_project_dataset.csv. */
data loan_data;
    length loan_status $9 branch $9 state $11 product_type $13 channel $6;
    infile datalines dsd truncover;
    input loan_id customer_id
          application_date  : yymmdd10.
          approval_date     : yymmdd10.
          disbursement_date : yymmdd10.
          loan_amount
          loan_status $ branch $ state $ product_type $ channel $;
    format application_date approval_date disbursement_date yymmdd10.;
datalines;
1,1102,2024-01-01,2024-01-05,2024-01-09,253687,Approved,Chennai,Tamil Nadu,Home Loan,DSA
2,1435,2024-01-02,2024-01-04,2024-01-08,123523,Disbursed,Mumbai,Maharashtra,Personal Loan,Online
3,1860,2024-01-03,2024-01-04,2024-01-06,286175,Pending,Delhi,Maharashtra,Personal Loan,Direct
4,1270,2024-01-04,2024-01-07,2024-01-10,144476,Approved,Mumbai,Delhi,Personal Loan,Direct
5,1106,2024-01-05,2024-01-08,2024-01-12,283841,Pending,Delhi,Tamil Nadu,Home Loan,Online
6,1071,2024-01-06,2024-01-07,2024-01-09,329163,Disbursed,Chennai,Maharashtra,Auto Loan,Direct
7,1700,2024-01-07,2024-01-10,2024-01-11,395757,Approved,Bangalore,Tamil Nadu,Home Loan,Direct
8,1020,2024-01-08,2024-01-11,2024-01-14,272866,Pending,Mumbai,Maharashtra,Personal Loan,DSA
9,1614,2024-01-09,2024-01-10,2024-01-11,136672,Approved,Bangalore,Karnataka,Auto Loan,Online
10,1121,2024-01-10,2024-01-14,2024-01-15,123847,Disbursed,Mumbai,Maharashtra,Auto Loan,Online
11,1466,2024-01-11,2024-01-12,2024-01-14,394894,Pending,Delhi,Tamil Nadu,Home Loan,Online
12,1214,2024-01-12,2024-01-16,2024-01-20,260706,Approved,Bangalore,Karnataka,Personal Loan,Online
13,1330,2024-01-13,2024-01-16,2024-01-18,78251,Disbursed,Mumbai,Karnataka,Home Loan,DSA
14,1458,2024-01-14,2024-01-17,2024-01-19,153481,Approved,Delhi,Karnataka,Auto Loan,DSA
15,1087,2024-01-15,2024-01-18,2024-01-20,424710,Approved,Bangalore,Tamil Nadu,Home Loan,Direct
16,1372,2024-01-16,2024-01-18,2024-01-20,75945,Rejected,Bangalore,Delhi,Home Loan,Direct
17,1099,2024-01-17,2024-01-21,2024-01-24,402996,Rejected,Mumbai,Delhi,Personal Loan,Direct
18,1871,2024-01-18,2024-01-20,2024-01-24,82217,Disbursed,Mumbai,Delhi,Personal Loan,Direct
19,1663,2024-01-19,2024-01-21,2024-01-22,58308,Rejected,Mumbai,Tamil Nadu,Auto Loan,DSA
20,1130,2024-01-20,2024-01-21,2024-01-22,318093,Disbursed,Delhi,Karnataka,Home Loan,Online
21,1661,2024-01-21,2024-01-23,2024-01-27,233062,Rejected,Mumbai,Delhi,Home Loan,DSA
22,1308,2024-01-22,2024-01-23,2024-01-24,444366,Approved,Bangalore,Tamil Nadu,Home Loan,Direct
23,1769,2024-01-23,2024-01-24,2024-01-28,270552,Disbursed,Bangalore,Delhi,Auto Loan,DSA
24,1343,2024-01-24,2024-01-26,2024-01-27,150235,Disbursed,Mumbai,Maharashtra,Auto Loan,Online
25,1491,2024-01-25,2024-01-29,2024-01-31,124740,Approved,Mumbai,Delhi,Personal Loan,Online
26,1413,2024-01-26,2024-01-30,2024-01-31,428496,Disbursed,Chennai,Delhi,Personal Loan,DSA
27,1805,2024-01-27,2024-01-31,2024-02-04,378761,Disbursed,Bangalore,Karnataka,Personal Loan,DSA
28,1385,2024-01-28,2024-02-01,2024-02-05,275913,Rejected,Delhi,Tamil Nadu,Home Loan,DSA
29,1191,2024-01-29,2024-02-02,2024-02-06,329040,Disbursed,Chennai,Karnataka,Home Loan,Direct
30,1955,2024-01-30,2024-02-01,2024-02-05,442942,Pending,Mumbai,Karnataka,Personal Loan,DSA
31,1276,2024-01-31,2024-02-02,2024-02-06,227247,Approved,Mumbai,Karnataka,Home Loan,DSA
32,1160,2024-02-01,2024-02-04,2024-02-07,188877,Rejected,Bangalore,Karnataka,Personal Loan,DSA
33,1459,2024-02-02,2024-02-06,2024-02-09,55237,Rejected,Mumbai,Karnataka,Auto Loan,Online
34,1313,2024-02-03,2024-02-05,2024-02-06,70056,Pending,Delhi,Delhi,Personal Loan,Online
35,1021,2024-02-04,2024-02-07,2024-02-11,226615,Approved,Bangalore,Karnataka,Auto Loan,Direct
36,1252,2024-02-05,2024-02-09,2024-02-10,237628,Approved,Mumbai,Karnataka,Home Loan,Direct
37,1747,2024-02-06,2024-02-07,2024-02-11,164548,Rejected,Bangalore,Tamil Nadu,Personal Loan,Online
38,1856,2024-02-07,2024-02-10,2024-02-14,423632,Disbursed,Mumbai,Maharashtra,Home Loan,Online
39,1560,2024-02-08,2024-02-10,2024-02-13,184415,Rejected,Mumbai,Delhi,Auto Loan,Online
40,1474,2024-02-09,2024-02-10,2024-02-13,456716,Approved,Mumbai,Delhi,Auto Loan,DSA
;
run;

/* Data Cleaning (as in TAT.sas) */
data clean_data;
    set loan_data;
    if loan_amount = . then delete;
    if loan_amount < 0 then loan_amount = abs(loan_amount);
    format application_date approval_date disbursement_date date9.;
run;

/* AUTOMATION — the %generate_mis macro from TAT.sas.
   The only change from the repo: the two PROC EXPORT outfile= paths were
   hardcoded to a SAS OnDemand home directory; here they write xlsx into
   the run's working directory so the macro runs end to end. */

%macro generate_mis;

/*  Base Monthly MIS */
proc sql;
    create table monthly_mis as
    select
        year(disbursement_date) as year,
        month(disbursement_date) as month,
        sum(loan_amount) as total_disbursed,
        count(*) as total_loans
    from clean_data
    group by year, month
    order by year, month;
quit;
/*  Add Business Columns */
data monthly_mis_final;
    set monthly_mis;

    /* Month Name */
    month_name = put(mdy(month,1,year), monname.);

    /* Avg Ticket Size */
    avg_ticket = total_disbursed / total_loans;

    /* Growth % */
    prev_disbursed = lag(total_disbursed);

    if prev_disbursed ne . then
        growth_pct = ((total_disbursed - prev_disbursed)/prev_disbursed)*100;
run;

/*  Branch Performance */
proc sql;
    create table branch_perf as
    select
        branch,
        sum(loan_amount) as total_disbursed,
        count(*) as total_loans
    from clean_data
    group by branch
    order by total_disbursed desc;
quit;

/* Export Reports */
proc export data=monthly_mis_final
    outfile="mon.xlsx"
    dbms=xlsx replace;
run;

proc export data=branch_perf
    outfile="branch.xlsx"
    dbms=xlsx replace;
run;

%mend;

%generate_mis;

/* Show the enriched monthly MIS the macro built */
proc print data=monthly_mis_final;
    var year month month_name total_loans total_disbursed avg_ticket growth_pct;
run;
