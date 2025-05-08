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
- Prompt for your Max for Live devices directory (default: `~/Music/Max 8/Max For Live Devices`)
- Install the `RDN_Liveset` project to your Ableton Live projects directory
- Install the `RDN_Orchestrator_2.1` device to your Max for Live devices directory
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

## Directory Structure

```
avnightwatch/
├── install.sh           # Installation script
├── start.sh            # Startup script
├── .env                # Environment configuration (created during installation)
├── .env.example        # Example environment configuration
├── RDN_Liveset/        # Ableton Live project
└── RDN_Orchestrator_2.1 Project/  # Max for Live device
```

## Environment Variables

The `.env` file stores the following paths:
- `ABLETON_PROJECTS_DIR`: Path to your Ableton Live projects directory
- `MAX_DEVICES_DIR`: Path to your Max for Live devices directory

## Troubleshooting

1. **Permission Denied**
   - If you see "permission denied" errors, run:
     ```bash
     chmod +x install.sh start.sh
     ```

2. **Docker Issues**
   - Ensure Docker Desktop is running
   - Check Docker network status with `docker network ls`

3. **Connection Issues**
   - Verify your network connection
   - Check if the target device (router/Raspberry Pi) is reachable
   - Ensure correct IP addresses in your network configuration

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