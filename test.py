import logging
import datetime
from telegram.ext import Updater, CommandHandler

# تعریف تابع برای پاسخ به start
def start(update, context):
    # ارسال پیام زمان فعلی به کاربر
    update.message.reply_text('Welcome to the bot!\nCurrent time: ' + str(datetime.datetime.now()))

# تنظیمات و شروع ربات
if __name__ == '__main__':
    # تنظیمات لاگینگ
    logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)

    # ساخت instance از Updater با توکن ربات تلگرام
    updater = Updater(token='5910802300:AAEBnLaHP2Gn3h3hvJ5Z_WVNaI1bm3LntAc', use_context=True)

    # ساخت dispatcher برای ربات
    dispatcher = updater.dispatcher

    # تعریف handler برای پاسخ به start
    start_handler = CommandHandler('start', start)

    # اضافه کردن handler به dispatcher
    dispatcher.add_handler(start_handler)

    # شروع polling برای دریافت پیام‌های کاربران
    updater.start_polling()
