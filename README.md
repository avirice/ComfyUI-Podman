# ComfyUI Podman Quadlet (AMD + Nvidia)

Self-built ComfyUI containers from official sources only:
    AMD's 'rocm-terminal' + PyTorch official wheels + official 'comfy-cli'.
    No third-party prebuilt images.

## Compatability

Requires **Linux with systemd** (podman quadlets initialize comfyui as a systemd service).

## Prerequisites

**AMD**
-   'amdgpu' kernel module installed and loaded on host
-   Your user in the 'video' and 'render' groups:
        sudo usermod -aG video,render $(whoami)

    Log out and back in afterward

- Check that your GPU is supported: [ROCm supported GPUs] (https://rocm.docs.amd.com/en/latest/compatibility/compatibility-matrix.html?fam=radeon&w=compute&gpu=v620&gfx=gfx1030&os=ubuntu)

**NVIDIA**
-   NVIDIA driver installed on host
-   NVIDIA Container Toolkit configured for CDI: [NVIDIA Container Toolkit] (https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Install - AMD

1. Clone this repo:

git clone <this-repo>
cd comfyui-podman

2. Build the image:

podman build -f Containerfile.amd -t comfyui .

3. Find your 'HSA_OVERRIDE_GFX_VERSION' in the table below, then copy the quadlet with your value filled in:

Open `http://localhost:8188` once started.

## AMD: HSA_OVERRIDE_GFX_VERSION

| Architecture | Value | Cards |
|---|---|---|
| RDNA 4 (gfx1201) | `12.0.1` | Radeon AI PRO R9700, Radeon RX 9070/9070 XT/9070 GRE |
| RDNA 4 (gfx1200) | `12.0.0` | Radeon RX 9060/9060 XT |
| RDNA 3.5 (gfx1151) | `11.5.1` | Ryzen AI Max+ 395/390/385 |
| RDNA 3.5 (gfx1150) | `11.5.0` | Ryzen AI 9 HX 375/370/365 |
| RDNA 3 (gfx1101) | `11.0.1` | Radeon RX 7700 XT/7800 XT, Radeon PRO W7700/V710 |
| RDNA 3 (gfx1100) | `11.0.0` | Radeon RX 7900 XT/XTX/GRE, Radeon PRO W7900/W7800 |
| RDNA 2 (gfx1030) | `10.3.0` | Radeon PRO W6800/V620 (RX 6000 unofficial, may not work) |

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

- Podman volumes typically stored at ~/.local/share/containers/storage/volumes/
- Models/output/workflows persist in named podman volumes. Everything
  else is read-only or tmpfs by design.
- LAN-only by default. Do not port-forward to the internet, ComfyUI has
  no built-in authentication.
- No models bundled in the image, download into the `comfyui-models`
  volume after first start.

## Status

AMD path tested and confirmed working. NVIDIA path written with same pattern but not yet run against real NVIDIA hardware (feedback and PRs needed).

## Roadmap

- CPU-only support
- Intel XPU support
