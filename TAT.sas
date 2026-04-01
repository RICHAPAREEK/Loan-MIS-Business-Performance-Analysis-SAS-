libname Loan "/home/u63461142/sasuser.v94/TAT";

/* import data */
proc import datafile="/home/u63461142/sasuser.v94/TAT/loan_mis_project_dataset.csv"
    out=loan_data
    dbms=csv
    replace;
    getnames=yes;
run;

/* Data Cleaning */
data clean_data;
    set loan_data;

    /* Remove missing values */
    if loan_amount = . then delete;

    /* Fix negative values */
    if loan_amount < 0 then loan_amount = abs(loan_amount);

    /* Format dates */
    format application_date approval_date disbursement_date date9.;
run;

/* TOTAL DISBURSEMENT */
proc sql;
    create table kpi_disbursement as
    select sum(loan_amount) as total_disbursed
    from clean_data;
quit;

/* TOTAL LOAN COUNT */
proc sql;
    create table kpi_count as
    select count(*) as total_loans
    from clean_data;
quit;

/* Calculate TAT */
data tat_calc;
    set clean_data;

    tat = disbursement_date - application_date;
run;

/* Average TAT */
proc means data=tat_calc mean;
    var tat;
run;

/* SLA TRACKING  */

data sla_check;
    set tat_calc;

    if tat <= 5 then sla_met = 1;
    else sla_met = 0;
run;

/* SLA % Calculation */
proc sql;
    select 
        sum(sla_met)/count(*) * 100 as sla_percentage
    from sla_check;
quit;

/*  LEAD FUNNEL  */
proc sql;
    create table funnel as
    select 
        loan_status,
        count(*) as count
    from clean_data
    group by loan_status;
quit;


/* MONTHLY MIS REPORT  */

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


/*  DAILY MIS REPORT */
proc sql;
    create table daily_mis as
    select 
        disbursement_date,
        sum(loan_amount) as total_disbursed,
        count(*) as total_loans
    from clean_data
    group by disbursement_date
    order by disbursement_date;
quit;


/* BRANCH-WISE PERFORMANCE */

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

/* PRODUCT-WISE PERFORMANCE */
proc sql;
    create table product_perf as
    select 
        product_type,
        sum(loan_amount) as total_disbursed,
        count(*) as total_loans
    from clean_data
    group by product_type
    order by total_disbursed desc;
quit;

/* CHANNEL PERFORMANCE  */

proc sql;
    create table channel_perf as
    select 
        channel,
        count(*) as total_loans,
        sum(loan_amount) as total_disbursed
    from clean_data
    group by channel;
quit;


/* AUTOMATION */

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
    outfile="/home/u63461142/sasuser.v94/TAT/mon"
    dbms=xlsx replace;
run;

proc export data=branch_perf
    outfile="/home/u63461142/sasuser.v94/TAT/branch"
    dbms=xlsx replace;
run;

%mend;

%generate_mis;


