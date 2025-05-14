---
layout: query-api
title: 'ElasticGraph Query API: Aggregation Counts'
permalink: "/query-api/aggregations/counts/"
nav_title: Counts
menu_order: 20
---
The aggregations API allows you to count documents within a grouping:

{% include copyable_code_snippet.html language="graphql" data="music_queries.aggregations.ArtistCountsByCountry" %}

This query, for example, returns a grouping for each country, and provides a count of how many artists
call each country home.
