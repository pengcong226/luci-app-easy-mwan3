# Changelog

## [2.1.1] - 2026-01-21

### Changed

- **Project Structure**: Removed redundant `ff0f8630...` subdirectory
- **Makefile**: Updated to use standard `luci.mk` build system

### Added

- **Translation Support**: Added `po/templates/easy-mwan3.pot` template
- **Chinese Translation**: Added `po/zh_Hans/easy-mwan3.po` for Chinese localization
- Separate `luci-i18n-easy-mwan3-zh-cn` package will be generated during build

## [2.1] - Initial Release

### Features

- Easy MWAN3 Configurator with Hybrid Strategy Engine
- Load balancing modes: Balanced (Weighted) and Failover (Active/Backup)
- Advanced device policies for per-IP routing
- Real-time connection status monitoring
