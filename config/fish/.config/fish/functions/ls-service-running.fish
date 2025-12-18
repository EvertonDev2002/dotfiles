function ls-service-running
    if command -v sv > /dev/null; and test -d /run/runit/service
        sudo sv status /run/runit/service/* | grep "^run:"

    else if command -v systemctl > /dev/null
        systemctl list-units --type=service --state=running

    else
        echo "Nenhum sistema de init suportado (Runit/Systemd) foi detectado."
    end
end
