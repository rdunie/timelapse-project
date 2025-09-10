# Timelapse Project

## Overview
This application provides a simple yet robust solution for creating timelapse videos from an RTSP (Real-Time Streaming Protocol) camera feed. It is designed to run continuously, capturing frames at a specified interval, compiling them into timelapse videos periodically, and managing storage efficiently. The entire system is containerized using Docker and Docker Compose for easy deployment and management.

## Features
*   **RTSP Stream Capture:** Continuously captures still frames from a configurable RTSP camera stream.
*   **Automated Timelapse Creation:** Periodically compiles captured frames into high-quality timelapse videos.
*   **Storage Management:** Automatically rotates frame directories and deletes old frames after video creation to manage disk space.
*   **Restart Resilience:** Resumes frame numbering from where it left off after restarts, preventing overwrites and ensuring continuous capture.
*   **Configurable Capture Rate:** Adjust the interval at which frames are captured (e.g., every 5 seconds).
*   **Configurable Video Framerate:** Set the playback speed (frames per second) of the generated timelapse videos.
*   **External Configuration:** Key settings like the RTSP URL are managed via environment variables for easy deployment and updates without modifying code.
*   **Dockerized:** Packaged as Docker containers for isolated, consistent, and portable execution across different environments.

## Prerequisites
Before you begin, ensure you have the following installed on your system:
*   **Docker:** [Install Docker Engine](https://docs.docker.com/engine/install/)
*   **Docker Compose:** [Install Docker Compose](https://docs.docker.com/compose/install/)
*   **An RTSP Camera Stream:** The URL of your camera's RTSP feed.

## Setup

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/your-repo/timelapse-project.git
    cd timelapse-project
    ```
    *(Note: Replace `https://github.com/your-repo/timelapse-project.git` with the actual repository URL if different.)*

2.  **Create and Configure the `.env` file:**
    Create a file named `.env` in the root directory of the project (where `docker-compose.yml` is located).
    Add your RTSP camera URL to this file:
    ```
    RTSP_URL=rtsp://your-camera-ip/live
    ```
    *(Replace `rtsp://your-camera-ip/live` with your actual RTSP stream URL.)*

3.  **Review and Adjust Configuration (Optional):**
    You can customize various aspects of the application by modifying the following files:

    *   **`docker-compose.yml`**:
        *   **Memory Limits (`mem_limit`):** Adjust the memory allocated to each service (`ffmpeg-capture`, `frame-rotator`, `watchdog`). Current optimized values are:
            *   `ffmpeg-capture`: `100m`
            *   `frame-rotator`: `32m`
            *   `watchdog`: `16m`
        *   **CPU Limits (`cpus`):** Control the CPU share for each service.

    *   **`capture/capture.sh`**:
        *   **Frame Capture Rate (`-vf fps=0.2`):** This line in the `ffmpeg` command controls how often frames are captured. `fps=0.2` means 0.2 frames per second, or one frame every 5 seconds. Adjust `0.2` to your desired rate (e.g., `1` for every second, `0.1` for every 10 seconds).

    *   **`rotator/rotator.sh`**:
        *   **Timelapse Interval (`sleep 43200`):** This line determines how long the `frame-rotator` waits before creating a new timelapse video and rotating directories. `43200` seconds equals 12 hours.
        *   **Video Framerate (`-framerate 15`):** This option in the `ffmpeg` command sets the playback speed of the generated timelapse video to 15 frames per second.

## Usage

1.  **Start the Application:**
    Navigate to the project's root directory in your terminal and run:
    ```bash
    docker-compose up -d
    ```
    This command builds the Docker images (if not already built or if changes are detected), creates the containers, and starts them in detached mode (in the background).

2.  **Monitor Logs:**
    To view the real-time logs of all services:
    ```bash
    docker-compose logs -f
    ```
    To view logs for a specific service (e.g., `ffmpeg-capture`):
    ```bash
    docker-compose logs -f ffmpeg-capture
    ```

3.  **Stop the Application:**
    To stop and remove the running containers, networks, and volumes:
    ```bash
    docker-compose down
    ```

4.  **Access Output:**
    Captured frames and generated timelapse videos will be stored in the `output/` directory within your project.
    *   Frames are saved in subdirectories like `output/frames_YYYYMMDD_HHMMSS/`.
    *   Timelapse videos are saved in `output/videos/`.

## Directory Structure

*   `.env`: Stores environment variables, such as `RTSP_URL`.
*   `.gitignore`: Specifies intentionally untracked files to ignore by Git (e.g., `output/`, `.env`).
*   `docker-compose.yml`: Defines the services, networks, and volumes for the application.
*   `capture/`:
    *   `Dockerfile`: Defines the Docker image for the frame capture service.
    *   `capture.sh`: Script responsible for capturing frames from the RTSP stream.
*   `rotator/`:
    *   `Dockerfile`: Defines the Docker image for the frame rotation and video creation service.
    *   `rotator.sh`: Script responsible for creating timelapse videos, rotating frame directories, and managing old frames.
*   `output/`: (Ignored by Git)
    *   `frames_YYYYMMDD_HHMMSS/`: Directories where captured frames are temporarily stored.
    *   `videos/`: Directory where the final timelapse videos are saved.

## Troubleshooting

*   **`ffmpeg-capture` not starting or showing errors:**
    *   **RTSP URL:** Double-check that the `RTSP_URL` in your `.env` file is correct and accessible from where Docker is running.
    *   **Camera Connectivity:** Ensure your camera is online and the RTSP stream is active.
    *   **Memory Limits:** If you've lowered `mem_limit` for `ffmpeg-capture`, try increasing it if you see "out of memory" errors in the logs.
    *   **Corrupt Decoded Frame:** Occasional "corrupt decoded frame" messages in `ffmpeg-capture` logs might indicate issues with the RTSP stream stability or network. While frames might still be captured, consistent errors could lead to missing frames.

*   **`frame-rotator` not creating videos:**
    *   **Symlink:** Ensure the `current` symlink in the `output/` directory points to an active frames directory.
    *   **Frames Available:** The `frame-rotator` will only create a video if there are frames in the active directory. Check `output/frames_YYYYMMDD_HHMMSS/` to ensure frames are being captured.
    *   **FFmpeg Errors:** Check the `frame-rotator` logs for any `ffmpeg` errors during video creation.

*   **General Issues:**
    *   **Docker Logs:** Always check `docker-compose logs -f` for detailed error messages.
    *   **Resource Usage:** Use `docker stats` to monitor CPU and memory usage of your containers.
    *   **Disk Space:** Ensure you have enough free disk space, especially in the `output/` directory.