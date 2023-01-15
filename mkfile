MKSHELL = rc

install:V:
	for(f in *) {
		if(! ~ $"f mkfile README.md .git) {
			ln -s $"PWD/$"f $"HOME/.local/bin/$"f || true
		}
	}
