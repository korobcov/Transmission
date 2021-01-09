# Примеры вывода различных команд применяемых в файле torrentclear
Пример команды: `$TR_CONNECT -l`
```
ID     Done       Have  ETA           Up    Down  Ratio  Status       Name
  35   100%   22.11 GB  12 days      0.0     0.0    0.0  Seeding      Шерлок Холмс S01 Serial WEB-DL (1080p)
  37    66%    1.97 GB  1 min       15.0  18007.0    0.0  Up & Down    The.Expanse.S05E01.1080p.rus.LostFilm.TV.mkv
Sum:          24.08 GB              15.0  18007.0
```
Пример команды: `$TR_CONNECT -l | grep -Eo '^ *([0-9]+)' | sed -r 's/[^0-9]//g'`
```
35
37
```
Пример команды: `$TR_CONNECT -t35 -i`  
Тут сериал скачен сразу сезоном (папкой)
```
NAME
  Id: 35
  Name: Шерлок Холмс S01 Serial WEB-DL (1080p)
  Hash: c9b9b562d3e3064a04aabce139e06b8b0321e71e
  Magnet: magnet:?xt=urn:btih:c9b9b562d3e3064a04aabce139e06b8b0321e71e&dn=%D0

TRANSFER
  State: Seeding
  Location: /mnt/data/download
  Percent Done: 100%
  ETA: 8 days (771864 seconds)
  Download Speed: 0 kB/s
  Upload Speed: 49 kB/s
  Have: 22.11 GB (22.11 GB verified)
  Availability: 100%
  Total size: 22.11 GB (22.11 GB wanted)
  Downloaded: 22.13 GB
  Uploaded: 637.5 MB
  Ratio: 0.0
  Corrupt DL: None
  Peers: connected to 1, uploading to 1, downloading from 0

HISTORY
  Date added:       Sat Jan  9 21:59:14 2021
  Date finished:    Sat Jan  9 22:20:08 2021
  Date started:     Sat Jan  9 21:59:24 2021
  Latest activity:  Sun Jan 10 01:42:24 2021
  Downloading Time: 21 minutes (1299 seconds)
  Seeding Time:     3 hours, 22 minutes (12133 seconds)

ORIGINS
  Date created: Fri May 20 14:35:06 2016
  Public torrent: Yes
  Comment: https://rut.ooom/fm/viewtopic.php?t=520008919
  Creator: uTorrent/2210
  Piece Count: 5273
  Piece Size: 4.00 MiB

LIMITS & BANDWIDTH
  Download Limit: Unlimited
  Upload Limit: Unlimited
  Ratio Limit: Default
  Honors Session Limits: Yes
  Peer limit: 50
  Bandwidth Priority: Normal
```
Пример команды: `$TR_CONNECT -t37 -i`  
А тут просто файл сериала
```
NAME
  Id: 37
  Name: The.Expanse.S05E01.1080p.rus.LostFilm.TV.mkv
  Hash: 505ec320ab33e27dd56a531e3a5242947e8e299e
  Magnet: magnet:?xt=urn:btih:505ec320ab33e27dd56a531e3a5242947e8e299e&dn=The

TRANSFER
  State: Seeding
  Location: /mnt/data/media/serials/The_Expanse/Season_05/
  Percent Done: 100%
  ETA: 3 days, 20 hours (332499 seconds)
  Download Speed: 0 kB/s
  Upload Speed: 16 kB/s
  Have: 2.94 GB (2.94 GB verified)
  Availability: 100%
  Total size: 2.94 GB (2.94 GB wanted)
  Downloaded: 3.01 GB
  Uploaded: 7.58 MB
  Ratio: 0.0
  Corrupt DL: None
  Peers: connected to 33, uploading to 1, downloading from 0

HISTORY
  Date added:       Sun Jan 10 01:48:52 2021
  Date finished:    Sun Jan 10 01:51:57 2021
  Date started:     Sun Jan 10 01:48:54 2021
  Latest activity:  Sun Jan 10 01:55:20 2021
  Downloading Time: 3 minutes, 1 second (181 seconds)
  Seeding Time:     3 minutes, 23 seconds (203 seconds)

ORIGINS
  Date created: Sat Dec 19 22:57:37 2020
  Public torrent: Yes
  Creator: uTorrent/3.5.5
  Piece Count: 702
  Piece Size: 4.00 MiB

LIMITS & BANDWIDTH
  Download Limit: Unlimited
  Upload Limit: Unlimited
  Ratio Limit: Default
  Honors Session Limits: Yes
  Peer limit: 50
  Bandwidth Priority: Normal
```