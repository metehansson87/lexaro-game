# Lexaro Server Deployment Guide

## Prerequisites

- Ubuntu/Debian VPS (Hetzner recommended)
- Node.js 18+ and npm
- Firewall access to port 3000

## Server Setup

### 1. Install Node.js

```bash
sudo apt update
sudo apt install -y nodejs npm
```

Or install via nvm for better version management:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
```

### 2. Clone and Install

```bash
cd /opt
git clone <repository-url> lexaro-game
cd lexaro-game/server
npm install
```

### 3. Configure Firewall

```bash
sudo ufw allow 3000
sudo ufw enable
```

### 4. Run Server

Development:
```bash
node index.js
```

Production (with PM2):
```bash
npm install -g pm2
pm2 start index.js --name lexaro-server
pm2 save
pm2 startup
```

### 5. Verify

```bash
curl http://localhost:3000/api/health
```

## Client Configuration

Update `lib/core/config/app_config.dart`:

```dart
static const String serverUrl = 'http://YOUR_SERVER_IP:3000';
static const String wsUrl = 'ws://YOUR_SERVER_IP:3000';
```

## API Endpoints

- `GET /api/health` - Server health check
- `GET /api/leaderboard?league=Global&limit=50` - Get leaderboard
- `GET /api/daily-puzzle?language=en` - Get daily puzzle
- `POST /api/daily-puzzle/complete` - Submit daily puzzle completion
- `GET /api/analytics/summary` - Analytics summary

## Socket.io Events

### Client -> Server
- `match:queue` - Join matchmaking queue
- `match:leave_queue` - Leave queue
- `round:answer` - Submit answer
- `round:hint` - Use hint
- `match:reconnect` - Reconnect to match

### Server -> Client
- `match:start` - Match found
- `round:start` - Round begins (includes puzzle)
- `round:tick` - Timer tick
- `round:result` - Round result
- `round:timeout` - Round timed out
- `match:complete` - Match finished
- `opponent:hint` - Opponent used hint
