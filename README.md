# OrangeFox Action Builder
Compile your first custom recovery from OrangeFox Recovery Project using Github Action.

# How to Use
1. Fork this repository.

2. Go to `Action` tab > `All workflows` > `OrangeFox - Build` > `Run workflow`, then fill all the required information:
 * Manifest Branch (12.1 and 11.0)
 * Device Tree (Your device tree repository link)
 * Device Tree Branch (Your device tree repository branch)
 * Device Name (Your device codename)
 * Device Path (device/brand/codename)
 * Build Target (boot, reecovery, vendorboot)

 # Note
This action will now only support manifest 12.1 and 11.0, since all orangefox manifest below 11.0 are considered obsolete.