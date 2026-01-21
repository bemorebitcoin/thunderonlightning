# Use rocker base with install2.r available
FROM rocker/tidyverse:latest

# Install system dependencies (often needed for R packages like httr/jsonlite)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Plumber + your packages using install2.r
RUN install2.r --error --skipinstalled \
    plumber \
    jsonlite \
    uuid \
    && rm -rf /tmp/downloaded_packages

# Copy your Plumber script
COPY plumber.R /plumber/plumber.R

# Expose port
EXPOSE 8000

# Start Plumber with library load
CMD ["R", "-e", "library(plumber); pr(\"/plumber/plumber.R\")$run(host=\"0.0.0.0\", port=8000)"]
