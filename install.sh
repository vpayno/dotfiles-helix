#!/usr/bin/env bash

if [[ ! -d helix.git/ ]]; then
	printf "ERROR: helix.git submodule doesn't exist.\n"
	printf "\n"
	exit 1
fi

echo Running: rustc --version
rustc --version
printf "\n"

echo Running: cd helix.git/
cd helix.git/ || exit
printf "\n"

echo Running: cargo clean
time cargo clean
printf "\n"

echo Running: git restore .
git restore .
printf "\n"

echo Running: git switch master
git switch master || exit
printf "\n"

echo Running: git pull
time git pull || exit
printf "\n"

printf -v hx_tag "%s" "$(git tag | grep -E '^[2-9][0-9][.][0-9]+([.][0-9]+)?$' | tail -n 1)"
printf "Latest helix tag: %s\n" "${hx_tag}"
printf "\n"

echo Running: git switch --detach "${hx_tag}"
git switch --detach "${hx_tag}" || exit
printf "\n"

echo Running: rustup override set stable
rustup override set stable
printf "\n"

echo Running: cargo install --path helix-term
time cargo install --path helix-term || exit
printf "\n"

echo Running: hx --version
hx --version || exit
printf "\n"

# echo Running: hx --grammar fetch
# hx --grammar fetch
# printf "\n"

# echo Running: hx --grammar build
# hx --grammar build
# printf "\n"
