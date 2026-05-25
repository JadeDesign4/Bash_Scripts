# This find files in the current directory that where created or modified in the last 2 days.

find . -maxdepth 1 -type f -mtime -5 -printf "%TY-%Tm-%Td %TT %p\n"

