#!/bin/bash

# Torrent Clear Script v0.0.2
# Скрипт для Cron
# Очистка торрентов в Transmission, которые достигли коэффициента = 2
# Расписание запуска по умолчанию: Каждый час
#
# Протестировано на:
# Debian GNU/Linux 9.4 (stretch)
# transmission-daemon 2.92 (14714)
#
# Настройка Cron: 
# 
#

# Определяем переменные
PREF="transremover:"
TR_LOGIN="user"
TR_PASSWORD="12345"
TR_CONNECT=$(transmission-remote 192.168.88.21:9091 -n $TR_LOGIN:$TR_PASSWORD)

# ФУНКЦИИ
#
# Функция отправки оповещения на почту
emailsend(){
	# Задаем парметры для отправки E-Mail письма
	local TMP=$(mktemp)
	local SMTP="smtp.yandex.ru:25"
	local EMAIL_ACCOUNT_PASSWORD="smtp_password"
	local FROM_EMAIL_ADDRESS="no-reply@mydomen.ru"
	local TO_EMAIL_ADDRESS="myname@mydomen.ru"
	
	local EMAIL_THEME="Тема письма"
	local EMAIL_SUBJECT="Текст письма"
	
	# Пишем во временный файл

}

# ВЫПОЛНЕНИЕ

# Проверяем запущен ли transmission-daemon
# Если нет, то сразу завершаем выполнение скрипта
TR_STATUS=$(service transmission-daemon status | grep 'Active' | grep -Eo '\([a-z]+\)' | sed -r 's/(\(|\))//g')
if [[ $TR_STATUS != "running" ]]; then
	echo "$PREF Служба transmission-daemon не запущена! Дальнейшая обработка не производится."
	exit 0;
fi
# Если сервис запущен, работаем дальше

# Выбираем все торренты со 100% выполнением и коэффициентом раздачи = 2
# Обрабатываем их в цикле
for TORRENTID in $($TR_CONNECT -l | grep )
do

done
