# if OSX
# xcode-select --install
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# brew bundle
# if Debian
# xargs -a dpkgs sudo apt-get install -y  

for i in dot/*; do
	cp $i ~/.$(basename $i)
done
echo 'quit when complete if successful' | vim -
