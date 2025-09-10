FROM jrottenberg/ffmpeg:4.4-alpine

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the workdir
WORKDIR /app

# Copy the script with correct ownership
COPY --chown=appuser:appgroup rotator.sh .
RUN chmod +x rotator.sh

# Switch to the non-root user
USER appuser

ENTRYPOINT ["./rotator.sh"]