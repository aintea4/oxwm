TARGET = oxwm

BUILD_DIR = zig-out
TARGET_DIR = $(BUILD_DIR)/bin
INSTALL_DIR = /usr/bin
RESOURCE_DIR = resources
CONFIG_DIR = $$HOME/.config/oxwm
XSESSIONS_DIR = /usr/share/xsessions
CACHE_DIR = .zig-cache

OPTIMIZE_RULE = ReleaseSafe

SRCS = $(shell find src/ -type f -name '*.zig')

ifeq ($(strip $(V)),)
	E = @echo
	Q = @
else
	E = @\#
	Q =
endif

build: $(TARGET_DIR)/$(TARGET)

$(TARGET_DIR)/$(TARGET): $(SRCS)
	$(E) "  [build]   " $@
	$(Q) zig build -Doptimize=$(OPTIMIZE_RULE)

install: $(INSTALL_DIR)/$(TARGET)

$(INSTALL_DIR)/$(TARGET): $(TARGET_DIR)/$(TARGET)
	$(E) "  [install] " $@
	$(Q) chmod +x $(TARGET_DIR)/$(TARGET)
	$(Q) sudo cp $(TARGET_DIR)/$(TARGET) $(INSTALL_DIR)/$(TARGET)
	$(Q) sudo cp $(RESOURCE_DIR)/oxwm.desktop $(XSESSIONS_DIR)/oxwm.desktop

checkinstall:
	$(E) "  [check-install]"
	$(Q) checkinstall --pkgname oxwm --exclude /root -y make install

uninstall:
	$(E) "  [uninstall] (keeping $$HOME/.config/oxwm)"
	$(Q) sudo $(RM) -f $(INSTALL_DIR)/$(TARGET)

clean:
	$(E) "  [clean]"
	$(Q) $(RM) -rf $(BUILD_DIR)
	$(Q) $(RM) -rf $(CACHE_DIR)

test-clean:
	$(E) "  [test-clean]"
	$(Q) pkill Xephyr || true
	$(Q) $(RM) -rf $(CONFIG_DIR)/$(TARGET)
	$(Q) Xephyr -screen 1280x800 :1 & sleep 1
	$(Q) DISPLAY=:1 zig build run -- -c $(RESOURCE_DIR)/config.lua

test:
	$(E) "  [test]"
	$(Q) zig build xephyr

test-multimon:
	$(E) "  [test-multimon]"
	$(Q) zig build xephyr-multi

edit:
	$(Q) $$EDITOR $(CONFIG_DIR)/$(TARGET)/config.lua

fmt: $(SRCS)
	$(E) "  [format]"
	$(Q) zig build fmt

pre-commit: fmt build
	$(E) "  [pre-commit]"
	$(Q) @echo "All checks passed!"

run: $(TARGET_DIR)/$(TARGET)
	$(E) "  [run]     " $<
	$(Q) $(TARGET_DIR)/$(TARGET)
