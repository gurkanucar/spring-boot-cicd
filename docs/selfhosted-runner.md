# Self-Hosted GitHub Actions Runner

Setup for a self-hosted runner on Linux with Docker, running as a systemd service.

## Setup

Run as **root**:

```bash
# 1. Install Docker (use your distro's method)

# 2. Create a dedicated user
useradd -m github-runner
usermod -aG docker github-runner

# 3. Switch to the user
su - github-runner
```

Get a token from `https://github.com/<user>/<repo>/settings/actions/runners/new` and run as `github-runner`:

```bash
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.334.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.334.0/actions-runner-linux-x64-2.334.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.334.0.tar.gz
./config.sh --url https://github.com/<user>/<repo> --token <TOKEN>
```

## Install as a service

`./run.sh` dies when you close the terminal. Install as a service instead — back as **root**:

```bash
cd /home/github-runner/actions-runner
./svc.sh install github-runner
./svc.sh start
./svc.sh status
```

Check logs:

```bash
journalctl -u 'actions.runner.*' -f
```

## Use in a workflow

```yaml
jobs:
  build:
    runs-on: self-hosted
```
