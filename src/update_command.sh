repo="mkuchak/sugar-git"

latest_url=$(curl -sL -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest")
latest_version="${latest_url##*/}"
latest_version="${latest_version#v}"

if [[ -z "$latest_version" ]]; then
  echo "Could not determine the latest sgit version. Check your network connection." >&2
  exit 1
fi

if [[ "$latest_version" == "$version" ]]; then
  echo "sgit is already up to date (v$version)"
  exit 0
fi

echo "Updating sgit v$version -> v$latest_version..."

binary_path=$(command -v sgit || true)
[[ -z "$binary_path" ]] && binary_path="/usr/local/bin/sgit"

sudo=""
if [[ ! -w "$binary_path" && ( -e "$binary_path" || ! -w "$(dirname "$binary_path")" ) ]]; then
  sudo="sudo"
fi

if ! $sudo bash -c "curl -fsSL 'https://github.com/$repo/releases/latest/download/sgit' > '$binary_path'"; then
  echo "Failed to download the latest sgit release." >&2
  exit 1
fi
$sudo chmod +x "$binary_path"

echo "Done. Now running v$latest_version."
