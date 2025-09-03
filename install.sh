#!/bin/bash
# install.sh - نصاب یک‌کلیکی ربات‌ساز

echo "🚀 در حال نصب UserBot..."

# نصب wget اگر نبود
if ! command -v wget &> /dev/null; then
    echo "📦 نصب wget..."
    sudo apt update && sudo apt install -y wget
fi

# دانلود اسکریپت اصلی
wget -O botmaker.sh https://raw.githubusercontent.com/a99113881-design/userbot-maker/main/botmaker.sh

# دادن دسترسی اجرا
chmod +x botmaker.sh

echo "✅ نصب کامل شد!"
echo "اجرا کنید با دستور:"
echo "./botmaker.sh"
