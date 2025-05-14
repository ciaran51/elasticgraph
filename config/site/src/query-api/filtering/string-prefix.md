---
layout: query-api
title: 'ElasticGraph Query API: String Prefix Filtering'
permalink: "/query-api/filtering/string-prefix/"
nav_title: String Prefix
menu_order: 47
---

ElasticGraph offers a predicate to support string prefix filtering:

{% include filtering_predicate_definitions/starts_with.md %}

Here's a basic example:

{% include copyable_code_snippet.html language="graphql" data="music_queries.filtering.ArtistsPrefixedWithThe" %}

By default, prefix searching is case-sensitive. To make it case-insensitive, pass `ignoreCase: true`:

{% include copyable_code_snippet.html language="graphql" data="music_queries.filtering.ArtistsPrefixedWithTheCaseInsensitive" %}
