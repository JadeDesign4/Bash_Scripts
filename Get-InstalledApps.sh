#!/bin/bash

sleep 1
echo "# This will list packages Installed by you On Arch & Debian based Distros"

sleep 3
echo ""

echo "=================================================="
echo "  Explicitly Installed Packages (Official Repos)  "
echo "=================================================="
# -Q: Query, -e: Explicitly installed, -n: Native (Official repos)
pacman -Qen

echo -e "\n=================================================="
echo "  Explicitly Installed Packages (AUR / Foreign)   "
echo "=================================================="
# -m: Foreign (AUR, manually installed, etc.)
pacman -Qem

echo -e "\n=================================================="
echo "  Flatpak Applications (If any)                   "
echo "=================================================="
if command -v flatpak &> /dev/null; then
    flatpak list --app --columns=application,name
else
    echo "Flatpak is not installed."
fi

#!/bin/bash

echo "=================================================="
echo "  Manually Installed Packages (APT)              "
echo "=================================================="
# 'apt-mark showmanual' lists packages you or a script explicitly installed.
# We use grep to filter out core system plumbing if desired, but this is the truest list.
apt-mark showmanual

echo -e "\n=================================================="
echo "  Snap Applications (If any)                      "
echo "=================================================="
if command -v snap &> /dev/null; then
    snap list
else
    echo "Snap is not installed."
fi
