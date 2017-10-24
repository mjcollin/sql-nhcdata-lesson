---
title: "Basic Queries"
teaching: 30
exercises: 5
questions:
- "How do I write a basic query in SQL?"
objectives:
- "Write and build queries."
- "Filter data given various criteria."
- "Sort the results of a query."
keypoints:
- "It is useful to apply conventions when writing SQL queries to aid readability."
- "Use logical connectors such as AND or OR to create more complex queries."
- "Calculations using mathematical symbols can also be performed on SQL queries."
- "Adding comments in SQL helps keep complex queries understandable."
---

## Writing my first query

Let's start by using the **specimens** table. Here we have data on a subset of
rodent specimens in iDigBio including where they were collected, their 
identification, and extracted information on their sex and weight in grams.

Let’s write an SQL query that selects only the year column from the
specimens table. SQL queries can be written in the box located under 
the "Execute SQL" tab. Click 'Run SQL' to execute the query in the box.

    SELECT year
    FROM specimens;

We have capitalized the words SELECT and FROM because they are SQL keywords.
SQL is case insensitive, but it helps for readability, and is good style.

If we want more information, we can just add a new column to the list of fields,
right after SELECT:

    SELECT year, month, day
    FROM specimens;

Or we can select all of the columns in a table using the wildcard *

    SELECT *
    FROM specimens;

### Limiting results

Sometimes you don't want to see all the results you just want to get a sense of
of what's being returned. In that case you can use the LIMIT command. In particular
you would want to do this if you were working with large databases.

    SELECT *
    FROM specimens
    LIMIT 10; 

### Unique values

If we want only the unique values so that we can quickly see what who has
been collecting we use `DISTINCT` 

    SELECT DISTINCT recordedBy
    FROM specimens;

If we select more than one column, then the distinct pairs of values are
returned

    SELECT DISTINCT year, recordedBy
    FROM specimens;

### Calculated values

We can also do calculations with the values in a query.
For example, if we wanted to look at the mass of each specimen
on different dates, but we needed it in kg instead of g we would use

    SELECT year, month, day, weight/1000
    FROM specimens;

When we run the query, the expression `weight / 1000` is evaluated for each
row and appended to that row, in a new column. If we used the `INTEGER` data type
for the weight field then integer division would have been done, to obtain the
correct results in that case divide by `1000.0`. Expressions can use any fields,
any arithmetic operators (`+`, `-`, `*`, and `/`) and a variety of built-in
functions. For example, we could round the values to make them easier to read.

    SELECT locality_id, species_id, sex, weight, ROUND(weight / 1000, 2)
    FROM specimens;

> ## Challenge
>
> - Write a query that returns The year, month, day, species_id and weight in mg
{: .challenge}

## Filtering

Databases can also filter data – selecting only the data meeting certain
criteria.  For example, let’s say we only want data The Museum of Vertebrate 
Zoology at Berkeley which has the institution code mvz.  We need to add a
`WHERE` clause to our query:

    SELECT *
    FROM specimens
    WHERE institutionCode = 'mvz';

We can do the same thing with numbers.
Here, we only want the data since 2000:

    SELECT * FROM specimens
    WHERE year >= 2000;

If we used the `TEXT` data type for the year the `WHERE` clause should
be `year >= '2000'`. We can use more sophisticated conditions by combining tests
with `AND` and `OR`.  For example, suppose we want the data from mvz
starting in the year 2000:

    SELECT *
    FROM specimens
    WHERE (year >= 2000) AND (institutionCode = 'mvz');

Note that the parentheses are not needed, but again, they help with
readability.  They also ensure that the computer combines `AND` and `OR`
in the way that we intend.

If we wanted to get data from the institutions in the continental US, we could
combine the tests using OR:

    SELECT *
    FROM specimens
    WHERE (institutionCode = 'msb') OR (institutionCode = 'omnh') OR (institutionCode = 'mvz');

> ## Challenge
>
> - Produce a table listing the data for all individuals from the University of
> Alaska Museum (uam) that weighed more than 150 grams, telling us the date, 
> species id code, and weight (in kg). 
{: .challenge}

## Building more complex queries

Now, lets combine the above queries to get data for the 3 lower 48 institutions from
the year 2000 on.  This time, let’s use IN as one way to make the query easier
to understand.  It is equivalent to saying `WHERE (institutionCode = 'msb') OR 
(institutionCode = 'omnh') OR (institutionCode = 'mvz')`, but reads more neatly:

    SELECT *
    FROM specimens
    WHERE (year >= 2000) AND (institutionCode IN ('msb', 'omnh', 'mvz'));

We started with something simple, then added more clauses one by one, testing
their effects as we went along.  For complex queries, this is a good strategy,
to make sure you are getting what you want.  Sometimes it might help to take a
subset of the data that you can easily see in a temporary database to practice
your queries on before working on a larger or more complicated database.

When the queries become more complex, it can be useful to add comments. In SQL,
comments are started by `--`, and end at the end of the line. For example, a
commented version of the above query can be written as:

    -- Get post 2000 data from continental institutions
    -- These are in the specimens table, and we are interested in all columns
    SELECT * FROM specimens
    -- Sampling year is in the column `year`, and we want to include 2000
    WHERE (year >= 2000)
    -- lower 48 collections have the codes msb, omnh, mvz
    AND (institutionCode IN ('msb', 'omnh', 'mvz'));

Although SQL queries often read like plain English, it is *always* useful to add
comments; this is especially true of more complex queries.

## Sorting

We can also sort the results of our queries by using `ORDER BY`.
For simplicity, let’s go back to the **species** table and alphabetize it by taxa.

First, let's look at what's in the **species** table. It's a table of the species_id 
and the full genus, species and scientific name information for each species_id.
Having this in a separate table is nice, because we didn't need to include all
this information in our main **specimens** table.

    SELECT *
    FROM species;

Now let's order it by genus.

    SELECT *
    FROM species
    ORDER BY genus ASC;

The keyword `ASC` tells us to order it in Ascending order.
We could alternately use `DESC` to get descending order.

    SELECT *
    FROM species
    ORDER BY genus DESC;

`ASC` is the default.

We can also sort on several fields at once.
To truly be alphabetical, we might want to order by genus then species.

    SELECT *
    FROM species
    ORDER BY genus ASC, specificEpithet ASC;

> ## Challenge
>
> - Write a query that returns year, species_id, and weight in kg from
> the specimens table, sorted with the largest weights at the top.
{: .challenge}

## Order of execution

Another note for ordering. We don’t actually have to display a column to sort by
it.  For example, let’s say we want to order the microtus by their species ID, but
we only want to see the whole scientific name.

    SELECT scientificName
    FROM species
    WHERE genus = 'microtus'
    ORDER BY id ASC;

We can do this because sorting occurs earlier in the computational pipeline than
field selection.

The computer is basically doing this:

1. Filtering rows according to WHERE
2. Sorting results according to ORDER BY
3. Displaying requested columns or expressions.

Clauses are written in a fixed order: `SELECT`, `FROM`, `WHERE`, then `ORDER
BY`. It is possible to write a query as a single line, but for readability,
we recommend to put each clause on its own line.

> ## Challenge
>
> - Let's try to combine what we've learned so far in a single
> query.  Using the specimens table write a query to display the institution, the 
> three date fields, `species_id`, and weight in kilograms (rounded to two 
> decimal places), for individuals captured in 1999, ordered alphabetically by 
> the `institutionCode`. 
> - Write the query as a single line, then put each clause on its own line, and
> see how more legible the query becomes!
{: .challenge}

