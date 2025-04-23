ARG VERSION=latest
FROM docker.elastic.co/elasticsearch/elasticsearch:${VERSION}
RUN bin/elasticsearch-plugin install mapper-size analysis-icu
