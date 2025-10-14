# ElasticGraph Codebase Overview

ElasticGraph is designed to be modular, with a small core, and many built-in extensions that extend that core
for specific use cases. This minimizes exposure to vulnerabilities, reduces bloat, and makes ongoing upgrades
easier. The libraries that ship with ElasticGraph can be broken down into several categories.

### Core Libraries (8 gems)

These libraries form the core backbone of ElasticGraph and are typically all included in production deployments.

* [elasticgraph-admin](elasticgraph-admin/README.md): Administers a datastore for an ElasticGraph project.
* [elasticgraph-datastore_core](elasticgraph-datastore_core/README.md): Contains the core datastore logic used by the rest of ElasticGraph.
* [elasticgraph-graphiql](elasticgraph-graphiql/README.md): Provides a GraphiQL IDE for ElasticGraph projects.
* [elasticgraph-graphql](elasticgraph-graphql/README.md): Provides the ElasticGraph GraphQL query engine.
* [elasticgraph-indexer](elasticgraph-indexer/README.md): Indexes ElasticGraph data into a datastore.
* [elasticgraph-rack](elasticgraph-rack/README.md): Serves an ElasticGraph application using Rack.
* [elasticgraph-schema_artifacts](elasticgraph-schema_artifacts/README.md): Provides access to ElasticGraph schema artifacts.
* [elasticgraph-support](elasticgraph-support/README.md): Provides support utilities for other ElasticGraph gems.

#### Dependency Diagram

```mermaid
graph LR;
    classDef targetGemStyle fill:#FADBD8,stroke:#EC7063,color:#000,stroke-width:2px;
    classDef otherEgGemStyle fill:#A9DFBF,stroke:#2ECC71,color:#000;
    classDef externalGemCatStyle fill:#E0EFFF,stroke:#70A1D7,color:#2980B9;
    elasticgraph-admin["eg-admin"];
    elasticgraph-datastore_core["eg-datastore_core"];
    elasticgraph-indexer["eg-indexer"];
    elasticgraph-schema_artifacts["eg-schema_artifacts"];
    elasticgraph-support["eg-support"];
    rake["rake"];
    elasticgraph-graphiql["eg-graphiql"];
    elasticgraph-rack["eg-rack"];
    elasticgraph-graphql["eg-graphql"];
    base64["base64"];
    graphql["graphql"];
    graphql-c_parser["graphql-c_parser"];
    hashdiff["hashdiff"];
    rack["rack"];
    logger["logger"];
    json_schemer["json_schemer"];
    elasticgraph-admin --> elasticgraph-datastore_core;
    elasticgraph-admin --> elasticgraph-indexer;
    elasticgraph-admin --> elasticgraph-schema_artifacts;
    elasticgraph-admin --> elasticgraph-support;
    elasticgraph-admin --> rake;
    elasticgraph-datastore_core --> elasticgraph-schema_artifacts;
    elasticgraph-datastore_core --> elasticgraph-support;
    elasticgraph-graphiql --> elasticgraph-rack;
    elasticgraph-graphql --> base64;
    elasticgraph-graphql --> elasticgraph-datastore_core;
    elasticgraph-graphql --> elasticgraph-schema_artifacts;
    elasticgraph-graphql --> graphql;
    elasticgraph-graphql --> graphql-c_parser;
    elasticgraph-indexer --> elasticgraph-datastore_core;
    elasticgraph-indexer --> elasticgraph-schema_artifacts;
    elasticgraph-indexer --> elasticgraph-support;
    elasticgraph-indexer --> hashdiff;
    elasticgraph-rack --> elasticgraph-graphql;
    elasticgraph-rack --> rack;
    elasticgraph-schema_artifacts --> elasticgraph-support;
    elasticgraph-support --> logger;
    elasticgraph-support --> json_schemer;
    class elasticgraph-admin targetGemStyle;
    class elasticgraph-datastore_core targetGemStyle;
    class elasticgraph-indexer targetGemStyle;
    class elasticgraph-schema_artifacts targetGemStyle;
    class elasticgraph-support targetGemStyle;
    class rake externalGemCatStyle;
    class elasticgraph-graphiql targetGemStyle;
    class elasticgraph-rack targetGemStyle;
    class elasticgraph-graphql targetGemStyle;
    class base64 externalGemCatStyle;
    class graphql externalGemCatStyle;
    class graphql-c_parser externalGemCatStyle;
    class hashdiff externalGemCatStyle;
    class rack externalGemCatStyle;
    class logger externalGemCatStyle;
    class json_schemer externalGemCatStyle;
    click rake href "https://rubygems.org/gems/rake" "Open on RubyGems.org" _blank;
    click base64 href "https://rubygems.org/gems/base64" "Open on RubyGems.org" _blank;
    click graphql href "https://rubygems.org/gems/graphql" "Open on RubyGems.org" _blank;
    click graphql-c_parser href "https://rubygems.org/gems/graphql-c_parser" "Open on RubyGems.org" _blank;
    click hashdiff href "https://rubygems.org/gems/hashdiff" "Open on RubyGems.org" _blank;
    click rack href "https://rubygems.org/gems/rack" "Open on RubyGems.org" _blank;
    click logger href "https://rubygems.org/gems/logger" "Open on RubyGems.org" _blank;
    click json_schemer href "https://rubygems.org/gems/json_schemer" "Open on RubyGems.org" _blank;
```

