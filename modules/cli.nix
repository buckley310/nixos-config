{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        pwgen pv tree tmux psmisc ncdu git file sqlite usbutils entr ffmpeg gcc
        python3 hugo openssl wget lm_sensors htop zip unzip dnsutils whois
        tcpdump rsync

        (writeScriptBin "nix-roots" "nix-store --gc --print-roots | grep -v ^/proc/")

        (vim_configurable.customize {
            name="vim";
            vimrcConfig.customRC=''
                syntax enable
                set nowrap ruler scrolloff=9 backspace=start,indent
                set autoindent smartindent expandtab tabstop=4 shiftwidth=4
            '';
        })

        (writeScriptBin "zfsram" ''
            #!${pkgs.python3}/bin/python
            for ln in open('/proc/spl/kstat/zfs/arcstats').readlines():
                if ln.startswith('size '):
                    print(str(int(ln.split(' ')[-1])/(1024*1024*1024))[:5],'GB')
        '')
    ];

    programs.bash.interactiveShellInit = ''
        stty -ixon
        echo $XDG_SESSION_TYPE
        alias p=python3
        alias buildsys='nix build -f "<nixpkgs/nixos>" --no-link system'

        alias channel='
            echo " Local: $(cat /nix/var/nix/profiles/per-user/root/channels/nixos/.git-revision)";\
            echo "Remote: $(curl --silent -L https://channels.nixos.org/nixos-unstable/git-revision)"
        '

        function _update_ps1() {
            PS1="\n$(${pkgs.powerline-go}/bin/powerline-go \
                        -mode=flat \
                        -colorize-hostname \
                        -cwd-mode=dironly \
                        -modules=user,host,cwd,nix-shell,git,jobs \
                        # -git-assume-unchanged-size 0 \
            )$ "
        }
        PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    '';
}
