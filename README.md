# AVNightwatch

AVNightwatch is a system that integrates Ableton Live with IRC (Internet Relay Chat) for real-time audio-visual performance and interaction. It consists of two main components: an Ableton Live project (`RDN_Liveset`) and a Max for Live device (`RDN_Orchestrator_2.1`).

## Prerequisites

- macOS operating system
- Ableton Live 11 (version 11.3.41 or newer) or Ableton Live 12
- Max 8 (either standalone or bundled with Ableton Live)
- Node.js (version 14 or newer)
- Docker Desktop for macOS

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/avnightwatch.git
   cd avnightwatch
   ```

2. Make the installation script executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the installation script:
   ```bash
   ./install.sh
   ```

The installation script will:
- Check for required software (Ableton Live, Max, Node.js)
- Prompt for your Ableton Live projects directory (default: `~/Music/Ableton`)
- Install the `RDN_Liveset` project to your Ableton Live projects directory
- Install required Node.js dependencies
- Save the directory paths to a `.env` file for future use

## Usage

1. Make the start script executable:
   ```bash
   chmod +x start.sh
   ```

2. Run the start script:
   ```bash
   ./start.sh
   ```

The start script offers three connection modes:

1. **Local Mode (0)**: Connects via localhost
   - Uses `http://127.0.0.1:6000` for WebSocket connection
   - Suitable for local development and testing

2. **Demo Mode (1)**: Connects directly to router
   - Uses `http://127.0.0.1:6000` for WebSocket connection
   - Checks for GL-MT300N router connection
   - Opens QR code for device connection
   - Requires Ethernet connection to router

3. **Mesh Mode (2)**: Connects to Raspberry Pi over Ethernet
   - Uses `http://raspi.local:6000` for WebSocket connection
   - Checks for Raspberry Pi connectivity
   - Offers SSH connection to Raspberry Pi

The script will:
- Check Docker installation and status
- Set up the IRCNightwatch environment
- Launch the Ableton Live project
- Display sentiment API logs

## Important Notes

### Custom Ableton Projects Directory
If your Ableton Live projects are not in the default `~/Music/Ableton` directory:
1. During installation, provide your custom Ableton projects directory path
2. After installation, you may need to relink media files in your Live session
3. To find the media files:
   - Open the RDN_Liveset project
   - Look for the RDN_Orchestrator device
   - The media files should be referenced from their original location
   - Use Ableton's "Collect All and Save" feature to ensure all files are properly linked

### Docker Management
- Before restarting Docker or running the start script again, always run:
  ```bash
  ./stop_local.sh
  ```
- This ensures proper cleanup of Docker resources and prevents port conflicts
- If you don't stop Docker properly, you might encounter port conflicts or stale containers

## Directory Structure

```
avnightwatch/
├── install.sh           # Installation script
├── start.sh            # Startup script
├── stop_local.sh       # Docker cleanup script
├── .env                # Environment configuration (created during installation)
├── .env.example        # Example environment configuration
└── RDN_Liveset/        # Ableton Live project
    └── RDN_Orchestrator_2.1 Project/  # Max for Live device
```

## Environment Variables

The `.env` file stores the following paths:
- `ABLETON_PROJECTS_DIR`: Path to your Ableton Live projects directory
- `WEBSOCKET_URL`: WebSocket connection URL (automatically set based on mode)

## Troubleshooting

1. **Permission Denied**
   - If you see "permission denied" errors, run:
     ```bash
     chmod +x install.sh start.sh stop_local.sh
     ```

2. **Docker Issues**
   - Ensure Docker Desktop is running
   - Check Docker network status with `docker network ls`
   - Always run `./stop_local.sh` before restarting
   - If ports are still in use, check for stale containers with `docker ps -a`

3. **Connection Issues**
   - Verify your network connection
   - Check if the target device (router/Raspberry Pi) is reachable
   - Ensure correct IP addresses in your network configuration

4. **Media Files Not Found**
   - If media files are missing after installation:
    1. Open the RDN_Liveset project
    2. Locate the RDN_Orchestrator device
    3. Check the media file references
    4. Use "Collect All and Save" to ensure all files are properly linked

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

[Your chosen license]

## Acknowledgments

- [List any acknowledgments or credits]

---

## ⚙️ Requirements

- macOS
- **Ableton Live 11 Suite** installed in `/Applications`
- **Max 8** (required for Max for Live), installed in `/Applications`
- Max for Live enabled in Ableton Live preferences

---

## 🚀 Installation

To set up the project:

1. **Make scripts executable:**

```bash
chmod +x install.sh
chmod +x start.sh
chmod +x stop_local.sh
chmod +x uninstall.sh
```