### Local Development Libraries (3 gems)

These libraries are used for local development of ElasticGraph applications.

* [elasticgraph](elasticgraph/README.md): Bootstraps ElasticGraph projects.
* [elasticgraph-local](elasticgraph-local/README.md): Provides support for developing ElasticGraph applications locally.
* [elasticgraph-schema_definition](elasticgraph-schema_definition/README.md): Provides the ElasticGraph schema definition API.

#### Dependency Diagram

```mermaid
graph LR;
    classDef targetGemStyle fill:#FADBD8,stroke:#EC7063,color:#000,stroke-width:2px;
    classDef otherEgGemStyle fill:#A9DFBF,stroke:#2ECC71,color:#000;
    classDef externalGemCatStyle fill:#E0EFFF,stroke:#70A1D7,color:#2980B9;
    elasticgraph["eg"];
    elasticgraph-support["eg-support"];
    thor["thor"];
    elasticgraph-local["eg-local"];
    elasticgraph-admin["eg-admin"];
    elasticgraph-graphql["eg-graphql"];
    elasticgraph-graphiql["eg-graphiql"];
    elasticgraph-indexer["eg-indexer"];
    elasticgraph-schema_definition["eg-schema_definition"];
    rackup["rackup"];
    rake["rake"];
    webrick["webrick"];
    elasticgraph-schema_artifacts["eg-schema_artifacts"];
    graphql["graphql"];
    graphql-c_parser["graphql-c_parser"];
    elasticgraph --> elasticgraph-support;
    elasticgraph --> thor;
    elasticgraph-local --> elasticgraph-admin;
    elasticgraph-local --> elasticgraph-graphql;
    elasticgraph-local --> elasticgraph-graphiql;
    elasticgraph-local --> elasticgraph-indexer;
    elasticgraph-local --> elasticgraph-schema_definition;
    elasticgraph-local --> rackup;
    elasticgraph-local --> rake;
    elasticgraph-local --> webrick;
    elasticgraph-schema_definition --> elasticgraph-graphql;
    elasticgraph-schema_definition --> elasticgraph-indexer;
    elasticgraph-schema_definition --> elasticgraph-schema_artifacts;
    elasticgraph-schema_definition --> elasticgraph-support;
    elasticgraph-schema_definition --> graphql;
    elasticgraph-schema_definition --> graphql-c_parser;
    elasticgraph-schema_definition --> rake;
    class elasticgraph targetGemStyle;
    class elasticgraph-support otherEgGemStyle;
    class thor externalGemCatStyle;
    class elasticgraph-local targetGemStyle;
    class elasticgraph-admin otherEgGemStyle;
    class elasticgraph-graphql otherEgGemStyle;
    class elasticgraph-graphiql otherEgGemStyle;
    class elasticgraph-indexer otherEgGemStyle;
    class elasticgraph-schema_definition targetGemStyle;
    class rackup externalGemCatStyle;
    class rake externalGemCatStyle;
    class webrick externalGemCatStyle;
    class elasticgraph-schema_artifacts otherEgGemStyle;
    class graphql externalGemCatStyle;
    class graphql-c_parser externalGemCatStyle;
    click thor href "https://rubygems.org/gems/thor" "Open on RubyGems.org" _blank;
    click rackup href "https://rubygems.org/gems/rackup" "Open on RubyGems.org" _blank;
    click rake href "https://rubygems.org/gems/rake" "Open on RubyGems.org" _blank;
    click webrick href "https://rubygems.org/gems/webrick" "Open on RubyGems.org" _blank;
    click graphql href "https://rubygems.org/gems/graphql" "Open on RubyGems.org" _blank;
    click graphql-c_parser href "https://rubygems.org/gems/graphql-c_parser" "Open on RubyGems.org" _blank;
```

