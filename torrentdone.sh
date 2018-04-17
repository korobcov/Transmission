#!/bin/bash

# Скрипт для Transmission Daemon
# Перемещение завершенных торрентов по папкам
#
# Базовые переменные. Они передаются скрипту самим Transmission
# =================================================================================
# $TR_APP_VERSION: версия Transmission
# $TR_TORRENT_ID: идентификатор торрента (число, показывается в remote-GUI)
# $TR_TORRENT_NAME: имя торента в том виде, как оно отображается в интерфейсе
# $TR_TORRENT_DIR: папка торрента
# $TR_TORRENT_HASH: хэш торрента
# $TR_TIME_LOCALTIME: дата и время запуска скрипта
#

# Определяем дополнительные переменные
PREF="transsaver:"
TR_LOGIN="user"
TR_PASSWORD="12345"
TR_TORRENT_DIR="$TR_TORRENT_DIR/"
regex_ser="(LostFilm|TV|serial|Serial|S[0-9].E[0-9].|novafilm)"
regex_film="(Film|BDRip|iTunes|WEBRip|BDRemux|)"
regex_3d="(\s(3D|3d)\s)"

# ВЫПОЛНЕНИЕ

# Проверяем существует ли файл
if [ -f "$TR_TORRENT_DIR$TR_TORRENT_NAME" ]
then
	# Файл на месте
	echo "$PREF Начало обработки торрента - $TR_TORRENT_NAME"

	# Формируем путь к исходному файлу
	FILE="$TR_TORRENT_DIR$TR_TORRENT_NAME"

	# Ищем соответствие сериалу
	if [[ "${TR_TORRENT_NAME}" =~ $regex_ser ]]; then
		# Это сериал
		# Вытаскиваем имя сериала и его сезон
		# Формируем путь сохранения из этих данных
		SERIALNAME=$(echo $TR_TORRENT_NAME | grep -Eo '^(.*+).S[0-9].' | sed -r 's/(\.)/_/g' | sed -r 's/(_S[0-9].)//')
		SEASON=$(echo $TR_TORRENT_NAME | grep -Eo 'S[0-9].' | grep -Eo '[0-9].')
		SERIALPATH="/mnt/data/media/serials/$SERIALNAME/Season_$SEASON/"
		
		# Проверяем есть ли уже такая дирректория
		if ! [ -d $SERIALPATH ]; then
			echo "$PREF Пути $SERIALPATH не существует. Создаем недостающие папки."
			mkdir -m 777 -p $SERIALPATH
		fi

		# Перемещаем файл силами самого Transmission
		# mv -f $FILE $SERIALPATH # Если нет желания использовать Transmission
		transmission-remote 192.168.88.21:9091 -n $TR_LOGIN:$TR_PASSWORD -t $TR_TORRENT_ID --move $SERIALPATH
		
		# Проверяем корректно ли переместился файл
		if [ -f "$SERIALPATH$TR_TORRENT_NAME" ]
		then
			echo "$PREF Файл $TR_TORRENT_NAME успешно сохранен в папку $SERIALPATH"
			exit 0;
		else
			echo "$PREF Файл $TR_TORRENT_NAME НЕ сохранен в папку $SERIALPATH"
			exit 0;
		fi
	else
		# Файл не сериал.
		# Ищем соответствие фильму
		if [[ "${TR_TORRENT_NAME}" =~ $regex_film ]]; then
			# Это фильм
			# Пример названия фильма для сохранения: Дикий Запад (2018).mkv
			# Пример названия 3D фильма для сохранения: Дикий Запад 3D (2018).mkv
			# Вытаскиваем год фильма
			YEAR=$(echo $TR_TORRENT_NAME | grep -Eo '\([0-9]+\)' | sed -r 's/(\(|\))//g')
			
			# Проверяем в 3D фильм или нет
			if [[ "${TR_TORRENT_NAME}" =~ $regex_3d ]]; then
				# Фильм в 3D
				# Меняем путь для сохранения
				FILMPATH="/mnt/data/media/films/3d/$YEAR/"
			else
				# Обычный фильм
				# Задаем базовый путь сохранения фильма
				FILMPATH="/mnt/data/media/films/$YEAR/"
			fi
			
			# Проверяем есть ли уже такая дирректория
			if ! [ -d $FILMPATH ]; then
				# Создаем папки
				echo "$PREF Пути $FILMPATH не существует. Создаем нужные папки."
				mkdir -m 777 -p $FILMPATH
			fi

			# Перемещаем файл силами самого Transmission
			# mv -f $FILE $FILMPATH # Если нет желания использовать Transmission
			transmission-remote 192.168.88.21:9091 -n $TR_LOGIN:$TR_PASSWORD -t $TR_TORRENT_ID --move $FILMPATH
			
			# Проверяем корректно ли переместился файл
			if [ -f "$FILMPATH$TR_TORRENT_NAME" ]
			then
				echo "$PREF Файл $TR_TORRENT_NAME успешно сохранен в папку $FILMPATH"
				exit 0;
			else
				echo "$PREF Файл $TR_TORRENT_NAME НЕ сохранен в папку $FILMPATH"
				exit 0;
			fi
		else
			# Просто какой-то файл.
			# Он не Сериал и не Фильм. Оставляем его лежать в папке Complete
			echo "$PREF Неизвестный файл. Место хранения не изменяется."
			exit 0;
		fi
	fi

else
	# Файла нет
	echo "$PREF Запрашиваемый файл \"$TR_TORRENT_NAME\" не существует по пути \"$TR_TORRENT_DIR\""
	exit 0;
fi
