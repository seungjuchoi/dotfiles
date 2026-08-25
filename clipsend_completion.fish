# clipsend 자동완성: ~/.ssh/config 의 Host 목록을 제안한다 (3_set_config.fish 가 ~/.config/fish/completions/clipsend.fish 로 링크)
complete -c clipsend -f
complete -c clipsend -n '__fish_is_first_arg' -a '(clipsend --hosts)' -d 'ssh host'
complete -c clipsend -n '__fish_is_first_arg' -a '(clipsend --last 2>/dev/null)' -d 'last host'
complete -c clipsend -l hosts -d 'List ssh config hosts'
complete -c clipsend -l last -d 'Show last host'
complete -c clipsend -l install-shim -x -a '(clipsend --hosts)' -d 'Install xclip shim on headless Linux host'
complete -c clipsend -s h -l help -d 'Help'
