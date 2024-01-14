# autologin_platform_interface

A common platform interface for the `autologin` plugin.

This interface allows platform-specific implementations of the `autologin` plugin, as well as the plugin itself, to
ensure they are supporting the same interface.

# Usage

To implement a new platform-specific implementation of `autologin`, extend `AutologinPlatform` with an implementation
that performs the platform-specific behavior.
