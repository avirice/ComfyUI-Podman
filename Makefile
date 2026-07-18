QUADLET_DIR := $(HOME)/.config/containers/systemd

.PHONY: build-amd build-nvidia install-amd install-nvidia help

help:
	@echo "Usage:"
	@echo "  make install-amd HSA=VALUE		# build + install for AMD (see README for HSA value)"
	@echo "	 make install-nvidia           		# build + install for NVIDIA"
	@echo ""
	@echo "After install, this folder can be deleted. Manage the service with:"
	@echo "  systemctl --user start comfyui"
	@echo "  systemctl --user stop comfyui"
	@echo "  systemctl --user status comfyui"
	@echo "  journalctl --user -u comfyui -f"

build-amd:
	podman build -f Containerfile.amd -t comfyui .

build-nvidia:
	podman build -f Containerfile.nvidia -t comfyui .

install-amd: build-amd
ifndef HSA
	$(error HSA is not set. Run: make install-amd HSA=VALUE - see README for your card\'s value)
endif
	mkdir -p $(QUADLET_DIR)
	sed 's/__HSA_VERSION__/$(HSA)/' comfyui.container.amd > $(QUADLET_DIR)/comfyui.container
	systemctl --user daemon-reload
	@echo ""
	@echo "Installed. This folder can now be deleted."
	@echo ""
	@echo "Make sure your user is in the 'video' and 'render' groups:"
	@echo "  sudo usermod -aG video,render \$$(whoami)"
	@echo "  (log out and back in after groups added)"
	@echo ""
	@echo "Start comfyui with: systemctl --user start comfyui"

install-nvidia: check-nvidia-cdi build-nvidia
	mkdir -p $(QUADLET_DIR)
	cp comfyui.container.nvidia $(QUADLET_DIR)/comfyui.container
	systemctl --user daemon-reload
	@echo ""
	@echo "Installed. This folder can now be deleted if you want."
	@echo ""
	@echo "Start it with: systemctl --user start comfyui"

