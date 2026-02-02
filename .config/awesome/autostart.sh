#!/usr/bin/env dash

run() {
  if ! pgrep -f -- "$1" >/dev/null 2>&1; then
    "$@" &
  fi
}

run nm-applet
run copyq
run chromium-browser --force-device-scale-factor=1.25 --use-angle=vulkan --enable-zero-copy --enable-gpu-rasterization --enable-features=Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,UseMultiPlaneFormatForHardwareVideo,AcceleratedVideoDecodeLinuxZeroCopyGL
