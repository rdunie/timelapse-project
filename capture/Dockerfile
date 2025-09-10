FROM jrottenberg/ffmpeg:4.4-alpine

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the workdir
WORKDIR /app

# Copy the script with correct ownership
COPY --chown=appuser:appgroup capture.sh .
RUN chmod +x capture.sh

# Switch to the non-root user
USER appuser

ENTRYPOINT ["./capture.sh"]