FROM postgis/postgis

RUN apt-get update && apt-get install -y gdal-bin unzip && \
    apt-get clean

COPY scripts/load-kmz.sh /docker-entrypoint-initdb.d/
COPY data/ /docker-entrypoint-initdb.d/data/