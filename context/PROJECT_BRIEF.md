# aetherOS Project Brief

aetherOS is a lightweight local-first operating environment for reviving constrained hardware for artists, independents, and small businesses.

## Sprint Goal

Produce a stable Arch/mkarchiso VM demo with reproducible build steps, lightweight UX, and clear operational standards.

## Hard Constraints

- Arch-based workflow preferred.
- mkarchiso preferred.
- No custom kernel.
- No custom package manager.
- No autonomous self-modification.
- Local-first by default.
- AI/NIM/RAG integrations must be optional and non-blocking.

## Success Definition

A VM-demo artifact that:
1. Boots in QEMU with 2 GB RAM
2. Reaches graphical session or documented login flow
3. Includes terminal, file manager, text editor, help document
4. Has reproducible build steps
5. Documents known limitations