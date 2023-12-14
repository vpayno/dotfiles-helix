#!/usr/bin/env bash

if [[ ! -d helix.git/ ]]; then
	printf "ERROR: helix.git submodule doesn't exist.\n"
	printf "\n"
	exit 1
fi

declare hx_tag
declare hx_ver

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

# temporary fix for the 23.10 tag
if [[ ${hx_tag} == 23.10 ]]; then
	echo Running: git cherry-pick 6d168eda275deb23b0c643aecd746af3f4cc9937
	git cherry-pick 6d168eda275deb23b0c643aecd746af3f4cc9937
fi

echo Running: cargo install --path helix-term
time cargo install --path helix-term || exit
printf "\n"

echo Running: hx --version
hx --version || exit
printf "\n"

hx_ver="$(hx --version | awk '/^helix/ { print $2 }')"

if [[ ${hx_ver} == "${hx_tag}" ]]; then
	printf "Success: installed hx has the expected version (got:%s == want:%s)\n" "${hx_ver}" "${hx_tag}"
else
	printf "Failure: installed hx doesn't have the expected version (got:%s == want:%s)\n" "${hx_ver}" "${hx_tag}"
	exit 1
fi

# echo Running: hx --grammar fetch
# hx --grammar fetch
# printf "\n"

# echo Running: hx --grammar build
# hx --grammar build
# printf "\n"
