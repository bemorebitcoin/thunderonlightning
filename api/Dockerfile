FROM rstudio/plumber:latest

# Install dependencies
RUN install2.r --error \
    jsonlite \
    uuid \
    && rm -rf /tmp/downloaded_packages

# Copy Plumber script
COPY plumber.R /plumber/plumber.R

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make executable
RUN chmod +x /entrypoint.sh

EXPOSE 8000

# Run via shell script
CMD ["/entrypoint.sh"]
