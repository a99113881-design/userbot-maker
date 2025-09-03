#!/bin/bash

# ========================================
#     🤖 UserBot – ربات‌ساز یک‌فایلی
#    ساخته شده با عشق توسط تو!
#    https://github.com/a99113881-design/userbot-maker
# ========================================

# بررسی ابزارهای لازم
check_tools() {
    command -v python3 >/dev/null 2>&1 || { echo "❌ python3 نصب نیست. نصب کن: sudo apt install python3"; exit 1; }
    command -v pip3 >/dev/null 2>&1 || { echo "❌ pip3 نصب نیست. نصب کن: sudo apt install python3-pip"; exit 1; }
    command -v screen >/dev/null 2>&1 || { echo "⚠️  screen نصب نیست. نصب می‌کنم..."; sudo apt install -y screen; }
}

# نصب کتابخانه پایتون
install_python_deps() {
    pip3 show python-telegram-bot >/dev/null 2>&1 || pip3 install python-telegram-bot --quiet --no-cache-dir
}

# نصب Node.js و telegraf (در صورت نیاز)
install_node_deps() {
    if ! command -v node >/dev/null; then
        echo "⚠️  Node.js نصب نیست. نصب می‌کنم..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >/dev/null 2>&1
        sudo apt install -y nodejs >/dev/null 2>&1
    fi
    if [ ! -d "node_modules" ] || [ ! -f "node_modules/telegraf/package.json" ]; then
        echo "📦 telegraf نصب نیست. نصب می‌کنم..."
        npm init -y >/dev/null 2>&1
        npm install telegraf --save >/dev/null 2>&1
    fi
}

# ساخت ربات بدون کدنویسی (Python)
create_bot_interactive() {
    echo "=== 🛠️ ساخت ربات بدون کدنویسی (Python) ==="
    read -p "نام ربات: " bot_name
    read -p "توکن ربات تلگرام: " bot_token
    read -p "پیام دستور /start: " start_msg
    read -p "پیام پاسخ به متن: " reply_msg

    BOT_FILE="${bot_name}.py"

    cat << EOF > "$BOT_FILE"
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

TOKEN = "$bot_token"

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("$start_msg")

async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("$reply_msg \${update.message.text}")

def main():
    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, echo))
    print("✅ ربات '\$bot_name' در حال اجراست...")
    app.run_polling()

if __name__ == '__main__':
    main()
EOF

    echo "🎉 ربات با موفقیت ساخته شد: $BOT_FILE"
    echo "اجرا کنید با: python3 $BOT_FILE"
}

# اجرای ربات پایتون در پس‌زمینه
run_python_bot() {
    read -p "نام فایل ربات پایتون (مثلاً mybot.py): " py_file
    if [ ! -f "$py_file" ]; then
        echo "❌ فایل \$py_file یافت نشد."
        return
    fi
    session_name="pybot_\$(date +%s)"
    screen -dmS "\$session_name" python3 "\$py_file"
    echo "🟢 ربات در پس‌زمینه اجرا شد (session: \$session_name)"
    echo "مشاهده لاگ: screen -r \$session_name"
}

# ساخت ربات Node.js بدون کدنویسی
create_node_bot() {
    echo "=== 🛠️ ساخت ربات Node.js بدون کدنویسی ==="
    read -p "توکن ربات تلگرام: " bot_token
    read -p "پیام /start: " start_msg
    read -p "پیام پاسخ به متن: " reply_msg

    cat << EOF > "nodebot.js"
const { Telegraf } = require('telegraf');
const bot = new Telegraf('$bot_token');

bot.start((ctx) => ctx.reply('$start_msg'));
bot.on('text', (ctx) => ctx.reply('$reply_msg ' + ctx.message.text));

bot.launch();
console.log('✅ ربات Node.js در حال اجراست...');
EOF

    echo "🎉 ربات Node.js ساخته شد: nodebot.js"
}

# اجرای ربات Node.js
run_node_bot() {
    if [ ! -f "nodebot.js" ]; then
        echo "❌ فایل nodebot.js وجود ندارد. ابتدا ربات Node.js بسازید."
        return
    fi
    session_name="nodebot_\$(date +%s)"
    screen -dmS "\$session_name" node nodebot.js
    echo "🟢 ربات Node.js در پس‌زمینه اجرا شد (session: \$session_name)"
    echo "مشاهده لاگ: screen -r \$session_name"
}

# نمایش لیست ربات‌ها
list_bots() {
    echo "=== 📁 فایل‌های ربات موجود ==="
    ls *.py *.js 2>/dev/null | grep -v "node_modules" || echo "هیچ رباتی یافت نشد."
}

# نمایش منوی اصلی
show_menu() {
    echo
    echo "========== 🤖 ربات‌ساز UserBot =========="
    echo "1) 🛠️ ساخت ربات جدید (بدون کدنویسی - Python)"
    echo "2) ▶️ اجرای ربات Python در پس‌زمینه"
    echo "3) 🛠️ ساخت ربات Node.js (بدون کدنویسی)"
    echo "4) ▶️ اجرای ربات Node.js"
    echo "5) 📁 نمایش همه ربات‌ها"
    echo "6) 🧹 نصب وابستگی‌ها (اولین بار اجرا کنید)"
    echo "7) 🚪 خروج"
    echo "========================================"
}

# اصلی‌ترین بخش اسکریپت
main() {
    check_tools

    while true; do
        show_menu
        read -p "انتخاب کنید (1-7): " choice
        echo

        case \$choice in
            1) create_bot_interactive ;;
            2) run_python_bot ;;
            3) create_node_bot ; install_node_deps ;;
            4) run_node_bot ; install_node_deps ;;
            5) list_bots ;;
            6) install_python_deps && install_node_deps && echo "✅ تمام وابستگی‌ها نصب شدند." ;;
            7) echo "👋 خداحافظ!"; exit 0 ;;
            *) echo "❌ انتخاب نامعتبر. عدد 1 تا 7 وارد کنید." ;;
        esac
        echo
    done
}

# اجرای برنامه
main
