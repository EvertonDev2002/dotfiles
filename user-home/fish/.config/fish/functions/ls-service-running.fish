echo 'function ls-service-running --description "Lista serviços rodando (Auto-detecta Runit ou Systemd)"
    if command -v sv > /dev/null; and test -d /run/runit/service
        echo "--> Detectado Runit (Artix)"
        sudo sv status /run/runit/service/* | grep "^run:"

    else if command -v systemctl > /dev/null
        echo "--> Detectado Systemd"
        systemctl list-units --type=service --state=running

    else
        echo "Nenhum sistema de init suportado (Runit/Systemd) foi detectado."
    end
end' > ~/.config/fish/functions/ls-service-running.fish
