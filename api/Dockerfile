# Use official Posit/RStudio Plumber image (recommended over rocker variants)
FROM rstudio/plumber:latest

# Install extra R packages your API needs (add more as required)
RUN install2.r --error \
    httr \
    uuid \
    jsonlite \
    && rm -rf /tmp/downloaded_packages

# Copy your Plumber script (adjust path if needed)
COPY plumber.R /plumber/plumber.R

# Expose Plumber's default port
EXPOSE 8000

# Run the API (host on 0.0.0.0 for Render)
CMD ["R", "-e", "pr('/plumber/plumber.R')$run(host='0.0.0.0', port=8000)"]
