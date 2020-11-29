function web
    env MOZ_ENABLE_WAYLAND=1 firefox $argv >/dev/null 2>/dev/null &
end