### Datastore Adapters (2 gems)

These libraries adapt ElasticGraph to your choice of datastore (Elasticsearch or OpenSearch).

* [elasticgraph-elasticsearch](elasticgraph-elasticsearch/README.md): Wraps the Elasticsearch client for use by ElasticGraph.
* [elasticgraph-opensearch](elasticgraph-opensearch/README.md): Wraps the OpenSearch client for use by ElasticGraph.

#### Dependency Diagram

```mermaid
graph LR;
    classDef targetGemStyle fill:#FADBD8,stroke:#EC7063,color:#000,stroke-width:2px;
    classDef otherEgGemStyle fill:#A9DFBF,stroke:#2ECC71,color:#000;
    classDef externalGemCatStyle fill:#E0EFFF,stroke:#70A1D7,color:#2980B9;
    elasticgraph-elasticsearch["eg-elasticsearch"];
    elasticgraph-support["eg-support"];
    elasticsearch["elasticsearch"];
    faraday["faraday"];
    faraday-retry["faraday-retry"];
    elasticgraph-opensearch["eg-opensearch"];
    opensearch-ruby["opensearch-ruby"];
    elasticgraph-elasticsearch --> elasticgraph-support;
    elasticgraph-elasticsearch --> elasticsearch;
    elasticgraph-elasticsearch --> faraday;
    elasticgraph-elasticsearch --> faraday-retry;
    elasticgraph-opensearch --> elasticgraph-support;
    elasticgraph-opensearch --> faraday;
    elasticgraph-opensearch --> faraday-retry;
    elasticgraph-opensearch --> opensearch-ruby;
    class elasticgraph-elasticsearch targetGemStyle;
    class elasticgraph-support otherEgGemStyle;
    class elasticsearch externalGemCatStyle;
    class faraday externalGemCatStyle;
    class faraday-retry externalGemCatStyle;
    class elasticgraph-opensearch targetGemStyle;
    class opensearch-ruby externalGemCatStyle;
    click elasticsearch href "https://rubygems.org/gems/elasticsearch" "Open on RubyGems.org" _blank;
    click faraday href "https://rubygems.org/gems/faraday" "Open on RubyGems.org" _blank;
    click faraday-retry href "https://rubygems.org/gems/faraday-retry" "Open on RubyGems.org" _blank;
    click opensearch-ruby href "https://rubygems.org/gems/opensearch-ruby" "Open on RubyGems.org" _blank;
```

### Extensions (5 gems)

These libraries extend ElasticGraph to provide optional but commonly needed functionality.

* [elasticgraph-apollo](elasticgraph-apollo/README.md): Transforms an ElasticGraph project into an Apollo subgraph.
* [elasticgraph-health_check](elasticgraph-health_check/README.md): Provides a health check for high availability ElasticGraph deployments.
* [elasticgraph-query_interceptor](elasticgraph-query_interceptor/README.md): Intercepts ElasticGraph datastore queries.
* [elasticgraph-query_registry](elasticgraph-query_registry/README.md): Provides a source-controlled query registry for ElasticGraph applications.
* [elasticgraph-warehouse](elasticgraph-warehouse/README.md): Adds Data Warehouse configuration generation to ElasticGraph

#### Dependency Diagram

