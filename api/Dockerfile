FROM rstudio/plumber:latest

# Install required packages
RUN install2.r --error \
    jsonlite \
    uuid \
    && rm -rf /tmp/downloaded_packages

# Copy the Plumber script
COPY plumber.R /plumber/plumber.R

RUN ls -la /plumber/

# Expose port
EXPOSE 8000

# Run Plumber – use double quotes for path to avoid quote issues
CMD ["R", "-e", "pr(\"/plumber/plumber.R\")$run(host='0.0.0.0', port=8000)"]
