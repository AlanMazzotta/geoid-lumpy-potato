FROM osgeo/gdal:ubuntu-small-3.7

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install numpy pillow rasterio

WORKDIR /work

# Copy tools and viewer skeleton (expect user to mount data/assets for inputs/outputs)
COPY tools/ /work/tools/
COPY geoid_viewer_cleanup.html /work/geoid_viewer_cleanup.html
COPY assets/ /work/assets/

CMD ["/bin/bash"]
