if command -v "$1" &> /dev/null; then
    echo '{"exists": "true"}'
else
    echo '{"exists": "false"}'
fi
