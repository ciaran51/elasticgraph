---
layout: query-api
title: 'ElasticGraph Query API: Filtering'
permalink: "/query-api/filtering/"
nav_title: Filtering
menu_order: 2
---
Use `filter:` on a root query field to narrow down the returned results:

```graphql
{{ site.data.music_queries.filtering.FindArtist }}
```

As shown here, filters have two basic parts:

* A _field path_: this specifies which field you want to filter on. When dealing with a nested field (e.g. `bio.yearFormed`),
  you'll need to provide a nested object matching the field structure.
* A _filtering predicate_: this specifies a filtering operator to apply at the field path.

### Empty Filters

Filters with a value of `null` or empty object (`{}`) match all documents. When negated with `not`, no documents are matched.
The filters in this query match all documents:

```graphql
{{ site.data.music_queries.filtering.EmptyFilters }}
```

This particularly comes in handy when using [query variables](https://graphql.org/learn/queries/#variables).
It allows a query to flexibly support a wide array of filters without requiring them to all be used for an
individual request.

```graphql
{{ site.data.music_queries.filtering.FindArtists }}
```