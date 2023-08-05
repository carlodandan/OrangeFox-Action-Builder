# OrangeFox Action Builder
Compile your first custom recovery from OrangeFox Recovery Project using Github Action.

# How to Use
1. Fork this repository.

2. Go to `Action` tab > `All workflows` > `OrangeFox - Build` > `Run workflow`, then fill all the required information:
 * Manifest Branch (12.1, 11.0, etc.)
 * Device Tree (Your device tree repository link)
 * Device Tree Branch (Your device tree repository branch)
 * Device Name (Your device codename)
 * Device Path (device/brand/codename)
 * Build Target (boot, reecovery, vendorboot)

 # Note
 * Initially, it only have four default choices for fox branch; 12.1, 11.0, 10.0 and 9.0. If there's more to it, feel free to modify the .yml configurations.