```mermaid
graph LR;
    classDef targetGemStyle fill:#FADBD8,stroke:#EC7063,color:#000,stroke-width:2px;
    classDef otherEgGemStyle fill:#A9DFBF,stroke:#2ECC71,color:#000;
    classDef externalGemCatStyle fill:#E0EFFF,stroke:#70A1D7,color:#2980B9;
    elasticgraph-apollo["eg-apollo"];
    elasticgraph-graphql["eg-graphql"];
    elasticgraph-support["eg-support"];
    graphql["graphql"];
    apollo-federation["apollo-federation"];
    elasticgraph-health_check["eg-health_check"];
    elasticgraph-datastore_core["eg-datastore_core"];
    elasticgraph-query_interceptor["eg-query_interceptor"];
    elasticgraph-schema_artifacts["eg-schema_artifacts"];
    elasticgraph-query_registry["eg-query_registry"];
    graphql-c_parser["graphql-c_parser"];
    rake["rake"];
    elasticgraph-warehouse["eg-warehouse"];
    elasticgraph-schema_definition["eg-schema_definition"];
    elasticgraph-apollo --> elasticgraph-graphql;
    elasticgraph-apollo --> elasticgraph-support;
    elasticgraph-apollo --> graphql;
    elasticgraph-apollo --> apollo-federation;
    elasticgraph-health_check --> elasticgraph-datastore_core;
    elasticgraph-health_check --> elasticgraph-graphql;
    elasticgraph-health_check --> elasticgraph-support;
    elasticgraph-query_interceptor --> elasticgraph-graphql;
    elasticgraph-query_interceptor --> elasticgraph-schema_artifacts;
    elasticgraph-query_registry --> elasticgraph-graphql;
    elasticgraph-query_registry --> elasticgraph-support;
    elasticgraph-query_registry --> graphql;
    elasticgraph-query_registry --> graphql-c_parser;
    elasticgraph-query_registry --> rake;
    elasticgraph-warehouse --> elasticgraph-schema_definition;
    elasticgraph-warehouse --> elasticgraph-support;
    class elasticgraph-apollo targetGemStyle;
    class elasticgraph-graphql otherEgGemStyle;
    class elasticgraph-support otherEgGemStyle;
    class graphql externalGemCatStyle;
    class apollo-federation externalGemCatStyle;
    class elasticgraph-health_check targetGemStyle;
    class elasticgraph-datastore_core otherEgGemStyle;
    class elasticgraph-query_interceptor targetGemStyle;
    class elasticgraph-schema_artifacts otherEgGemStyle;
    class elasticgraph-query_registry targetGemStyle;
    class graphql-c_parser externalGemCatStyle;
    class rake externalGemCatStyle;
    class elasticgraph-warehouse targetGemStyle;
    class elasticgraph-schema_definition otherEgGemStyle;
    click graphql href "https://rubygems.org/gems/graphql" "Open on RubyGems.org" _blank;
    click apollo-federation href "https://rubygems.org/gems/apollo-federation" "Open on RubyGems.org" _blank;
    click graphql-c_parser href "https://rubygems.org/gems/graphql-c_parser" "Open on RubyGems.org" _blank;
    click rake href "https://rubygems.org/gems/rake" "Open on RubyGems.org" _blank;
```

### AWS Lambda Integration Libraries (5 gems)

These libraries wrap the the core ElasticGraph libraries so that they can be deployed using AWS Lambda.

* [elasticgraph-admin_lambda](elasticgraph-admin_lambda/README.md): Adapts elasticgraph-admin to run as an AWS Lambda.
* [elasticgraph-graphql_lambda](elasticgraph-graphql_lambda/README.md): Adapts elasticgraph-graphql to run as an AWS Lambda.
* [elasticgraph-indexer_autoscaler_lambda](elasticgraph-indexer_autoscaler_lambda/README.md): Monitors OpenSearch CPU utilization to autoscale elasticgraph-indexer_lambda concurrency.
* [elasticgraph-indexer_lambda](elasticgraph-indexer_lambda/README.md): Adapts elasticgraph-indexer to run in an AWS Lambda.
* [elasticgraph-lambda_support](elasticgraph-lambda_support/README.md): Supports running ElasticGraph using AWS Lambda.

#### Dependency Diagram

