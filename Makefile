# Check if 'make' is run from the 'ali' directory (the directory where this Makefile
# resides).
$(if $(findstring /,$(MAKEFILE_LIST)),$(error Please only invoke this Makefile from the directory it resides in))

# Run all shell commands with bash.
SHELL := bash

.PHONY: setup

setup: setup.vim setup.ssh setup.alik-mf
	@echo "Make goals successful: $^"; rm $^
	
setup.vim: $(HOME)/.vimrc $(HOME)/.vim/autoload/pathogen.vim $(HOME)/.vim/bundle.updated
	@echo $@ > $@

setup.ssh: /etc/ssh/ssh_config /etc/ssh/sshd_config
	@echo $@ > $@

setup.alik-mf: ./alik-mf ./alik-mf.updated
	@echo $@ > $@

./alik-mf:
	@[ -d $@ ] || git clone https://github.com/amissine/alik-mf.git

./alik-mf.updated:
	@pushd alik-mf; git pull --tags origin master; popd

/etc/ssh/ssh_config: ./ssh/ssh_config
	@sudo cp $< $@; echo "Updated $@ with $< to allow remote port forwarding"

/etc/ssh/sshd_config: ./ssh/sshd_config
	@[ -s /etc/ssh/sshd_config ] || exit;\
		sudo cp $< $@; echo "Updated $@ with $< to prevent login with passwd and to allow remote port forwarding";\
		if [ `uname` = 'Linux' ]; then \
		  sudo service ssh stop; sudo service ssh start; service ssh status;\
		else \
		  launchctl unload  /System/Library/LaunchDaemons/ssh.plist; \
			launchctl load -w /System/Library/LaunchDaemons/ssh.plist; \
		fi

$(HOME)/.vimrc: ./vim/.vimrc
	@cp $< $@; echo "Updated $@ with $<"

$(HOME)/.vim/autoload/pathogen.vim: ./vim/.vim/autoload/pathogen.vim
	@[ -d $$HOME/.vim/autoload ] || mkdir -p $$HOME/.vim/autoload;\
		cp $< $@; echo "Updated $@ with $<"

$(HOME)/.vim/bundle.updated: ./vim/.vim/bundle
	@[ -d $$HOME/.vim/bundle ] && rm -rf $$HOME/.vim/bundle;\
		cp -a ./vim/.vim/bundle $$HOME/.vim; echo $@ > $@; echo "Updated $@ with $<"
