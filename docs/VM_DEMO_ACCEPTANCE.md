# VM Demo Acceptance Criteria

## Target Platform

- **Platform**: QEMU/KVM x86_64
- **CPU**: 2 vCPU
- **RAM**: 2 GB
- **Disk**: optional, live ISO boot is sufficient
- **Firmware**: BIOS or UEFI (both preferred)
- **Network**: optional for core UX
- **GPU**: standard virtual display, no passthrough

## Pass Criteria

The demo passes if ALL of the following work:

### Boot
- [ ] ISO boots from a clean VM
- [ ] System reaches graphical session or clearly documented login flow
- [ ] No cloud service is required for boot

### Core UX
- [ ] Terminal opens
- [ ] File manager opens
- [ ] Text editor opens
- [ ] Basic system/about/help document is present
- [ ] Shutdown/reboot works from UI or documented command
- [ ] UX is lightweight and responsive at 2 GB RAM

### Build Provenance
- [ ] Build metadata is captured
- [ ] SHA256 checksum is generated
- [ ] Known limitations are documented

## AI/NIM Boundaries

- [ ] NVIDIA NIM/API key is not committed
- [ ] `.env.example` exists if API variables are referenced
- [ ] Missing API credentials do not break boot or UX
- [ ] Local inference support does not require bundled model weights

## Stretch Goals

- [ ] Boot at 1 GB RAM
- [ ] Both BIOS and UEFI boot verified
- [ ] Local inference launcher stub or documentation present
- [ ] Future RAG source manifest present under context/rag/sources.md

## Definition of Done

The sprint is done only when all required items below are true:

- [ ] Artifact exists
- [ ] Artifact checksum exists
- [ ] Build manifest exists
- [ ] VM boots from artifact
- [ ] Demo workflow is documented
- [ ] Known limitations are documented
- [ ] Validation report exists
- [ ] Human approval gate HG-7 is passed