#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEABLOCK_TRUNK="${SCRIPT_DIR}/trunk"

FACTORIO_VERSION=2.0.72
FACTORIO_ARCHIVE="factorio_linux_${FACTORIO_VERSION}.tar.xz"
FACTORIO_DOWNLOAD_URL="https://factorio.com/get-download/${FACTORIO_VERSION}/alpha/linux64"

read -r -p "Download and extract Factorio ${FACTORIO_VERSION}? [y/N] " response
case "${response}" in
  [yY])
    if [ ! -f "${SCRIPT_DIR}/${FACTORIO_ARCHIVE}" ]; then
      printf -- "Downloading %s...\n" "${FACTORIO_ARCHIVE}"
      curl -L "${FACTORIO_DOWNLOAD_URL}" -o "${SCRIPT_DIR}/${FACTORIO_ARCHIVE}"
    fi
    FACTORIO_DIR="${SCRIPT_DIR}/factorio"
    if [ ! -d "${FACTORIO_DIR}" ]; then
      tar -xf "${SCRIPT_DIR}/${FACTORIO_ARCHIVE}" -C "${SCRIPT_DIR}"
    fi
    SEABLOCK_MODS="${FACTORIO_DIR}/mods"
    ;;
  *)
    SEABLOCK_MODS="${HOME}/.factorio/mods"
    ;;
esac

SEABLOCK_TRUNK_PACK=(
  'SeaBlock/SeaBlock'
  'SeaBlock/SeaBlockMetaPack'
  'SpaceMod'
  'ScienceCostTweakerM'
  'Angelmods/angelsbioprocessing'
  'Angelmods/angelsrefining'
  'Angelmods/angelssmelting'
  'Angelmods/angelspetrochem'
  'Angelmods/angelsaddons-storage'
  'Angelmods/angelsbioprocessinggraphics'
  'Angelmods/angelsrefininggraphics'
  'Angelmods/angelspetrochemgraphics'
  'Angelmods/angelssmeltinggraphics'
  'bobsmods/bobelectronics'
  'bobsmods/boblibrary'
  'bobsmods/boblogistics'
  'bobsmods/bobores'
  'bobsmods/bobplates'
  'bobsmods/bobassembly'
  'bobsmods/bobenemies'
  'bobsmods/bobequipment'
  'bobsmods/bobinserters'
  'bobsmods/bobmining'
  'bobsmods/bobmodules'
  'bobsmods/bobpower'
  'bobsmods/bobrevamp'
  'bobsmods/bobtech'
  'bobsmods/bobwarfare'
  'CircuitProcessing/CircuitProcessing'
  'LandfillPainting/LandfillPainting'
  'reskins-angels'
  'reskins-bobs'
  'reskins-compatibility'
)

# Pull all submodules to latest commit on their tracked branch
git -C "${SCRIPT_DIR}" submodule update --init --remote --merge --recursive

mkdir -p "${SEABLOCK_MODS}"

function create_symlink() {
  local target="${1}"
  local dest="${SEABLOCK_MODS}/${target##*/}"

  if [ -e "${dest}" ] || [ -L "${dest}" ]; then
    if [ -L "$dest" ]; then
      printf -- "Skipping: %s is already a symlink\n" "${dest}"
      return 0
    fi

    if [ -d "${dest}" ]; then
      printf -- "Error: %s is a directory\n" "${dest}" >&2
      return 1
    fi
  fi

  ln -s "${SEABLOCK_TRUNK}/${target}" "${dest}"
}

for trunk_mod in "${SEABLOCK_TRUNK_PACK[@]}"; do
  if [ -d "${SEABLOCK_TRUNK}/${trunk_mod}" ]; then
    create_symlink "${trunk_mod}"
  fi
done

# Copy zip mods directly into mods directory
for zip in "${SEABLOCK_TRUNK}"/*.zip; do
  [ -f "${zip}" ] || continue
  dest="${SEABLOCK_MODS}/${zip##*/}"
  if [ -f "${dest}" ]; then
    printf -- "Skipping: %s already exists\n" "${dest}"
  else
    cp "${zip}" "${dest}"
  fi
done
