#!/usr/bin/env bash

if [[ ! -d helix.git/ ]]; then
	printf "ERROR: helix.git submodule doesn't exist.\n"
	printf "\n"
	exit 1
fi

declare USE_HEAD=false

if [[ ${1} == head ]]; then
	USE_HEAD=true
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

if ${USE_HEAD}; then
	printf -v hx_tag "%s" "$(git describe --tags --long | sed -r -e 's/^([0-9]+\.[0-9]+)-[0-9]+-([a-z0-9]+)$/\1/g')"
else
	printf -v hx_tag "%s" "$(git tag | grep -E '^[2-9][0-9][.][0-9]+([.][0-9]+)?$' | tail -n 1)"
fi

printf "Latest helix tag: %s\n" "${hx_tag}"
printf "\n"

if ! ${USE_HEAD}; then
	echo Running: git switch --detach "${hx_tag}"
	git switch --detach "${hx_tag}" || exit
	printf "\n"

	# temporary fix for the 23.10 tag
	if [[ ${hx_tag} == 23.10 ]]; then
		echo Running: git cherry-pick 6d168eda275deb23b0c643aecd746af3f4cc9937
		git cherry-pick 6d168eda275deb23b0c643aecd746af3f4cc9937
	fi
fi

echo Running: rustup override set stable
rustup override set stable
printf "\n"

echo Running: cargo install --path helix-term
time cargo install --path helix-term || exit
printf "\n"

echo Running: hx --version
hx --version || exit
printf "\n"

printf -v hx_ver "%s" "$(hx --version | awk '/^helix/ { print $2 }')"

# starting with 24.03, the app reports 24.3
if [[ ${hx_ver} =~ ^[0-9]+[.][0-9]+$ ]]; then
	printf -v hx_ver "%02d.%02d" "${hx_ver%.*}" "${hx_ver#*.}"
elif [[ ${hx_ver} =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]]; then
	# shellcheck disable=SC2086
	printf -v hx_ver "%02d.%02d.%02d" ${hx_ver//[.]/ }
fi

if [[ -f ~/.vim/configs/editorconfig ]]; then
	cp -v ~/.vim/configs/editorconfig .editorconfig
fi

# echo Running: hx --grammar fetch
# hx --grammar fetch
# printf "\n"

# echo Running: hx --grammar build
# hx --grammar build
# printf "\n"

if [[ ${hx_ver} == "${hx_tag}" ]]; then
	printf "Success: installed hx has the expected version (got:%s == want:%s)\n" "${hx_ver}" "${hx_tag}"
else
	printf "Failure: installed hx doesn't have the expected version (got:%s == want:%s)\n" "${hx_ver}" "${hx_tag}"
	exit 1
fi