```mermaid
graph LR;
    classDef targetGemStyle fill:#FADBD8,stroke:#EC7063,color:#000,stroke-width:2px;
    classDef otherEgGemStyle fill:#A9DFBF,stroke:#2ECC71,color:#000;
    classDef externalGemCatStyle fill:#E0EFFF,stroke:#70A1D7,color:#2980B9;
    elasticgraph-admin_lambda["eg-admin_lambda"];
    rake["rake"];
    elasticgraph-admin["eg-admin"];
    elasticgraph-lambda_support["eg-lambda_support"];
    elasticgraph-graphql_lambda["eg-graphql_lambda"];
    elasticgraph-graphql["eg-graphql"];
    elasticgraph-indexer_autoscaler_lambda["eg-indexer_autoscaler_lambda"];
    elasticgraph-datastore_core["eg-datastore_core"];
    aws-sdk-lambda["aws-sdk-lambda"];
    aws-sdk-sqs["aws-sdk-sqs"];
    aws-sdk-cloudwatch["aws-sdk-cloudwatch"];
    ox["ox"];
    elasticgraph-indexer_lambda["eg-indexer_lambda"];
    elasticgraph-indexer["eg-indexer"];
    aws-sdk-s3["aws-sdk-s3"];
    elasticgraph-opensearch["eg-opensearch"];
    faraday_middleware-aws-sigv4["faraday_middleware-aws-sigv4"];
    elasticgraph-admin_lambda --> rake;
    elasticgraph-admin_lambda --> elasticgraph-admin;
    elasticgraph-admin_lambda --> elasticgraph-lambda_support;
    elasticgraph-graphql_lambda --> elasticgraph-graphql;
    elasticgraph-graphql_lambda --> elasticgraph-lambda_support;
    elasticgraph-indexer_autoscaler_lambda --> elasticgraph-datastore_core;
    elasticgraph-indexer_autoscaler_lambda --> elasticgraph-lambda_support;
    elasticgraph-indexer_autoscaler_lambda --> aws-sdk-lambda;
    elasticgraph-indexer_autoscaler_lambda --> aws-sdk-sqs;
    elasticgraph-indexer_autoscaler_lambda --> aws-sdk-cloudwatch;
    elasticgraph-indexer_autoscaler_lambda --> ox;
    elasticgraph-indexer_lambda --> elasticgraph-indexer;
    elasticgraph-indexer_lambda --> elasticgraph-lambda_support;
    elasticgraph-indexer_lambda --> aws-sdk-s3;
    elasticgraph-indexer_lambda --> ox;
    elasticgraph-lambda_support --> elasticgraph-opensearch;
    elasticgraph-lambda_support --> faraday_middleware-aws-sigv4;
    class elasticgraph-admin_lambda targetGemStyle;
    class rake externalGemCatStyle;
    class elasticgraph-admin otherEgGemStyle;
    class elasticgraph-lambda_support targetGemStyle;
    class elasticgraph-graphql_lambda targetGemStyle;
    class elasticgraph-graphql otherEgGemStyle;
    class elasticgraph-indexer_autoscaler_lambda targetGemStyle;
    class elasticgraph-datastore_core otherEgGemStyle;
    class aws-sdk-lambda externalGemCatStyle;
    class aws-sdk-sqs externalGemCatStyle;
    class aws-sdk-cloudwatch externalGemCatStyle;
    class ox externalGemCatStyle;
    class elasticgraph-indexer_lambda targetGemStyle;
    class elasticgraph-indexer otherEgGemStyle;
    class aws-sdk-s3 externalGemCatStyle;
    class elasticgraph-opensearch otherEgGemStyle;
    class faraday_middleware-aws-sigv4 externalGemCatStyle;
    click rake href "https://rubygems.org/gems/rake" "Open on RubyGems.org" _blank;
    click aws-sdk-lambda href "https://rubygems.org/gems/aws-sdk-lambda" "Open on RubyGems.org" _blank;
    click aws-sdk-sqs href "https://rubygems.org/gems/aws-sdk-sqs" "Open on RubyGems.org" _blank;
    click aws-sdk-cloudwatch href "https://rubygems.org/gems/aws-sdk-cloudwatch" "Open on RubyGems.org" _blank;
    click ox href "https://rubygems.org/gems/ox" "Open on RubyGems.org" _blank;
    click aws-sdk-s3 href "https://rubygems.org/gems/aws-sdk-s3" "Open on RubyGems.org" _blank;
    click faraday_middleware-aws-sigv4 href "https://rubygems.org/gems/faraday_middleware-aws-sigv4" "Open on RubyGems.org" _blank;
```

