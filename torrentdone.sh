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
#TR_TORRENT_DIR="$1"
TR_TORRENT_DIR="$TR_TORRENT_DIR/"
#TR_TORRENT_NAME="$2"
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
		# Это сериал. Просто сохраняем в папку сериалов
		SERIALNAME=$(echo $TR_TORRENT_NAME | grep -Eo '^(.*+).S[0-9].' | sed -r 's/(\.)/_/g' | sed -r 's/(_S[0-9].)//')
		SEASON=$(echo $TR_TORRENT_NAME | grep -Eo 'S[0-9].' | grep -Eo '[0-9].')
		SERIALPATH="/mnt/data/media/serials/$SERIALNAME/$SEASON/"
		# Проверяем есть ли уже такая дирректория
		if ! [ -d $SERIALPATH ]; then
			echo "$PREF Пути $SERIALPATH не существует. Создаем недостающие папки."
			mkdir -m 777 -p $SERIALPATH
		fi

		# Перемещаем файл
		mv -f $FILE $SERIALPATH
		# Проверяем корректно ли переместился файл
		if [ -f "$SERIALPATH$TR_TORRENT_NAME" ]
		then
			echo "$PREF Файл $TR_TORRENT_NAME успешно сохранен в папку $SERIALPATH"
		else
			echo "$PREF Файл $TR_TORRENT_NAME НЕ сохранен в папку $SERIALPATH"
		fi
	else
		# Другой файл. Проверяем не фильм ли это
		if [[ "${TR_TORRENT_NAME}" =~ $regex_film ]]; then
			# Это фильм. Вытаскиваем год"
			YEAR=$(echo $TR_TORRENT_NAME | grep -Eo '\([0-9]+\)' | sed -r 's/(\(|\))//g')
			# В 3D фильм или нет
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

			# Перемещаем файл
			mv -f $FILE $FILMPATH
			# Проверяем корректно ли переместился файл
			if [ -f "$SERIALPATH$TR_TORRENT_NAME" ]
			then
				echo "$PREF Файл $TR_TORRENT_NAME успешно сохранен в папку $FILMPATH"
			else
				echo "$PREF Файл $TR_TORRENT_NAME НЕ сохранен в папку $FILMPATH"
			fi
		else
			# Просто файл. Сохраняем его в общее файловое хранилище
			echo "$PREF Просто файл. Сохраняем его в общее файловое хранилище."
		fi
	fi

else
	# Файла нет
	echo "$PREF Запрашиваемый файл \"$TR_TORRENT_NAME\" не существует по пути \"$TR_TORRENT_DIR\""
	exit 0;
fi
