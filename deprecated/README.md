# Deprecated Artifacts

These artifacts were from the original Debian/live-build approach (ADR-0001).

Superseded by ADR-0004 (Arch Linux + mkarchiso).

Preserved for reference but not part of the active build path.

The `bootstrap-aether.sh` script requires `apt` and targets Debian package names. The `manifests/` directory contains Debian package lists (e.g., `apt-utils`, `firefox-esr`) that will cause `pacman` failures if referenced.
