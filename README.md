# ComfyUI Podman (AMD + NVIDIA)

Self-built ComfyUI containers from official sources only — AMD's `rocm-terminal`, Nvidia's base `cuda:ubuntu`, plus PyTorch's official wheels and official `comfy-cli`. No third-party prebuilt images.

**Hardened:** Read-only root filesystem, all Linux capabilities dropped, SELinux confinement (`container_runtime_t`). Only the specific paths ComfyUI needs are writable while everything else is locked or tmpfs.
## Compatibility

| OS      | Support                                       |
| ------- | --------------------------------------------- |
| Linux   | ✅ Tested on Fedora, should work on any distro |
| Windows | ⚠️ Untested, needs WSL                        |
| macOS   | ❓ Unknown                                     |
## Prerequisites

### Common

- **Podman**: [install guide](https://podman.io/docs/installation) (all platforms)
- **Make** *(optional, for the Make install path)*, usually preinstalled on Linux; check with:
	`make --version`
### AMD

- `amdgpu` kernel module loaded on host
- Your user in the `video` and `render` groups:
	```bash
	sudo usermod -aG video,render $(whoami)
	# Log out and back in after groups are added
	```

### NVIDIA

- NVIDIA drivers installed on host
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) configured

## Clone

```bash
git clone https://github.com/avirice/ComfyUI-Podman.git
cd ComfyUI-Podman
mkdir -p ~/.config/containers/systemd
```

## Install — Make (recommended)

**AMD**: Find your `HSA_OVERRIDE_GFX_VERSION` in the table below

```bash
make install-amd HSA=VALUE
```

**NVIDIA**
```bash
make install-nvidia
```
## Install — Manual

**AMD**
```bash
podman build -f Containerfile.amd -t comfyui .
sed 's/__HSA_VERSION__/VALUE/' comfyui.container.amd >
~/.config/containers/systemd/comfyui.container
systemctl --user daemon-reload
# Replace `VALUE` with your card's value from the table below
```

**NVIDIA**
```bash
podman build -f Containerfile.nvidia -t comfyui .
cp comfyui.container.nvidia ~/.config/containers/systemd/comfyui.container
systemctl --user daemon-reload
```

## Start

Once installed, this folder can be deleted, as the image and quadlet live outside it.

```bash
systemctl --user start comfyui    # start
systemctl --user stop comfyui     # stop
systemctl --user status comfyui   # check status
journalctl --user -u comfyui -f   # check logs
```

ComfyUI available at `http://localhost:8188`
## AMD: HSA_OVERRIDE_GFX_VERSION

| Architecture       | Value    | Cards                                                    |
| ------------------ | -------- | -------------------------------------------------------- |
| RDNA 4 (gfx1201)   | `12.0.1` | Radeon AI PRO R9700, Radeon RX 9070/9070 XT/9070 GRE     |
| RDNA 4 (gfx1200)   | `12.0.0` | Radeon RX 9060/9060 XT                                   |
| RDNA 3.5 (gfx1151) | `11.5.1` | Ryzen AI Max+ 395/390/385                                |
| RDNA 3.5 (gfx1150) | `11.5.0` | Ryzen AI 9 HX 375/370/365                                |
| RDNA 3 (gfx1101)   | `11.0.1` | Radeon RX 7700 XT/7800 XT, Radeon PRO W7700/V710         |
| RDNA 3 (gfx1100)   | `11.0.0` | Radeon RX 7900 XT/XTX/GRE, Radeon PRO W7900/W7800        |
| RDNA 2 (gfx1030)   | `10.3.0` | Radeon PRO W6800/V620 (RX 6000 unofficial, may not work) |

RDNA 3.5 cards also need `HIP_VISIBLE_DEVICES=0`, add it as an extra 
`Environment=` line in the quadlet before or after copying it.

## NVIDIA: CUDA compatibility

| Architecture | Example GPU | Compatible |
|---|---|---|
| Blackwell/Hopper/Lovelace/Ampere/Turing | RTX 5090, H100, RTX 4090, RTX 3090, RTX 2080, GTX 1660 | cu130, cu132 |
| Volta, Pascal, Maxwell | TITAN V, GTX 1080, GTX 980 | cu126 |

## Optional environment variables

Add as extra `Environment=` lines in `~/.config/containers/systemd/comfyui.container`:

| Variable | Effect |
|---|---|
| `CLI_ARGS=--disable-smart-memory` | Offload VRAM to RAM more aggressively - slower, reduces memory leaks |
| `HSA_DISABLE_FRAGMENT_ALLOCATOR=1` | AMD only - mitigates memory faults on some cards |
| `PYTORCH_TUNABLEOP_ENABLED=1` | Slower first run, faster subsequent runs |

After editing: `systemctl --user daemon-reload` then restart the service.

## Notes

- Podman volumes live at `~/.local/share/containers/storage/volumes/`
- No models bundled in the image, download into the `comfyui-models`
  volume after first start.

## Status

* AMD path tested and confirmed working. NVIDIA path written with same pattern but not yet run against real NVIDIA hardware (feedback and PRs needed).
* Windows not tested
## Roadmap

- CPU-only support
- Intel XPU support
