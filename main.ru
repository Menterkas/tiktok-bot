import telebot
import requests

# ВСТАВЬТЕ ВАШ ТОКЕН ОТ @BotFather МЕЖДУ КАВЫЧКАМИ
BOT_TOKEN = '8333303907:AAE5h7jwq3lvK9MmgSOJWeSjamkqEzlKLSw'

bot = telebot.TeleBot(BOT_TOKEN)

@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    welcome_text = (
        "Привет! Отправь мне ссылку на TikTok, и я скачаю видео без водяного знака. 🎬"
    )
    bot.reply_to(message, welcome_text)

@bot.message_handler(func=lambda message: True)
def handle_message(message):
    url = message.text.strip()

    if "tiktok.com" in url:
        status_message = bot.reply_to(message, "⏳ Обрабатываю ссылку...")

        try:
            # Используем TikWM API
            api_url = f"https://www.tikwm.com/api/?url={url}"
            response = requests.get(api_url).json()

            if response.get('code') == 0:
                data = response['data']
                video_url = data.get('play') # Ссылка на видео без знака
                
                bot.delete_message(message.chat.id, status_message.message_id)
                
                # Отправка видео пользователю
                bot.send_video(
                    message.chat.id, 
                    video_url, 
                    caption="Готово! ✅",
                    reply_to_message_id=message.message_id
                )
            else:
                bot.edit_message_text("❌ Ошибка: Не удалось найти видео по этой ссылке.", 
                                      chat_id=message.chat.id, 
                                      message_id=status_message.message_id)
        except Exception as e:
            bot.edit_message_text(f"❌ Произошла ошибка: {e}", 
                                  chat_id=message.chat.id, 
                                  message_id=status_message.message_id)
    else:
        bot.reply_to(message, "⚠️ Это не похоже на ссылку TikTok.")

if __name__ == '__main__':
    print("Бот запущен!")
    bot.infinity_polling()
