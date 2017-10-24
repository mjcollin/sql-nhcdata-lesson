---
title: "SQL Aggregation"
teaching: 30
exercises: 5
questions:
- "How can I summarize my data by aggregating, filtering, or ordering query results?"
objectives:
- "Apply aggregation to group records in SQL."
- "Filter and order results of a query based on aggregate functions."
- "Save a query to make a new table."
- "Apply filters to find missing values in SQL."
keypoints:
- "Use the `GROUP BY` keyword to aggregate data."
- "Functions like `MIN`, `MAX`, `AVERAGE`, `SUM`, `COUNT`, etc. operate on aggregated data."
- "Use the `HAVING` keyword to filter on aggregate properties."
- "Use a `VIEW` to access the result of a query as though it was a new table."
---

## COUNT and GROUP BY

Aggregation allows us to combine results by grouping records based on value and
calculating combined values in groups.

Let’s go to the specimens table and find out how many individuals there are.
Using the wildcard simply counts the number of records (rows):

    SELECT COUNT(*)
    FROM specimens;

We can also find out how much all of those individuals weigh:

    SELECT COUNT(*), SUM(weight)
    FROM specimens;

We can output this value in kilograms, rounded to 3 decimal places:

    SELECT ROUND(SUM(weight)/1000, 3)
    FROM specimens;

There are many other aggregate functions included in SQL including
`MAX`, `MIN`, and `AVG`.

> ## Challenge
>
> Write a query that returns: total weight, average weight, and the min and max weights
> for all specimens.
> Can you modify it so that it outputs these values only for weights between 100 and 200?
{: .challenge}

Now, let's see how many individuals were counted in each species. We do this
using a `GROUP BY` clause

    SELECT species_id, COUNT(*)
    FROM specimens
    GROUP BY species_id;

`GROUP BY` tells SQL what field or fields we want to use to aggregate the data.
If we want to group by multiple fields, we give `GROUP BY` a comma separated list.

> ## Challenge
>
> Write queries that return:
>
> 1. How many individuals were counted in each year
>    *   in total
>    *   per each species
> 2. Average weight of each species in each year.
>
> Can you modify the above queries combining them into one?
{: .challenge}

## The `HAVING` keyword

In the previous lesson, we have seen the keywords `WHERE`, allowing to
filter the results according to some criteria. SQL offers a mechanism to
filter the results based on aggregate functions, through the `HAVING` keyword.

For example, we can adapt the last request we wrote to only return information
about species with a count higher than 10:

    SELECT species_id, COUNT(species_id)
    FROM specimens
    GROUP BY species_id
    HAVING COUNT(species_id) > 10;

The `HAVING` keyword works exactly like the `WHERE` keyword, but uses
aggregate functions instead of database fields.

If you use `AS` in your query to rename a column, `HAVING` can use this
information to make the query more readable. For example, in the above
query, we can call the `COUNT(species_id)` by another name, like
`records`. This can be written this way:

    SELECT species_id, COUNT(species_id) AS records
    FROM specimens
    GROUP BY species_id
    HAVING records > 10;

Note that in both queries, `HAVING` comes *after* `GROUP BY`. One way to
think about this is: the data are retrieved (`SELECT`), can be filtered
(`WHERE`), then joined in groups (`GROUP BY`); finally, we only select some
of these groups (`HAVING`).

> ## Challenge
>
> Write a query that returns, from the `species` table, the number of
> `specificEpithet` in each `genus`, only for the `genus` with more than 10
> `specificEpithet`.
{: .challenge}

## Ordering Aggregated Results

We can order the results of our aggregation by a specific column, including
the aggregated column.  Let’s count the number of individuals of each
species captured, ordered by the count:

    SELECT species_id, COUNT(*)
    FROM specimens
    GROUP BY species_id
    ORDER BY COUNT(species_id);

## Saving Queries for Future Use

It is not uncommon to repeat the same operation more than once, for example
for monitoring or reporting purposes. SQL comes with a very powerful mechanism
to do this: views. Views are a form of query that is saved in the database,
and can be used to look at, filter, and even update information. One way to
think of views is as a table, that can read, aggregate, and filter information
from several places before showing it to you.

Creating a view from a query requires to add `CREATE VIEW viewname AS`
before the query itself. For example, imagine that my project only covers
the data gathered during the summer (May - September) of 2000.  That
query would look like:

    SELECT *
    FROM specimens
    WHERE year = 1990 AND (month >= 1  AND month < 4);

But we don't want to have to type that every time we want to ask a
question about that particular subset of data.  Let's create a view:

    CREATE VIEW spring_1990 AS
    SELECT *
    FROM specimens
    WHERE year = 1990 AND (month >= 1  AND month < 4);

You can also add a view using *Create View* in the *View* menu and see the
results in the *Views* tab just like a table.

Now, we will be able to access these results with a much shorter notation:

    SELECT *
    FROM spring_1990;

There should only be six records.  If you look at the `weight` column, it's
easy to see what the average weight would be.  If we use SQL to find the
average weight, SQL behaves like we would hope, ignoring
the NULL values: 

    SELECT AVG(weight)
    FROM spring_1990
    WHERE species_id = 1323405193;

But if we try to be extra clever, and find the average ourselves,
we might get tripped up:

    SELECT AVG(weight), SUM(weight), COUNT(*), SUM(weight)/COUNT(*)
    FROM spring_1990
    WHERE species_id = 1323405193;

Here the `COUNT` command includes all 15 records (even those with NULL
values), but the `SUM` only includes the 14 records with data in the
`weight` field, giving us an incorrect average.  However,
our strategy *will* work if we modify the count command slightly:

    SELECT AVG(weight), SUM(weight), COUNT(weight), SUM(weight)/COUNT(weight)
    FROM spring_1990
    WHERE species_id = 1323405193;

When we count the weight field specifically, SQL ignores the records with data
missing in that field.  So here is one example where NULLs can be tricky:
`COUNT(*)` and `COUNT(field)` can return different values.

Another case is when we use a "negative" query.  Let's count all the
non-female animals:

    SELECT COUNT(*)
    FROM spring_1990
    WHERE sex != 'female';

Now let's count all the non-male animals:

    SELECT COUNT(*)
    FROM spring_1990
    WHERE sex != 'male';

But if we compare those two numbers with the total:

    SELECT COUNT(*)
    FROM spring_1990;

We'll see that they don't add up to the total!  That's because SQL
doesn't automatically include NULL values in a negative conditional
statement.  So if we are quering "not x", then SQL divides our data
into three categories: 'x', 'not NULL, not x' and NULL and
returns the 'not NULL, not x' group. Sometimes this may be what we want -
but sometimes we may want the missing values included as well!  In that
case, we'd need to change our query to:

    SELECT COUNT(*)
    FROM spring_1990
    WHERE sex != 'male' OR sex IS NULL;

There is one more subtlety we need to be aware of.
Suppose we run this query:

    SELECT COUNT(*), length
    FROM spring_1990;

What length was returned?