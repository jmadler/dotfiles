set -exuo pipefail

if [[ "$(uname)" == "Darwin" ]]; then
	# if OSX
	echo xcode-select --install
	echo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	brew bundle
else
	# if Debian
	xargs -a dpkgs sudo apt-get install -y  
fi

for i in dot/*; do
	cp $i ~/.$(basename $i)
done
echo 'quit when complete if successful' | vim -
